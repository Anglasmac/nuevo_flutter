// lib/features/produccion/screens/order_production_screen.dart
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Asegúrate de tenerlo en pubspec.yaml

// Antes era OrderProductionPage
class OrderProductionScreen extends StatefulWidget {
  const OrderProductionScreen({super.key});

  @override
  State<OrderProductionScreen> createState() => _OrderProductionScreenState();
}

class _OrderProductionScreenState extends State<OrderProductionScreen> {
  // Controlador para el PageView
  final PageController _pageController = PageController();

  // Datos de ejemplo para las páginas (reemplazar con datos reales)
  // Idealmente, estos serían objetos de un modelo OrderProduction
  final List<Map<String, dynamic>> _orderPages = [
    {
      'title': 'Órdenes Pendientes',
      'employeeName': 'Empleado A',
      'product': 'Solomillo Wellington',
      'status': 'Pendiente',
      'imageUrl':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80',
      'dueDate': 'Hoy, 14:00'
    },
    {
      'title': 'En Progreso',
      'employeeName': 'Empleado B',
      'product': 'Lomo al Pedro Ximénez',
      'status': 'En progreso',
      'imageUrl':
          'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=400&q=80',
      'dueDate': 'Hoy, 18:30'
    },
    {
      'title': 'Control Calidad',
      'employeeName': 'Empleado C',
      'product': 'Tarta de Queso',
      'status': 'En progreso',
      'imageUrl':
          'https://images.unsplash.com/photo-1588195538326-c5b1e9f80a1b?w=400&q=80',
      'dueDate': 'Mañana, 10:00'
    },
    {
      'title': 'Listas para Entrega',
      'employeeName': 'Empleado D',
      'product': 'Paella Mixta',
      'status': 'Completada',
      'imageUrl':
          'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400&q=80',
      'dueDate': 'Ayer'
    },
  ];

  int _currentPageIndex = 0; // Para saber qué página está activa

  @override
  void initState() {
    super.initState();
    // Escuchar cambios en el PageController para actualizar _currentPageIndex
    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPageIndex) {
        setState(() {
          _currentPageIndex = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // Liberar el controlador
    super.dispose();
  }

  // Función para determinar el color del chip de estado
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en progreso':
        return Colors.orangeAccent;
      case 'pendiente':
        return Colors.blueAccent;
      case 'completada':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Obtiene los datos de la orden actual para el botón "Completar"
    final currentOrder =
        _orderPages.isNotEmpty ? _orderPages[_currentPageIndex] : null;
    final bool canCompleteCurrentOrder = currentOrder != null &&
        currentOrder['status'] ==
            'En progreso'; // Solo se puede completar si está en progreso

    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes de Producción'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar Órdenes',
            onPressed: () {
              // nImplementar lógica de filtrado (por estado, fecha, etc.)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtrar órdenes (Pendiente)')),
              );
            },
          )
        ],
      ),
      body: Column(
        // Organiza el contenido verticalmente
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Estira los hijos horizontalmente
        children: [
          // --- Cabecera con Fecha/Hora y Estado (si aplica a la orden actual) ---
          if (currentOrder != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Fecha de Vencimiento / Creación
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vence:',
                            style: textTheme.labelMedium
                                ?.copyWith(color: Colors.grey)),
                        Text(
                          currentOrder['dueDate'] ?? 'Fecha no especificada',
                          style: textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme
                                  .primary, // Color destacado para la fecha
                              fontWeight: FontWeight.w500),
                        ),
                      ]),

                  // Chip de Estado
                  Chip(
                    label: Text(
                      currentOrder['status'] ?? 'Desconocido',
                      style:
                          textTheme.labelMedium!.copyWith(color: Colors.white),
                    ),
                    backgroundColor:
                        _getStatusColor(currentOrder['status'] ?? ''),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    visualDensity: VisualDensity.compact, // Más pequeño
                  ),
                ],
              ),
            ),

          const Divider(
              height: 16.0, thickness: 1.0, indent: 16, endIndent: 16),

          // --- Título de la sección (opcional, podría estar en cada página) ---
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          //   child: Text(
          //     'Órdenes Activas', // Título general
          //     style: textTheme.titleLarge,
          //   ),
          // ),

          // --- PageView para las Órdenes ---
          Expanded(
            // Ocupa el espacio restante
            // Añadir padding horizontal para que las tarjetas no peguen a los bordes
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: PageView.builder(
                controller: _pageController,
                itemCount:
                    _orderPages.length, // Número total de órdenes/páginas
                itemBuilder: (context, index) {
                  final orderData = _orderPages[index];
                  // Llama al widget que construye el contenido de cada página
                  return _buildOrderPageContent(
                    context,
                    theme,
                    title: orderData['title'] ?? 'Sin Título',
                    employeeName: orderData['employeeName'] ?? 'No asignado',
                    product: orderData['product'] ?? 'Producto no especificado',
                    imageUrl: orderData['imageUrl'] ?? '', // Manejar URL vacía
                  );
                },
              ),
            ),
          ),

          // --- Indicador de Página ---
          if (_orderPages.length > 1) // Mostrar solo si hay más de una página
            Center(
              // Centrar el indicador
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _orderPages.length, // Número total de páginas
                  effect: ExpandingDotsEffect(
                    // Efecto visual (puedes probar otros)
                    dotWidth: 8.0,
                    dotHeight: 8.0,
                    spacing: 6.0,
                    dotColor: Colors.grey.shade400,
                    activeDotColor:
                        theme.colorScheme.primary, // Color primario del tema
                  ),
                  // Opcional: onTap para navegar directamente
                  // onTap: (index) => _pageController.animateToPage(
                  //   index,
                  //   duration: const Duration(milliseconds: 300),
                  //   curve: Curves.easeInOut,
                  // ),
                ),
              ),
            ),

          // --- Botón de Completar Tarea (visible condicionalmente) ---
          Padding(
            // Aumentar padding inferior para separarlo del borde y del BottomNavBar si existe
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 32.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Marcar como Completada'),
              onPressed: canCompleteCurrentOrder
                  ? () {
                      // Habilitado solo si se puede completar
                      // nImplementar lógica para marcar la orden actual como completada
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Marcando "${currentOrder['product']}" como completada (Pendiente)'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Podrías querer que navegue a la siguiente orden o actualice la lista
                    }
                  : null, // Deshabilitado si no se puede completar
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 14), // Altura del botón
                // Cambiar estilo si está deshabilitado
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
      // Opcional: FloatingActionButton para crear nueva orden
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // nNavegar a la pantalla de creación de órdenes
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Crear nueva orden (Pendiente)')),
          );
        },
        tooltip: 'Crear Orden',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget Helper para el contenido de CADA página del PageView
  Widget _buildOrderPageContent(BuildContext context, ThemeData theme,
      {required String title,
      required String employeeName,
      required String product,
      required String imageUrl}) {
    return Padding(
      // Padding alrededor de cada página para crear espacio
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        // Contenido dentro de una Card
        elevation: 4.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Ajustar al contenido
            children: [
              // Título de la página (Estado de la orden)
              Text(
                title,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24.0),

              // Tarjeta interna con los detalles del empleado y producto
              _buildOrderInfoCard(
                  context, theme, employeeName, product, imageUrl),

              const SizedBox(height: 24.0),

              // Opcional: Más detalles o acciones específicas de la orden
              Text(
                'Notas Adicionales:',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Sin notas adicionales para esta orden.', // Placeholder
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper para la tarjeta de información de la orden (Empleado y Producto)
  Widget _buildOrderInfoCard(BuildContext context, ThemeData theme,
      String employeeName, String product, String imageUrl) {
    return Container(
      // No necesita ser Card si ya está dentro de una
      decoration: BoxDecoration(
        // Color de fondo sutil o borde
        color: theme.colorScheme.surfaceContainerHighest
            .withOpacity(0.3), // Color ligeramente diferente
        borderRadius: BorderRadius.circular(12.0),
        // border: Border.all(color: Colors.grey.shade300)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Imagen (del empleado o del producto)
            CircleAvatar(
              // Usar CircleAvatar para empleado o producto
              radius: 30.0, // Tamaño del círculo
              backgroundImage: NetworkImage(imageUrl),
              onBackgroundImageError: (e, s) =>
                  // ignore: avoid_print
                  print('Error cargando imagen: $e'), // Manejo de error
              backgroundColor:
                  Colors.grey[300], // Color de fondo si falla la imagen
              child: imageUrl.isEmpty
                  ? const Icon(Icons.person_outline, size: 30)
                  : null, // Icono si no hay URL
            ),
            const SizedBox(width: 16.0), // Espacio

            // Nombre del empleado y producto/posición
            Expanded(
              // Para que el texto se ajuste
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employeeName, // Nombre del empleado
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    product, // Producto o Puesto
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey[700]),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Opcional: Icono de acción o información
            // IconButton(
            //    icon: Icon(Icons.info_outline, color: Colors.grey[600]),
            //    tooltip: 'Ver detalles del empleado/producto',
            //    onPressed: () {},
            // )
          ],
        ),
      ),
    );
  }
}
