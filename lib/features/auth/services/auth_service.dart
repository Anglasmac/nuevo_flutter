import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Asegúrate de que esta ruta sea correcta para tu proyecto
import 'package:nuevo_proyecto_flutter/app/config/app_config.dart';

// Las claves de almacenamiento no cambian.
class AuthStorageKeys {
  static const String token = 'token';
  static const String user = 'authUser';
  static const String permissions = 'effectivePermissions';
}

class AuthService {

  Future<bool> login(String email, String password) async {
    final Uri url = Uri.parse('${AppConfig.apiBaseUrl}/auth/login');
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

          print('[AuthService DEBUG] Contenido del objeto USER recibido: $user'); 

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AuthStorageKeys.token, token);
          await prefs.setString(AuthStorageKeys.user, jsonEncode(user));
          await prefs.setString(AuthStorageKeys.permissions, jsonEncode(permissions));

          print('[AuthService] Login exitoso. Token, usuario y permisos guardados.');
          
          // --- ¡AQUÍ ESTÁ LA CORRECCIÓN! ---
          // Devolvemos 'true' para indicar que el login fue exitoso,
          // cumpliendo con la firma del método Future<bool>.
          return true;

        } else {
          throw Exception('Respuesta inválida del servidor (faltan datos).');
        }
      } else {
        final errorMessage = data['message'] ?? 'Error de autenticación.';
        throw Exception(errorMessage);
      }
    } on SocketException {
       throw Exception('No se pudo conectar al servidor. Revisa tu conexión y la URL: ${AppConfig.apiBaseUrl}');
    } catch (e) {
      print('[AuthService] Excepción en login: $e');
      await clearClientSession();
      // Si ocurre cualquier error, relanzamos la excepción,
      // y el que llame a esta función puede devolver 'false' si lo desea.
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final permissionsString = prefs.getString(AuthStorageKeys.permissions);

    if (permissionsString != null && permissionsString.isNotEmpty) {
      try {
        final decodedData = jsonDecode(permissionsString);
        if (decodedData is Map<String, dynamic>) {
          return decodedData;
        } else {
          print('[AuthService] Alerta: Los permisos guardados no son un Mapa. Se devolverá un mapa vacío.');
          return {};
        }
      } catch (e) {
        print('[AuthService] Error al decodificar los permisos: $e. Se devolverá un mapa vacío.');
        return {};
      }
    }
    return {};
  }

  Future<bool> hasPermission(String screen, String privilege) async {
    final permissions = await getPermissions();
    
    if (permissions.isNotEmpty && permissions.containsKey(screen)) {
      final List<dynamic> privileges = permissions[screen] as List<dynamic>;
      return privileges.contains(privilege);
    }
    
    return false;
  }
  
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        final url = Uri.parse('${AppConfig.apiBaseUrl}/auth/logout');
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
  
  Future<String> getRoleName() async {
    final user = await getUser();

    if (user != null && user.containsKey('idRole')) {
      final dynamic roleIdValue = user['idRole'];
      
      if (roleIdValue is int) {
        final int roleId = roleIdValue;
        
        switch (roleId) {
          case 1:
            return 'Administrador';
          case 2:
            return 'Empleado';
          default:
            return 'Rol ID $roleId (Desconocido)';
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