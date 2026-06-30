import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile.dart';

class ProfileService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _profiles =>
      _db.collection('profiles');

  // ---------- read ----------
  // live
  Stream<Profile?> streamProfile(String uid) {
    return _profiles.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Profile.fromMap(doc.data()!, doc.id);
    });
  }

  // one time fetch
  Future<Profile?> getProfile(String uid) async {
    final doc = await _profiles.doc(uid).get();
    if (!doc.exists) return null;
    return Profile.fromMap(doc.data()!, doc.id);
  }

  // ---------- write ----------
  Future<void> saveProfile(Profile profile) async {
    await _profiles
        .doc(profile.userId)
        .set(profile.toMap(), SetOptions(merge: true));
  }
}
