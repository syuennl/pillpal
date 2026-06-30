import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // --- TimeOfDay <-> int helpers  ---
  static int? _timeToInt(TimeOfDay? t) =>
      t == null ? null : t.hour * 60 + t.minute;

  static TimeOfDay? _intToTime(int? m) =>
      m == null ? null : TimeOfDay(hour: m ~/ 60, minute: m % 60);

  // ---------- serialisation ----------
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'birthDate': Timestamp.fromDate(birthDate),
      'gender': gender.name,
      'profileImagePath': profileImagePath,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'medicalConditions': medicalConditions,
      'allergies': allergies,
      'quietStartTime': _timeToInt(quietStartTime),
      'quietEndTime': _timeToInt(quietEndTime),
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map, String documentId) {
    List<String>? strList(dynamic v) =>
        (v as List<dynamic>?)?.map((e) => e.toString()).toList();

    return Profile(
      id: documentId, // doc.id = user uid
      userId: map['userId'] as String,
      birthDate: (map['birthDate'] as Timestamp).toDate(),
      gender: GenderType.values.firstWhere(
        (e) => e.name == map['gender'],
        orElse: () => GenderType.preferNotToSay,
      ),
      profileImagePath: map['profileImagePath'] as String?,
      emergencyContactName: map['emergencyContactName'] as String?,
      emergencyContactPhone: map['emergencyContactPhone'] as String?,
      medicalConditions: strList(map['medicalConditions']),
      allergies: strList(map['allergies']),
      quietStartTime: _intToTime(map['quietStartTime'] as int?),
      quietEndTime: _intToTime(map['quietEndTime'] as int?),
    );
  }
}
