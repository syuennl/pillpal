import 'package:flutter/material.dart';

import '../models/medication.dart';
import '../models/adherence_log.dart';

class DailyTask {
  final Medication medication;
  final TimeOfDay scheduledTime;
  final AdherenceLog? log; // if null, pending

  DailyTask({required this.medication, required this.scheduledTime, this.log});
}

extension DailyTaskStatusExt on DailyTask {
  bool get isPending => log == null;
  bool get isSnoozed => log?.status == LogStatus.snoozed;
  bool get isMissed => log?.status == LogStatus.missed;
  bool get isTaken => log?.status == LogStatus.taken;

  /// pending or snoozed needs user action (shown in "To take")
  bool get needsAction => isPending || isSnoozed;
}
