import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  String status = '';
  GoogleSignInAccount? googleUser;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      if (user == null) {
        status = 'No autenticado';
      } else {
        status = 'Autenticado: ${user.email ?? user.displayName ?? 'Usuario'}';
      }
      notifyListeners();
    });
  }

  Future<void> initializeGoogleSignIn(String serverClientId) async {
    await _authService.initializeGoogleSignIn(
      serverClientId: serverClientId,
      onUserChanged: (user) {
        googleUser = user;
        notifyListeners();
      },
      onError: (msg) {
        status = msg;
        notifyListeners();
      },
    );
  }

  Future<void> register(String email, String password) async {
    await _authService.register(email, password, (msg) {
      status = msg;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    await _authService.login(email, password, (msg) {
      status = msg;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    await _authService.signInWithGoogle((msg) {
      status = msg;
      notifyListeners();
    }, (user) {
      googleUser = user;
      notifyListeners();
    });
  }

  Future<void> logout() async {
    await _authService.logout((msg) {
      status = msg;
      notifyListeners();
    });
    googleUser = null;
    notifyListeners();
  }
}