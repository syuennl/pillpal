import 'medication.dart';

class Reminder {
  final String id;
  final Medication medication;
  final String medicationId;
  final String scheduledTime; // Timeofday

  Reminder({
    required this.id,
    required this.medication,
    required this.medicationId,
    required this.scheduledTime,
  });
}


