class OverallPatientAdherenceStats {
  // Today's Data
  final int takenToday;
  final int missedToday;

  // Overview Data (Past 30 days)
  final int totalTaken;
  final int totalMissed;
  final int totalSnoozed;
  final double adherencePercentage;

  OverallPatientAdherenceStats({
    required this.takenToday,
    required this.missedToday,
    required this.totalTaken,
    required this.totalMissed,
    required this.totalSnoozed,
    required this.adherencePercentage,
  });
}
