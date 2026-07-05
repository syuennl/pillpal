import 'package:flutter/material.dart';
import '../../models/diary_note.dart';
import '../../models/medication.dart';
import '../../utils/app_colours.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/medication_diary/add_note_card.dart';
import '../../widgets/medication_diary/diary_tip_card.dart';
import '../../widgets/medication_diary/note_card.dart';
import '../../widgets/medication_diary/note_filter_chips.dart';
import '../../widgets/medication_diary/empty_state.dart';
import '../../services/diary_note_service.dart';

class MedicationDiaryScreen extends StatefulWidget {
  final Medication medication;

  const MedicationDiaryScreen({super.key, required this.medication});

  @override
  State<MedicationDiaryScreen> createState() => _MedicationDiaryScreenState();
}

class _MedicationDiaryScreenState extends State<MedicationDiaryScreen> {
  final _diaryNoteService = DiaryNoteService();
  DiaryNoteType? _filter; // null == "All"

  Future<void> _addNote(DiaryNoteType type, String content) async {
    final newNote = DiaryNote(
      id: '', // Firestore will generate this
      medicationId: widget.medication.id,
      userId: widget.medication.userId,
      type: type,
      content: content,
      createdAt: DateTime.now(),
    );
    try {
      await _diaryNoteService.addNote(newNote);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding note: $e')));
      }
    }
  }

  Future<void> _deleteNote(String id) async {
    try {
      await _diaryNoteService.deleteNote(id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting note: $e')));
      }
    }
  }

  void _showEditNoteDialog(BuildContext context, DiaryNote note) {
    final controller = TextEditingController(text: note.content);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          // title
          title: const Text(
            'Edit Note',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          // text box
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColours.textboxGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),

          // buttons
          actions: [
            // cancel
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // save
            TextButton(
              onPressed: () async {
                final newText = controller.text.trim();
                if (newText.isNotEmpty) {
                  final updatedNote = note.copyWith(content: newText);
                  Navigator.of(context).pop();
                  try {
                    await _diaryNoteService.updateNote(updatedNote);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating note: $e')),
                      );
                    }
                  }
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: AppColours.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // count number of notes for each type
  Map<DiaryNoteType, int> _getCountByType(List<DiaryNote> notes) {
    final map = {
      for (final t in DiaryNoteType.values) t: 0, // initialise all types to 0
    };
    for (final n in notes) {
      map[n.type] = (map[n.type] ?? 0) + 1; // increment count for each type
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.backgroundGreen,
      appBar: CustomAppBar(
        title: 'Medication Diary',
        subtitle: widget.medication.name,
        showBackButton: true,
      ),
      body: StreamBuilder<List<DiaryNote>>(
        stream: _diaryNoteService.streamNotesForMedication(
          widget.medication.userId,
          widget.medication.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Error loading diary notes: ${snapshot.error}');
            return Center(
              child: Text(
                'Failed to load notes.\nCheck console for details.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allNotes = snapshot.data!;
          final countByType = _getCountByType(allNotes);

          final filteredNotes = _filter == null
              ? allNotes
              : allNotes.where((n) => n.type == _filter).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // add note card
                AddNoteCard(onSubmit: _addNote),
                const SizedBox(height: 12),

                // diary tip card
                const DiaryTipCard(),

                // your notes heading
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Your Notes (${allNotes.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // note filter chips
                NoteFilterChips(
                  selectedType: _filter,
                  onChanged: (t) => setState(() => _filter = t),
                  totalCount: allNotes.length,
                  countByType: countByType,
                ),
                const SizedBox(height: 16),

                if (filteredNotes.isEmpty)
                  const EmptyState()
                else
                  ...filteredNotes.map(
                    (n) => NoteCard(
                      note: n,
                      onEdit: () => _showEditNoteDialog(context, n),
                      onDelete: () => _deleteNote(n.id),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
