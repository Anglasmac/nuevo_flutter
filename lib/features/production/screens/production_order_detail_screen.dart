import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_proyecto_flutter/features/production/models/production_order_model.dart';

class ProductionOrderDetailScreen extends StatelessWidget {
  final ProductionOrder order;

  const ProductionOrderDetailScreen({super.key, required this.order});

  // Helper para traducir el estado y obtener un color
  (String, Color) _getStatusInfo(String? status) {
    switch (status) {
      case 'IN_PROGRESS': return ('En Proceso', Colors.orange);
      case 'PAUSED': return ('En Pausa', Colors.blueGrey);
      case 'COMPLETED': return ('Completada', Colors.green);
      case 'CANCELLED': return ('Cancelada', Colors.red);
      default: return ('Desconocido', Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Orden #${order.idProductionOrder}'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummarySection(context, theme),
                  const Divider(height: 32),
                  _buildSectionHeader(context, 'Plan vs. Resultado'),
                  const SizedBox(height: 16),
                  _buildComparisonRow(
                    context, 
                    title: 'Cantidad (Unidades)',
                    planned: '${order.initialAmount ?? 'N/A'}', 
                    actual: '${order.finalQuantityProduct ?? 'N/A'}'
                  ),
                  const SizedBox(height: 16),
                  _buildComparisonRow(
                    context, 
                    title: 'Peso Producido',
                    planned: '${order.inputInitialWeight ?? 'N/A'} ${order.inputInitialWeightUnit ?? ''}', 
                    actual: '${order.finishedProductWeight ?? 'N/A'} ${order.finishedProductWeightUnit ?? ''}'
                  ),
                  const Divider(height: 32),
                  _buildSectionHeader(context, 'Línea de Tiempo'),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, icon: Icons.calendar_today_outlined, title: 'Fecha de Creación', content: order.createdAt != null ? dateFormat.format(order.createdAt!) : 'No disponible'),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, icon: Icons.event_available_outlined, title: 'Fecha de Finalización', content: order.completedAt != null ? dateFormat.format(order.completedAt!) : 'No finalizada'),
                  if(order.observations != null && order.observations!.isNotEmpty) ...[
                     const Divider(height: 32),
                    _buildSectionHeader(context, 'Observaciones'),
                    const SizedBox(height: 8),
                    Text(order.observations!, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[800])),
                  ]
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, ThemeData theme) {
    final (statusText, statusColor) = _getStatusInfo(order.status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.productNameSnapshot ?? 'Producto Desconocido',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'ID de la Orden: ${order.idProductionOrder}',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
         Align(
           alignment: Alignment.centerLeft,
           child: Chip(
              label: Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: statusColor,
            ),
         ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildComparisonRow(BuildContext context, {required String title, required String planned, required String actual}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              // ===== CORRECCIÓN 2: Pasamos el 'context' a la función _buildInfoBox =====
              child: _buildInfoBox(context, 'Planificado', planned, Colors.blueGrey),
            ),
            const SizedBox(width: 12),
            Expanded(
              // ===== CORRECCIÓN 2: Pasamos el 'context' a la función _buildInfoBox =====
              child: _buildInfoBox(context, 'Real Obtenido', actual, Colors.teal),
            ),
          ],
        )
      ],
    );
  }

  // ===== CORRECCIÓN 1: La función ahora necesita recibir el 'context' =====
  Widget _buildInfoBox(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String title, String? content}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
              const SizedBox(height: 2),
              Text(content ?? 'No especificado', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}