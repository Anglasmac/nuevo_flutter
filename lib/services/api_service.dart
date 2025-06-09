// lib/services/api_service.dart

// <-- 1. AÑADIDO: Import para detectar la plataforma web.
import 'package:flutter/foundation.dart' show kIsWeb; 

import 'dart:convert';
import 'dart:io'; // Se mantiene, pero se usará de forma segura.
import 'package:http/http.dart' as http;
import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart';

class ApiService {
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  // <-- 2. CORREGIDO: Toda la lógica de la URL base ha sido reemplazada.
  String get _baseUrl {
    const String backendHost = "localhost";
    const String backendPort = "3000";
    const String apiPrefix = ""; // <-- CAMBIA ESTO

    // Primero, verificamos si estamos en un entorno web.
    if (kIsWeb) {
      // Si es web, siempre usamos localhost. El navegador se encarga del resto.
      return 'http://$backendHost:$backendPort$apiPrefix';
    } else {
      // Si NO es web, estamos en una plataforma nativa (móvil/escritorio).
      // Aquí sí es SEGURO usar Platform.
      if (Platform.isAndroid) {
        // Para el emulador de Android, usa la IP especial 10.0.2.2.
        return 'http://10.0.2.2:$backendPort$apiPrefix';
      } else {
        // Para el simulador de iOS o escritorio, localhost funciona.
        // NOTA: Para un dispositivo físico real (iPhone/Android),
        // DEBES reemplazar 'localhost' con la IP de tu PC en la red WiFi.
        // Ejemplo: 'http://192.168.1.105:$backendPort$apiPrefix'
        return 'http://$backendHost:$backendPort$apiPrefix';
      }
    }
  }

  Map<String, String> get _commonHeaders => {
        'Content-Type': 'application/json; charset=UTF-8',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // --- MÉTODOS ESPECÍFICOS PARA EL ENDPOINT DE RESERVAS ---
  // (El resto del archivo no necesita cambios)

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

  Future<void> deleteReservation(String reservationId) async {
    final Uri url = Uri.parse('$_baseUrl/reservations/$reservationId');
    print('ApiService: DELETE $url');

    try {
      final response = await http.delete(url, headers: _commonHeaders);

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