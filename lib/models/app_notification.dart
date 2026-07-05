import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums/notification_enums.dart';
export 'enums/notification_enums.dart'; // home screen only needs to import appNoti, will get enum oso

class AppNotification {
  final String id;
  final String userId; // who this notification is for
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool read;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.read = false,
  });

  // immutable copy helper, useful for "mark as read", etc.
  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? read,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
    );
  }

  // ---------- Firestore serialisation ----------

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name, // enum -> string
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'read': read,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map, String documentId) {
    return AppNotification(
      id: documentId,
      userId: map['userId'] as String? ?? '',
      
      // string -> enum
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.values.first,
      ),
      
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: map['read'] as bool? ?? false,
    );
  }
}
