import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> register(String email, String password, String name) async {
    // create login credentials
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // save actual info (name etc.) in db
    await _db.collection('users').doc(cred.user!.uid).set({
      'id': cred.user!.uid,
      'email': email,
      'name': name,
      'phone': null,
      'fcmToken': '', // update this later, for notifications
      // 'quietHoursEnabled': false,
      // 'linkedCaregiverUids': [],
      // 'linkedPatientUids': [],
      'createdAt': FieldValue.serverTimestamp(),
      // 'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;
}
