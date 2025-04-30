// lib/features/supplier/screens/insumo_detail_screen.dart
// REDISEÑADO: Se eliminaron las configuraciones de tooltip interactivo
//             problemáticas de fl_chart v0.68.0

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// *** IMPORTANTE: Cambia <your_app_name> por el nombre real de tu paquete ***
import 'package:nuevo_proyecto_flutter/features/supplier/models/insumo_model.dart';


class InsumoDetailScreen extends StatelessWidget {
  final Insumo insumo;

  const InsumoDetailScreen({
    required this.insumo,
    super.key,
  });

  // --- Datos de Ejemplo para Gráficos ---
  List<FlSpot> _getMoneyChartData() {
    return const [
      FlSpot(0, 2.5), FlSpot(1, 3.1), FlSpot(2, 3.0), FlSpot(3, 4.2), FlSpot(4, 3.8),
      FlSpot(5, 5.0), FlSpot(6, 4.8), FlSpot(7, 5.5), FlSpot(8, 6.0), FlSpot(9, 5.7),
    ];
  }
  List<PieChartSectionData> _getPercentageChartData(BuildContext context) {
     final theme = Theme.of(context);
    return [
      PieChartSectionData(value: 40, title: '40%', color: theme.colorScheme.primary, radius: 50),
      PieChartSectionData(value: 35, title: '35%', color: theme.colorScheme.secondary, radius: 50),
      PieChartSectionData(value: 25, title: '25%', color: Colors.orangeAccent, radius: 50),
    ];
  }
   List<BarChartGroupData> _getTimeChartData(BuildContext context) {
     final theme = Theme.of(context);
      BarChartRodData rod(double y) => BarChartRodData(
          toY: y,
          gradient: LinearGradient(
              colors: [theme.colorScheme.primary.withOpacity(0.6), theme.colorScheme.primary],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
          ),
          width: 16,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
       );
     return [
       BarChartGroupData(x: 0, barRods: [rod(5)]),
       BarChartGroupData(x: 1, barRods: [rod(10)]),
       BarChartGroupData(x: 2, barRods: [rod(7)]),
       BarChartGroupData(x: 3, barRods: [rod(8)]),
     ];
   }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(insumo.nombre),
        actions: [
           IconButton(
             icon: const Icon(Icons.edit_outlined),
             tooltip: 'Editar Insumo',
             onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Editar ${insumo.nombre} (Pendiente)')),
                );
             },
           ),
            IconButton(
             icon: Icon(insumo.activo ? Icons.toggle_on_outlined : Icons.toggle_off_outlined,
                      color: insumo.activo ? Colors.green : Colors.grey),
             tooltip: insumo.activo ? 'Marcar como Inactivo' : 'Marcar como Activo',
             onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cambiar estado de ${insumo.nombre} (Pendiente)')),
                );
             },
           ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(context, theme),
            const SizedBox(height: 24.0),
            const Divider(),
            const SizedBox(height: 24.0),

            Text('Estadísticas y Rendimiento', style: textTheme.headlineSmall),
            const SizedBox(height: 24.0),

            _buildChartCard(
               context, theme,
               title: 'Historial de Costo/Stock',
               chart: _buildMoneyLineChart(context),
            ),
            const SizedBox(height: 24.0),

            _buildChartCard(
               context, theme,
               title: 'Uso por Departamento',
               chart: _buildPercentagePieChart(context),
            ),
            const SizedBox(height: 24.0),

            _buildChartCard(
               context, theme,
               title: 'Tiempo Promedio Preparación (min)',
               chart: _buildTimeBarChart(context),
            ),

             const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context, ThemeData theme) {
    final textTheme = theme.textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.network(
            insumo.imagenUrl,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
             loadingBuilder: (context, child, loadingProgress) {
               if (loadingProgress == null) return child;
               return Container(width: 120, height: 120, color: Colors.grey[200], child: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
             },
             errorBuilder: (context, error, stackTrace) => Container(width: 120, height: 120, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey, size: 40)),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                insumo.nombre,
                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                insumo.descripcion,
                style: textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                   Icon(
                     insumo.activo ? Icons.check_circle : Icons.cancel,
                     color: insumo.activo ? Colors.green : Colors.redAccent,
                     size: 20,
                   ),
                   const SizedBox(width: 8.0),
                   Text(
                    insumo.activo ? 'Activo' : 'Inactivo',
                    style: textTheme.titleMedium?.copyWith(
                      color: insumo.activo ? Colors.green[700] : Colors.redAccent[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

   Widget _buildChartCard(BuildContext context, ThemeData theme, {required String title, required Widget chart}) {
      return Card(
         elevation: 2.0,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
         child: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                 const SizedBox(height: 20.0),
                 SizedBox(
                    height: 180,
                    child: chart,
                 ),
              ],
           ),
         ),
      );
   }

  Widget _buildMoneyLineChart(BuildContext context) {
    final spots = _getMoneyChartData();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
           show: true,
           drawVerticalLine: false,
           horizontalInterval: 1,
           getDrawingHorizontalLine: (value) {
             return FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1);
           },
        ),
        titlesData: FlTitlesData(
           show: true,
           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
           bottomTitles: AxisTitles(
             sideTitles: SideTitles(
               showTitles: true,
               reservedSize: 30,
               interval: 2,
               getTitlesWidget: (value, meta) {
                 String text = '';
                  switch (value.toInt()) {
                    case 0: text = 'Ene'; break;
                    case 2: text = 'Mar'; break;
                    case 4: text = 'May'; break;
                    case 6: text = 'Jul'; break;
                    case 8: text = 'Sep'; break;
                  }
                 return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: theme.textTheme.bodySmall));
               },
             ),
           ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                 reservedSize: 40,
                 getTitlesWidget: (value, meta) {
                   return Text('\$${value.toStringAsFixed(0)}', style: theme.textTheme.bodySmall, textAlign: TextAlign.right);
                 }
              ),
            ),
        ),
        borderData: FlBorderData(
           show: true,
           border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
               colors: [colorScheme.secondary, colorScheme.primary],
            ),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
               show: true,
               gradient: LinearGradient(
                  colors: [colorScheme.secondary.withOpacity(0.3), colorScheme.primary.withOpacity(0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
               ),
            ),
          ),
        ],
         // --- SECCIÓN DE TOOLTIP ELIMINADA ---
         // lineTouchData: LineTouchData(
         //     touchTooltipData: LineTouchTooltipData(
         //         // ... parámetros problemáticos ...
         //     ),
         //     handleBuiltInTouches: true,
         //  ),
         // --- FIN SECCIÓN ELIMINADA ---
         // Puedes dejar handleBuiltInTouches si quieres el comportamiento por defecto al tocar
         lineTouchData: const LineTouchData(handleBuiltInTouches: true),
      ),
    );
  }

  Widget _buildPercentagePieChart(BuildContext context) {
     final sections = _getPercentageChartData(context);
     return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        pieTouchData: PieTouchData(
           touchCallback: (FlTouchEvent event, pieTouchResponse) {
              // Interactividad básica por defecto
           }
        ),
        startDegreeOffset: -90,
      ),
    );
  }

  Widget _buildTimeBarChart(BuildContext context) {
     final groups = _getTimeChartData(context);
     final theme = Theme.of(context);

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
           show: true,
           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
           bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                 showTitles: true,
                 reservedSize: 30,
                 getTitlesWidget: (value, meta) {
                   String text = '';
                    switch (value.toInt()) {
                      case 0: text = 'Lote A'; break;
                      case 1: text = 'Lote B'; break;
                      case 2: text = 'Lote C'; break;
                      case 3: text = 'Lote D'; break;
                    }
                   return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: theme.textTheme.bodySmall));
                 },
              ),
           ),
           leftTitles: AxisTitles(
              sideTitles: SideTitles(
                 showTitles: true,
                 reservedSize: 35,
                  interval: 2,
                 getTitlesWidget: (value, meta) {
                   return Text('${value.toInt()}m', style: theme.textTheme.bodySmall);
                 }
              ),
           ),
        ),
        borderData: FlBorderData(
           show: true,
           border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1)),
        ),
        barGroups: groups,
        alignment: BarChartAlignment.spaceAround,
         // --- SECCIÓN DE TOOLTIP ELIMINADA ---
         // barTouchData: BarTouchData(
         //    touchTooltipData: BarTouchTooltipData(
         //         // ... parámetros problemáticos ...
         //    ),
         //  ),
         // --- FIN SECCIÓN ELIMINADA ---
          // Puedes dejar handleBuiltInTouches si quieres el comportamiento por defecto al tocar
         barTouchData: BarTouchData(enabled: true), // Habilita interacción básica
      ),
    );
  }
}