import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/diary_note.dart';
import '../medication/medication_card.dart';
import 'note_type_chip.dart';

class NoteCard extends StatelessWidget {
  final DiaryNote note;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const NoteCard({super.key, required this.note, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return MedicationCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NoteTypeChip(type: note.type),

              // action buttons
              Row(
                children: [
                  _IconAction(icon: Icons.edit_outlined, onPressed: onEdit),
                  const SizedBox(width: 4),

                  _IconAction(icon: Icons.delete_outline, onPressed: onDelete),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // content
          Text(
            note.content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // date
          Text(
            DateFormat('MMM d, yyyy').format(note.createdAt),
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _IconAction({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: Colors.grey[500]),
      ),
    );
  }
}
