import 'dart:convert';
import 'package:flutter/material.dart';

// --- FUNCIONES HELPER ---
List<Reserva> reservaFromJson(String str) => List<Reserva>.from(json.decode(str).map((x) => Reserva.fromJson(x)));
String reservaToJson(Reserva data) => json.encode(data.toJson());

/// ✅ NUEVA CLASE PARA REPRESENTAR UN ABONO O PAGO PARCIAL.
class Abono {
  final DateTime fecha;
  final double monto;

  Abono({required this.fecha, required this.monto});

  // Convierte un JSON de la API a un objeto Abono.
  factory Abono.fromJson(Map<String, dynamic> json) => Abono(
    fecha: DateTime.parse(json["fecha"]),
    monto: (json["monto"] as num).toDouble(),
  );

  // Convierte el objeto Abono a un JSON para enviar a la API.
  Map<String, dynamic> toJson() => {
    "fecha": fecha.toIso8601String(),
    "cantidad": monto,
  };
}


/// ✅ MODELO DE DATOS DEFINITIVO PARA UNA RESERVA
///
/// Esta clase combina la estructura completa de la API, incluyendo los abonos,
/// con la lógica de UI y compatibilidad que ya tenías implementada.
class Reserva {
  // --- PROPIEDADES ALINEADAS CON LA API (CAMPOS REQUERIDOS) ---
  final int? idReservations; // Nullable para la creación
  final DateTime dateTime;
  final int numberPeople;
  final String matter;
  final String timeDurationR;
  final List<dynamic> pass; // Representa los servicios adicionales seleccionados
  final double decorationAmount;
  final double remaining;
  final String evenType;
  final double totalPay;
  final String status;
  final int idCustomers;
  
  // ✅ NUEVA PROPIEDAD: Lista de abonos
  final List<Abono> abonos;

  // --- PROPIEDADES ADICIONALES/OPCIONALES DE TU MODELO ORIGINAL ---
  final String? location;
  final String? notes;

  // --- PROPIEDAD SOLO PARA LA UI ---
  final Color color;
  
  // --- GETTERS DE COMPATIBILIDAD (PARA QUE EL CÓDIGO ANTIGUO NO SE ROMPA) ---
  DateTime get eventDateTime => dateTime;
  String get eventName => matter;

  // --- CONSTRUCTOR ---
  Reserva({
    // Campos de la API
    this.idReservations,
    required this.dateTime,
    required this.numberPeople,
    required this.matter,
    required this.timeDurationR,
    required this.pass,
    required this.decorationAmount,
    required this.remaining,
    required this.evenType,
    required this.totalPay,
    required this.status,
    required this.idCustomers,
    // ✅ NUEVO PARÁMETRO CON VALOR POR DEFECTO
    this.abonos = const [], 
    // Campos de UI
    this.location,
    this.notes,
    this.color = Colors.blue,
  });


  // --- MÉTODO `fromJson` (De JSON de la API a Objeto Dart) ---
  // En tu archivo lib/features/reservas/models/reserva_model.dart

factory Reserva.fromJson(Map<String, dynamic> json) {
  // ✅ LÓGICA DE PARSEO ROBUSTA PARA ABONOS
  List<Abono> parsedAbonos = [];
  final abonosData = json['abonos'] ?? json['pass']; // Busca en 'abonos' o 'pass'

  if (abonosData != null) {
    // Si los datos son un String, lo decodificamos primero
    if (abonosData is String) {
      try {
        final List<dynamic> decodedList = jsonDecode(abonosData);
        parsedAbonos = decodedList.map((item) => Abono.fromJson(item)).toList();
      } catch (e) {
        print("Error decodificando el string de abonos: $e");
      }
    } 
    // Si ya es una lista (el formato correcto), la procesamos directamente
    else if (abonosData is List) {
      parsedAbonos = abonosData.map((item) => Abono.fromJson(item)).toList();
    }
  }

  return Reserva(
    idReservations: json["idReservations"],
    dateTime: DateTime.parse(json["dateTime"]),
    numberPeople: json["numberPeople"],
    matter: json["matter"],
    timeDurationR: json["timeDurationR"],
    pass: json["pass"] != null && json["pass"] is List ? List<dynamic>.from(json["pass"].map((x) => x)) : [],
    decorationAmount: (json["decorationAmount"] as num).toDouble(),
    remaining: (json["remaining"] as num).toDouble(),
    evenType: json["evenType"],
    totalPay: (json["totalPay"] as num).toDouble(),
    status: json["status"],
    idCustomers: json["idCustomers"],
    // Usamos la lista de abonos que hemos parseado de forma segura
    abonos: parsedAbonos, 
    location: json['location'],
    notes: json['notes'],
    color: _getColorFromJson(json), 
  );
}
  /// Método helper privado para determinar el color (tu lógica original).
  static Color _getColorFromJson(Map<String, dynamic> json) {
    final idString = json['idReservations']?.toString();
    if (idString != null) {
      final List<Color> defaultColors = [
        Colors.blue.shade300,
        Colors.red.shade300,
        Colors.green.shade300,
        Colors.orange.shade300,
        Colors.purple.shade300,
        Colors.teal.shade300,
      ];
      return defaultColors[idString.hashCode % defaultColors.length];
    }
    return Colors.blueGrey;
  }

  
 // ✅ MÉTODO toJson() DEFINITIVO PARA TU BACKEND
Map<String, dynamic> toJson() {
  return {
    // Campos que ya estaban bien
    "dateTime": dateTime.toIso8601String(),
    "numberPeople": numberPeople,
    "matter": matter,
    "timeDurationR": timeDurationR,
    "decorationAmount": decorationAmount,
    "remaining": remaining,
    "evenType": evenType,
    "totalPay": totalPay,
    "status": status,
    "idCustomers": idCustomers,
    if (notes != null) "notes": notes,
    // La propiedad 'location' no la estamos usando en el form, la puedes omitir o dejar
    if (location != null) "location": location,

    // ✅ CORRECCIÓN FINAL:
    // Enviamos la lista de objetos de abono bajo la clave 'pass',
    // que es lo que el backend está esperando validar.
    "pass": abonos.map((abono) => abono.toJson()).toList(),
  };
}
}