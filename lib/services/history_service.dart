import 'package:flutter/material.dart';
import '../view_models/history_group.dart';
import '../models/adherence_log.dart';
import '../mock/adherence_log.dart';
import '../mock/medication.dart';
import '../models/enums/medication_enums.dart';

class HistoryService {
  /// fetches adherence logs and joins them with medication details,
  /// then groups them by date to provide UI-ready data.
  static Future<List<HistoryGroup>> getHistoryGroups() async {
    // simulate network/db latency
    await Future.delayed(const Duration(milliseconds: 600));

    // grouping map
    final Map<String, List<HistoryRecord>> groupedRecords = {};

    for (var log in mockAdherenceLogs) {
      // find the medication associated w/ the log
      final medication = mockMedications.firstWhere(
        (med) => med.id == log.medicationId,
        orElse: () => throw Exception('Medication not found for log ${log.id}'),
      );

      // create the record DTO (not dto anymore)
      final dto = HistoryRecord(
        medicationName: medication.name,
        timeTaken: _formatTimeOfDay(log.takenTime),
        scheduledTime: _formatTimeOfDay(log.scheduledTime),
        status: log.status,
        iconType: medication.type,
      );

      // format the date header
      final dateHeader = _formatDateHeader(log.date);

      // add to group
      // if (!groupedRecords.containsKey(dateHeader)) {
      //   groupedRecords[dateHeader] = []; // must initialise with the header(key) bfr assigning value
      // }
      // groupedRecords[dateHeader]!.add(dto);
      groupedRecords.putIfAbsent(dateHeader, () => []).add(dto);
    }

    // append some hardcoded missed data just to make the mock UI look rich and demonstrate filtering
    groupedRecords['Sunday, February 1'] = [
      HistoryRecord(
        medicationName: 'Aspirin',
        timeTaken: '08:00',
        status: LogStatus.missed,
        iconType: MedicationType.pill,
      ),
      HistoryRecord(
        medicationName: 'Vitamin D',
        timeTaken: '12:00',
        status: LogStatus.missed,
        iconType: MedicationType.capsule,
      ),
      HistoryRecord(
        medicationName: 'Amoxicillin Syrup',
        timeTaken: '20:00',
        status: LogStatus.missed,
        iconType: MedicationType.syrup,
      ),
    ];

    // convert map to List of HistoryGroup
    final List<HistoryGroup> historyGroups = groupedRecords.entries.map((
      entry,
    ) {
      return HistoryGroup(dateHeader: entry.key, records: entry.value);
    }).toList();

    return historyGroups;
  }

  static String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '--:--';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _formatDateHeader(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final weekdayStr = weekdays[date.weekday - 1];
    final monthStr = months[date.month - 1];

    return '$weekdayStr, $monthStr ${date.day}';
  }
}
