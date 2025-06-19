// lib/features/product/screens/spec_sheet_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas si es necesario
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

// Añadimos TickerProviderStateMixin para el TabController
class _SpecSheetDetailScreenState extends State<SpecSheetDetailScreen>
    with TickerProviderStateMixin {
  final ProductService _productService = ProductService();
  late Future<SpecSheetDetailModel> _detailsFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador de pestañas
    _tabController = TabController(length: 2, vsync: this);
    _loadDetails();
  }

  void _loadDetails() {
    setState(() {
      _detailsFuture = _productService.fetchSpecSheetDetails(widget.specSheetId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productName),
        elevation: 1,
        // Usamos un estilo consistente con tus otras pantallas
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('GENERAL'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.layers_outlined),
                  SizedBox(width: 8),
                  Text('COMPONENTES'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<SpecSheetDetailModel>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error);
          }
          if (!snapshot.hasData) {
            return const Center(
                child: Text('No se encontraron detalles para esta ficha.'));
          }

          final details = snapshot.data!;
          return TabBarView(
            controller: _tabController,
            children: [
              _buildGeneralInfoTab(context, details),
              _buildComponentsTab(context, details),
            ],
          );
        },
      ),
    );
  }

  // Pestaña 1: Información General (como en la columna izquierda de tu app web)
  Widget _buildGeneralInfoTab(
      BuildContext context, SpecSheetDetailModel details) {
    final theme = Theme.of(context);
    final (statusText, statusColor) = _getStatusInfo(details.status);
    final formattedDate = details.dateEffective != null
        ? DateFormat('dd/MM/yyyy').format(details.dateEffective!)
        : 'N/A';

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.versionName,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (details.description != null &&
                    details.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: Text(details.description!,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey[700])),
                  ),
                const Divider(height: 24),
                _buildInfoRow(
                  context,
                  icon: Icons.tag,
                  label: 'ID Ficha',
                  valueWidget: Text('#${details.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.calendar_today_outlined,
                  label: 'Fecha Efectiva',
                  valueWidget: Text(formattedDate),
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.scale_outlined,
                  label: 'Cantidad Base',
                  valueWidget: Text(
                      '${details.quantityBase} ${details.unitOfMeasure ?? ''}'),
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.toggle_on_outlined,
                  label: 'Estado',
                  valueWidget: Chip(
                    label: Text(
                      statusText,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12),
                    ),
                    backgroundColor: statusColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Pestaña 2: Insumos y Pasos (como en la columna derecha de tu app web)
  Widget _buildComponentsTab(
      BuildContext context, SpecSheetDetailModel details) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Sección de Insumos
        _buildSectionHeader(context, 'Insumos Requeridos',
            Icons.inventory_2_outlined, details.supplies.length),
        if (details.supplies.isEmpty)
          const Center(child: Text('No hay insumos definidos.'))
        else
          ...details.supplies.map((supply) => _buildSupplyTile(context, supply)),

        const SizedBox(height: 24),

        // Sección de Pasos
        _buildSectionHeader(context, 'Pasos de Producción',
            Icons.format_list_numbered_outlined, details.processes.length),
        if (details.processes.isEmpty)
          const Center(child: Text('No hay pasos definidos.'))
        else
          ...details.processes.map((process) => _buildProcessTile(context, process)),
      ],
    );
  }

  // --- WIDGETS AUXILIARES PARA EL DISEÑO ---

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '($count)',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey[600]),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context,
      {required IconData icon,
      required String label,
      required Widget valueWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildSupplyTile(
      BuildContext context, SpecSheetSupplyModel supply) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(Icons.blender_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        title: Text(supply.supplyName,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(
          '${supply.quantity.toStringAsFixed(2)} ${supply.unitOfMeasure}',
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildProcessTile(
      BuildContext context, SpecSheetProcessModel process) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Text(
            '${process.order}',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer),
          ),
        ),
        title: Text(process.processName),
        subtitle: process.estimatedTimeMinutes != null
            ? Text('Tiempo estimado: ${process.estimatedTimeMinutes} min')
            : null,
      ),
    );
  }

  (String, Color) _getStatusInfo(bool? status) {
    if (status == true) {
      return ('Activa', Colors.green.shade700);
    }
    return ('Inactiva', Colors.blueGrey);
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
            const Text('Error al cargar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'No se pudieron cargar los detalles. Por favor, verifica tu conexión e intenta de nuevo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              onPressed: _loadDetails,
            )
          ],
        ),
      ),
    );
  }
}