import '../models/app_notification.dart';

// using DateTime.now() offsets so "x hours/days ago" stays accurate over time
final DateTime _now = DateTime.now();

final List<AppNotification> mockNotifications = [
  AppNotification(
    id: '1',
    userId: '1',
    type: NotificationType.reminder,
    title: 'Medication Reminder',
    message: 'Time to take Metformin (500 mg)',
    timestamp: _now.subtract(const Duration(hours: 2)),
    read: false,
  ),
  AppNotification(
    id: '2',
    userId: '1',
    type: NotificationType.alert,
    title: 'Low Inventory Alert',
    message: 'Aspirin is running low (5 tablets remaining)',
    timestamp: _now.subtract(const Duration(hours: 5)),
    read: false,
  ),
  AppNotification(
    id: '3',
    userId: '1',
    type: NotificationType.alert,
    title: 'Expiry Warning',
    message: 'Amoxicillin Syrup expires in 7 days',
    timestamp: _now.subtract(const Duration(days: 1)),
    read: true,
  ),
  AppNotification(
    id: '4',
    userId: '1',
    type: NotificationType.message,
    title: 'Message from Caregiver',
    message: 'Dr. Smith: Please take your evening medication with food',
    timestamp: _now.subtract(const Duration(days: 1)),
    read: true,
  ),
  AppNotification(
    id: '5',
    userId: '1',
    type: NotificationType.announcement,
    title: 'New Feature Available',
    message: 'You can now track symptoms after taking medications',
    timestamp: _now.subtract(const Duration(days: 2)),
    read: true,
  ),
  AppNotification(
    id: '6',
    userId: '1',
    type: NotificationType.reminder,
    title: 'Missed Medication',
    message: 'You missed your 8:00 AM dose of Lisinopril',
    timestamp: _now.subtract(const Duration(days: 3)),
    read: true,
  ),
];
