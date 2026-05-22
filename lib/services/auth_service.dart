import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _logAction(String email, String action) async {
    await _firestore.collection('logs').add({
      'email': email,
      'action': action,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _logAction(email, 'Sisteme giriş yaptı.');
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> signUp(String email, String password, String role) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _logAction(email, 'Sisteme yeni kayıt oldu ($role).');
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    final email = _auth.currentUser?.email ?? 'Bilinmiyor';
    await _logAction(email, 'Sistemden çıkış yaptı.');
    await _auth.signOut();
  }
}
