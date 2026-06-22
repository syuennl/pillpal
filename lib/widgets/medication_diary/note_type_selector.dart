import 'package:flutter/material.dart';
import '../../models/diary_note.dart';

class NoteTypeSelector extends StatelessWidget {
  final DiaryNoteType selectedType;
  final ValueChanged<DiaryNoteType> onChanged;

  const NoteTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final type in DiaryNoteType.values) ...[
          Expanded(child: _buildButton(type)),
          if (type != DiaryNoteType.values.last) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _buildButton(DiaryNoteType type) {
    final selected = selectedType == type;
    return GestureDetector(
      onTap: () => onChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? type.backgroundColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),

        child: Text(
          type.displayName,
          style: TextStyle(
            color: selected ? type.foregroundColor : Colors.grey[700],
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
