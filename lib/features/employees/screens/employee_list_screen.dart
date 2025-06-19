// lib/features/employees/screens/employee_list_screen.dart

import 'dart:async'; // Importar para el Debounce
import 'package:flutter/material.dart';
import 'dart:math';
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

  // --- NUEVO: ESTADO PARA BUSCADOR Y FILTRADO ---
  final TextEditingController _searchController = TextEditingController();
  List<EmployeePerformance> _allEmployees = [];
  List<EmployeePerformance> _filteredEmployees = [];
  Timer? _debounce;

  // --- ESTADO PARA PAGINACIÓN ---
  int _currentPage = 0;
  final int _itemsPerPage = 3; 

  final Map<int, Color> _employeeColors = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _loadData() {
    if (mounted) {
      setState(() {
        _employeesFuture = _employeeService.fetchEmployeePerformance();
        _employeesFuture.then((employees) {
          if (mounted) {
            setState(() {
              _allEmployees = employees;
              _filterEmployees();
            });
          }
        });
      });
    }
  }

  // --- NUEVO: LÓGICA DE FILTRADO ---
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterEmployees();
    });
  }

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEmployees = _allEmployees.where((employee) {
        return (employee.fullName ?? '').toLowerCase().contains(query);
      }).toList();
      _currentPage = 0; // Resetear página
    });
  }

  Color _getColorForEmployee(int employeeId) {
    if (!_employeeColors.containsKey(employeeId)) {
      _employeeColors[employeeId] =
          Colors.primaries[Random().nextInt(Colors.primaries.length)].shade200;
    }
    return _employeeColors[employeeId]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rendimiento de Empleados'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: Column(
          children: [
            // --- NUEVO: BARRA DE BÚSQUEDA ---
            _buildSearchBar(),
            Expanded(
              child: FutureBuilder<List<EmployeePerformance>>(
                future: _employeesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _allEmployees.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError && _allEmployees.isEmpty) {
                    return _buildErrorWidget(context, snapshot.error);
                  }
                  if (_allEmployees.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
                    return _buildEmptyStateWidget(context);
                  }
                  if (_filteredEmployees.isEmpty && _searchController.text.isNotEmpty) {
                    return _buildNoResultsWidget();
                  }

                  final employeesToDisplay = _filteredEmployees;
                  employeesToDisplay.sort((a, b) => (a.fullName ?? '').compareTo(b.fullName ?? ''));

                  if (employeesToDisplay.length <= _itemsPerPage) {
                    return _buildEmployeeListView(employeesToDisplay);
                  } else {
                    final totalPages = (employeesToDisplay.length / _itemsPerPage).ceil();
                    if (_currentPage >= totalPages) _currentPage = totalPages - 1;

                    final startIndex = _currentPage * _itemsPerPage;
                    final endIndex = (startIndex + _itemsPerPage > employeesToDisplay.length)
                        ? employeesToDisplay.length
                        : startIndex + _itemsPerPage;
                    
                    final paginatedEmployees = employeesToDisplay.sublist(startIndex, endIndex);

                    return Column(
                      children: [
                        Expanded(
                          child: _buildEmployeeListView(paginatedEmployees, animate: false),
                        ),
                        _buildPaginator(totalPages),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- NUEVO: WIDGET DE LA BARRA DE BÚSQUEDA ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar empleado por nombre...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildEmployeeListView(List<EmployeePerformance> employees, {bool animate = true}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employeeCard = _buildEmployeeCard(context, employees[index]);
        if (animate) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 50 * (1 - value)), child: child));
            },
            child: employeeCard,
          );
        }
        return employeeCard;
      },
    );
  }

  Widget _buildPaginator(int totalPages) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages, (index) {
          final bool isActive = index == _currentPage;
          return GestureDetector(
            onTap: () => setState(() => _currentPage = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              width: isActive ? 36.0 : 32.0,
              height: isActive ? 36.0 : 32.0,
              decoration: BoxDecoration(
                color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
                boxShadow: isActive ? [ BoxShadow( color: Theme.of(context).colorScheme.primary.withOpacity(0.3), spreadRadius: 2, blurRadius: 4, offset: const Offset(0, 2), ) ] : [],
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Sin resultados', style: TextStyle(fontSize: 18, color: Colors.grey)),
          Text(
            'No se encontraron empleados que coincidan con "${_searchController.text}".',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // El resto de los widgets no necesitan cambios
  Widget _buildEmployeeCard(BuildContext context, EmployeePerformance employee) {
    final theme = Theme.of(context);
    final name = employee.fullName ?? 'Empleado Desconocido';
    final totalOrders = (employee.inProgressOrdersCount ?? 0) + (employee.completedOrdersCount ?? 0);
    final progress = totalOrders == 0 ? 0.0 : (employee.completedOrdersCount ?? 0) / totalOrders;
    final avatarColor = _getColorForEmployee(employee.idEmployee ?? 0);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: avatarColor,
                    child: Text(
                      (name.isNotEmpty) ? name.split(' ').map((e) => e[0]).take(2).join().toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 20,
                        color: theme.brightness == Brightness.dark ? Colors.black87 : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${employee.completedOrdersCount ?? 0} de $totalOrders órdenes completadas',
                           style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        )
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 16),
              Tooltip(
                message: '${(progress * 100).toStringAsFixed(0)}% completado',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatChip(context, Icons.hourglass_top, 'En Proceso', '${employee.inProgressOrdersCount ?? 0}'),
                  _buildStatChip(context, Icons.task_alt, 'Completadas', '${employee.completedOrdersCount ?? 0}'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text('$label: ', style: TextStyle(color: Colors.grey[700])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
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