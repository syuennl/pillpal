import 'package:flutter/material.dart';
import '../../models/diary_note.dart';
import '../../utils/app_colours.dart';

class NoteFilterChips extends StatelessWidget {
  final DiaryNoteType? selectedType;
  final ValueChanged<DiaryNoteType?> onChanged;
  final int totalCount;
  final Map<DiaryNoteType, int> countByType;

  const NoteFilterChips({
    super.key,
    required this.selectedType,
    required this.onChanged,
    required this.totalCount,
    required this.countByType,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // all
          _Chip(
            label: 'All ($totalCount)',
            selected: selectedType == null, // null for All notes
            selectedBg: AppColours.primaryGreen,
            selectedFg: Colors.white,
            onTap: () => onChanged(null),
          ),

          // types
          for (final type in DiaryNoteType.values) ...[
            const SizedBox(width: 8),
            _Chip(
              label: '${type.displayName} (${countByType[type] ?? 0})',
              selected: selectedType == type,
              selectedBg: type.backgroundColor,
              selectedFg: type.foregroundColor,
              onTap: () => onChanged(type),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedBg;
  final Color selectedFg;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.selectedBg,
    required this.selectedFg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? selectedBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: selected ? null : Border.all(color: Colors.grey[200]!),
        ),

        child: Text(
          label,
          style: TextStyle(
            color: selected ? selectedFg : Colors.grey[600],
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
