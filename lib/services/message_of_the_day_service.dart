import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_of_the_day.dart';

class MessageOfTheDayService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _messages =>
      _db.collection('messagesOfTheDay');

  // ---------- read ----------

  // live 
  Stream<MessageOfTheDay?> streamMessageForPatient(String patientId) {
    return _messages.doc(patientId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return MessageOfTheDay.fromMap(doc.data()!, doc.id);
    });
  }

  // one-time fetch 
  Future<MessageOfTheDay?> getMessageForPatient(String patientId) async {
    final doc = await _messages.doc(patientId).get();
    if (!doc.exists) return null;
    return MessageOfTheDay.fromMap(doc.data()!, doc.id);
  }

  // ---------- write ----------

  // save/update message for patient
  Future<void> saveMessage(MessageOfTheDay message) async {
    await _messages
        .doc(message.patientId)
        .set(message.toMap(), SetOptions(merge: true));
  }
}
