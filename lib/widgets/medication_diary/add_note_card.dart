import 'package:flutter/material.dart';
import '../../models/diary_note.dart';
import '../../utils/app_colours.dart';
import '../medication/medication_card.dart';
import 'note_type_selector.dart';

class AddNoteCard extends StatefulWidget {
  final void Function(DiaryNoteType type, String content) onSubmit;

  const AddNoteCard({super.key, required this.onSubmit});

  @override
  State<AddNoteCard> createState() => _AddNoteCardState();
}

class _AddNoteCardState extends State<AddNoteCard> {
  final _controller = TextEditingController();
  DiaryNoteType _selectedType = DiaryNoteType.sideEffect;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(_selectedType, text);
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _controller.text.trim().isNotEmpty;

    return MedicationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.description_outlined,
                color: AppColours.primaryGreen,
                size: 20,
              ),
              SizedBox(width: 8),

              Text(
                'Add New Note',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const _Label('Note Type'),
          const SizedBox(height: 8),

          NoteTypeSelector(
            selectedType: _selectedType,
            onChanged: (t) => setState(() => _selectedType = t),
          ),
          const SizedBox(height: 20),

          const _Label('Description'),
          const SizedBox(height: 8),

          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            maxLines: 4, //?
            decoration: InputDecoration(
              hintText:
                  'Describe what you experienced or want to ask your doctor...',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
              filled: true,
              fillColor: AppColours.textboxGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 20),

          // add note button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: enabled ? _handleSubmit : null,
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: const Text(
                'Add Note',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColours.primaryGreen,
                disabledBackgroundColor: AppColours.primaryGreen.withOpacity(
                  0.5,
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}
