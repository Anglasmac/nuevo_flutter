import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/features/employees/models/employee_performance_model.dart';
import 'package:nuevo_proyecto_flutter/features/employees/screens/employee_detail_screen.dart';
import 'package:nuevo_proyecto_flutter/features/employees/services/employee_service.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final EmployeeService _employeeService = EmployeeService();
  late Future<List<EmployeePerformance>> _employeesFuture;

  // --- INICIO: VARIABLES PARA PAGINACIÓN ---
  int _currentPage = 0;
  final int _itemsPerPage = 4;
  // --- FIN: VARIABLES PARA PAGINACIÓN ---

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (mounted) {
      setState(() {
        _currentPage = 0; // Resetea la página al cargar/refrescar
        _employeesFuture = _employeeService.fetchEmployeePerformance();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rendimiento de Empleados'),
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: FutureBuilder<List<EmployeePerformance>>(
          future: _employeesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _buildErrorWidget(context, snapshot.error);
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyStateWidget(context);
            }

            final employees = snapshot.data!;
            
            // --- INICIO: LÓGICA DE PAGINACIÓN ---
            if (employees.length <= _itemsPerPage) {
              // Sin paginación si hay pocos elementos
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  return _buildEmployeeCard(context, employees[index]);
                },
              );
            } else {
              // Con paginación si hay muchos elementos
              final totalPages = (employees.length / _itemsPerPage).ceil();
              if (_currentPage >= totalPages) _currentPage = totalPages - 1;

              final startIndex = _currentPage * _itemsPerPage;
              final endIndex = (startIndex + _itemsPerPage > employees.length)
                  ? employees.length
                  : startIndex + _itemsPerPage;
              
              final paginatedEmployees = employees.sublist(startIndex, endIndex);

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: paginatedEmployees.length,
                      itemBuilder: (context, index) {
                        return _buildEmployeeCard(context, paginatedEmployees[index]);
                      },
                    ),
                  ),
                  _buildPaginator(totalPages),
                ],
              );
            }
            // --- FIN: LÓGICA DE PAGINACIÓN ---
          },
        ),
      ),
    );
  }

  // --- NUEVO WIDGET: PAGINADOR REDONDO (Reutilizado de Productos) ---
  Widget _buildPaginator(int totalPages) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages, (index) {
          final bool isActive = index == _currentPage;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentPage = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, EmployeePerformance employee) {
    final theme = Theme.of(context);
    final name = employee.fullName;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EmployeeDetailScreen(employee: employee)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  (name != null && name.isNotEmpty) ? name.substring(0, 1).toUpperCase() : '?',
                  style: TextStyle(fontSize: 22, color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.fullName ?? 'Empleado sin nombre',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatChip(
                            context,
                            Icons.hourglass_top_outlined,
                            '${employee.inProgressOrdersCount ?? 0} Activos',
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatChip(
                            context,
                            Icons.check_circle_outline,
                            '${employee.completedOrdersCount ?? 0} Terminados',
                            Colors.green,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildEmptyStateWidget(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('No se encontraron empleados', style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(
                  'Intenta refrescar la lista o crea nuevos empleados en el sistema.',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildErrorWidget(BuildContext context, Object? error) {
     return LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 80, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    const Text('Ocurrió un error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'No se pudo cargar el rendimiento. Por favor, verifica tu conexión e intenta de nuevo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      onPressed: _loadData,
                    )
                  ],
                ),
              ),
            ),
          ),
        );
     });
  }
}