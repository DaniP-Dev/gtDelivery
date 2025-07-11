import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String _status = '';
  String get status => _status;

  Future<bool> login(String email, String password) async {
    final result = await _authService.login(email, password);
    _status = result ? 'Login exitoso' : 'Usuario no existe o contraseña incorrecta';
    notifyListeners();
    return result;
  }

  Future<bool> signInWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _status = 'Login Google exitoso';
        notifyListeners();
        return true;
      } else {
        _status = 'Error en login con Google';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = 'Error en login con Google';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    // Aquí puedes implementar la lógica real si la necesitas
    _status = 'Sesión cerrada';
    notifyListeners();
  }

  Future<bool> register(String email, String password) async {
    final result = await _authService.register(email, password);
    _status = result ? 'Registro exitoso' : 'Error en el registro';
    notifyListeners();
    return result;
  }
}