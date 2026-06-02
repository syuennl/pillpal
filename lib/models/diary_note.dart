import 'enums/diary_note_type_enum.dart';
export 'enums/diary_note_type_enum.dart';

class DiaryNote {
  final String id;
  final String medicationId;
  final DiaryNoteType type;
  final String content;
  final DateTime createdAt;

  const DiaryNote({
    required this.id,
    required this.medicationId,
    required this.type,
    required this.content,
    required this.createdAt,
  });

  DiaryNote copyWith({
    // clone the obj during update, keep the original obj immutable
    DiaryNoteType?
    type, // cloned obj saved in new mem spot, flutter will rebuild
    String? content,
  }) {
    return DiaryNote(
      id: id,
      medicationId: medicationId,
      type: type ?? this.type,
      content: content ?? this.content,
      createdAt: createdAt,
    );
  }
}
