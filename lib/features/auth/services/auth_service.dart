// lib/services/auth_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// <-- REFACTORIZACIÓN: Se importa la clase base para unificar la configuración.
import 'package:nuevo_proyecto_flutter/services/ase_api_service.dart'; 

// Las claves para SharedPreferences no cambian.
class AuthStorageKeys {
  static const String token = 'token';
  static const String user = 'authUser';
  static const String permissions = 'effectivePermissions';
}

// <-- REFACTORIZACIÓN: AuthService ahora extiende BaseApiService.
class AuthService extends BaseApiService {

  Future<bool> login(String email, String password) async {
    // <-- REFACTORIZACIÓN: Usa `baseUrl` heredado en lugar de `AppConfig`.
    final Uri url = Uri.parse('$baseUrl/auth/login');
    print('[AuthService] Intentando login en: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data.containsKey('token') && data.containsKey('user') && data.containsKey('effectivePermissions')) {
          final String token = data['token'];
          final Map<String, dynamic> user = data['user'];
          final Map<String, dynamic> permissions = data['effectivePermissions'];

          // <-- INTEGRACIÓN CLAVE: Informamos a la clase base del nuevo token.
          // Ahora todos los demás servicios usarán este token automáticamente.
          BaseApiService.setAuthToken(token);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AuthStorageKeys.token, token);
          await prefs.setString(AuthStorageKeys.user, jsonEncode(user));
          await prefs.setString(AuthStorageKeys.permissions, jsonEncode(permissions));

          print('[AuthService] Login exitoso. Token, usuario y permisos guardados.');
          return true;

        } else {
          throw Exception('Respuesta inválida del servidor (faltan datos).');
        }
      } else {
        final errorMessage = data['message'] ?? 'Error de autenticación.';
        throw Exception(errorMessage);
      }
    } on SocketException {
       throw Exception('No se pudo conectar al servidor. Revisa tu conexión y la URL: $baseUrl');
    } catch (e) {
      print('[AuthService] Excepción en login: $e');
      await clearClientSession();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        // <-- REFACTORIZACIÓN: Usa `baseUrl` heredado.
        final url = Uri.parse('$baseUrl/auth/logout');
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );
        print('[AuthService] Petición de logout al backend enviada.');
      }
    } catch (e) {
       print('[AuthService] Error en petición de logout al backend (se ignorará): $e');
    }
    await clearClientSession();
  }

  Future<void> clearClientSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AuthStorageKeys.token);
    await prefs.remove(AuthStorageKeys.user);
    await prefs.remove(AuthStorageKeys.permissions);

    // <-- INTEGRACIÓN CLAVE: Limpiamos el token en la clase base.
    BaseApiService.clearAuthToken();
    
    print('[AuthService] Sesión del cliente (token, user, permissions) limpiada.');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AuthStorageKeys.token);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(AuthStorageKeys.user);
    if (userString != null) {
      return jsonDecode(userString) as Map<String, dynamic>;
    }
    return null;
  }
  
  Future<Map<String, dynamic>> getPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final permissionsString = prefs.getString(AuthStorageKeys.permissions);

    if (permissionsString != null && permissionsString.isNotEmpty) {
      try {
        final decodedData = jsonDecode(permissionsString);
        if (decodedData is Map<String, dynamic>) {
          return decodedData;
        }
      } catch (e) {
        print('[AuthService] Error al decodificar los permisos: $e. Se devolverá un mapa vacío.');
      }
    }
    return {};
  }

  Future<bool> hasPermission(String screen, String privilege) async {
    final permissions = await getPermissions();
    
    if (permissions.isNotEmpty && permissions.containsKey(screen)) {
      final List<dynamic> privileges = permissions[screen];
      return privileges.contains(privilege);
    }
    return false;
  }

  Future<String> getRoleName() async {
    final user = await getUser();
    if (user != null && user.containsKey('idRole')) {
      final dynamic roleIdValue = user['idRole'];
      if (roleIdValue is int) {
        switch (roleIdValue) {
          case 1: return 'Administrador';
          case 2: return 'Empleado';
          default: return 'Rol ID $roleIdValue (Desconocido)';
        }
      }
    }
    return 'Sin Rol Definido';
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}