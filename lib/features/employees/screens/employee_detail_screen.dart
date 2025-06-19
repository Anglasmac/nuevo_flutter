// lib/features/employees/screens/employee_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_proyecto_flutter/features/employees/services/employee_service.dart';
import 'package:nuevo_proyecto_flutter/features/employees/models/employee_performance_model.dart';
import 'package:nuevo_proyecto_flutter/features/production/models/production_order_model.dart';
import 'package:nuevo_proyecto_flutter/features/production/screens/production_order_detail_screen.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final EmployeePerformance employee;
  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> with TickerProviderStateMixin {
  final EmployeeService _employeeService = EmployeeService();
  late Future<Map<String, List<ProductionOrder>>> _ordersFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ordersFuture = _loadOrders();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, List<ProductionOrder>>> _loadOrders() async {
    try {
      final employeeId = widget.employee.idEmployee;
      if (employeeId == null) throw Exception("El ID del empleado es nulo.");
      
      final results = await Future.wait([
        _employeeService.fetchOrdersForEmployee(employeeId, statuses: ['IN_PROGRESS', 'PAUSED']),
        _employeeService.fetchOrdersForEmployee(employeeId, statuses: ['COMPLETED']),
      ]);
      
      return {'inProgress': results[0], 'completed': results[1]};
    } catch (e) {
      // Usar print en desarrollo está bien, pero considera un logger para producción.
      // ignore: avoid_print
      print("Error en _loadOrders: $e");
      rethrow;
    }
  }

  void _refreshOrders() {
    if (mounted) {
      setState(() {
        _ordersFuture = _loadOrders();
      });
    }
  }

  // --- CAMBIO #2: Creamos una función para manejar la navegación y el refresco ---
  void _navigateToDetail(ProductionOrder order) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductionOrderDetailScreen(
          orderId: order.idProductionOrder,
          // --- CAMBIO #1: Añadimos el parámetro requerido 'isKitchenStaff' ---
          // TODO: Reemplaza 'true' con la lógica real de tu app para saber
          // si el USUARIO ACTUAL (no el empleado del detalle) tiene permisos.
          // Por ejemplo: authService.currentUser.role == 'kitchen_staff'
          isKitchenStaff: true,
        ),
      ),
    );

    // Si la pantalla de detalle devolvió 'true', significa que hubo un cambio.
    if (result == true && mounted) {
      _refreshOrders();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee.fullName ?? 'Detalle de Empleado'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: 'EN PROCESO'),
            Tab(text: 'TERMINADAS'),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, List<ProductionOrder>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildErrorWidget();
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No se encontraron datos de órdenes."));
          }

          final inProgressOrders = snapshot.data!['inProgress'] ?? [];
          final completedOrders = snapshot.data!['completed'] ?? [];

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(context, inProgressOrders, 'No hay órdenes en proceso.'),
              _buildOrderList(context, completedOrders, 'No hay órdenes terminadas.'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<ProductionOrder> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(emptyMessage, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            ],
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async => _refreshOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderDetailCard(context, order);
        },
      ),
    );
  }

  Widget _buildOrderDetailCard(BuildContext context, ProductionOrder order) {
    final theme = Theme.of(context);
    final (statusText, statusColor) = _getStatusInfo(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Usamos la nueva función de navegación
        onTap: () => _navigateToDetail(order),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.productNameSnapshot ?? 'Producto no especificado',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12)),
                    backgroundColor: statusColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn('ID Orden', '#${order.idProductionOrder}'),
                  _buildInfoColumn('Creada', order.createdAt != null ? DateFormat('dd/MM/yyyy').format(order.createdAt!) : 'N/A'),
                  _buildInfoColumn('Cantidad', '${order.initialAmount ?? 'N/A'} u.'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  (String, Color) _getStatusInfo(String? status) {
    switch (status) {
      case 'IN_PROGRESS': return ('En Proceso', Colors.orange.shade700);
      case 'PAUSED': return ('En Pausa', Colors.blueGrey);
      case 'COMPLETED': return ('Completada', Colors.green.shade700);
      default: return ('Desconocido', Colors.grey);
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text('Ocurrió un error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'No se pudieron cargar las órdenes. Por favor, verifica tu conexión e intenta de nuevo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              onPressed: _refreshOrders,
            )
          ],
        ),
      ),
    );
  }
}