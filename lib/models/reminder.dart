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

  // When you connect Firebase later, you just call reminder.toFirestore()
  // Map<String, dynamic> toFirestore() {
  //   return {
  //     'id': id,
  //     'medicationId': medicationId,
  //     'scheduledTime': scheduledTime,
  //     // 2. Look closely: We DO NOT include the 'medication' object here!
  //     // Firebase will never even know the Medication object existed in memory.
  //   };
  // }
}


