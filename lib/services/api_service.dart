// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart';
import 'package:nuevo_proyecto_flutter/services/ase_api_service.dart';

// <-- REFACTORIZACIÓN: ApiService ahora extiende BaseApiService.
// Hereda automáticamente `baseUrl`, `commonHeaders` y la gestión del token.
class ApiService extends BaseApiService {
  
  // --- MÉTODOS ESPECÍFICOS PARA EL ENDPOINT DE RESERVAS (/reservations) ---

  Future<List<Reserva>> fetchReservations() async {
    final Uri url = Uri.parse('$baseUrl/reservations');
    print('ApiService: GET $url');

    try {
      final response = await http.get(url, headers: commonHeaders);

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

  Future<Reserva> createReservation(Reserva reservationData) async {
    final Uri url = Uri.parse('$baseUrl/reservations');
    final String requestBody = jsonEncode(reservationData.toJson());
    print('ApiService: POST $url with body: $requestBody');

    try {
      final response = await http.post(
        url,
        headers: commonHeaders,
        body: requestBody,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
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

  Future<Reserva> fetchReservationById(String reservationId) async {
    final Uri url = Uri.parse('$baseUrl/reservations/$reservationId');
    print('ApiService: GET $url');

    try {
      final response = await http.get(url, headers: commonHeaders);

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

  Future<Reserva> updateReservation(String reservationId, Reserva reservationData) async {
    final Uri url = Uri.parse('$baseUrl/reservations/$reservationId');
    final String requestBody = jsonEncode(reservationData.toJson());
    print('ApiService: PUT $url with body: $requestBody');

    try {
      final response = await http.put(
        url,
        headers: commonHeaders,
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

  Future<void> deleteReservation(String reservationId) async {
    final Uri url = Uri.parse('$baseUrl/reservations/$reservationId');
    print('ApiService: DELETE $url');

    try {
      final response = await http.delete(url, headers: commonHeaders);

      if (response.statusCode == 200 || response.statusCode == 204) {
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