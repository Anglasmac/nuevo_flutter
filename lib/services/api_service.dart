// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io'; // Para Platform.isAndroid / Platform.isIOS
import 'package:http/http.dart' as http;
// ¡IMPORTANTE! Ajusta la ruta y el nombre del paquete
import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart';

class ApiService {
  String? _authToken; // 1. Variable para guardar el token

  // 2. Método para establecer el token después del login
  void setAuthToken(String token) {
    _authToken = token;
  }

   String get _baseUrl {
    // --- ¡¡¡CONFIGURACIÓN CRÍTICA DE LA URL BASE!!! ---
    const String backendHost = "localhost"; // Para web/iOS sim. Cambiar por IP para dispositivo físico.
    const String backendPort = "3000";    // Puerto de tu backend Node.js
    const String apiPrefix = "/api";      // Prefijo de tu API si lo usas (ej. /api)

    if (Platform.isAndroid) {
      // Para emulador Android, 10.0.2.2 es el localhost de tu PC
      return 'http://10.0.2.2:$backendPort$apiPrefix';
    } else { // Para iOS simulador, web, o dispositivo físico (si configuras IP)
      // ¡PARA DISPOSITIVO FÍSICO, REEMPLAZA backendHost CON LA IP DE TU PC EN LA RED LOCAL!
      // Ejemplo: return 'http://192.168.1.100:$backendPort$apiPrefix';
      return 'http://$backendHost:$backendPort$apiPrefix';
    }
  }

  // 3. Headers comunes, usando el token almacenado si existe
  Map<String, String> get _commonHeaders => {
        'Content-Type': 'application/json; charset=UTF-8',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // --- MÉTODOS ESPECÍFICOS PARA EL ENDPOINT DE RESERVAS ---
  // AJUSTA "/reservations" SI TU ENDPOINT ES DIFERENTE

  // GET /api/reservations - Obtener todas las reservas
  Future<List<Reserva>> fetchReservations() async {
    final Uri url = Uri.parse('$_baseUrl/reservations');
    print('ApiService: GET $url');

    try {
      final response = await http.get(url, headers: _commonHeaders);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('ApiService: Fetched ${jsonData.length} reservations.');
        return jsonData
            .map((item) => Reserva.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        print('ApiService Error (fetchReservations): ${response.statusCode} - ${response.body}');
        throw Exception('Fallo al cargar reservaciones (Código: ${response.statusCode})\n${response.body}');
      }
    } catch (e) {
      print('ApiService Exception (fetchReservations): $e');
      throw Exception('Error de conexión al obtener reservaciones: $e');
    }
  }

  // POST /api/reservations - Crear una nueva reserva
  Future<Reserva> createReservation(Reserva reservationData) async {
    final Uri url = Uri.parse('$_baseUrl/reservations');
    final String requestBody = jsonEncode(reservationData.toJson());
    print('ApiService: POST $url with body: $requestBody');

    try {
      final response = await http.post(
        url,
        headers: _commonHeaders,
        body: requestBody,
      );

      if (response.statusCode == 201 || response.statusCode == 200) { // 201 es 'Created'
        print('ApiService: Reservation created successfully. Response: ${response.body}');
        return Reserva.fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        print('ApiService Error (createReservation): ${response.statusCode} - ${response.body}');
        throw Exception('Fallo al crear la reservación (Código: ${response.statusCode})\n${response.body}');
      }
    } catch (e) {
      print('ApiService Exception (createReservation): $e');
      throw Exception('Error de conexión al crear reservación: $e');
    }
  }

  // GET /api/reservations/:id - Obtener una reserva específica por ID
  Future<Reserva> fetchReservationById(String reservationId) async {
    final Uri url = Uri.parse('$_baseUrl/reservations/$reservationId');
    print('ApiService: GET $url');

    try {
      final response = await http.get(url, headers: _commonHeaders);

      if (response.statusCode == 200) {
        print('ApiService: Fetched reservation $reservationId. Response: ${response.body}');
        return Reserva.fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        print('ApiService Error (fetchReservationById): ${response.statusCode} - ${response.body}');
        throw Exception('Fallo al cargar reservación $reservationId (Código: ${response.statusCode})\n${response.body}');
      }
    } catch (e) {
      print('ApiService Exception (fetchReservationById): $e');
      throw Exception('Error de conexión al obtener reservación $reservationId: $e');
    }
  }

  // PUT /api/reservations/:id - Actualizar una reserva existente
  Future<Reserva> updateReservation(String reservationId, Reserva reservationData) async {
    final Uri url = Uri.parse('$_baseUrl/reservations/$reservationId');
    final String requestBody = jsonEncode(reservationData.toJson());
    print('ApiService: PUT $url with body: $requestBody');

    try {
      final response = await http.put(
        url,
        headers: _commonHeaders,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        print('ApiService: Reservation $reservationId updated. Response: ${response.body}');
        return Reserva.fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        print('ApiService Error (updateReservation): ${response.statusCode} - ${response.body}');
        throw Exception('Fallo al actualizar reservación $reservationId (Código: ${response.statusCode})\n${response.body}');
      }
    } catch (e) {
      print('ApiService Exception (updateReservation): $e');
      throw Exception('Error de conexión al actualizar reservación $reservationId: $e');
    }
  }

  // DELETE /api/reservations/:id - Eliminar una reserva
  Future<void> deleteReservation(String reservationId) async {
    final Uri url = Uri.parse('$_baseUrl/reservations/$reservationId');
    print('ApiService: DELETE $url');

    try {
      final response = await http.delete(url, headers: _commonHeaders);

      if (response.statusCode == 200 || response.statusCode == 204) { // 204 es 'No Content'
        print('ApiService: Reservation $reservationId deleted successfully.');
      } else {
        print('ApiService Error (deleteReservation): ${response.statusCode} - ${response.body}');
        throw Exception('Fallo al eliminar reservación $reservationId (Código: ${response.statusCode})\n${response.body}');
      }
    } catch (e) {
      print('ApiService Exception (deleteReservation): $e');
      throw Exception('Error de conexión al eliminar reservación $reservationId: $e');
    }
  }
}