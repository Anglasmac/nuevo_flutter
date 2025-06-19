// lib/features/production/screens/order_production_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_proyecto_flutter/features/production/models/production_order_model.dart';
import 'package:nuevo_proyecto_flutter/features/production/screens/production_order_detail_screen.dart';
import 'package:nuevo_proyecto_flutter/services/production_order_service.dart';

class OrderProductionScreen extends StatefulWidget {
  const OrderProductionScreen({super.key});

  @override
  State<OrderProductionScreen> createState() => _OrderProductionScreenState();
}

class _OrderProductionScreenState extends State<OrderProductionScreen> {
  final ProductionOrderService _productionService = ProductionOrderService();
  late Future<List<ProductionOrder>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    if (mounted) {
      setState(() {
        _ordersFuture = _productionService.fetchProductionOrders(
            statuses: ['PENDING', 'IN_PROGRESS', 'PAUSED']);
      });
    }
  }

  void _navigateToDetail(ProductionOrder order) async {
    // --- ÚNICO CAMBIO EN ESTE ARCHIVO ---
    // Ahora pasamos el flag `isKitchenStaff` al detalle.
    // Deberás reemplazar `true` con tu lógica real para verificar el rol del usuario.
    // Por ejemplo: `isKitchenStaff: authService.currentUser.role == 'kitchen'`
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductionOrderDetailScreen(
          orderId: order.idProductionOrder,
          isKitchenStaff: true, // <-- TODO: Reemplaza esto con tu lógica de roles
        ),
      ),
    );
    
    // Si la pantalla de detalle devuelve 'true', significa que hubo un cambio y refrescamos.
    if (result == true && mounted) {
      _loadOrders();
    }
  }

  // ... (el resto del archivo no cambia)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes de Producción'),
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadOrders(),
        child: FutureBuilder<List<ProductionOrder>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error);
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyStateWidget();
            }

            final orders = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(context, orders[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, ProductionOrder order) {
    final theme = Theme.of(context);
    final (statusText, statusColor, statusIcon) = _getStatusInfo(order.status);
    
    final double progress = (order.inputInitialWeight != null && order.inputInitialWeight! > 0 && order.finishedProductWeight != null)
        ? (order.finishedProductWeight! / order.inputInitialWeight!)
        : 0.0;
        
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToDetail(order),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.productNameSnapshot ?? 'Producto Desconocido',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Orden #${order.idProductionOrder}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    avatar: Icon(statusIcon, color: Colors.white, size: 16),
                    label: Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    backgroundColor: statusColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  )
                ],
              ),
              const SizedBox(height: 16),
              if (order.status == 'IN_PROGRESS')
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: statusColor.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(context, Icons.scale_outlined, 'Plan', '${order.initialAmount ?? 'N/A'} u.'),
                  _buildStatItem(context, Icons.person_outline, 'Asignado a', order.employeeFullName ?? 'N/A', flex: 2),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
                Text(
                  value, 
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData) _getStatusInfo(String? status) {
    switch (status) {
      case 'IN_PROGRESS': return ('En Proceso', Colors.orange, Icons.sync);
      case 'PAUSED': return ('En Pausa', Colors.blueGrey, Icons.pause_circle_outline);
      case 'PENDING': return ('Pendiente', Colors.blue.shade700, Icons.pending_actions_outlined);
      case 'COMPLETED': return ('Completada', Colors.green.shade700, Icons.check_circle_outline);
      case 'CANCELLED': return ('Cancelada', Colors.red.shade700, Icons.cancel_outlined);
      default: return ('Desconocido', Colors.grey, Icons.help_outline);
    }
  }

  Widget _buildEmptyStateWidget() {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('No hay órdenes activas', style: TextStyle(fontSize: 18, color: Colors.grey)),
                Text('Todas las órdenes están al día o no hay pendientes.', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildErrorWidget(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text('Error al cargar órdenes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('No se pudieron cargar los datos. Revisa la conexión.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              onPressed: _loadOrders,
            )
          ],
        ),
      ),
    );
  }
}