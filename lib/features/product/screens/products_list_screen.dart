import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/features/product/models/product_model.dart';
// Importamos las DOS pantallas de detalle
import 'package:nuevo_proyecto_flutter/features/product/screens/product_detail_screen.dart';
import 'package:nuevo_proyecto_flutter/features/product/screens/spec_sheet_detail_screen.dart';
import 'package:nuevo_proyecto_flutter/services/product_service.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;

  int _currentPage = 0;
  final int _itemsPerPage = 4;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    if (mounted) {
      setState(() {
        _currentPage = 0; 
        _productsFuture = _productService.fetchProducts();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadProducts(),
        child: FutureBuilder<List<Product>>(
          future: _productsFuture,
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

            final products = snapshot.data!;

            if (products.length <= _itemsPerPage) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(context, products[index]);
                },
              );
            } else {
              final totalPages = (products.length / _itemsPerPage).ceil();
              
              if (_currentPage >= totalPages) {
                _currentPage = totalPages - 1;
              }

              final startIndex = _currentPage * _itemsPerPage;
              final endIndex = (startIndex + _itemsPerPage > products.length)
                  ? products.length
                  : startIndex + _itemsPerPage;
              
              final paginatedProducts = products.sublist(startIndex, endIndex);

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemCount: paginatedProducts.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(context, paginatedProducts[index]);
                      },
                    ),
                  ),
                  _buildPaginator(totalPages),
                ],
              );
            }
          },
        ),
      ),
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
            onTap: () {
              setState(() {
                _currentPage = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              width: isActive ? 36.0 : 32.0,
              height: isActive ? 36.0 : 32.0,
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
                boxShadow: isActive ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ] : [],
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

  // ============================ CAMBIO CLAVE AQUÍ ============================
  // Este widget ahora contiene la lógica para decidir a qué pantalla navegar.
  Widget _buildProductCard(BuildContext context, Product product) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Si el producto ya tiene una ficha activa, muestra los detalles.
          if (product.activeSpecSheetId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SpecSheetDetailScreen(
                  specSheetId: product.activeSpecSheetId!,
                  productName: product.nombre,
                ),
              ),
            );
          } else {
            // Si no tiene ficha activa, ve a la pantalla para seleccionar una.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            ).then((value) {
              // Si se seleccionó una ficha y volvimos, refresca la lista de productos
              // para que la próxima vez que toquemos, el 'activeSpecSheetId' ya exista.
              if (value == true) {
                _loadProducts();
              }
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  // Mostramos un icono diferente si ya tiene una ficha activa.
                  product.activeSpecSheetId != null 
                    ? Icons.assignment_turned_in_outlined 
                    : Icons.inventory_2_outlined,
                  size: 28,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nombre,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.warehouse_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Stock: ${product.minimo} / ${product.maximo}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${product.specSheetCount}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Fichas',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
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
                const Text('No se encontraron productos', style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('Intenta refrescar la lista o crea un nuevo producto.', style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildErrorWidget(Object? error) {
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
                    Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    const Text('Ocurrió un error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'No se pudieron cargar los productos. Por favor, verifica tu conexión e intenta de nuevo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      onPressed: _loadProducts,
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