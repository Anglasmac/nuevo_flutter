// lib/services/user_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nuevo_proyecto_flutter/services/ase_api_service.dart';

class UserService extends BaseApiService {
  
  /// Actualiza la contraseña del usuario.
  /// Lanza una excepción si la API devuelve un error.
  Future<void> updatePassword(int userId, String newPassword) async {
    final url = Uri.parse('$baseUrl/users/$userId'); 
    
    // --- CORRECCIÓN AQUÍ ---
    // Llamamos al método ESTÁTICO de la clase base, no a un método de instancia.
    final token = await BaseApiService.getAuthToken(); 
    
    if (token == null) {
      throw Exception('Operación no autorizada. El usuario no está autenticado.');
    }

    print('[UserService] Actualizando contraseña para el usuario ID: $userId en $url');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'password': newPassword}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Error desconocido al actualizar la contraseña.';
        throw Exception(errorMessage);
      }
      print('[UserService] Contraseña actualizada correctamente.');

    } catch (e) {
      print('[UserService] Error en updatePassword: $e');
      rethrow;
    }
  }
}