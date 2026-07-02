import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../view_models/history_group.dart';
import '../models/enums/medication_enums.dart';
import '../models/adherence_log.dart';

import '../services/auth_service.dart';
import '../services/adherence_log_service.dart';
import '../services/medication_service.dart';

class HistoryService {
  /// fetches adherence logs and joins them with medication details,
  /// then groups them by date to provide UI-ready data
  static Future<List<HistoryGroup>> getHistoryGroups() async {
    // simulate network/db latency
    // await Future.delayed(const Duration(milliseconds: 600));
    final uid = AuthService().currentUser!.uid;

    // .first turns the stream into a one-time fetch (the screen uses a Future)
    final logs = await AdherenceLogService().streamAllLogs(uid).first;
    final medications = await MedicationService().streamMedications(uid).first;

    // create a map, with m.id as key, m as obj
    final medById = {for (final m in medications) m.id: m};

    // sort logs newest first
    logs.sort((a, b) {
      final dateCmp = b.date.compareTo(a.date);
      if (dateCmp != 0) return dateCmp;

      // same day -> later scheduled time first
      final aMin = a.scheduledTime.hour * 60 + a.scheduledTime.minute;
      final bMin = b.scheduledTime.hour * 60 + b.scheduledTime.minute;
      return bMin.compareTo(aMin);
    });

    // grouping logs by day
    final Map<String, List<HistoryRecord>> groupedRecords = {};
    for (final log in logs) {
      // skip snoozed logs
      if (log.status == LogStatus.snoozed) continue;

      // find the medication associated w/ the log frm the map
      final med = medById[log.medicationId];

      // skip logs whose medication was deleted (orphans), or show a fallback
      final medName = med?.name ?? 'Deleted medication';
      final iconType = med?.type ?? MedicationType.pill;

      // format the date header
      final dateHeader = _formatDateHeader(log.date);
      // final dateKey = _dateHeader(log.date);

      // create the record
      final record = HistoryRecord(
        medicationName: medName,
        timeTaken: _formatTimeOfDay(log.takenTime),
        scheduledTime: _formatTimeOfDay(log.scheduledTime),
        status: log.status,
        iconType: iconType,
      );

      // add to group
      groupedRecords.putIfAbsent(dateHeader, () => []).add(record);
    }

    // convert the map into the ordered list (History Group) the screen expects
    return groupedRecords.entries
        .map((e) => HistoryGroup(dateHeader: e.key, records: e.value))
        .toList();
  }

  static String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '--:--';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(thatDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }
}
