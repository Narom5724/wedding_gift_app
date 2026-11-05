import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  FirebaseAuth get _auth => Firebase.apps.isNotEmpty
      ? FirebaseAuth.instance
      : throw StateError('Firebase is not initialized.');
  FirebaseFirestore get _firestore => Firebase.apps.isNotEmpty
      ? FirebaseFirestore.instance
      : throw StateError('Firebase is not initialized.');

  User? get currentUser =>
      Firebase.apps.isNotEmpty ? FirebaseAuth.instance.currentUser : null;

  Stream<User?> get authStateChanges => Firebase.apps.isNotEmpty
      ? FirebaseAuth.instance.authStateChanges()
      : const Stream.empty();

  Future<String?> fetchUserName(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    final fullName = snapshot.data()?['fullName']?.toString().trim();
    return fullName == null || fullName.isEmpty ? null : fullName;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<UserCredential> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    await credential.user?.updateDisplayName(fullName.trim());
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'fullName': fullName.trim(),
      'email': credential.user!.email,
      'phone': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return credential;
  }

  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
