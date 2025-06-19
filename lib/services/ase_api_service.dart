// lib/services/base_api_service.dart

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nuevo_proyecto_flutter/features/auth/services/auth_service.dart'; // Para acceder a AuthStorageKeys

/// Clase base abstracta para todos los servicios de API.
/// Centraliza la configuración de la URL base y la gestión de tokens.
abstract class BaseApiService {
  // El token de autenticación se gestiona de forma estática y centralizada.
  static String? _authToken;

  /// Guarda el token de autenticación para usarlo en futuras peticiones.
  static void setAuthToken(String token) {
    _authToken = token;
  }

  /// Limpia el token de autenticación (ej. al cerrar sesión).
  static void clearAuthToken() {
    _authToken = null;
  }

  // --- MÉTODO AÑADIDO (LA SOLUCIÓN PRINCIPAL) ---
  /// Obtiene el token de autenticación actual.
  ///
  /// Primero revisa si el token ya está en memoria (_authToken).
  /// Si no, intenta cargarlo desde el almacenamiento persistente (SharedPreferences).
  /// Esto es crucial para que la sesión persista si se cierra la app.
  static Future<String?> getAuthToken() async {
    // Si ya tenemos el token en memoria, lo devolvemos al instante.
    if (_authToken != null && _authToken!.isNotEmpty) {
      return _authToken;
    }

    // Si no, lo buscamos en SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(AuthStorageKeys.token);
    
    if (storedToken != null && storedToken.isNotEmpty) {
      _authToken = storedToken; // Guardamos en memoria para futuros accesos rápidos.
      return _authToken;
    }

    // Si no hay token en ningún lado, devolvemos null.
    return null;
  }
  // --- FIN DEL MÉTODO AÑADIDO ---


  /// Define la URL base del backend.
  String get baseUrl {
    // Tu lógica para determinar la IP local está perfecta.
    // La IP '192.168.1.10' es un ejemplo, reemplázala por la IP de la máquina
    // donde corre tu backend si estás probando en un dispositivo físico.
    const String backendHost = "192.168.1.10"; // <--- CAMBIA ESTO POR LA IP DE TU PC
    const String backendPort = "3000";

    if (kIsWeb) {
      // Para web, 'localhost' funciona.
      return 'http://localhost:$backendPort';
    }

    if (Platform.isAndroid) {
      // El emulador de Android usa 10.0.2.2 para el localhost de la máquina.
      return 'http://10.0.2.2:$backendPort';
    }

    // Para dispositivos físicos en la misma red, simulador de iOS, macOS, etc.
    return 'http://$backendHost:$backendPort';
  }

  /// Define los headers comunes para todas las peticiones.
  /// Incluye el Content-Type y el token de autorización si está disponible.
  Map<String, String> get commonHeaders => {
        'Content-Type': 'application/json; charset=UTF-8',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
}