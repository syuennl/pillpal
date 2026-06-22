import 'package:flutter/material.dart';
import 'package:pillpal/mock/medication.dart';
import 'package:pillpal/models/adherence_log.dart';
import '../models/enums/log_status_enum.dart';

final List<AdherenceLog> mockAdherenceLogs = [
  // John Doe
  AdherenceLog(
    id: '1',
    medicationId: mockMedications[0].id,
    userId: mockMedications[0].userId,
    date: DateTime.now(),
    scheduledTime: mockMedications[0].scheduledTimes[0],
    takenTime: TimeOfDay(hour: 8, minute: 5),
    status: LogStatus.taken,
  ),

  AdherenceLog(
    id: '2',
    medicationId: mockMedications[1].id,
    userId: mockMedications[1].userId,
    date: DateTime.now(),
    scheduledTime: mockMedications[0].scheduledTimes[1],
    takenTime: TimeOfDay(hour: 8, minute: 0),
    status: LogStatus.taken,
  ),

  AdherenceLog(
    id: '3',
    medicationId: mockMedications[1].id,
    userId: mockMedications[1].userId,
    date: DateTime.now(),
    scheduledTime: mockMedications[1].scheduledTimes[0],
    takenTime: TimeOfDay(hour: 12, minute: 3),
    status: LogStatus.missed,
  ),

  // Robert Johnson
  AdherenceLog(
    id: '4',
    medicationId: mockMedications[6].id, // Lisinopril
    userId: mockMedications[6].userId,
    date: DateTime.now(),
    scheduledTime: const TimeOfDay(hour: 8, minute: 0),
    status: LogStatus.snoozed,
    snoozeCount: 3,
  ),

  AdherenceLog(
    id: '5',
    medicationId: mockMedications[7].id, // Metformin
    userId: mockMedications[7].userId,
    date: DateTime.now(),
    scheduledTime: const TimeOfDay(hour: 8, minute: 0),
    status: LogStatus.snoozed,
    snoozeCount: 2,
  ),

  // Jane Doe
  AdherenceLog(
    id: '6',
    medicationId: mockMedications[15].id, // Lisinopril
    userId: mockMedications[15].userId,
    date: DateTime.now(),
    scheduledTime: const TimeOfDay(hour: 8, minute: 0),
    status: LogStatus.snoozed,
    snoozeCount: 2,
  ),
];
