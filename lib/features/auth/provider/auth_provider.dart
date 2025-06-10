// lib/features/auth/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/features/auth/services/auth_service.dart'; // Ajusta la ruta

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // Al iniciar, comprobamos si ya hay una sesión guardada
  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isAuthenticated = await _authService.isAuthenticated();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    // Lanza excepción si falla, para que la UI la pueda mostrar.
    await _authService.login(email, password);
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}