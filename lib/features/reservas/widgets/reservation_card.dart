// lib/features/reservas/widgets/reservation_card.dart (EXTRAÍDO y MEJORADO)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas y horas
import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart'; // <- Reemplaza

// Widget reutilizable para mostrar una tarjeta de reserva
class ReservationCard extends StatelessWidget {
  final Reserva reserva; // Recibe el modelo de Reserva
  final VoidCallback? onTap; // Callback para cuando se toca la tarjeta

  const ReservationCard({
    required this.reserva,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Formateadores para fecha y hora (requiere paquete intl)
    final timeFormatter = DateFormat.jm(Localizations.localeOf(context).toString()); // Formato hora local (ej: 2:30 PM)
    final dateFormatter = DateFormat.yMMMd(Localizations.localeOf(context).toString()); // Formato fecha local (ej: Aug 3, 2022)


    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0), // Margen exterior
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell( // Hacerla clickeable
        onTap: onTap, // Llama al callback proporcionado
        borderRadius: BorderRadius.circular(12.0), // Borde para el InkWell
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Alinea arriba
            children: [
              // Indicador de color del evento
              Container(
                 width: 8,
                 height: 60, // Altura aproximada del contenido
                 decoration: BoxDecoration(
                    color: reserva.color, // Usa el color de la reserva
                    borderRadius: BorderRadius.circular(4.0),
                 ),
              ),
              const SizedBox(width: 16.0),

              // Información de la reserva
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reserva.eventName, // Nombre del evento
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    // Fila con Hora y Fecha
                    Row(
                      children: [
                        // Chip para la Hora
                        Chip(
                           avatar: Icon(Icons.access_time_outlined, size: 16, color: Colors.white.withOpacity(0.9)),
                           label: Text(
                             timeFormatter.format(reserva.eventDateTime),
                             style: textTheme.labelSmall?.copyWith(color: Colors.white),
                           ),
                            backgroundColor: reserva.color.withOpacity(0.9), // Color del evento
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            visualDensity: VisualDensity.compact,
                         ),
                        const SizedBox(width: 12.0),
                        // Texto para la Fecha
                        Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4.0),
                        Text(
                           dateFormatter.format(reserva.eventDateTime), // Fecha formateada
                           style: textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                     // Opcional: Mostrar ubicación
                      if (reserva.location != 'No especificada') ...[
                         const SizedBox(height: 6.0),
                         Row(
                            children: [
                               Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                               const SizedBox(width: 4.0),
                               Expanded(
                                 child: Text(
                                     reserva.location,
                                     style: textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                                     overflow: TextOverflow.ellipsis,
                                 ),
                               ),
                            ],
                         ),
                      ]
                  ],
                ),
              ),
              const SizedBox(width: 16.0),

              // Icono o Imagen representativa (Placeholder)
              // Podría ser una imagen subida por el usuario o un icono según el tipo de evento
              Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                   // Podrías intentar cargar una imagen aquí si la tienes
                   // image: DecorationImage(image: NetworkImage(reserva.imageUrl), fit: BoxFit.cover)
                ),
                child: Icon(
                  Icons.event_note_outlined, // Icono genérico de evento
                  color: Colors.grey[600],
                  size: 28.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}