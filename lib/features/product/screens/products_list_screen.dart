// lib/features/products/screens/products_list_screen.dart

import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/features/product/models/product_model.dart';
import 'package:nuevo_proyecto_flutter/features/product/screens/product_detail_screen.dart';
import 'package:nuevo_proyecto_flutter/services/product_service.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = _productService.fetchProducts();
    });
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
            // CAMBIO: Ya no usamos ListView.separated. El margen de las Cards crea la separación.
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0), // Padding solo arriba y abajo
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                // CAMBIO: Llamamos a nuestro nuevo widget de tarjeta.
                return _buildProductCard(context, product);
              },
            );
          },
        ),
      ),
    );
  }

  // --- NUEVO WIDGET DE TARJETA ---
  // Este widget reemplaza al anterior _buildProductTile
  Widget _buildProductCard(BuildContext context, Product product) {
    final theme = Theme.of(context);
    
    return Card(
      // Estilo de la tarjeta
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      clipBehavior: Clip.antiAlias, // Asegura que el InkWell respete los bordes

      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          ).then((value) {
            if (value == true) {
              _loadProducts();
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icono principal a la izquierda
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              // Columna central con la información principal
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
              // Columna derecha con el contador y la flecha
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

  // --- WIDGETS AUXILIARES (Sin cambios, siguen siendo útiles) ---

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