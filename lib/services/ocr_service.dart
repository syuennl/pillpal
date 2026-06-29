import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ScannedMedication {
  final String? name;
  final String? medicationType;
  final String? imagePath;
  final int? quantity;
  final double? dosageAmount;
  final String? dosageUnit;
  final int? strengthValue;
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
      quantity: (j['quantity'] as num?)?.toInt(),
      dosageAmount: (j['dosageAmount'] as num?)?.toDouble(),
      dosageUnit: j['dosageUnit'] as String?,
      strengthValue: (j['strengthValue'] as num?)?.toInt(),
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

class OcrService {
  // sends the medication packaging photos to Gemini and returns structured fields
  static Future<ScannedMedication> scanLabel(List<String> imagePaths) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Missing GEMINI_API_KEY');
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash', // current model
      apiKey: apiKey,
      // ask the model to always return JSON
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

    final prompt = TextPart(
      'You are reading a medication package from one or more photos (different '
      'surfaces of the same package). Combine all photos into ONE result. '
      'Return ONLY a JSON object, no markdown:\n'
      '{\n'
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
      'Rules: For sideEffects, combine those printed on the package with common ones '
      'from your general knowledge into one list. Use null for anything not '
      'determinable from the photos. Do not fabricate dosages, strengths, or expiry dates.',
    );

    // multi img handling
    final parts = <Part>[prompt];
    for (final path in imagePaths) {
      final bytes = await File(path).readAsBytes();
      parts.add(DataPart('image/jpeg', bytes));
    }

    final response = await model.generateContent([Content.multi(parts)]);

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('No response from Gemini');
    }

    // strip any stray markdown fences just in case
    final cleaned = text.replaceAll('```json', '').replaceAll('```', '').trim();
    final json = jsonDecode(cleaned) as Map<String, dynamic>;
    json['imagePath'] = imagePaths.isNotEmpty ? imagePaths.first : null;
    return ScannedMedication.fromJson(json);
  }
}
