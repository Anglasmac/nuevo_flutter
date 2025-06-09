// lib/features/products/screens/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/features/product/models/product_model.dart';
import 'package:nuevo_proyecto_flutter/services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({required this.product, super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  late Future<List<FichaTecnica>> _fichasFuture;
  final ValueNotifier<int?> _activeFichaIdNotifier = ValueNotifier(null);
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadFichas();
  }
  
  void _loadFichas() {
    setState(() {
      _fichasFuture = _productService.fetchFichasByProductId(widget.product.id);
      _fichasFuture.then((fichas) {
        if (mounted) {
          final fichaActiva = fichas.where((f) => f.activo).firstOrNull;
          _activeFichaIdNotifier.value = fichaActiva?.id;
        }
      }).catchError((error) {
        print("Error al cargar fichas en _loadFichas: $error");
      });
    });
  }

  Future<void> _handleActiveChange(int newActiveId) async {
    if (newActiveId == _activeFichaIdNotifier.value || _isSaving) return;

    setState(() { _isSaving = true; });

    try {
      await _productService.setFichaStatus(newActiveId, true);
      _activeFichaIdNotifier.value = newActiveId;
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ficha activa actualizada.'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
      );
      // Notificamos a la pantalla anterior que hubo un cambio para que pueda refrescar la lista.
      Navigator.pop(context, true); 
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) {
        setState(() { _isSaving = false; });
      }
    }
  }

  @override
  void dispose() {
    _activeFichaIdNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.nombre),
        backgroundColor: colorScheme.surface,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          FutureBuilder<List<FichaTecnica>>(
            future: _fichasFuture,
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

              final fichas = snapshot.data!;
              
              return ValueListenableBuilder<int?>(
                valueListenable: _activeFichaIdNotifier,
                builder: (context, activeId, child) {
                  return ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildSectionHeader(
                        context,
                        icon: Icons.rule_folder_outlined,
                        title: 'Selecciona la Ficha Activa',
                        subtitle: 'Esta será la utilizada en las órdenes de producción.',
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: fichas.asMap().entries.map((entry) {
                            int index = entry.key;
                            FichaTecnica ficha = entry.value;
                            bool isLast = index == fichas.length - 1;

                            return Column(
                              children: [
                                RadioListTile<int>(
                                  title: Text(ficha.nombre, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  value: ficha.id,
                                  groupValue: activeId,
                                  onChanged: _isSaving ? null : (id) => _handleActiveChange(id!),
                                  activeColor: colorScheme.primary,
                                  controlAffinity: ListTileControlAffinity.trailing,
                                ),
                                if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Text(
            subtitle,
            style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.find_in_page_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No hay fichas técnicas', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Este producto aún no tiene fichas asociadas.', style: TextStyle(color: Colors.grey[600])),
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
            Icon(Icons.cloud_off, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text('Error al cargar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'No se pudieron cargar las fichas. Por favor, verifica tu conexión e intenta de nuevo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              onPressed: _loadFichas,
            )
          ],
        ),
      ),
    );
  }
}