import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- IMPORTACIONES ---
// Si tu servicio está en 'lib/services/employee_service.dart', cambia la ruta.
import 'package:nuevo_proyecto_flutter/features/employees/services/employee_service.dart';
import 'package:nuevo_proyecto_flutter/features/employees/models/employee_performance_model.dart';
import 'package:nuevo_proyecto_flutter/features/production/models/production_order_model.dart';


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

  /// Carga todas las órdenes del empleado y las devuelve en un mapa.
  Future<Map<String, List<ProductionOrder>>> _loadOrders() async {
    try {
      final employeeId = widget.employee.idEmployee;
      if (employeeId == null) {
        throw Exception("El ID del empleado es nulo.");
      }
      
      final results = await Future.wait([
        _employeeService.fetchOrdersForEmployee(employeeId, statuses: ['IN_PROGRESS', 'PAUSED']),
        _employeeService.fetchOrdersForEmployee(employeeId, statuses: ['COMPLETED']),
      ]);
      
      return {
        'inProgress': results[0],
        'completed': results[1],
      };
    } catch (e) {
      print("Error en _loadOrders: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ====================== CORRECCIÓN APLICADA AQUÍ ======================
        // Cambiamos `employeeName` por `fullName`, que es el nombre correcto
        // en el modelo `EmployeePerformance` que me proporcionaste anteriormente.
        // Si el nombre en tu modelo es diferente, cámbialo aquí.
        title: Text(widget.employee.fullName ?? 'Detalle de Empleado'),
        // ======================================================================
      ),
      body: FutureBuilder<Map<String, List<ProductionOrder>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error al cargar órdenes: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No se encontraron datos de órdenes."));
          }

          final inProgressOrders = snapshot.data!['inProgress'] ?? [];
          final completedOrders = snapshot.data!['completed'] ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _ordersFuture = _loadOrders();
              });
            },
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

  /// Widget helper para renderizar una sección de la lista de órdenes.
  Widget _buildOrderSection(BuildContext context, String title, List<ProductionOrder> orders, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 8),
            Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text('(${orders.length})', style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey[600])),
          ],
        ),
        const Divider(height: 20, thickness: 1),
        if (orders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: Text("No hay órdenes en esta categoría.", style: TextStyle(color: Colors.grey))),
          )
        else
          ...orders.map((order) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              elevation: 2,
              child: ListTile(
                title: Text(order.productNameSnapshot ?? 'Producto no especificado', style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('ID: ${order.idProductionOrder} - Estado: ${order.status}'),
                trailing: order.createdAt != null
                    ? Text(DateFormat('dd/MM/yy').format(order.createdAt!))
                    : const Text('Sin fecha'),
                onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Viendo detalle de orden #${order.idProductionOrder}')),
                    );
                },
              ),
            );
          }).toList(),
      ],
    );
  }
}