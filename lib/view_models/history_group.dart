import '../models/enums/medication_enums.dart';
import '../models/enums/log_status_enum.dart';

class HistoryRecord {
  final String medicationName;
  final String timeTaken;
  final String? scheduledTime;
  final LogStatus status;
  final MedicationType iconType;

  HistoryRecord({
    required this.medicationName,
    required this.timeTaken,
    this.scheduledTime,
    required this.status,
    required this.iconType,
  });
}

class HistoryGroup {
  final String dateHeader;
  final List<HistoryRecord> records;

  HistoryGroup({required this.dateHeader, required this.records});
}
