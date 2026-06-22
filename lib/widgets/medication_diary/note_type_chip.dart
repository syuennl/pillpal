import 'package:flutter/material.dart';
import '../../models/diary_note.dart';

class NoteTypeChip extends StatelessWidget {
  final DiaryNoteType type;

  const NoteTypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: type.backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),

      child: Text(
        type.displayName,
        style: TextStyle(
          color: type.foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
