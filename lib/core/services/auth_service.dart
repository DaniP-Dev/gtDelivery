import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'uid': credential.user!.uid,
        'email': credential.user!.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseAuthException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> login(
    String email,
    String password,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      return true; // Usuario existe y login correcto
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return false; // Usuario no existe
      }
      if (e.code == 'wrong-password') {
        return false; // Contraseña incorrecta
      }
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout(Function(String) onStatus) async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    onStatus('Sesión cerrada');
  }

  String? get userName {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? user?.email ?? 'Usuario';
  }
}
