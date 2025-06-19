// lib/services/auth_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nuevo_proyecto_flutter/services/ase_api_service.dart';

// --- IMPORTANTE: Asegúrate que las rutas a tus modelos sean correctas ---
import 'package:nuevo_proyecto_flutter/features/auth/models/user_model.dart';
import 'package:nuevo_proyecto_flutter/features/auth/models/login_response_model.dart';

// Modificamos las claves para incluir el usuario.
class AuthStorageKeys {
  static const String token = 'token';
  static const String user = 'authUser';
  // Si usas permisos, descomenta la siguiente línea:
  // static const String permissions = 'effectivePermissions';
}

class AuthService extends BaseApiService {

  /// Realiza el login y, si es exitoso, guarda el token y el usuario.
  /// Devuelve el objeto [User] para que el AuthProvider lo utilice.
  Future<User> login(String email, String password) async {
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
        // Usamos tu modelo LoginResponse para parsear la respuesta.
        final loginResponse = LoginResponse.fromJson(data);
        
        final prefs = await SharedPreferences.getInstance();
        
        // Guardar el token de autenticación.
        await prefs.setString(AuthStorageKeys.token, loginResponse.token);
        
        // ¡CLAVE! Guardar el objeto de usuario completo como un string JSON.
        await prefs.setString(AuthStorageKeys.user, jsonEncode(loginResponse.user.toJson()));

        // Configurar el token en la clase base para futuras peticiones.
        BaseApiService.setAuthToken(loginResponse.token);

        print('[AuthService] Login exitoso. Token y usuario guardados.');
        return loginResponse.user; // Devolvemos el objeto User.

      } else {
        final errorMessage = data['message'] ?? 'Error de autenticación.';
        throw Exception(errorMessage);
      }
    } on SocketException {
       throw Exception('No se pudo conectar al servidor. Revisa tu conexión y la URL: $baseUrl');
    } catch (e) {
      print('[AuthService] Excepción en login: $e');
      await clearClientSession(); // Limpia cualquier dato si el login falla.
      rethrow;
    }
  }

  /// Cierra la sesión en el backend (si existe endpoint) y limpia los datos locales.
  Future<void> logout() async {
    // Opcional: Llamada al endpoint de logout del backend.
    try {
      final token = await getToken();
      if (token != null) {
        final url = Uri.parse('$baseUrl/auth/logout');
        await http.post(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );
        print('[AuthService] Petición de logout al backend enviada.');
      }
    } catch (e) {
       print('[AuthService] Error en petición de logout al backend (se ignorará): $e');
    }
    // Siempre limpia la sesión local, incluso si la llamada al backend falla.
    await clearClientSession();
  }

  /// Limpia todos los datos de sesión guardados en el dispositivo.
  Future<void> clearClientSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AuthStorageKeys.token);
    await prefs.remove(AuthStorageKeys.user); // <-- ¡Importante! Limpiar también el usuario.
    
    BaseApiService.clearAuthToken();
    print('[AuthService] Sesión del cliente (token, user) limpiada.');
  }

  /// Obtiene el token guardado. Devuelve null si no existe.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AuthStorageKeys.token);
  }

  /// Obtiene el objeto User guardado. Devuelve null si no existe.
  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(AuthStorageKeys.user);
    if (userString != null) {
      try {
        // Decodifica el string JSON y crea un objeto User.
        return User.fromJson(jsonDecode(userString));
      } catch (e) {
        print('[AuthService] Error al decodificar el usuario guardado: $e');
        return null;
      }
    }
    return null;
  }
  
  /// Comprueba si existe un token válido.
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}