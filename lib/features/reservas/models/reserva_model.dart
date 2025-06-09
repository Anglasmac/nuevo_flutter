import 'package:flutter/material.dart';

/// Modelo de datos para una Reserva.
///
/// Esta clase representa una reserva en la aplicación, incluyendo sus propiedades
/// y los métodos para serializar/deserializar desde/hacia JSON.
class Reserva {
  // --- PROPIEDADES PRINCIPALES ---

  /// ID único de la reserva, generado por el backend. Es nullable porque
  /// al crear una nueva reserva, aún no tenemos ID.
  final String? id;

  /// Nombre del evento o cliente asociado a la reserva.
  final String eventName;

  /// **Fecha y hora de la reserva. Este es el campo unificado y correcto.**
  final DateTime reservationDate;

  /// Ubicación de la reserva (opcional).
  final String? location;

  /// Notas adicionales sobre la reserva (opcional).
  final String? notes;

  /// Color para la UI. No se envía al backend en este modelo.
  final Color color;

  // --- GETTER DE COMPATIBILIDAD (Solución al error actual) ---

  /// Getter para retrocompatibilidad.
  ///
  /// Cualquier parte del código que aún use `reserva.eventDateTime`
  /// será redirigida para que use el valor de `reservationDate`.
  /// Esto evita que la aplicación se rompa mientras refactorizas.
  /// **OBJETIVO: Eliminar el uso de `eventDateTime` en tu UI y luego borrar este getter.**
  DateTime get eventDateTime => reservationDate;

  // --- CONSTRUCTOR ---

  Reserva({
    this.id,
    required this.eventName,
    required this.reservationDate,
    this.location,
    this.notes,
    this.color = Colors.blue,
  });

  // --- MÉTODO `fromJson` (De JSON a Objeto Dart) ---

  /// Crea una instancia de `Reserva` a partir de un mapa JSON (respuesta de la API).
  ///
  /// Este método es robusto y busca la fecha con varias claves posibles (`reservationDate` o `eventDateTime`)
  /// para asegurar la compatibilidad con lo que envíe la API.
  factory Reserva.fromJson(Map<String, dynamic> json) {
    // 1. Validar y parsear la fecha (el campo más crítico)
    DateTime? parsedDate;
    
    // Primero, intenta buscar la clave 'reservationDate'. Si no existe, busca 'eventDateTime'.
    final dateString = json['reservationDate'] ?? json['eventDateTime'];

    if (dateString != null && dateString is String) {
      try {
        parsedDate = DateTime.parse(dateString);
      } catch (e) {
        print("Error al parsear la fecha de la reserva: '$dateString'. Error: $e");
        // Asignamos una fecha por defecto como fallback para no crashear la app.
        parsedDate = DateTime.now();
      }
    } else {
      // Si la fecha es nula o no es un String, se maneja el error.
      print("Advertencia: La fecha de la reserva es nula o inválida en el JSON. ID: ${json['id']}");
      parsedDate = DateTime.now(); // Fallback
    }

    // 2. Determinar el color para la UI
    Color parsedColor = _getColorFromJson(json);

    // 3. Crear y devolver la instancia de Reserva
    return Reserva(
      id: json['id']?.toString(),
      eventName: json['eventName'] as String? ?? 'Evento sin nombre',
      reservationDate: parsedDate, // Siempre usamos la propiedad correcta en el constructor
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      color: parsedColor,
    );
  }

  /// Método helper privado para determinar el color a partir del JSON.
  static Color _getColorFromJson(Map<String, dynamic> json) {
    // Lógica simple para asignar un color basado en el hash del ID.
    // Esto da un color consistente para la misma reserva cada vez.
    final idString = json['id']?.toString();
    if (idString != null) {
      final List<Color> defaultColors = [
        Colors.blue.shade300,
        Colors.red.shade300,
        Colors.green.shade300,
        Colors.orange.shade300,
        Colors.purple.shade300,
        Colors.teal.shade300,
        Colors.pink.shade300,
      ];
      return defaultColors[idString.hashCode % defaultColors.length];
    }
    return Colors.blueGrey; // Color por defecto si no hay ID
  }

  // --- MÉTODO `toJson` (De Objeto Dart a JSON) ---

  /// Convierte la instancia de `Reserva` a un mapa JSON para enviar a la API.
  ///
  /// Se asegura de usar la clave que el backend espera.
  Map<String, dynamic> toJson() {
    return {
      // No incluimos 'id' aquí, ya que el backend lo genera o se pasa en la URL.
      'eventName': eventName,
      // **IMPORTANTE**: Usa la clave que tu backend espera al recibir datos.
      // Si el backend espera 'reservationDate', déjalo así.
      // Si el backend espera 'eventDateTime', cambia la clave aquí abajo.
      'reservationDate': reservationDate.toIso8601String(),
      'location': location,
      'notes': notes,
      // No incluimos el color, ya que es solo para la UI.
    };
  }
}