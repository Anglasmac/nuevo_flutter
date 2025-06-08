// lib/features/auth/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nuevo_proyecto_flutter/app/config/app_config.dart'; // Ajusta la ruta
import 'package:nuevo_proyecto_flutter/features/auth/models/login_response_model.dart'; // Ajusta la ruta
// Ajusta la ruta

const String _tokenKey = 'auth_token';

class AuthService {
  final Dio _dio = Dio(); // Puedes configurar Dio con interceptores más adelante

  Future<LoginResponse> login(String email, String password) async {
    const String loginEndpoint = "/api/auth/login";
    const String url = AppConfig.apiBaseUrl + loginEndpoint;

    try {
      final response = await _dio.post(
        url,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final loginData = LoginResponse.fromJson(response.data as Map<String, dynamic>);
        await _storeToken(loginData.token);
        return loginData;
      } else {
        // Manejar otros códigos de estado si es necesario, o confiar en DioException
        throw Exception('Respuesta inesperada del servidor.');
      }
    } on DioException catch (e) {
      // DioException proporciona más detalles sobre el error HTTP
      String errorMessage = "Error de conexión. Inténtalo de nuevo.";
      if (e.response != null) {
        // El servidor respondió con un código de error (4xx, 5xx)
        if (kDebugMode) {
          print("Error en login (Dio): ${e.response?.statusCode} - ${e.response?.data}");
        }
        final responseData = e.response?.data;
        if (responseData is Map && responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        } else if (e.response?.statusCode == 401) {
          errorMessage = "Credenciales incorrectas.";
        } else {
          errorMessage = "Error del servidor: ${e.response?.statusCode}";
        }
      } else {
        // Error de red, timeout, etc.
        if (kDebugMode) {
          print("Error en login (Dio - sin respuesta): ${e.message}");
        }
      }
      throw Exception(errorMessage); // Lanza una excepción más amigable
    } catch (e) {
      // Otro tipo de error
      if (kDebugMode) {
        print("Error desconocido en login: $e");
      }
      throw Exception('Ocurrió un error inesperado. Inténtalo de nuevo.');
    }
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    // Aquí podrías querer notificar al resto de la app para que vuelva al login,
    // usualmente a través de un gestor de estado.
  }

  // Opcional: para configurar un cliente Dio con interceptor de token para otras llamadas API
  Dio getDioClientWithAuth() {
    final dioClient = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
    dioClient.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options); // Continúa con la petición
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Token inválido o expirado
            await logout(); // Limpia el token
            // Aquí podrías redirigir al login globalmente usando un gestor de estado
            // o un callback si este DioClient es usado por múltiples servicios.
            if (kDebugMode) {
              print("Error 401: Token inválido/expirado. Sesión cerrada.");
            }
          }
          return handler.next(e); // Continúa con el error
        },
      ),
    );
    return dioClient;
  }
}