import 'dart:convert';
import 'package:flutter/foundation.dart'; // Necesario para kDebugMode (mejora)
import 'package:http/http.dart' as http;

// Importamos todos los modelos que este servicio va a manejar.
import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart';
import 'package:nuevo_proyecto_flutter/features/clientes/models/cliente_model.dart';
import 'package:nuevo_proyecto_flutter/features/servicios/models/servicio_model.dart';
// TODO: Considera añadir un servicio de autenticación para obtener el token.
// import 'package:nuevo_proyecto_flutter/services/auth_service.dart';


class ApiService {
  // ✅ CONFIGURACIÓN CENTRALIZADA DENTRO DE LA CLASE
  // ¡IMPORTANTE! Usa 'http://10.0.2.2:3000/api' para el emulador de Android.
  // Para iOS o dispositivo físico, usa la IP de tu PC (ej: 'http://192.168.1.100:3000/api').
  // ✅ LÍNEA CORRECTA (para web)
static const String _baseUrl = 'http://localhost:3000';

  
  // Getter para las cabeceras comunes. Puede ser dinámico.
  Map<String, String> get _commonHeaders {
    // Si tuvieras un sistema de login, aquí obtendrías el token.
    // final String? token = AuthService.instance.token;
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      // if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- MÉTODOS PARA EL ENDPOINT DE RESERVAS ---

  Future<List<Reserva>> fetchReservations() async {
    final Uri url = Uri.parse('$_baseUrl/reservations');
    if (kDebugMode) print('ApiService: GET $url');

    try {
      final response = await http.get(url, headers: _commonHeaders);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => Reserva.fromJson(item)).toList();
      } else {
        throw Exception('Fallo al cargar reservaciones (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener reservaciones: $e');
    }
  }

  Future<Reserva> createReservation(Reserva reservationData) async {
    final Uri url = Uri.parse('$_baseUrl/reservations');
    final String requestBody = jsonEncode(reservationData.toJson());
    if (kDebugMode) print('ApiService: POST $url with body: $requestBody');

    try {
      final response = await http.post(url, headers: _commonHeaders, body: requestBody);

      if (response.statusCode == 201) { // 201 Created es el código correcto
        return Reserva.fromJson(json.decode(response.body));
      } else {
        throw Exception('Fallo al crear la reservación (Código: ${response.statusCode})\n${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al crear reservación: $e');
    }
  }
  
  Future<Reserva> updateReservation(int reservationId, Reserva reservationData) async {
    final Uri url = Uri.parse('$_baseUrl/reservations/$reservationId');
    final String requestBody = jsonEncode(reservationData.toJson());
    if (kDebugMode) print('ApiService: PUT $url with body: $requestBody');

    try {
      final response = await http.put(url, headers: _commonHeaders, body: requestBody);

      if (response.statusCode == 200) {
        return Reserva.fromJson(json.decode(response.body));
      } else {
        throw Exception('Fallo al actualizar reservación (Código: ${response.statusCode})\n${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar reservación: $e');
    }
  }

  Future<void> deleteReservation(String reservationId) async {
    final Uri url = Uri.parse('$_baseUrl/reservations/$reservationId');
    if (kDebugMode) print('ApiService: DELETE $url');

    try {
      final response = await http.delete(url, headers: _commonHeaders);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Fallo al eliminar reservación (Código: ${response.statusCode})\n${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al eliminar reservación: $e');
    }
  }

  // ✅ NUEVO MÉTODO: Obtener lista de clientes
  Future<List<Cliente>> fetchClientes() async {
    final response = await http.get(Uri.parse('$_baseUrl/customers')); // Asegúrate de que la ruta `/customers` sea correcta
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Cliente.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los clientes');
    }
  }

  // ✅ NUEVO MÉTODO: Obtener lista de servicios adicionales
  Future<List<ServicioAdicional>> fetchServiciosAdicionales() async {
    final response = await http.get(Uri.parse('$_baseUrl/aditionalServices')); // Asegúrate de que la ruta `/aditionalServices` sea correcta
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ServicioAdicional.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los servicios adicionales');
    }
  }

  // Agregar este método a tu ApiService:

// Reemplaza el método fetchServiceIdsForReservation con esta versión corregida:

// REEMPLAZA el método fetchServiceIdsForReservation con este:
// (Elimina el método anterior y usa este)

Future<List<int>> fetchServiceIdsForReservation(int reservationId) async {
  try {
    print("📞 Obteniendo servicios para reserva $reservationId desde reserva individual");
    
    // Obtener la reserva individual con servicios incluidos
    final response = await http.get(
      Uri.parse('$_baseUrl/reservations/$reservationId'), // ✅ Endpoint que SÍ existe
      headers: _commonHeaders,
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> reservaData = json.decode(response.body);
      print("🔍 Datos de reserva individual: $reservaData");
      
      // Verificar si tiene servicios adicionales
      if (reservaData.containsKey('AditionalServices')) {
        final List<dynamic> services = reservaData['AditionalServices'];
        final serviceIds = services.map((service) => service['idAditionalServices'] as int).toList();
        print("✅ IDs de servicios obtenidos: $serviceIds");
        return serviceIds;
      }
    }
    
    print("⚠️ No se encontraron servicios para la reserva $reservationId");
    return [];
  } catch (e) {
    print("❌ Error obteniendo servicios: $e");
    return [];
  }
}

}