// lib/features/product/screens/products_list_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/features/product/models/product_model.dart';
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

  // --- NUEVO: ESTADO PARA EL BUSCADOR Y FILTRADO ---
  final TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = []; // Almacenará todos los productos sin filtrar
  List<Product> _filteredProducts = []; // Productos mostrados (filtrados)
  Timer? _debounce;

  // --- ESTADO PARA PAGINACIÓN ---
  int _currentPage = 0;
  final int _itemsPerPage = 3; // Aumentamos para que se vea mejor con tarjetas pequeñas

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _loadProducts() {
    if (mounted) {
      setState(() {
        _productsFuture = _productService.fetchProducts();
        _productsFuture.then((products) {
          if (mounted) {
            setState(() {
              _allProducts = products;
              _filterProducts(); // Aplicar filtro inicial (si lo hay)
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
      _filterProducts();
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        return product.nombre.toLowerCase().contains(query);
      }).toList();
      _currentPage = 0; // Resetear a la primera página con cada búsqueda
    });
  }

  void _navigateToProduct(Product product) {
    // (Sin cambios en esta función)
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
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadProducts(),
        child: Column(
          children: [
            // --- NUEVO: WIDGET DE BÚSQUEDA ---
            _buildSearchBar(),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _allProducts.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError && _allProducts.isEmpty) {
                    return _buildErrorWidget(snapshot.error);
                  }
                  if (_allProducts.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
                    return _buildEmptyStateWidget();
                  }
                  if (_filteredProducts.isEmpty && _searchController.text.isNotEmpty) {
                    return _buildNoResultsWidget();
                  }

                  final productsToDisplay = _filteredProducts;
                  productsToDisplay.sort((a,b) => a.nombre.compareTo(b.nombre));

                  if (productsToDisplay.length <= _itemsPerPage) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: productsToDisplay.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(context, productsToDisplay[index]);
                      },
                    );
                  } else {
                    final totalPages = (productsToDisplay.length / _itemsPerPage).ceil();
                    if (_currentPage >= totalPages) _currentPage = totalPages - 1;

                    final startIndex = _currentPage * _itemsPerPage;
                    final endIndex = (startIndex + _itemsPerPage > productsToDisplay.length)
                        ? productsToDisplay.length
                        : startIndex + _itemsPerPage;
                    
                    final paginatedProducts = productsToDisplay.sublist(startIndex, endIndex);

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
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
          hintText: 'Buscar producto por nombre...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
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

  // --- WIDGET DE TARJETA REDISEÑADO (MÁS COMPACTO) ---
  Widget _buildProductCard(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final hasActiveSheet = product.activeSpecSheetId != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToProduct(product),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      hasActiveSheet ? Icons.assignment_turned_in_outlined : Icons.inventory_2_outlined,
                      size: 24,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      product.nombre,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatChip(
                    context, 
                    Icons.storefront_outlined, 
                    'En Venta', 
                    '${product.stockForSale.toStringAsFixed(1)} kg',
                    Colors.green
                  ),
                  _buildStatChip(
                    context, 
                    Icons.all_inbox_outlined, 
                    'En Bodega', 
                    '${product.currentStock} u.',
                    Colors.blueGrey
                  ),
                  _buildStatChip(
                    context, 
                    Icons.file_copy_outlined, 
                    'Fichas', 
                    '${product.specSheetCount}',
                    Theme.of(context).colorScheme.primary
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
      ],
    );
  }

  // --- WIDGETS DE ESTADO Y PAGINACIÓN (SIN CAMBIOS) ---
  Widget _buildPaginator(int totalPages) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: isActive ? 32.0 : 28.0,
              height: isActive ? 32.0 : 28.0,
              decoration: BoxDecoration(
                color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
                boxShadow: isActive ? [ BoxShadow( color: Theme.of(context).colorScheme.primary.withOpacity(0.3), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1),) ] : [],
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
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
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Sin resultados', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            'No se encontraron productos que coincidan con "${_searchController.text}".',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No se encontraron productos', style: TextStyle(fontSize: 18, color: Colors.grey)),
          Text('Intenta refrescar la lista o crea un nuevo producto.', style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text('Ocurrió un error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('No se pudieron cargar los productos. Por favor, verifica tu conexión e intenta de nuevo.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              onPressed: _loadProducts,
            )
          ],
        ),
      ),
    );
  }
}