import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  GoogleSignInAccount? googleUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> initializeGoogleSignIn({required String serverClientId, required Function(GoogleSignInAccount?) onUserChanged, required Function(String) onError}) async {
    try {
      await _googleSignIn.initialize(
        serverClientId: serverClientId,
      );
      _googleSignIn.authenticationEvents.listen((event) {
        googleUser = switch (event) {
          GoogleSignInAuthenticationEventSignIn() => event.user,
          GoogleSignInAuthenticationEventSignOut() => null,
        };
        onUserChanged(googleUser);
      });
      _googleSignIn.attemptLightweightAuthentication();
    } catch (e) {
      onError('Error inicializando Google Sign-In: $e');
    }
  }

  Future<void> register(String email, String password, Function(String) onStatus) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
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
      onStatus(e.toString());
    }
  }

  Future<void> login(String email, String password, Function(String) onStatus) async {
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
      onStatus(e.toString());
    }
  }

  Future<void> signInWithGoogle(Function(String) onStatus, Function(GoogleSignInAccount?) onUserChanged) async {
    try {
      onStatus('Iniciando Google Sign-In...');
      if (!_googleSignIn.supportsAuthenticate()) {
        onStatus('Esta plataforma no soporta autenticación con Google');
        return;
      }
      await _googleSignIn.authenticate();
      await Future.delayed(Duration(milliseconds: 500));
      if (googleUser == null) {
        onStatus('Login cancelado o falló');
        return;
      }
      final Map<String, String>? headers = await googleUser!.authorizationClient.authorizationHeaders(['email', 'profile']);
      if (headers == null) {
        onStatus('No se pudo obtener autorización');
        return;
      }
      onStatus('Google Sign-In exitoso: ${googleUser!.displayName ?? googleUser!.email}');
      onUserChanged(googleUser);
    } on GoogleSignInException catch (e) {
      onStatus('Error de Google Sign-In: ${e.description}');
    } catch (e) {
      onStatus('Error en Google Sign-In: $e');
    }
  }

  Future<void> logout(Function(String) onStatus) async {
    await _auth.signOut();
    await _googleSignIn.disconnect();
    onStatus('Sesión cerrada');
    googleUser = null;
  }
}