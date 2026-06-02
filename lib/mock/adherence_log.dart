import 'package:flutter/material.dart';
import 'package:pillpal/mock/medication.dart';
// import 'package:pillpal/models/reminder.dart';
import 'package:pillpal/models/adherence_log.dart';
import '../models/enums/log_status_enum.dart';

// final List<Medication> medications = mockMedications;
// final List<Reminder> reminders = mockReminders;

final List<AdherenceLog> mockAdherenceLogs = [
  AdherenceLog(
    id: '1',
    // reminderId: reminders[0].id,
    medicationId: mockMedications[0].id,
    userId: mockMedications[0].userId,
    date: DateTime.now(),
    scheduledTime: mockMedications[0].scheduledTimes[0],
    takenTime: TimeOfDay(hour: 8, minute: 5),
    status: LogStatus.taken,
  ),

  AdherenceLog(
    id: '2',
    // reminderId: reminders[1].id,
    medicationId: mockMedications[1].id,
    userId: mockMedications[1].userId,
    date: DateTime.now(),
    scheduledTime: mockMedications[0].scheduledTimes[1],
    takenTime: TimeOfDay(hour: 8, minute: 0),
    status: LogStatus.taken,
  ),

  AdherenceLog(
    id: '3',
    // reminderId: reminders[2].id,
    medicationId: mockMedications[1].id,
    userId: mockMedications[1].userId,
    date: DateTime.now(),
    scheduledTime: mockMedications[1].scheduledTimes[0],
    takenTime: TimeOfDay(hour: 12, minute: 3),
    status: LogStatus.missed,
  ),
];
