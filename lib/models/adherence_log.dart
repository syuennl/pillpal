import 'package:flutter/material.dart';
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
}
