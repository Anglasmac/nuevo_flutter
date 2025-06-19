// lib/features/auth/provider/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/features/auth/models/user_model.dart';
import 'package:nuevo_proyecto_flutter/features/auth/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  // --- ESTADO INTERNO DEL PROVIDER ---
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = true; // Empieza en true para mostrar un spinner al inicio.

  // --- GETTERS PÚBLICOS (para que la UI los consuma) ---
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  /// Constructor: Al iniciar la app, comprueba el estado de autenticación.
  AuthProvider() {
    _checkAuthStatus();
  }

  /// Comprueba si ya existe una sesión válida en el dispositivo.
  Future<void> _checkAuthStatus() async {
    _isAuthenticated = await _authService.isAuthenticated();
    if (_isAuthenticated) {
      // Si hay un token, cargamos los datos del usuario.
      _user = await _authService.getSavedUser();
      // Si por alguna razón el usuario no se puede cargar, cerramos sesión por seguridad.
      if (_user == null) {
        _isAuthenticated = false;
        await _authService.clearClientSession();
      }
    }
    
    _isLoading = false; // El chequeo inicial ha terminado.
    notifyListeners(); // Notifica a los widgets que escuchan.
  }

  /// Inicia sesión con email y password.
  Future<void> login(String email, String password) async {
    try {
      // El servicio ahora devuelve el usuario, lo guardamos en nuestro estado.
      final loggedInUser = await _authService.login(email, password);
      _user = loggedInUser;
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      // Si el login falla, nos aseguramos de que el estado sea "no autenticado".
      _user = null;
      _isAuthenticated = false;
      notifyListeners();
      rethrow; // Relanzamos el error para que la UI de login lo muestre.
    }
  }

  /// Cierra la sesión del usuario.
  Future<void> logout() async {
    await _authService.logout();
    // Limpiamos el estado local.
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}