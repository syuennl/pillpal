import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ScannedMedication {
  final String? name;
  final String? medicationType;
  final String? imagePath;
  final double? quantity;
  final double? dosageAmount;
  final String? dosageUnit;
  final double? strengthValue;
  final String? strengthUnit;
  final String? frequencyType;
  final List<String>? times;
  final String? intakeInstruction;
  final String? treatmentEndDate;
  final String? expiryDate;

  final String? aiSummary;
  final List<String>? sideEffects;

  final String? rawText; // everything Gemini read, as a fallback

  ScannedMedication({
    this.name,
    this.medicationType,
    this.imagePath,
    this.quantity,
    this.dosageAmount,
    this.dosageUnit,
    this.strengthValue,
    this.strengthUnit,
    this.frequencyType,
    this.times,
    this.intakeInstruction,
    this.treatmentEndDate,
    this.expiryDate,
    this.aiSummary,
    this.sideEffects,
    this.rawText,
  });

  factory ScannedMedication.fromJson(Map<String, dynamic> j) {
    List<String>? strList(dynamic v) =>
        (v as List<dynamic>?)?.map((e) => e.toString()).toList();

    return ScannedMedication(
      name: j['name'] as String?,
      medicationType: j['medicationType'] as String?,
      imagePath: j['imagePath'] as String?,
      quantity: (j['quantity'] as num?)?.toDouble(),
      dosageAmount: (j['dosageAmount'] as num?)?.toDouble(),
      dosageUnit: j['dosageUnit'] as String?,
      strengthValue: (j['strengthValue'] as num?)?.toDouble(),
      strengthUnit: j['strengthUnit'] as String?,
      frequencyType: j['frequencyType'] as String?,
      times: strList(j['times']),
      intakeInstruction: j['intakeInstruction'] as String?,
      treatmentEndDate: j['treatmentEndDate'] as String?,
      expiryDate: j['expiryDate'] as String?,
      aiSummary: j['aiSummary'] as String?,
      sideEffects: strList(j['sideEffects']),
      rawText: j['rawText'] as String?,
    );
  }
}

// thrown when Gemini decides the photos are not a medication package/label
class NotAMedicationException implements Exception {
  final String? reason;
  NotAMedicationException([this.reason]);

  @override
  String toString() =>
      'NotAMedicationException: ${reason ?? "photos are not a medication"}';
}

class OcrService {
  static const _promptText =
      'You are reading a medication package from one or more photos (different '
      'surfaces of the same package). Combine all photos into ONE result. '
      'Return ONLY a JSON object, no markdown:\n'
      '{\n'
      '  "isMedication": true or false. false if the photos are NOT a medication '
      'package, box, blister pack, bottle, or label (e.g. a random object, a person, '
      'a screenshot, food, or an unrelated document),\n'
      '  "notMedicationReason": if isMedication is false, a short plain-language '
      'phrase describing what the photo actually shows (e.g. "a photo of a receipt"). '
      'Otherwise null,\n'
      '  "name": string or null, only the first letter of each word is in capital letters\n'
      '  "medicationType": one of ["pill","capsule","syrup","injection","others"] or null,\n'
      '  "quantity": total count/volume in the pack as a number or null,\n'
      '  "dosageAmount": amount per intake as a number or null,\n'
      '  "dosageUnit": e.g. "tablet","ml", "packs" or null,\n'
      '  "strengthValue": numeric strength e.g. 500 or null,\n'
      '  "strengthUnit": e.g. "mg" or null,\n'
      '  "frequencyType": one of ["daily","specificDays","asNeeded"] or null,\n'
      '  "times": array of "HH:MM" 24h strings. Infer from how many times per day '
      'and meal instructions (e.g. twice daily after food -> ["08:00","12:00"]). '
      'If once daily, use ["09:00"]. If unknown, null,\n'
      '  "intakeInstruction": one of ["beforeFood","afterFood","anytime"] or null,\n'
      '  "treatmentEndDate": "yyyy-MM-dd" or null,\n'
      '  "expiryDate": "yyyy-MM-dd" or null,\n'
      '  "aiSummary": a 1-2 sentence plain-language summary of what this medication '
      'is for, from the packaging photos, your knowledge or null,\n'
      '  "sideEffects": array of side effects — include those printed on the package '
      'AND common ones from your knowledge, combined or null,\n'
      '  "rawText": all text read across all photos, as one string\n'
      '}\n'
      'Rules: If isMedication is false, set every other field (except '
      'notMedicationReason) to null and do not guess. For sideEffects, combine those '
      'printed on the package with common ones from your general knowledge into one '
      'list. Use null for anything not determinable from the photos. Do not fabricate '
      'dosages, strengths, or expiry dates.';

  static Future<ScannedMedication> scanLabel(List<String> imagePaths) async {
    final geminiKey = dotenv.env['GEMINI_API_KEY'];
    final groqKey = dotenv.env['GROQ_API_KEY'];

    if ((geminiKey == null || geminiKey.isEmpty) &&
        (groqKey == null || groqKey.isEmpty)) {
      throw Exception('Missing API keys for both Gemini and Groq');
    }

    try {
      if (geminiKey != null && geminiKey.isNotEmpty) {
        return await _scanWithGemini(geminiKey, imagePaths);
      } else {
        throw Exception('Gemini key is missing or invalid');
      }
    } catch (e) {
      if (e is NotAMedicationException)
        rethrow; // definitive, don't retry on Groq
      if (groqKey != null && groqKey.isNotEmpty) {
        debugPrint('Gemini failed or unavailable, falling back to Groq: $e');
        return await _scanWithGroq(groqKey, imagePaths);
      }
      rethrow;
    }
  }

  static Future<ScannedMedication> _scanWithGemini(
    String apiKey,
    List<String> imagePaths,
  ) async {
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

    final prompt = TextPart(_promptText);
    final parts = <Part>[prompt];

    // multi image handling
    for (final path in imagePaths) {
      final bytes = await File(path).readAsBytes();
      parts.add(DataPart('image/jpeg', bytes));
    }

    // in case gemini is overloaded or unavailable
    const maxAttempts = 4;
    GenerateContentResponse? response;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        response = await model.generateContent([Content.multi(parts)]);
        break;
      } on GenerativeAIException catch (e) {
        final msg = e.message.toLowerCase();
        final transient =
            msg.contains('503') ||
            msg.contains('unavailable') ||
            msg.contains('overloaded') ||
            msg.contains('high demand') ||
            msg.contains('500') ||
            msg.contains('internal');

        // give up on non-transient errors, or after the last attempt
        if (!transient || attempt == maxAttempts) rethrow;
        // wait 0.8s, 1.6s, 3.2s before retrying
        await Future.delayed(
          Duration(milliseconds: 800 * (1 << (attempt - 1))),
        );
      }
    }

    final text = response?.text;
    if (text == null || text.isEmpty) {
      throw Exception('No response from Gemini');
    }

    return _parseJsonResponse(text, imagePaths);
  }

  static Future<ScannedMedication> _scanWithGroq(
    String apiKey,
    List<String> imagePaths,
  ) async {
    final contentList = <Map<String, dynamic>>[
      {'type': 'text', 'text': _promptText},
    ];

    for (final path in imagePaths) {
      final bytes = await File(path).readAsBytes();
      final base64Image = base64Encode(bytes);
      contentList.add({
        'type': 'image_url',
        'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
      });
    }

    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
        'response_format': {'type': 'json_object'},
        'messages': [
          {'role': 'user', 'content': contentList},
        ],
        'temperature': 0.1,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Groq API error: ${response.statusCode} - ${response.body}',
      );
    }

    final jsonResponse = jsonDecode(response.body);
    final text = jsonResponse['choices'][0]['message']['content'] as String;

    return _parseJsonResponse(text, imagePaths);
  }

  // strip any stray markdown fences just in case
  static ScannedMedication _parseJsonResponse(
    String text,
    List<String> imagePaths,
  ) {
    final cleaned = text.replaceAll('```json', '').replaceAll('```', '').trim();
    final json = jsonDecode(cleaned) as Map<String, dynamic>;

    // photos x medication
    if (json['isMedication'] == false) {
      throw NotAMedicationException(json['notMedicationReason'] as String?);
    }

    json['imagePath'] = imagePaths.isNotEmpty ? imagePaths.first : null;
    return ScannedMedication.fromJson(json);
  }
}
