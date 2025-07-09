import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  String status = '';
  User? firebaseUser;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      firebaseUser = user;
      if (user == null) {
        status = 'No autenticado';
      } else {
        status = 'Autenticado: ${user.email ?? user.displayName ?? 'Usuario'}';
      }
      notifyListeners();
    });
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
      firebaseUser = user;
      notifyListeners();
    });
  }

  Future<void> logout() async {
    await _authService.logout((msg) {
      status = msg;
      notifyListeners();
    });
    firebaseUser = null;
    notifyListeners();
  }
}