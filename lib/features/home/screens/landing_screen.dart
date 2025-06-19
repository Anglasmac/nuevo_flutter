// lib/features/home/screens/landing_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- 1. Importa Provider
import 'package:nuevo_proyecto_flutter/features/home/widgets/notification_card.dart';
import 'package:nuevo_proyecto_flutter/features/production/models/production_order_model.dart';
import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart';
import 'package:nuevo_proyecto_flutter/services/api_service.dart';
import 'package:nuevo_proyecto_flutter/services/production_order_service.dart';
import 'package:nuevo_proyecto_flutter/features/auth/provider/auth_provider.dart'; // <-- 2. Importa tu AuthProvider
import 'package:nuevo_proyecto_flutter/features/auth/screens/user_profile_screen.dart.dart'; // <-- 3. Importa la pantalla de perfil

class LandingScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const LandingScreen({super.key, required this.onNavigate});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  // --- El resto de tu estado y métodos initState, _loadDashboardData, etc. permanecen IGUAL ---
  bool _isLoading = true;
  String? _error;
  int _reservationsThisWeek = 0;
  int _activeOrdersCount = 0;
  List<ProductionOrder> _cancelledOrders = [];
  List<ProductionOrder> _pausedOrders = [];
  final ApiService _apiService = ApiService();
  final ProductionOrderService _productionOrderService = ProductionOrderService();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait([
        _apiService.fetchReservations(),
        _productionOrderService.fetchProductionOrders(statuses: ['IN_PROGRESS', 'PENDING']),
        _productionOrderService.fetchProductionOrders(statuses: ['CANCELLED']),
        _productionOrderService.fetchProductionOrders(statuses: ['PAUSED']),
      ]);
      final allReservations = results[0] as List<Reserva>;
      final activeOrders = results[1] as List<ProductionOrder>;
      final cancelledOrders = results[2] as List<ProductionOrder>;
      final pausedOrders = results[3] as List<ProductionOrder>;
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final reservationsThisWeek = allReservations.where((reserva) {
        final reservaDate = reserva.dateTime;
        return reservaDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
               reservaDate.isBefore(endOfWeek.add(const Duration(days: 1)));
      }).toList();
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
      if (mounted) {
        setState(() { _error = "Error al cargar los datos: $e"; _isLoading = false; });
      }
    }
  }

  void _showCancelledOrdersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Órdenes Canceladas'),
          content: SizedBox(
            width: double.maxFinite,
            child: _cancelledOrders.isEmpty
                ? const Text('No hay órdenes canceladas para mostrar.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _cancelledOrders.length,
                    itemBuilder: (context, index) {
                      final order = _cancelledOrders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text('Orden #${order.idProductionOrder}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Producto: ${order.productNameSnapshot ?? 'N/A'}'),
                              Text('Motivo: ${order.observations ?? 'No especificado'}', style: TextStyle(color: Colors.red.shade700, fontStyle: FontStyle.italic)),
                              Text('Registró: ${order.employeeFullName ?? 'No disponible'}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [ TextButton( child: const Text('Cerrar'), onPressed: () => Navigator.of(context).pop(), ), ],
        );
      },
    );
  }

  // --- FIN DE TUS MÉTODOS EXISTENTES ---

  @override
  Widget build(BuildContext context) {
    // Obtenemos el nombre del usuario desde el AuthProvider
    final userName = context.watch<AuthProvider>().user?.fullName ?? 'Usuario';
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // Usamos el nombre del usuario real.
        title: Text('Bienvenido, $userName'), 
        actions: _buildAppBarActions(context), // Pasamos el context al método
      ),
      body: _buildBody(userName), // Pasamos el nombre del usuario al cuerpo
    );
  }

  /// Construye el cuerpo principal de la pantalla basado en el estado (cargando, error, datos).
  Widget _buildBody(String userName) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _buildErrorWidget();
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
              // Usamos el nombre del usuario real aquí también.
              userName: userName,
              notificationText: 'Tienes $_activeOrdersCount órdenes activas y $_reservationsThisWeek reservas para esta semana.',
              buttonText: 'Ver Órdenes Activas',
              onButtonPressed: () => widget.onNavigate(4),
            ),
            const SizedBox(height: 24),
            if (_cancelledOrders.isNotEmpty) ...[
              GestureDetector(
                onTap: _showCancelledOrdersDialog,
                child: _buildCancelledOrdersWarning(),
              ),
              const SizedBox(height: 24),
            ],
            _buildSectionTitle('Resumen Rápido'),
            const SizedBox(height: 12),
            _buildSummaryCards(context),
            const SizedBox(height: 24),
            if (_pausedOrders.isNotEmpty) ...[
              _buildSectionTitle('Órdenes en Pausa'),
              const SizedBox(height: 12),
              _buildPausedOrdersSection(),
              const SizedBox(height: 24),
            ],
            _buildSectionTitle('Acciones Rápidas'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                ElevatedButton.icon(
                  onPressed: () => widget.onNavigate(3),
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
  // (Estos métodos no cambian, los incluyo para que el archivo esté completo)
  Text _buildSectionTitle(String title) => Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600));
  Widget _buildCancelledOrdersWarning() => Card( color: Colors.orange.shade50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0), side: BorderSide(color: Colors.orange.shade200, width: 1)), elevation: 0, child: Padding( padding: const EdgeInsets.all(16.0), child: Row( children: [ Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 32), const SizedBox(width: 16), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( 'Atención', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)), Text( 'Hay ${_cancelledOrders.length} orden(es) cancelada(s). Toca para revisar.', style: TextStyle(color: Colors.orange.shade800)), ], ), ), Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange.shade700), ], ), ), );
  Widget _buildSummaryCards(BuildContext context) => Row( children: [ Expanded(child: _buildSummaryCard(context, Icons.construction_outlined, 'Órdenes Activas', '$_activeOrdersCount')), const SizedBox(width: 16), Expanded(child: _buildSummaryCard(context, Icons.calendar_month_outlined, 'Reservas (Semana)', '$_reservationsThisWeek')), ], );
  Widget _buildPausedOrdersSection() => Column( children: _pausedOrders.map((order) => Card( margin: const EdgeInsets.only(bottom: 12.0), clipBehavior: Clip.antiAlias, child: ListTile( leading: const Icon(Icons.pause_circle_outline, color: Colors.blueGrey), title: Text('Orden #${order.idProductionOrder}'), subtitle: Text('Cliente: ${order.nameClient ?? "N/A"}'), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: () => ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Ir a detalle de orden #${order.idProductionOrder} (Pendiente)')), ), ), )).toList(), );
  Widget _buildSummaryCard(BuildContext context, IconData icon, String title, String value) { final theme = Theme.of(context); return Card( elevation: 2.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), child: Padding( padding: const EdgeInsets.all(16.0), child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Icon(icon, size: 30, color: theme.colorScheme.primary), const SizedBox(height: 8), Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])), const SizedBox(height: 4), Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), ], ), ), ); }
  Widget _buildErrorWidget() => Center( child: Padding( padding: const EdgeInsets.all(16.0), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(Icons.cloud_off, color: Colors.red.shade300, size: 80), const SizedBox(height: 16), Text(_error!, style: TextStyle(color: Colors.red[700]), textAlign: TextAlign.center), const SizedBox(height: 16), ElevatedButton.icon( onPressed: _loadDashboardData, icon: const Icon(Icons.refresh), label: const Text('Reintentar'), ) ], ), ), );
  // --- FIN DE LOS MÉTODOS HELPER ---

  // --- MÉTODO CLAVE MODIFICADO ---
  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      PopupMenuButton<String>(
        icon: const Icon(Icons.person_outline),
        tooltip: 'Opciones de Usuario',
        onSelected: (String result) async {
          // Usamos listen:false porque estamos en una devolución de llamada, no en el método build.
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          
          if (result == 'logout') {
            // Llama al método logout del provider.
            // El AuthWrapper se encargará de redirigir a la pantalla de login.
            await authProvider.logout();
          } else if (result == 'profile') {
            // Navega a la nueva pantalla de perfil.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfileScreen()),
            );
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'profile',
            child: ListTile(
              leading: Icon(Icons.account_circle_outlined),
              title: Text('Mi Perfil'),
            ),
          ),
          // Puedes añadir más opciones si quieres
          // const PopupMenuItem<String>(
          //   value: 'settings',
          //   child: ListTile(
          //     leading: Icon(Icons.settings_outlined),
          //     title: Text('Configuración'),
          //   ),
          // ),
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            value: 'logout',
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.redAccent),
              title: Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(width: 8),
    ];
  }
}