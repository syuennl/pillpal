import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/adherence_log.dart';
import '../view_models/overall_patient_adherence_stats.dart';

/// Each dose (a medication at a specific scheduled time on a specific day)
/// gets ONE log, identified by a deterministic ID: "{medId}_{yyyymmdd}_{minutes}"
/// tapping "taken" then "snoozed" on the same dose updates the same doc instead of creating duplicates
class AdherenceLogService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _logs =>
      _db.collection('adherenceLogs');

  // ---------------- helpers ----------------

  // strips the time off a DateTime so all of "today's" logs share one date
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Builds the deterministic document ID for one dose.
  String _logId(String medicationId, DateTime date, TimeOfDay scheduledTime) {
    final d = _dateOnly(date);
    final dateStr =
        '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
    final minutes = scheduledTime.hour * 60 + scheduledTime.minute;
    return '${medicationId}_${dateStr}_$minutes';
  }

  // ---------------- writes ----------------
  // taken
  Future<void> logTaken({
    required String medicationId,
    required String userId,
    required TimeOfDay scheduledTime,
    DateTime? date,
    TimeOfDay? takenTime,
  }) async {
    final logDate = _dateOnly(date ?? DateTime.now());
    final id = _logId(medicationId, logDate, scheduledTime);

    final log = AdherenceLog(
      id: id,
      medicationId: medicationId,
      userId: userId,
      date: logDate,
      scheduledTime: scheduledTime,
      takenTime: takenTime ?? TimeOfDay.now(),
      status: LogStatus.taken,
      snoozeCount: 0,
    );

    await _logs.doc(id).set(log.toMap());
  }

  // missed/skipped
  Future<void> logMissed({
    required String medicationId,
    required String userId,
    required TimeOfDay scheduledTime,
    DateTime? date,
  }) async {
    final logDate = _dateOnly(date ?? DateTime.now());
    final id = _logId(medicationId, logDate, scheduledTime);

    final log = AdherenceLog(
      id: id,
      medicationId: medicationId,
      userId: userId,
      date: logDate,
      scheduledTime: scheduledTime,
      takenTime: null,
      status: LogStatus.missed,
      snoozeCount: 0,
    );

    await _logs.doc(id).set(log.toMap()); // overwrite data, else create new log
  }

  // snooze
  Future<void> logSnoozed({
    required String medicationId,
    required String userId,
    required TimeOfDay scheduledTime,
    DateTime? date,
  }) async {
    final logDate = _dateOnly(date ?? DateTime.now());
    final id = _logId(medicationId, logDate, scheduledTime);

    final existing = await _logs.doc(id).get();
    final currentCount = existing.exists
        ? (existing.data()?['snoozeCount'] as int? ?? 0)
        : 0;

    final log = AdherenceLog(
      id: id,
      medicationId: medicationId,
      userId: userId,
      date: logDate,
      scheduledTime: scheduledTime,
      takenTime: null,
      status: LogStatus.snoozed,
      snoozeCount: currentCount + 1,
    );

    await _logs.doc(id).set(log.toMap());
  }

  // ---------------- reads ----------------

  // live stream of all logs for a given day
  Stream<List<AdherenceLog>> streamLogsForDate(String userId, DateTime date) {
    final day = _dateOnly(date);
    return _logs
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: Timestamp.fromDate(day))
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => AdherenceLog.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // live stream of all logs for one medication
  Stream<List<AdherenceLog>> streamLogsForMedication(String medicationId) {
    return _logs
        .where('medicationId', isEqualTo: medicationId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => AdherenceLog.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // live stream of every log for a user
  Stream<List<AdherenceLog>> streamAllLogs(String userId) {
    return _logs
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => AdherenceLog.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // ---------------- overall adherence stats ----------------
  Future<OverallPatientAdherenceStats> getPatientStats(String patientId) async {
    // one-time fetch of this patient's logs
    final logs = await streamAllLogs(patientId).first;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cutoff = today.subtract(const Duration(days: 30));

    int takenToday = 0;
    int missedToday = 0;
    int totalTaken = 0;
    int totalMissed = 0;
    int totalSnoozed = 0;

    for (final log in logs) {
      // get the date of the log
      final logDay = DateTime(log.date.year, log.date.month, log.date.day);

      // today's counts
      if (logDay == today) {
        if (log.status == LogStatus.taken) takenToday++;
        if (log.status == LogStatus.missed) missedToday++;
      }

      // last-30-days totals
      if (!logDay.isBefore(cutoff)) {
        switch (log.status) {
          case LogStatus.taken:
            totalTaken++;
            break;
          case LogStatus.missed:
            totalMissed++;
            break;
          case LogStatus.snoozed:
            totalSnoozed++;
            break;
        }
      }
    }

    // adherence % = taken / (taken + missed) over the 30-day window.
    final considered = totalTaken + totalMissed;
    final adherence = considered == 0 ? 100.0 : (totalTaken / considered) * 100;

    return OverallPatientAdherenceStats(
      takenToday: takenToday,
      missedToday: missedToday,
      totalTaken: totalTaken,
      totalMissed: totalMissed,
      totalSnoozed: totalSnoozed,
      adherencePercentage: adherence,
    );
  }
}
