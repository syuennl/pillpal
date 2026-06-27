import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums/log_status_enum.dart';
export 'enums/log_status_enum.dart';

class AdherenceLog {
  final String id;
  final String medicationId;
  final String userId;
  final DateTime date;
  final TimeOfDay scheduledTime;
  final TimeOfDay? takenTime;
  final LogStatus status; // taken, missed, snoozed
  final int snoozeCount;

  AdherenceLog({
    required this.id,
    required this.medicationId,
    required this.userId,
    required this.date,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
    this.snoozeCount = 0,
  });

  AdherenceLog copyWith({
    String? id,
    String? medicationId,
    String? userId,
    DateTime? date,
    TimeOfDay? scheduledTime,
    TimeOfDay? takenTime,
    LogStatus? status,
    int? snoozeCount,
  }) {
    return AdherenceLog(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: status == LogStatus.taken
          ? (takenTime ?? this.takenTime)
          : null, // reset takenTime if not taken
      status: status ?? this.status,
      snoozeCount: snoozeCount ?? this.snoozeCount,
    );
  }

  // ------------ Firestore serialisation ------------
  static int _timeToInt(TimeOfDay t) => t.hour * 60 + t.minute;
  static TimeOfDay _intToTime(int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

  Map<String, dynamic> toMap() {
    return {
      'medicationId': medicationId,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'scheduledTime': _timeToInt(scheduledTime),
      'takenTime': takenTime == null ? null : _timeToInt(takenTime!),
      'status': status.name,
      'snoozeCount': snoozeCount,
    };
  }

  factory AdherenceLog.fromMap(Map<String, dynamic> map, String documentId) {
    return AdherenceLog(
      id: documentId,
      medicationId: map['medicationId'] as String,
      userId: map['userId'] as String,
      date: (map['date'] as Timestamp).toDate(),
      scheduledTime: _intToTime(map['scheduledTime'] as int),
      takenTime: map['takenTime'] == null ? null : _intToTime(map['takenTime'] as int),
      status: LogStatus.values.byName(map['status'] as String),
      snoozeCount: map['snoozeCount'] as int,
    );
  }
}
