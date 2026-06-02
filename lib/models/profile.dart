import 'package:flutter/material.dart';
import 'enums/gender_enum.dart';
export 'enums/gender_enum.dart';

class Profile {
  final String id;
  final String userId;
  final DateTime birthDate;
  final GenderType gender;
  final String? profileImagePath;

  final String? emergencyContactName;
  final String? emergencyContactPhone;

  final List<String>? medicalConditions;
  final List<String>? allergies;

  final TimeOfDay? quietStartTime;
  final TimeOfDay? quietEndTime;

  Profile({
    required this.id,
    required this.userId,
    required this.birthDate,
    required this.gender,
    this.profileImagePath,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.medicalConditions,
    this.allergies,
    this.quietStartTime,
    this.quietEndTime,
  });
}
