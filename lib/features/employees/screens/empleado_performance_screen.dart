// lib/features/empleados/screens/empleado_performance_screen.dart
import 'package:flutter/material.dart';

// Antes era RendimientoEmpleadosWidget
class EmpleadoPerformanceScreen extends StatefulWidget {
  const EmpleadoPerformanceScreen({super.key});

  @override
  State<EmpleadoPerformanceScreen> createState() =>
      _EmpleadoPerformanceScreenState();
}

// Añadir SingleTickerProviderStateMixin si usas TabController u otras animaciones
class _EmpleadoPerformanceScreenState extends State<EmpleadoPerformanceScreen> with SingleTickerProviderStateMixin {
  // Controladores y FocusNodes si los necesitas para TextFields
  // late TextEditingController _searchController;
  // late FocusNode _searchFocusNode;
  // late TabController _tabController; // Si usas pestañas

  // Datos de ejemplo (reemplazar con datos reales)
  final List<Map<String, dynamic>> _insumosConRendimiento = [
     {'title': 'Preparación Carnes', 'subtitle': '4 empleados asociados', 'icon': Icons.kitchen_outlined, 'empleados': ['A', 'B', 'C', 'D']},
     {'title': 'Corte Vegetales', 'subtitle': '2 empleados asociados', 'icon': Icons.eco_outlined, 'empleados': ['E', 'F']},
     {'title': 'Ensamblaje Platos', 'subtitle': '5 empleados asociados', 'icon': Icons.restaurant_menu_outlined, 'empleados': ['G', 'H', 'I', 'J', 'K']},
     {'title': 'Limpieza General', 'subtitle': '3 empleados asociados', 'icon': Icons.cleaning_services_outlined, 'empleados': ['L', 'M', 'N']},
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar controladores si los usas
    // _searchController = TextEditingController();
    // _searchFocusNode = FocusNode();
    // _tabController = TabController(length: 3, vsync: this); // Ejemplo con 3 pestañas
  }

  @override
  void dispose() {
    // Liberar recursos de los controladores
    // _searchController.dispose();
    // _searchFocusNode.dispose();
    // _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ignore: unused_local_variable
    final textTheme = theme.textTheme;

    return GestureDetector(
      // Permite quitar el foco de TextFields al tocar fuera
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // backgroundColor: Colors.white, // Usa el del tema
        appBar: AppBar(
          title: const Text('Rendimiento por Tarea'), // Título más claro
          // bottom: TabBar( // Ejemplo si usaras pestañas
          //   controller: _tabController,
          //   tabs: const [
          //     Tab(text: 'General'),
          //     Tab(text: 'Por Empleado'),
          //     Tab(text: 'Por Fecha'),
          //   ],
          // ),
        ),
        body:
         // TabBarView( // Si usaras pestañas
         //   controller: _tabController,
         //   children: [
         //     _buildGeneralPerformanceView(theme), // Vista para la pestaña General
         //     Center(child: Text('Vista por Empleado (Pendiente)')),
         //     Center(child: Text('Vista por Fecha (Pendiente)')),
         //   ],
         // ),
         // --- Si no usas pestañas, pon el contenido principal aquí ---
          _buildGeneralPerformanceView(theme),

      ),
    );
  }

   // Contenido principal (antes estaba directo en el body)
   Widget _buildGeneralPerformanceView(ThemeData theme) {
      final textTheme = theme.textTheme;
      return SingleChildScrollView( // Permite scroll
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Barra de Búsqueda (Opcional) ---
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 16.0),
              //   child: TextFormField(
              //     // controller: _searchController,
              //     // focusNode: _searchFocusNode,
              //     decoration: InputDecoration(
              //       hintText: 'Buscar tarea o empleado...',
              //       prefixIcon: const Icon(Icons.search),
              //       // Usar bordes redondeados si es consistente con el tema
              //       // border: OutlineInputBorder(
              //       //   borderRadius: BorderRadius.circular(40.0),
              //       // ),
              //     ),
              //     onChanged: (query) {
              //        //  Implementar lógica de filtrado
              //     },
              //   ),
              // ),

              // --- Sección de Rendimiento por Tarea/Insumo ---
              Text(
                'Rendimiento por Tarea/Insumo', // Título de la sección
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),

              // Lista horizontal de tarjetas de insumos/tareas
              SizedBox( // Contenedor con altura fija para la lista horizontal
                height: 260.0, // Ajusta la altura según necesites
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // Scroll horizontal
                  itemCount: _insumosConRendimiento.length,
                  itemBuilder: (context, index) {
                    final item = _insumosConRendimiento[index];
                    return _buildPerformanceCard(
                      context,
                      theme,
                      title: item['title'] ?? 'N/A',
                      subtitle: item['subtitle'] ?? 'N/A',
                      icon: item['icon'] ?? Icons.help_outline,
                      employeeAvatars: List<String>.from(item['empleados'] ?? []), // Pasa la lista de avatares
                    );
                  },
                ),
              ),

               const SizedBox(height: 24.0),

               // --- Otra Sección (Ejemplo: Gráfico General) ---
               Text(
                 'Visión General del Rendimiento',
                 style: textTheme.titleLarge,
               ),
               const SizedBox(height: 16.0),
               Card( // Gráfico dentro de una Card
                 elevation: 2.0,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                 child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container( // Placeholder para un gráfico
                       height: 200,
                       color: Colors.blueGrey.withOpacity(0.1),
                       child: const Center(child: Text('Aquí iría un gráfico general\n(Ej: Tareas completadas vs. Pendientes)')),
                    )
                 )
               )

              // Puedes añadir más secciones: empleados destacados, alertas, etc.
            ],
          ),
        );
    }

  // Método para construir las tarjetas de rendimiento (antes _buildInsumoCard)
  Widget _buildPerformanceCard(BuildContext context, ThemeData theme,
      {required String title,
      required String subtitle,
      required IconData icon,
      required List<String> employeeAvatars // Lista para los avatares
      }) {

      final colorScheme = theme.colorScheme;

    return Container(
      width: 240.0, // Ancho fijo para las tarjetas horizontales
      margin: const EdgeInsets.only(right: 16.0), // Margen entre tarjetas
      child: Card( // Usar Card como base
         elevation: 4.0,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
         clipBehavior: Clip.antiAlias, // Para que el contenido respete los bordes
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             // Parte superior coloreada con icono y texto
             Container(
               height: 140.0, // Altura fija para la sección superior
               width: double.infinity, // Ocupa todo el ancho de la card
               // Usa un color primario o secundario del tema
               color: colorScheme.primary.withOpacity(0.8),
               padding: const EdgeInsets.all(16.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuye el espacio
                 children: [
                   // Icono dentro de un círculo
                   CircleAvatar(
                     radius: 20.0,
                     backgroundColor: colorScheme.onPrimary.withOpacity(0.9), // Fondo claro sobre primario
                     child: Icon(
                       icon,
                       color: colorScheme.primary, // Icono con el color primario
                       size: 24.0,
                     ),
                   ),
                   // Textos
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary), // Texto claro
                          maxLines: 2, // Evita desbordamiento
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary.withOpacity(0.8)), // Texto claro más pequeño
                        ),
                     ]
                   ),
                 ],
               ),
             ),
             // Parte inferior con avatares de empleados (si hay)
             if (employeeAvatars.isNotEmpty)
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                 child: Row(
                   children: [
                     // Muestra hasta 3-4 avatares y un indicador de "+X" si hay más
                      ...employeeAvatars.take(3).map((avatarPlaceholder) => // Usa take() para limitar
                          Padding(
                            padding: const EdgeInsets.only(right: -8.0), // Solapa ligeramente los avatares
                            child: CircleAvatar(
                                radius: 16.0,
                                // 
                                backgroundImage: NetworkImage('https://i.pravatar.cc/40?u=$avatarPlaceholder'), // Placeholder con ID único
                                backgroundColor: Colors.grey[300],
                             ),
                          )
                       ), // Convierte el iterable a lista
                       // Indicador de más empleados si es necesario
                      if (employeeAvatars.length > 3)
                         Padding(
                           padding: const EdgeInsets.only(left: 12.0), // Espacio antes del +X
                           child: Text(
                             '+${employeeAvatars.length - 3}',
                             style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                           ),
                         ),
                   ],
                 ),
               )
             else // Mensaje si no hay empleados asignados
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Text(
                     'Sin empleados asignados',
                     style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  )
                ),
           ],
         ),
      ),
    );
  }
}