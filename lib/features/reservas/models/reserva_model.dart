import 'package:flutter/material.dart'; // Para Color

class Reserva {
  final String id;
  final String eventName;
  final DateTime eventDateTime;
  final String location; // Ejemplo: Añadir ubicación
  final String notes;    // Ejemplo: Notas
  final Color color;     // Ejemplo: Color para el evento

  Reserva({
    required this.id,
    required this.eventName,
    required this.eventDateTime,
    this.location = 'No especificada',
    this.notes = '',
    this.color = Colors.blue, // Color por defecto
  });

  // Métodos fromMap/toMap si interactúas con JSON/DB
}