import '../models/message_of_the_day.dart';
import 'user_profile.dart';

final List<MessageOfTheDay> mockMessagesOfTheDay = [
  MessageOfTheDay(
    id: '1',
    patientId: mockUsers[0].id, // John Doe
    caregiverId: mockUsers[2].id, // Sarah Johnson (his primary caregiver)
    message: "You're doing great — keep up the good work!",
    timestamp: DateTime.now().subtract(const Duration(hours: 2)), // 2 hours ago
  ),
  MessageOfTheDay(
    id: '2',
    patientId: mockUsers[4].id, // Robert Johnson
    caregiverId: mockUsers[0].id, // John Doe (his primary caregiver)
    message: 'Keep up the great work! Your health journey matters. 💚',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  MessageOfTheDay(
    id: '3',
    patientId: mockUsers[5].id, // Laura Smith
    caregiverId: mockUsers[0].id, // John Doe (his primary caregiver)
    message: 'Keep up the great work! Your health journey matters. 💚',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
  ),
];
