import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/caregiver_relationship.dart';

class CaregiverService {
  final _db = FirebaseFirestore.instance;

  // pointer to a specific folder (collection) in database
  // invite codes
  CollectionReference<Map<String, dynamic>> get _invites =>
      _db.collection('inviteCodes');

  // caregiver relationship
  CollectionReference<Map<String, dynamic>> get _relationships =>
      _db.collection('caregiverRelationships');

  // ---------- patient: generate invite code ----------

  // 6-digit code tied to patient, valid for 24hrs
  Future<String> generateInviteCode(String patientId) async {
    final rng = Random(); // random number generator
    String code = '';

    // try a few times in case of a collision (rare with 900k combos)
    for (var attempt = 0; attempt < 5; attempt++) {
      code = (rng.nextInt(900000) + 100000).toString(); // 100000–999999

      // if code already exists, try again
      final existing = await _invites.doc(code).get();
      if (!existing.exists) break;
    }

    await _invites.doc(code).set({
      'patientId': patientId,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(hours: 24)),
      ),
    });

    return code;
  }

  // ---------- caregiver: redeem a code ----------

  // looks up the code, validates, creates relationship
  Future<void> redeemInviteCode({
    required String code,
    required String caregiverId,
    required CaregiverRelationshipType relationship,
  }) async {
    final inviteDoc = await _invites.doc(code).get();
    // check if code exists
    if (!inviteDoc.exists) {
      throw Exception('Invalid code. Please check and try again.');
    }

    final data = inviteDoc.data()!;
    // check if code has expired
    final expiresAt = (data['expiresAt'] as Timestamp).toDate();
    if (DateTime.now().isAfter(expiresAt)) {
      throw Exception('This code has expired. Ask for a new one.');
    }

    final patientId = data['patientId'] as String;
    // check if user linking to themselves
    if (patientId == caregiverId) {
      throw Exception('You cannot link to your own account.');
    }

    // deterministic id for the relationship
    final relId = '${patientId}_$caregiverId';
    await _relationships.doc(relId).set({
      'id': relId,
      'patientId': patientId,
      'caregiverId': caregiverId,
      'relationship': relationship.name,
      'sinceDate': FieldValue.serverTimestamp(),
    });

    // consume the code so it can't be reused
    await _invites.doc(code).delete();
  }

  // ---------- streams ----------

  // linked patients
  Stream<List<CaregiverRelationship>> streamRelationshipsForCaregiver(
    String caregiverId,
  ) {
    return _relationships
        .where('caregiverId', isEqualTo: caregiverId)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => _relFromMap(d.data(), d.id)).toList(),
        );
  }

  // linked caregivers
  Stream<List<CaregiverRelationship>> streamRelationshipsForPatient(
    String patientId,
  ) {
    return _relationships
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => _relFromMap(d.data(), d.id)).toList(),
        );
  }

  // convert map to relationship object
  CaregiverRelationship _relFromMap(Map<String, dynamic> m, String id) {
    return CaregiverRelationship(
      id: id,
      patientId: m['patientId'] as String,
      caregiverId: m['caregiverId'] as String,
      relationship: CaregiverRelationshipType.values.firstWhere(
        (e) => e.name == m['relationship'],
        orElse: () => CaregiverRelationshipType.values.first,
      ),
      sinceDate: (m['sinceDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // remove a link (either party can unlink)
  Future<void> unlink(String relationshipId) =>
      _relationships.doc(relationshipId).delete();
}
