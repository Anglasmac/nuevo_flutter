import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart';
import 'package:nuevo_proyecto_flutter/features/clientes/models/cliente_model.dart';

class ReservationCard extends StatelessWidget {
  final Reserva reserva;
  final Cliente? cliente; // ✅ NUEVO: Agregar cliente como parámetro
  final VoidCallback? onTap;
  final VoidCallback? onDelete; 

  const ReservationCard({
    required this.reserva,
    this.cliente, // ✅ NUEVO: Cliente opcional
    this.onTap,
    this.onDelete,
    super.key,
  });

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final textTheme = theme.textTheme;
  final timeFormatter = DateFormat.jm('es_ES');
  final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: 'COP ', decimalDigits: 0);

  return Card(
    elevation: 2.0,
    margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
    shape: RoundedRectangleBorder(
      side: BorderSide(color: reserva.color, width: 4),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reserva.eventName,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  // ✅ CORRECCIÓN: Mostrar nombre del cliente en lugar de email
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 6.0),
                      Flexible(
                        child: Text(
                          cliente?.fullName ?? 'Cliente no encontrado',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 6.0),
                      Text(timeFormatter.format(reserva.eventDateTime), style: textTheme.bodyMedium),
                      const SizedBox(width: 12.0),
                      Icon(Icons.people_outline, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 6.0),
                      Flexible(
                        child: Text(
                          '${reserva.numberPeople} personas',
                          style: textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.monetization_on_outlined, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 6.0),
                      Flexible(
                        child: Text(
                          'Total: ${currencyFormatter.format(reserva.totalPay)}',
                          style: textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                   const SizedBox(height: 4.0),
                  Row(
                     children: [
                      Icon(Icons.hourglass_empty_outlined, size: 16, color: Colors.orange[800]),
                      const SizedBox(width: 6.0),
                      Flexible(
                        child: Text(
                          'Resta: ${currencyFormatter.format(reserva.remaining)}',
                          style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Chip(
                  label: Text(
                    reserva.status.replaceAll('_', ' ').toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: reserva.color,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                    onPressed: onDelete,
                    tooltip: 'Eliminar Reserva',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}