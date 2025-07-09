import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> register(
    String email,
    String password,
    Function(String) onStatus,
  ) async {
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

      onStatus('Registro exitoso');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        onStatus('La contraseña es muy débil.');
      } else if (e.code == 'email-already-in-use') {
        onStatus('El correo ya está en uso.');
      } else {
        onStatus(e.message ?? 'Error desconocido');
      }
    } catch (e) {
      onStatus('Error: $e');
    }
  }

  Future<void> login(
    String email,
    String password,
    Function(String) onStatus,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      onStatus('Login exitoso');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        onStatus('No existe usuario para ese correo.');
      } else if (e.code == 'wrong-password') {
        onStatus('Contraseña incorrecta.');
      } else {
        onStatus(e.message ?? 'Error desconocido');
      }
    } catch (e) {
      onStatus('Error: $e');
    }
  }

  Future<void> signInWithGoogle(
    Function(String) onStatus,
    Function(User?) onUserChanged,
  ) async {
    try {
      // Inicia el flujo de Google Sign-In
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        onStatus('Login cancelado');
        return;
      }

      // Obtiene tokens de autenticación
      final googleAuth = await googleUser.authentication;

      // Crea credencial para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Inicia sesión en Firebase
      final userCredential =
          await _auth.signInWithCredential(credential);

      // Si es un nuevo usuario, lo guarda en Firestore
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      onStatus('Google Sign-In exitoso: ${userCredential.user?.email}');
      onUserChanged(userCredential.user);
    } on FirebaseAuthException catch (e) {
      onStatus('Error Firebase Auth: ${e.message}');
    } catch (e) {
      onStatus('Error en Google Sign-In: $e');
    }
  }

  Future<void> logout(Function(String) onStatus) async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    onStatus('Sesión cerrada');
  }
}
