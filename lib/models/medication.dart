import 'package:flutter/material.dart';
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
}
