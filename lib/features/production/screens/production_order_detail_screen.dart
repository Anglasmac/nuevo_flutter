// lib/features/production/screens/production_order_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_proyecto_flutter/features/production/models/production_order_model.dart';
import 'package:nuevo_proyecto_flutter/services/production_order_service.dart';

class ProductionOrderDetailScreen extends StatefulWidget {
  final int orderId;
  // --- CAMBIO 1: Añadimos un flag para saber si el usuario es de cocina ---
  final bool isKitchenStaff;

  const ProductionOrderDetailScreen({
    super.key,
    required this.orderId,
    required this.isKitchenStaff, // <-- Requerimos el nuevo parámetro
  });

  @override
  State<ProductionOrderDetailScreen> createState() =>
      _ProductionOrderDetailScreenState();
}

class _ProductionOrderDetailScreenState extends State<ProductionOrderDetailScreen> {
  final ProductionOrderService _productionService = ProductionOrderService();
  late Future<ProductionOrder> _orderFuture;
  bool _isUpdating = false;
  bool _hasChanged = false; // Este flag nos dirá si debemos refrescar la lista anterior

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  void _loadOrderDetails() {
    if (mounted) {
      setState(() {
        _orderFuture = _productionService.fetchProductionOrderById(widget.orderId);
      });
    }
  }

  Future<void> _updateOrderStatus(String newStatus, {String? observation}) async {
    setState(() { _isUpdating = true; });

    try {
      await _productionService.updateOrderStatus(widget.orderId, newStatus, observation: observation);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Orden actualizada a: ${getStatusInfo(newStatus).$1}'),
          backgroundColor: Colors.green,
        ),
      );
      _hasChanged = true; // Marcamos que hubo un cambio
      _loadOrderDetails(); // Recargamos para ver el estado nuevo

      if (newStatus == 'CANCELLED') {
        // Al cancelar, volvemos a la pantalla anterior y le decimos que hubo cambios (true)
        Navigator.pop(context, true);
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() { _isUpdating = false; });
      }
    }
  }

  // ... (los métodos _showCancelDialog y _showConfirmationDialog no cambian)
  void _showCancelDialog() {
    final observationController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar Orden de Producción'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('¿Está seguro de que desea cancelar esta orden? Esta acción no se puede deshacer.'),
                const SizedBox(height: 16),
                TextField(
                  controller: observationController,
                  decoration: const InputDecoration(
                    labelText: 'Motivo de la cancelación (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Volver'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Confirmar Cancelación', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                _updateOrderStatus('CANCELLED', observation: observationController.text);
              },
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(String title, String content, String newStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop();
                _updateOrderStatus(newStatus);
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // --- CAMBIO 2: Eliminamos el PopScope problemático ---
    // En su lugar, controlamos el botón de retroceso en la AppBar.
    return Scaffold(
      appBar: AppBar(
        // --- CAMBIO 3: Añadimos un botón de retroceso manual ---
        // Esto nos da control para pasar el resultado `_hasChanged` a la pantalla anterior.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _hasChanged),
        ),
        title: Text('Detalle Orden #${widget.orderId}'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: Stack(
        children: [
          FutureBuilder<ProductionOrder>(
            future: _orderFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('No se encontraron datos.'));
              }

              final order = snapshot.data!;
              return _buildOrderDetailContent(context, order);
            },
          ),
          if (_isUpdating)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // ... (El resto de los widgets _build... no cambian, excepto _buildActionButtons)
  Widget _buildOrderDetailContent(BuildContext context, ProductionOrder order) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSummaryCard(context, order),
              const SizedBox(height: 16),
              if (order.steps.isNotEmpty)
                _buildStepsCard(context, order),
              const SizedBox(height: 16),
              _buildPlanVsResultCard(context, order),
              const SizedBox(height: 16),
              _buildTimelineCard(context, order),
            ],
          ),
        ),
        _buildActionButtons(context, order),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, ProductionOrder order) {
    final (statusText, statusColor, statusIcon) = getStatusInfo(order.status);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.productNameSnapshot ?? 'Producto Desconocido',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Chip(
              avatar: Icon(statusIcon, color: Colors.white, size: 16),
              label: Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: statusColor,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              icon: Icons.person_pin_outlined,
              title: 'Registrada por',
              content: order.employeeFullName,
            ),
            if (order.nameClient != null && order.nameClient!.isNotEmpty)
              _buildDetailRow(
                context,
                icon: Icons.business_center_outlined,
                title: 'Cliente',
                content: order.nameClient,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsCard(BuildContext context, ProductionOrder order) {
    final currentStepIndex = order.steps.indexWhere((step) => step.status == 'IN_PROGRESS');
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Pasos de Producción'),
            const SizedBox(height: 12),
            ...List.generate(order.steps.length, (index) {
              final step = order.steps[index];
              return _buildStepTile(
                context,
                step,
                isCurrent: index == currentStepIndex,
                isCompleted: step.status == 'COMPLETED',
                isFirst: index == 0,
                isLast: index == order.steps.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStepTile(BuildContext context, ProductionStep step, {required bool isCurrent, required bool isCompleted, required bool isFirst, required bool isLast}) {
    IconData icon;
    Color color;

    if (isCurrent) {
      icon = Icons.sync;
      color = Colors.orange;
    } else if (isCompleted) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else {
      icon = Icons.circle_outlined;
      color = Colors.grey.shade400;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isFirst) Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
              Icon(icon, color: color, size: 28),
              if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${step.processOrder}. ${step.processName}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCurrent ? color : (isCompleted ? Colors.black87 : Colors.grey[700]),
                    ),
                  ),
                  if (step.employeeFullName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Por: ${step.employeeFullName}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanVsResultCard(BuildContext context, ProductionOrder order) {
     return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Plan vs. Resultado'),
            const SizedBox(height: 16),
            _buildComparisonRow(context, 'Cantidad (Unidades)', '${order.initialAmount ?? 'N/A'}', '${order.finalQuantityProduct ?? 'N/A'}'),
            const SizedBox(height: 12),
            _buildComparisonRow(context, 'Peso Producido', '${order.inputInitialWeight ?? 'N/A'} ${order.inputInitialWeightUnit ?? ''}', '${order.finishedProductWeight ?? 'N/A'} ${order.finishedProductWeightUnit ?? ''}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, ProductionOrder order) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Línea de Tiempo'),
            const SizedBox(height: 16),
            _buildDetailRow(context, icon: Icons.calendar_today_outlined, title: 'Creación', content: order.createdAt != null ? dateFormat.format(order.createdAt!) : 'N/A'),
            _buildDetailRow(context, icon: Icons.event_available_outlined, title: 'Finalización', content: order.completedAt != null ? dateFormat.format(order.completedAt!) : 'N/A'),
            if (order.observations != null && order.observations!.isNotEmpty) ...[
              const Divider(height: 24),
              _buildSectionHeader(context, 'Observaciones'),
              const SizedBox(height: 8),
              Text(order.observations!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
            ]
          ],
        ),
      ),
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

  Widget _buildComparisonRow(BuildContext context, String title, String planned, String actual) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildInfoBox(context, 'Planificado', planned, Colors.blueGrey)),
            const SizedBox(width: 12),
            Expanded(child: _buildInfoBox(context, 'Real Obtenido', actual, Colors.teal)),
          ],
        )
      ],
    );
  }

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
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
      ),
    );
  }
  
  (String, Color, IconData) getStatusInfo(String? status) {
    switch (status) {
      case 'IN_PROGRESS': return ('En Proceso', Colors.orange, Icons.sync);
      case 'PAUSED': return ('En Pausa', Colors.blueGrey, Icons.pause_circle_outline);
      case 'PENDING': return ('Pendiente', Colors.blue.shade700, Icons.pending_actions_outlined);
      case 'COMPLETED': return ('Completada', Colors.green.shade700, Icons.check_circle_outline);
      case 'CANCELLED': return ('Cancelada', Colors.red.shade700, Icons.cancel_outlined);
      default: return ('Desconocido', Colors.grey, Icons.help_outline);
    }
  }

  Widget _buildActionButtons(BuildContext context, ProductionOrder order) {
    List<Widget> buttons = [];
    bool canCancel = order.status == 'PENDING' || order.status == 'IN_PROGRESS' || order.status == 'PAUSED';

    switch (order.status) {
      case 'PENDING':
        buttons.add(_actionButton(context, label: 'Iniciar Producción', icon: Icons.play_circle_outline, onPressed: () => _showConfirmationDialog('Iniciar Producción', '¿Desea iniciar la producción de esta orden?', 'IN_PROGRESS'), color: Colors.green, isPrimary: true));
        break;
      case 'IN_PROGRESS':
        buttons.add(_actionButton(context, label: 'Pausar', icon: Icons.pause_circle_outline, onPressed: () => _showConfirmationDialog('Pausar Orden', '¿Desea poner en pausa esta orden?', 'PAUSED'), color: Colors.blueGrey));
        
        // --- CAMBIO 4: Condicionamos la aparición del botón "Completar" ---
        // Solo se muestra si el usuario tiene el permiso.
        if (widget.isKitchenStaff) {
          buttons.add(const SizedBox(width: 12));
          buttons.add(_actionButton(context, label: 'Completar', icon: Icons.check_circle_outline, onPressed: () => _showConfirmationDialog('Completar Orden', '¿Confirma que la producción ha finalizado?', 'COMPLETED'), color: Colors.green, isPrimary: true));
        }
        break;
      case 'PAUSED':
        buttons.add(_actionButton(context, label: 'Reanudar', icon: Icons.play_circle_outline, onPressed: () => _showConfirmationDialog('Reanudar Producción', '¿Desea continuar con esta orden?', 'IN_PROGRESS'), color: Colors.orange, isPrimary: true));
        break;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -5))],
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: Row(
        children: [
          if (buttons.isNotEmpty) Expanded(child: Row(children: buttons)),
          if (canCancel) ...[
            if (buttons.isNotEmpty) const SizedBox(width: 12),
            IconButton(
              icon: Icon(Icons.cancel_outlined, color: Colors.red.shade700),
              onPressed: _isUpdating ? null : _showCancelDialog,
              tooltip: 'Cancelar Orden',
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onPressed, required Color color, bool isPrimary = false}) {
    return Expanded(
      child: isPrimary
          ? ElevatedButton.icon(
              icon: Icon(icon),
              label: Text(label),
              onPressed: _isUpdating ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          : OutlinedButton.icon(
              icon: Icon(icon),
              label: Text(label),
              onPressed: _isUpdating ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                foregroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
    );
  }
}