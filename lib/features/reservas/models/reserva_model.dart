// lib/features/reservas/models/reserva_model.dart
import 'package:flutter/material.dart'; // Para Color

class Reserva {
  final String? id; // Nullable si el backend lo genera al crear
  final String eventName;
  final DateTime eventDateTime;
  final String? location;
  final String? notes;
  final Color color; // Si no se guarda en backend, no incluir en toJson

  Reserva({
    this.id,
    required this.eventName,
    required this.eventDateTime,
    this.location,
    this.notes,
    this.color = Colors.blue, // Color por defecto para la UI
  });

  // Crea una instancia de Reserva desde un mapa JSON (respuesta de la API)
  factory Reserva.fromJson(Map<String, dynamic> json) {
    // Ejemplo de cómo podrías manejar el color si viniera del backend como un string hexadecimal
    Color parsedColor = Colors.blue; // Color por defecto
    if (json['colorHex'] != null && (json['colorHex'] as String).isNotEmpty) {
      try {
        // Asume formato #RRGGBB
        final hexCode = (json['colorHex'] as String).replaceAll('#', '');
        if (hexCode.length == 6) {
          parsedColor = Color(int.parse('FF$hexCode', radix: 16));
        }
      } catch (e) {
        print("Error parsing color from JSON: ${json['colorHex']}, $e");
        // Mantener el color por defecto si hay error
      }
    } else if (json['id'] != null) { // Lógica simple para asignar un color basado en ID si no viene del backend
        // Esto es solo un ejemplo para tener variedad visual, no es una práctica recomendada para producción
        final List<Color> defaultColors = [Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal];
        try {
            parsedColor = defaultColors[(int.tryParse(json['id'].toString()) ?? 0) % defaultColors.length];
        } catch(e) {
            // ignore
        }
    }


    return Reserva(
      id: json['id']?.toString(), // Asegúrate que 'id' coincida con tu JSON
      eventName: json['eventName'] as String,
      eventDateTime: DateTime.parse(json['eventDateTime'] as String), // Asume formato ISO8601
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      color: parsedColor, // Asigna el color parseado o el por defecto
      // ... parsea otros campos que tu API devuelva
    );
  }

  // Convierte una instancia de Reserva a un mapa JSON (para enviar a la API)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'eventName': eventName,
      'eventDateTime': eventDateTime.toIso8601String(),
      // No incluyas 'id' si es para crear y el backend lo genera.
      // Para actualizar, tu ApiService podría añadir el 'id' a la URL en lugar de al body,
      // o podrías incluirlo aquí si tu API lo espera en el body para PUT.
    };

    if (location != null && location!.isNotEmpty) {
      data['location'] = location;
    }
    if (notes != null && notes!.isNotEmpty) {
      data['notes'] = notes;
    }
    // Si quieres enviar el color al backend (ej. como string hexadecimal):
    // data['colorHex'] = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}'; // Formato #RRGGBB
    
    // ... añade otros campos que tu API espere para creación/actualización
    return data;
  }
}