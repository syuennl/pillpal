import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diary_note.dart';

class DiaryNoteService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notes =>
      _db.collection('diaryNotes');

  // get stream of notes for a specific medication
  Stream<List<DiaryNote>> streamNotesForMedication(String userId, String medicationId) {
    return _notes
        .where('userId', isEqualTo: userId)
        .where('medicationId', isEqualTo: medicationId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DiaryNote.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // add 
  Future<void> addNote(DiaryNote note) async {
    await _notes.add(note.toMap());
  }

  // update 
  Future<void> updateNote(DiaryNote note) async {
    await _notes.doc(note.id).update(note.toMap());
  }

  // delete 
  Future<void> deleteNote(String noteId) async {
    await _notes.doc(noteId).delete();
  }
}
