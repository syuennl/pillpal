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

  Profile copyWith({
    String? id,
    String? userId,
    DateTime? birthDate,
    GenderType? gender,
    String? profileImagePath,
    bool clearProfileImage = false,
    String? emergencyContactName,
    String? emergencyContactPhone,
    List<String>? medicalConditions,
    List<String>? allergies,
    TimeOfDay? quietStartTime,
    TimeOfDay? quietEndTime,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      profileImagePath: clearProfileImage
          ? null
          : (profileImagePath ?? this.profileImagePath),
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      quietStartTime: quietStartTime ?? this.quietStartTime,
      quietEndTime: quietEndTime ?? this.quietEndTime,
    );
  }
}
