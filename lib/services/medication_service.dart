import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication.dart';

class MedicationService {
  final _db = FirebaseFirestore.instance;

  // shortcut to the medications collection
  CollectionReference<Map<String, dynamic>> get _medications =>
      _db.collection('medications');

  // CREATE
  // a new medication and returns its generated document ID
  Future<String> addMedication(Medication med) async {
    final ref = await _medications.add(med.toMap());
    return ref.id;
  }

  // READ (live)
  // live stream of this user's medications
  // Updates automatically whenever a med is added, edited, or deleted, no need refresh
  // Use this with a StreamBuilder on the home and medication screens.
  Stream<List<Medication>> streamMedications(String userId) {
    return _medications
        .where('userId', isEqualTo: userId)
        .snapshots() // get new snapshot everytime data changes
        .map(
          (snapshot) => snapshot
              .docs // individual med objs in snapshot
              .map(
                (doc) => Medication.fromMap(doc.data(), doc.id),
              ) // convert each doc to a Medication object
              .toList(),
        );
  }

  // READ (one-off)
  //fetches a single medication by ID once
  // returns null if it doesn't exist
  Future<Medication?> getMedication(String medId) async {
    final doc = await _medications.doc(medId).get();
    if (!doc.exists) return null;
    return Medication.fromMap(doc.data()!, doc.id);
  }

  // UPDATE
  Future<void> updateMedication(Medication med) async {
    await _medications.doc(med.id).update(med.toMap());
  }

  // DELETE
  Future<void> deleteMedication(String medId) async {
    // delete related adherence logs first
    final logs = await _db
        .collection('adherenceLogs')
        .where('medicationId', isEqualTo: medId)
        .get();

    for (final doc in logs.docs) {
      await doc.reference.delete();
    }

    // delete the medication
    await _medications.doc(medId).delete();
  }
}
