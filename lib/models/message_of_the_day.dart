class MessageOfTheDay {
  final String id;
  final String patientId;
  final String caregiverId;
  final String message;
  final DateTime timestamp;

  MessageOfTheDay({
    required this.id,
    required this.patientId,
    required this.caregiverId,
    required this.message,
    required this.timestamp,
  });

  MessageOfTheDay copyWith({
    String? id,
    String? patientId,
    String? caregiverId,
    String? message,
    DateTime? timestamp,
  }) {
    return MessageOfTheDay(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      caregiverId: caregiverId ?? this.caregiverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'caregiverId': caregiverId,
      'message': message,
      'timestamp': timestamp,
    };
  }

  factory MessageOfTheDay.fromMap(Map<String, dynamic> map, String documentId) {
    return MessageOfTheDay(
      id: documentId,
      patientId: map['patientId'] ?? '',
      caregiverId: map['caregiverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as dynamic).toDate()
          : DateTime.now(),
    );
  }
}
