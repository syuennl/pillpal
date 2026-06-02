import 'package:pillpal/models/reminder.dart';
import 'medication.dart';

final List<Reminder> mockReminders = [
  Reminder(id: '1', medication: mockMedications[0], medicationId: '1', scheduledTime: '08:00'),

  Reminder(id: '2', medication: mockMedications[0], medicationId: '1', scheduledTime: '20:00'),

  Reminder(id: '3', medication: mockMedications[1], medicationId: '2', scheduledTime: '08:00'),
];
