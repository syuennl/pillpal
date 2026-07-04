import 'package:pillpal/models/diary_note.dart';
import 'medication.dart';

final DateTime _now = DateTime.now();

final List<DiaryNote> mockDiaryNotes = [
  DiaryNote(
    id: '1',
    userId: '1',
    medicationId: mockMedications[0].id, // Lisinopril
    type: DiaryNoteType.sideEffect,
    content: 'Experienced mild dizziness after taking the morning dose.',
    createdAt: _now.subtract(const Duration(days: 2)),
  ),
  DiaryNote(
    id: '2',
    userId: '1',
    medicationId: mockMedications[0].id, // Lisinopril
    type: DiaryNoteType.sideEffect,
    content: 'Dry cough started a few days after beginning treatment.',
    createdAt: _now.subtract(const Duration(days: 5)),
  ),
  DiaryNote(
    id: '3',
    userId: '1',
    medicationId: mockMedications[1].id, // Metformin
    type: DiaryNoteType.symptom,
    content: 'Feeling slightly nauseous after taking with empty stomach.',
    createdAt: _now.subtract(const Duration(days: 1)),
  ),
  DiaryNote(
    id: '4',
    userId: '1',
    medicationId: mockMedications[2].id, // Amoxicillin Suspension
    type: DiaryNoteType.sideEffect,
    content: 'Mild diarrhea noticed on day 3 of treatment.',
    createdAt: _now.subtract(const Duration(hours: 12)),
  ),
  DiaryNote(
    id: '5',
    userId: '1',
    medicationId: mockMedications[4].id, // Insulin Glargine
    type: DiaryNoteType.symptom,
    content: 'Blood sugar dropped slightly below normal after evening dose.',
    createdAt: _now.subtract(const Duration(days: 3)),
  ),
  DiaryNote(
    id: '6',
    userId: '1',
    medicationId: mockMedications[5].id, // Nicotine Patch
    type: DiaryNoteType.others,
    content:
        'Patch application site shows mild skin irritation. Will rotate to different area.',
    createdAt: _now.subtract(const Duration(hours: 6)),
  ),
  DiaryNote(
    id: '7',
    userId: '1',
    medicationId: mockMedications[3].id, // Cough Syrup
    type: DiaryNoteType.others,
    content: 'Took extra dose as cough was severe. Will monitor.',
    createdAt: _now.subtract(const Duration(days: 1)),
  ),
];
