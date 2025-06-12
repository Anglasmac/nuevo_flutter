import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_proyecto_flutter/features/employees/services/employee_service.dart';
import 'package:nuevo_proyecto_flutter/features/employees/models/employee_performance_model.dart';
import 'package:nuevo_proyecto_flutter/features/production/models/production_order_model.dart';
// --- INICIO: NUEVA IMPORTACIÓN ---
// Importamos la nueva pantalla de detalle de la orden.
// Asegúrate de que la ruta sea correcta.
import 'package:nuevo_proyecto_flutter/features/production/screens/production_order_detail_screen.dart';
// --- FIN: NUEVA IMPORTACIÓN ---

class EmployeeDetailScreen extends StatefulWidget {
  final EmployeePerformance employee;
  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  final EmployeeService _employeeService = EmployeeService();
  late Future<Map<String, List<ProductionOrder>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
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
      print("Error en _loadOrders: $e");
      rethrow;
    }
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = _loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee.fullName ?? 'Detalle de Empleado'),
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
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

          return RefreshIndicator(
            onRefresh: () async => _refreshOrders(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildOrderSection(context, 'Órdenes en Proceso', inProgressOrders, Icons.hourglass_top_outlined, Colors.orange),
                const SizedBox(height: 24),
                _buildOrderSection(context, 'Órdenes Terminadas', completedOrders, Icons.check_circle_outline, Colors.green),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSection(BuildContext context, String title, List<ProductionOrder> orders, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text('(${orders.length})', style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.normal)),
          ],
        ),
        const SizedBox(height: 8),
        if (orders.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            alignment: Alignment.center,
            child: Text("No hay órdenes en esta categoría.", style: TextStyle(color: Colors.grey[600])),
          )
        else
          ...orders.map((order) {
            return Card(
              margin: const EdgeInsets.only(top: 8.0),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(order.productNameSnapshot ?? 'Producto no especificado', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('ID: ${order.idProductionOrder}'),
                trailing: order.createdAt != null
                    ? Text(DateFormat('dd/MM/yy').format(order.createdAt!), style: const TextStyle(color: Colors.grey))
                    : const SizedBox.shrink(),
                // --- INICIO: CAMBIO EN onTap ---
                // Ahora navegamos a la pantalla de detalle de la orden
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductionOrderDetailScreen(order: order),
                    ),
                  );
                },
                // --- FIN: CAMBIO EN onTap ---
              ),
            );
          }).toList(),
      ],
    );
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