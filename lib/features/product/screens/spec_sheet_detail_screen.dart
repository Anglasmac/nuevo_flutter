import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/features/product/models/spec_sheet_detail_model.dart';
import 'package:nuevo_proyecto_flutter/services/product_service.dart';

class SpecSheetDetailScreen extends StatefulWidget {
  final int specSheetId;
  final String productName;

  const SpecSheetDetailScreen({
    super.key,
    required this.specSheetId,
    required this.productName,
  });

  @override
  State<SpecSheetDetailScreen> createState() => _SpecSheetDetailScreenState();
}

class _SpecSheetDetailScreenState extends State<SpecSheetDetailScreen> {
  final ProductService _productService = ProductService();
  late Future<SpecSheetDetailModel> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _productService.fetchSpecSheetDetails(widget.specSheetId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productName),
      ),
      body: FutureBuilder<SpecSheetDetailModel>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar detalles: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No se encontraron detalles para esta ficha.'));
          }

          final details = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                details.versionName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (details.description != null && details.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(details.description!, style: Theme.of(context).textTheme.bodyMedium),
                ),
              
              const Divider(height: 32),

              _buildSectionHeader(context, 'Pasos de Producción', Icons.format_list_numbered),
              if (details.processes.isEmpty)
                const Text('No hay pasos definidos.')
              else
                ...details.processes.map((process) => _buildProcessTile(process)),
              
              const Divider(height: 32),

              _buildSectionHeader(context, 'Insumos Requeridos', Icons.inventory_2_outlined),
               if (details.supplies.isEmpty)
                const Text('No hay insumos definidos.')
              else
                ...details.supplies.map((supply) => _buildSupplyTile(supply)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _buildProcessTile(SpecSheetProcessModel process) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text('${process.order}')),
        title: Text(process.processName),
        trailing: process.estimatedTimeMinutes != null
            ? Text('${process.estimatedTimeMinutes} min')
            : null,
      ),
    );
  }

  Widget _buildSupplyTile(SpecSheetSupplyModel supply) {
     return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(supply.supplyName),
        trailing: Text(
          '${supply.quantity.toStringAsFixed(2)} ${supply.unitOfMeasure}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}