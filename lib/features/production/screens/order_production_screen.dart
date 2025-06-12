import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_proyecto_flutter/features/production/models/production_order_model.dart';
import 'package:nuevo_proyecto_flutter/features/production/screens/production_order_detail_screen.dart';
import 'package:nuevo_proyecto_flutter/services/production_order_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OrderProductionScreen extends StatefulWidget {
  const OrderProductionScreen({super.key});

  @override
  State<OrderProductionScreen> createState() => _OrderProductionScreenState();
}

class _OrderProductionScreenState extends State<OrderProductionScreen> {
  final ProductionOrderService _productionService = ProductionOrderService();
  late Future<List<ProductionOrder>> _ordersFuture;

  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _isUpdatingNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (_currentPageNotifier.value != newPage) {
        _currentPageNotifier.value = newPage;
      }
    });
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = _productionService.fetchProductionOrders(statuses: ['IN_PROGRESS', 'PENDING']);
    });
  }

  Future<void> _markOrderAsCompleted(ProductionOrder order) async {
    _isUpdatingNotifier.value = true;
    try {
      await _productionService.updateOrderStatus(order.idProductionOrder, 'COMPLETED');
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Orden #${order.idProductionOrder} completada.'),
          backgroundColor: Colors.green,
        ),
      );
      _loadOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al completar la orden: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        _isUpdatingNotifier.value = false;
      }
    }
  }
  
  (String, Color) _getStatusInfo(String? status) {
    switch (status) {
      case 'IN_PROGRESS': return ('En Proceso', Colors.orange);
      case 'PENDING': return ('Pendiente', Colors.blue);
      default: return ('Desconocido', Colors.grey);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    _isUpdatingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes de Producción'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: FutureBuilder<List<ProductionOrder>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // ===== CORRECCIÓN 1: Pasamos 'context' al widget de error =====
            return _buildErrorWidget(context, snapshot.error);
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // ===== CORRECCIÓN 1: Pasamos 'context' al widget de estado vacío =====
            return _buildEmptyStateWidget(context);
          }

          final orders = snapshot.data!;

          if (_pageController.positions.isNotEmpty && _pageController.page!.round() >= orders.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _pageController.positions.isNotEmpty) {
                _pageController.jumpToPage(0);
              }
            });
          }

          return ValueListenableBuilder<int>(
            valueListenable: _currentPageNotifier,
            builder: (context, currentPage, child) {
              if (currentPage >= orders.length) {
                return _buildEmptyStateWidget(context);
              }
              final currentOrder = orders[currentPage];
              final (statusText, statusColor) = _getStatusInfo(currentOrder.status);

              return Column(
                children: [
                  _buildHeader(context, currentOrder, statusText, statusColor),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderPageContent(context, orders[index]);
                      },
                    ),
                  ),
                  if (orders.length > 1)
                    _buildPageIndicator(context, orders.length),
                  _buildCompleteButton(context, currentOrder),
                ],
              );
            },
          );
        },
      ),
    );
  }

   Widget _buildHeader(BuildContext context, ProductionOrder order, String statusText, Color statusColor) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Creada:', style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey)),
              Text(
                order.createdAt != null ? DateFormat('dd/MM HH:mm').format(order.createdAt!) : 'N/A',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Chip(
            label: Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: statusColor,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderPageContent(BuildContext context, ProductionOrder order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProductionOrderDetailScreen(order: order)));
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  order.productNameSnapshot ?? 'Producto sin nombre',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  // ===== CORRECCIÓN 2: Usamos 'initialAmount' en lugar de 'quantityToProduce' =====
                  'Cantidad: ${order.initialAmount ?? 0} unidades',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                ),
                const Spacer(),
                _buildOrderInfoCard(context, order.employeeFullName),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard(BuildContext context, String? employeeName) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const CircleAvatar(radius: 24.0, child: Icon(Icons.person_outline, size: 28)),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Asignado a:', style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey[700])),
                Text(
                  employeeName ?? 'No asignado',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SmoothPageIndicator(
        controller: _pageController,
        count: count,
        effect: ExpandingDotsEffect(
          dotWidth: 8.0,
          dotHeight: 8.0,
          activeDotColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCompleteButton(BuildContext context, ProductionOrder order) {
    final canComplete = order.status == 'IN_PROGRESS';
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 32.0),
      child: ValueListenableBuilder<bool>(
        valueListenable: _isUpdatingNotifier,
        builder: (context, isUpdating, child) {
          return ElevatedButton.icon(
            icon: isUpdating
                ? Container(width: 24, height: 24, padding: const EdgeInsets.all(4), child: const CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                : const Icon(Icons.check_circle_outline),
            label: Text(isUpdating ? 'Completando...' : 'Marcar como Completada'),
            onPressed: (canComplete && !isUpdating) ? () => _markOrderAsCompleted(order) : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              disabledBackgroundColor: Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }

  // ===== CORRECCIÓN 1: La función ahora recibe 'context' =====
  Widget _buildEmptyStateWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No hay órdenes activas', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Todas las órdenes de producción están al día.', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  // ===== CORRECCIÓN 1: La función ahora recibe 'context' =====
  Widget _buildErrorWidget(BuildContext context, Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text('Error al cargar órdenes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
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