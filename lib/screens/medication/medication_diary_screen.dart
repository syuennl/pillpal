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
import '../../mock/diary_note.dart';

class MedicationDiaryScreen extends StatefulWidget {
  final Medication medication;

  // initial notes fetched/cached, for zero loading time
  final List<DiaryNote>? initialNotes;

  const MedicationDiaryScreen({
    super.key,
    required this.medication,
    this.initialNotes,
  });

  @override
  State<MedicationDiaryScreen> createState() => _MedicationDiaryScreenState();
}

class _MedicationDiaryScreenState extends State<MedicationDiaryScreen> {
  late List<DiaryNote> _notes;
  DiaryNoteType? _filter; // null == "All"

  @override
  void initState() {
    super.initState();

    final centralNotes = mockDiaryNotes
        .where((n) => n.medicationId == widget.medication.id)
        .toList();

    // sort to show latest logs first
    centralNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _notes = widget.initialNotes ?? centralNotes;
  }

  void _addNote(DiaryNoteType type, String content) {
    final newNote = DiaryNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // temporary id for FE, prevent duplicate ids everytime obj created
      medicationId: widget.medication.id,
      type: type,
      content: content,
      createdAt: DateTime.now(),
    );
    setState(() {
      _notes = [newNote, ..._notes];
      mockDiaryNotes.add(newNote);
    });
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
            TextButton(
              onPressed: () {
                final newText = controller.text.trim();
                if (newText.isNotEmpty) {
                  _editNote(note.id, newText);
                }
                Navigator.of(context).pop();
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

  void _editNote(String id, String content) {
    setState(() {
      _notes = _notes.map((n) {
        if (n.id == id) {
          final updated = n.copyWith(content: content);
          // update in central mock database too
          final idx = mockDiaryNotes.indexWhere((item) => item.id == id);
          if (idx != -1) {
            mockDiaryNotes[idx] = updated;
          }
          return updated;
        }
        return n;
      }).toList();
    });
  }

  void _deleteNote(String id) {
    setState(() {
      _notes.removeWhere((n) => n.id == id);
      mockDiaryNotes.removeWhere((n) => n.id == id);
    });
  }

  // count number of notes for each type
  Map<DiaryNoteType, int> get _countByType {
    final map = {
      for (final t in DiaryNoteType.values) t: 0,
    }; // initialise all types to 0
    for (final n in _notes) {
      map[n.type] = (map[n.type] ?? 0) + 1; // increment count for each type
    }
    return map;
  }

  List<DiaryNote> get _filteredNotes => _filter == null
      ? _notes // all notes
      : _notes.where((n) => n.type == _filter).toList(); // filtered notes

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotes;

    return Scaffold(
      backgroundColor: AppColours.backgroundGreen,
      appBar: CustomAppBar(
        title: 'Medication Diary',
        subtitle: widget.medication.name,
        showBackButton: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // add note card
            AddNoteCard(onSubmit: _addNote),
            SizedBox(height: 12),

            // diary tip card
            const DiaryTipCard(),

            // your notes heading
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Your Notes (${_notes.length})',
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
              totalCount: _notes.length,
              countByType: _countByType,
            ),
            const SizedBox(height: 16),

            if (filtered.isEmpty)
              const EmptyState()
            else
              ...filtered.map(
                (n) => NoteCard(
                  note: n,
                  onEdit: () => _showEditNoteDialog(context, n),
                  onDelete: () => _deleteNote(n.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
