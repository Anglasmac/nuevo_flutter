// lib/services/base_api_service.dart

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Clase base abstracta para todos los servicios de API.
/// Centraliza la configuración de la URL base, los headers y la gestión de tokens.
abstract class BaseApiService {
  // El token de autenticación se gestiona de forma estática y centralizada.
  static String? _authToken;

  /// Guarda el token de autenticación para usarlo en futuras peticiones.
  /// Llama a este método desde tu lógica de login.
  /// Ejemplo: BaseApiService.setAuthToken(userToken);
  static void setAuthToken(String token) {
    _authToken = token;
  }

  /// Limpia el token de autenticación (ej. al cerrar sesión).
  static void clearAuthToken() {
    _authToken = null;
  }

  /// Define la URL base del backend.
  String get baseUrl {
    // <-- CAMBIO CRUCIAL: Apuntamos directamente a la URL de producción.
    // Toda la lógica de desarrollo local ha sido eliminada para claridad.
    // Esta es ahora la única fuente de verdad para la URL del backend.
    return 'https://api-foodnodedesp.onrender.com';
  }

  /// Define los headers comunes para todas las peticiones a la API.
  /// Incluye el Content-Type y el token de autorización si está disponible.
  Map<String, String> get commonHeaders => {
        'Content-Type': 'application/json; charset=UTF-8',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
}