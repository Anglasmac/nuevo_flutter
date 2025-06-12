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
    // <-- INICIO DEL CAMBIO -->

    // --- CONFIGURACIÓN DE DESPLIEGUE (COMENTADA) ---
    // Esta es la URL que se usaba para producción. La dejamos aquí por si necesitas volver a activarla.
    // return 'https://api-foodnodedesp.onrender.com';


    // --- CONFIGURACIÓN LOCAL (ACTIVA) ---
    // Esta URL se usará mientras desarrollas y pruebas en tu máquina.
    const String backendHost = "localhost"; // El host de tu backend local
    const String backendPort = "3000";      // El puerto de tu backend local

    // Lógica para determinar la IP correcta según la plataforma de desarrollo.
    if (kIsWeb) {
      // Para web, 'localhost' funciona directamente.
      return 'http://$backendHost:$backendPort';
    }

    // Para móvil, necesitamos una IP específica si es el emulador de Android.
    if (Platform.isAndroid) {
      // El emulador de Android usa 10.0.2.2 para referirse al 'localhost' de la máquina anfitriona.
      return 'http://10.0.2.2:$backendPort';
    }

    // Para el simulador de iOS, macOS, Windows, Linux, 'localhost' suele funcionar bien.
    return 'http://$backendHost:$backendPort';
    
    // <-- FIN DEL CAMBIO -->
  }

  /// Define los headers comunes para todas las peticiones a la API.
  /// Incluye el Content-Type y el token de autorización si está disponible.
  Map<String, String> get commonHeaders => {
        'Content-Type': 'application/json; charset=UTF-8',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
}