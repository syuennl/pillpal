import 'package:pillpal/models/adherence_log.dart';

// representation of an adherence log entry for recent history in med details screen
class HistoryEntry {
  final String time;
  final String date;
  final LogStatus status;

  HistoryEntry({
    required this.time,
    required this.date,
    required this.status,
  });
}
