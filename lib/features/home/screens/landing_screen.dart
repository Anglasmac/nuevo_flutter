import 'package:flutter/material.dart';

// ======================= SECCIÓN DE IMPORTACIONES =======================
// Widgets y servicios que utiliza esta pantalla.
import 'package:nuevo_proyecto_flutter/features/home/widgets/notification_card.dart';
import 'package:nuevo_proyecto_flutter/services/api_service.dart';

// Importamos el servicio de órdenes, ocultando el modelo para evitar conflictos.
import 'package:nuevo_proyecto_flutter/services/production_order_service.dart';

// Importamos los modelos de datos desde sus archivos de origen.
import 'package:nuevo_proyecto_flutter/features/production/models/production_order_model.dart';
import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart';
// ========================================================================


class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  // --- ESTADO DEL WIDGET ---
  bool _isLoading = true;
  String? _error;
  
  // Variables para almacenar los datos del dashboard.
  int _reservationsThisWeek = 0;
  int _activeOrdersCount = 0;
  List<ProductionOrder> _cancelledOrders = [];
  List<ProductionOrder> _pausedOrders = [];

  // Instancias de los servicios para realizar las llamadas a la API.
  final ApiService _apiService = ApiService();
  final ProductionOrderService _productionOrderService = ProductionOrderService();

  @override
  void initState() {
    super.initState();
    // Carga los datos iniciales cuando la pantalla se construye por primera vez.
    _loadDashboardData();
  }

  /// Carga todos los datos necesarios para el dashboard desde la API.
  Future<void> _loadDashboardData() async {
    // Evita errores si el widget se destruye mientras se carga.
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Ejecuta todas las llamadas a la API en paralelo para mayor eficiencia.
      final results = await Future.wait([
        _apiService.fetchReservations(),
        _productionOrderService.fetchProductionOrders(statuses: ['IN_PROGRESS', 'PENDING']),
        _productionOrderService.fetchProductionOrders(statuses: ['CANCELLED']),
        _productionOrderService.fetchProductionOrders(statuses: ['PAUSED']),
      ]);

      // Desempaqueta los resultados de Future.wait.
      final allReservations = results[0] as List<Reserva>;
      final activeOrders = results[1] as List<ProductionOrder>;
      final cancelledOrders = results[2] as List<ProductionOrder>;
      final pausedOrders = results[3] as List<ProductionOrder>;

      // Lógica para filtrar las reservas de la semana actual.
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final reservationsThisWeek = allReservations.where((reserva) {
      final reservaDate = reserva.dateTime;
        return reservaDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
               reservaDate.isBefore(endOfWeek.add(const Duration(days: 1)));
      }).toList();

      // Actualiza el estado con los nuevos datos si el widget sigue montado.
      if (mounted) {
        setState(() {
          _reservationsThisWeek = reservationsThisWeek.length;
          _activeOrdersCount = activeOrders.length;
          _cancelledOrders = cancelledOrders;
          _pausedOrders = pausedOrders;
          _isLoading = false;
        });
      }

    } catch (e) {
      // Manejo de errores durante la carga de datos.
      if (mounted) {
        setState(() {
          _error = "Error al cargar los datos: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Bienvenida'),
        actions: _buildAppBarActions(),
      ),
      body: _buildBody(), // Extraído a un método para mayor claridad.
    );
  }

  /// Construye el cuerpo principal de la pantalla basado en el estado (cargando, error, datos).
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: TextStyle(color: Colors.red[700]), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              )
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NotificationCard(
              userName: 'Lina', // Puedes hacerlo dinámico en el futuro
              notificationText: 'Tienes $_activeOrdersCount órdenes activas y $_reservationsThisWeek reservas para esta semana.',
              buttonText: 'Ver Órdenes Activas',
              onButtonPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navegando a órdenes... (Pendiente)')),
                );
              },
            ),
            const SizedBox(height: 24),

            if (_cancelledOrders.isNotEmpty) ...[
              _buildCancelledOrdersWarning(),
              const SizedBox(height: 24),
            ],
            
            Text('Resumen Rápido', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildSummaryCards(context),

            const SizedBox(height: 24),

            if (_pausedOrders.isNotEmpty) ...[
              Text('Órdenes en Pausa', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _buildPausedOrdersSection(),
            ],
            
            const SizedBox(height: 24),

             Text('Acciones Rápidas', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
             const SizedBox(height: 12),
             Wrap(
               spacing: 12.0,
               runSpacing: 12.0,
               children: [
                 
                  ElevatedButton.icon(
                   onPressed: () {},
                   icon: const Icon(Icons.event_available),
                   label: const Text('Nueva Reserva'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                 ),
               ],
             )
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS HELPER PARA CONSTRUIR PARTES DE LA UI ---

  Widget _buildSummaryCards(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard(context, Icons.construction_outlined, 'Órdenes Activas', '$_activeOrdersCount')),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard(context, Icons.calendar_month_outlined, 'Reservas (Semana)', '$_reservationsThisWeek')),
      ],
    );
  }

  Widget _buildCancelledOrdersWarning() {
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.orange.shade200, width: 1),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Atención',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                  ),
                  Text(
                    'Hay ${_cancelledOrders.length} orden(es) de producción cancelada(s).',
                     style: TextStyle(color: Colors.orange.shade800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPausedOrdersSection() {
    return Column(
      children: _pausedOrders.map((order) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: const Icon(Icons.pause_circle_outline, color: Colors.blueGrey),
            title: Text('Orden #${order.idProductionOrder}'),
            subtitle: Text('Cliente: ${order.nameClient ?? "N/A"}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ir a detalle de orden #${order.idProductionOrder} (Pendiente)')),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard(BuildContext context, IconData icon, String title, String value) {
     final theme = Theme.of(context);
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.notifications_none),
        tooltip: 'Notificaciones',
        onPressed: () {},
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.person_outline),
        tooltip: 'Opciones de Usuario',
        onSelected: (String result) {
          if (result == 'logout') {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Acción para "$result" pendiente')),
              );
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(value: 'profile', child: ListTile(leading: Icon(Icons.account_circle_outlined), title: Text('Mi Perfil'))),
          const PopupMenuItem<String>(value: 'settings', child: ListTile(leading: Icon(Icons.settings_outlined), title: Text('Configuración'))),
          const PopupMenuDivider(),
          const PopupMenuItem<String>(value: 'logout', child: ListTile(leading: Icon(Icons.logout, color: Colors.redAccent), title: Text('Cerrar sesión', style: TextStyle(color: Colors.redAccent)))),
        ],
      ),
      const SizedBox(width: 8),
    ];
  }
}