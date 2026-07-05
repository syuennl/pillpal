import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums/diary_note_type_enum.dart';
export 'enums/diary_note_type_enum.dart';

class DiaryNote {
  final String id;
  final String medicationId;
  final String userId;
  final DiaryNoteType type;
  final String content;
  final DateTime createdAt;

  const DiaryNote({
    required this.id,
    required this.medicationId,
    required this.userId,
    required this.type,
    required this.content,
    required this.createdAt,
  });

  DiaryNote copyWith({
    // clone the obj during update, keep the original obj immutable
    DiaryNoteType? type, // cloned obj saved in new mem spot, flutter will rebuild
    String? content,
  }) {
    return DiaryNote(
      id: id,
      medicationId: medicationId,
      userId: userId,
      type: type ?? this.type,
      content: content ?? this.content,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicationId': medicationId,
      'userId': userId,
      'type': type.name,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory DiaryNote.fromMap(Map<String, dynamic> map, String docId) {
    return DiaryNote(
      id: docId,
      medicationId: map['medicationId'] as String,
      userId: map['userId'] as String? ?? '',
      type: DiaryNoteType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DiaryNoteType.others,
      ),
      content: map['content'] as String,
      createdAt: (map['createdAt'] as dynamic).toDate(), 
    );
  }
}
