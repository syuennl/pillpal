import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pillpal/models/enums/medication_enums.dart';

class Medication {
  final String id;
  final String userId;
  final String name;
  final MedicationType type; // pill, capsule, syrup, injection, others
  final String? imagePath;

  // how many pills left, wht abt syrups tho, how many ml or how many bottles...
  final int quantity;
  final double dosageAmount; // how much per time
  final String dosageUnit;

  final FrequencyType frequencyType;
  final List<int>? selectedDays; // e.g. [1, 2, 4] for Mon, Tue, Thu
  final int? intervalDays; // e.g. 3 for "Every 3 days"

  final int? strengthValue; // strength of pill per intake (mg, etc.)
  final String? strengthUnit;

  final List<TimeOfDay> scheduledTimes;
  final IntakeInstruction intakeInstruction; // (bfr/aft meal or anytime)
  final DateTime treatmentStartDate;
  final DateTime? treatmentEndDate;
  final DateTime? expiryDate;

  final String? aiSummary;
  final List<String>? sideEffects;

  Medication({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.imagePath,
    required this.quantity,
    required this.dosageAmount,
    required this.dosageUnit,
    required this.frequencyType,
    this.selectedDays,
    this.intervalDays,
    this.strengthValue,
    this.strengthUnit,
    required this.scheduledTimes,
    required this.intakeInstruction,
    required this.treatmentStartDate,
    this.treatmentEndDate,
    this.expiryDate,
    this.aiSummary,
    this.sideEffects,
  });

  String get formattedDosage => '$dosageAmount $dosageUnit';
  String get formattedStrength => strengthValue == null || strengthUnit == null
      ? ''
      : '$strengthValue $strengthUnit';
  int get timesPerDay => scheduledTimes.length;

  String get frequencyDisplay => frequencyType.toDisplayString(
    selectedDays: selectedDays,
    intervalDays: intervalDays,
  );

  Medication copyWith({
    String? id,
    String? userId,
    String? name,
    MedicationType? type,
    String? imagePath,
    int? quantity,
    double? dosageAmount,
    String? dosageUnit,
    FrequencyType? frequencyType,
    List<int>? selectedDays,
    int? intervalDays,
    int? strengthValue,
    String? strengthUnit,
    List<TimeOfDay>? scheduledTimes,
    IntakeInstruction? intakeInstruction,
    DateTime? treatmentStartDate,
    DateTime? treatmentEndDate,
    DateTime? expiryDate,
    String? aiSummary,
    List<String>? sideEffects,
  }) {
    return Medication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      imagePath: imagePath ?? this.imagePath,
      quantity: quantity ?? this.quantity,
      dosageAmount: dosageAmount ?? this.dosageAmount,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      frequencyType: frequencyType ?? this.frequencyType,
      selectedDays: selectedDays ?? this.selectedDays,
      intervalDays: intervalDays ?? this.intervalDays,
      strengthValue: strengthValue ?? this.strengthValue,
      strengthUnit: strengthUnit ?? this.strengthUnit,
      scheduledTimes: scheduledTimes ?? this.scheduledTimes,
      intakeInstruction: intakeInstruction ?? this.intakeInstruction,
      treatmentStartDate: treatmentStartDate ?? this.treatmentStartDate,
      treatmentEndDate: treatmentEndDate ?? this.treatmentEndDate,
      expiryDate: expiryDate ?? this.expiryDate,
      aiSummary: aiSummary ?? this.aiSummary,
      sideEffects: sideEffects ?? this.sideEffects,
    );
  }

  // ------------ Firestore serialisation ------------
  static int _timeToInt(TimeOfDay t) => t.hour * 60 + t.minute; // to minutes
  static TimeOfDay _intToTime(int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

  /// converts into a Firestore-safe map
  /// Note: `id` is NOT included, it's the Firestore document ID,
  /// stored implicitly as the document key, not as a field.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type.name, // enum -> string
      'imagePath': imagePath,

      'quantity': quantity,
      'dosageAmount': dosageAmount,
      'dosageUnit': dosageUnit,
      'frequencyType': frequencyType.name,

      'selectedDays': selectedDays,
      'intervalDays': intervalDays,

      'strengthValue': strengthValue,
      'strengthUnit': strengthUnit,
      'scheduledTimes': scheduledTimes
          .map(_timeToInt)
          .toList(), // List<TimeOfDay> -> List<int>
      'intakeInstruction': intakeInstruction.name,

      'treatmentStartDate': Timestamp.fromDate(
        treatmentStartDate,
      ), // DateTime -> Timestamp
      'treatmentEndDate': treatmentEndDate == null
          ? null
          : Timestamp.fromDate(treatmentEndDate!),
      'expiryDate': expiryDate == null ? null : Timestamp.fromDate(expiryDate!),

      'aiSummary': aiSummary,
      'sideEffects': sideEffects,
    };
  }

  /// rebuilds a Medication from a Firestore map
  /// `documentId` = the Firestore doc ID, which becomes this object's `id`
  factory Medication.fromMap(Map<String, dynamic> map, String documentId) {
    return Medication(
      id: documentId,
      userId: map['userId'] as String,
      name: map['name'] as String,
      type: MedicationType.values.byName(
        // string -> enum
        map['type'] as String,
      ),
      imagePath: map['imagePath'] as String?,

      quantity: map['quantity'] as int,
      dosageAmount: (map['dosageAmount'] as num)
          .toDouble(), // Firestore may store a whole num (e.g., 5) as an int, so read as num then convert to double
      dosageUnit: map['dosageUnit'] as String,
      frequencyType: FrequencyType.values.byName(
        map['frequencyType'] as String,
      ),

      // List<int> -> List<TimeOfDay>
      selectedDays:
          (map['selectedDays']
                  as List<
                    dynamic
                  >?) // dynamic cuz originally list of ints, then bcome list of timeofday
              ?.map((e) => e as int)
              .toList(),
      intervalDays: map['intervalDays'] as int?,

      strengthValue: map['strengthValue'] as int?,
      strengthUnit: map['strengthUnit'] as String?,

      scheduledTimes: (map['scheduledTimes'] as List<dynamic>)
          .map((e) => _intToTime(e as int))
          .toList(),
      intakeInstruction: IntakeInstruction.values.byName(
        map['intakeInstruction'] as String,
      ),

      treatmentStartDate: (map['treatmentStartDate'] as Timestamp)
          .toDate(), // timestamp -? datetime
      treatmentEndDate: (map['treatmentEndDate'] as Timestamp?)?.toDate(),
      expiryDate: (map['expiryDate'] as Timestamp?)?.toDate(),
      aiSummary: map['aiSummary'] as String?,
      sideEffects: (map['sideEffects'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}
