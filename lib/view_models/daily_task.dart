import 'package:flutter/material.dart';

import '../models/medication.dart';
import '../models/adherence_log.dart';

class DailyTask {
  final Medication medication;
  final TimeOfDay scheduledTime;
  final AdherenceLog? log; // if null, pending

  DailyTask({required this.medication, required this.scheduledTime, this.log});

  /// scheduled time adjusted by the snooze count (10 minutes per snooze)
  TimeOfDay get adjustedTime {
    if (log == null || log!.snoozeCount == 0) return scheduledTime;
    final totalMinutes =
        scheduledTime.hour * 60 +
        scheduledTime.minute +
        (log!.snoozeCount * 10);
    return TimeOfDay(
      hour: (totalMinutes ~/ 60) % 24,
      minute: totalMinutes % 60,
    );
  }
}

extension DailyTaskStatusExt on DailyTask {
  bool get isPending => log == null;
  bool get isSnoozed => log?.status == LogStatus.snoozed;
  bool get isMissed => log?.status == LogStatus.missed;
  bool get isTaken => log?.status == LogStatus.taken;

  /// pending or snoozed needs user action (shown in "To take")
  bool get needsAction => isPending || isSnoozed;
}
