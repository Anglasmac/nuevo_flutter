// lib/services/base_api_service.dart

import 'dart:io' show Platform; // Importamos solo 'Platform' de dart:io
import 'package:flutter/foundation.dart' show kIsWeb; // Importamos kIsWeb

abstract class BaseApiService {
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static void clearAuthToken() {
    _authToken = null;
  }

  String get baseUrl {
    const String backendHost = "localhost";
    const String backendPort = "3000";
    // CAMBIO CRUCIAL: Tu backend NO usa un prefijo /api global.
    const String apiPrefix = ""; // Lo dejamos vacío.

    if (kIsWeb) {
      return 'http://$backendHost:$backendPort$apiPrefix';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:$backendPort$apiPrefix';
    } else {
      return 'http://$backendHost:$backendPort$apiPrefix';
    }
  }

  Map<String, String> get commonHeaders => {
        'Content-Type': 'application/json; charset=UTF-8',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
}