import 'package:flutter/material.dart';
// Importa la pantalla a la que navega el botón "Iniciar Orden"
import 'package:nuevo_proyecto_flutter/features/employees/screens/task_timer_screen.dart'; // <- Reemplaza

// Antes era PaginaEmpleadosWidget
class EmpleadosTaskScreen extends StatefulWidget {
  const EmpleadosTaskScreen({super.key});

  @override
  State<EmpleadosTaskScreen> createState() => _EmpleadosTaskScreenState();
}

class _EmpleadosTaskScreenState extends State<EmpleadosTaskScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? _selectedEmpleado; // Null si no hay selección
  String? _selectedInsumo;
  final List<String> _empleadosDisponibles = ['Juan Pérez', 'Ana García', 'Luis Martín']; // Ejemplo
  final List<String> _insumosDisponibles = ['Solomillo', 'Aceite Oliva', 'Sal Gruesa']; // Ejemplo

  final List<Map<String, String>> _tareasActivas = [
    {'task': 'Product Assembly', 'employee': 'John Smith', 'time': '2h 15m'},
    {'task': 'Quality Check', 'employee': 'Sarah Johnson', 'time': '45m'},
    {'task': 'Assembly Line', 'employee': 'Michael Lee', 'time': '3h 30m'},
     {'task': 'Packaging', 'employee': 'Emily White', 'time': '1h 05m'}, // Más datos
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: scaffoldKey,
      // backgroundColor: const Color(0xFFFBF9F5), // Usa el color del tema o uno específico
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // backgroundColor: Colors.white, // Usa el color del AppBar del tema
        automaticallyImplyLeading: false, // Considera si necesitas un Drawer o botón atrás
         leading: IconButton( // Ejemplo: Botón para abrir Drawer
            icon: Icon(Icons.menu, color: colorScheme.onSurface),
            tooltip: 'Abrir menú',
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abrir Drawer (Pendiente)')),
               );
               // O si es parte de un Scaffold con Drawer:
               // scaffoldKey.currentState?.openDrawer();
            },
          ),
        title: Text(
          'Time Tracker', // O un título más específico como "Asignar Tarea"
          // style: textTheme.headlineMedium?.copyWith(color: Color(0xFF101518)), // Usa estilo del tema
          style: theme.appBarTheme.titleTextStyle, // Hereda del tema
        ),
        centerTitle: false, // Título a la izquierda es más común
        // elevation: 0.0, // Usa la elevación del tema
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Permite scroll
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Sección: Iniciar Nueva Tarea ---
              _buildStartTaskCard(context, theme),

              const SizedBox(height: 24.0), // Espacio entre secciones

              // --- Sección: Tareas Activas ---
              _buildActiveTasksCard(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget para la tarjeta de "Iniciar Nueva Tarea"
  Widget _buildStartTaskCard(BuildContext context, ThemeData theme) {
    final textTheme = theme.textTheme;

    return Card( // Usar Card para agrupar visualmente
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch, // Estira los hijos al ancho
          children: [
            Text(
              'Iniciar Nueva Tarea', // O 'Asignar Tarea'
              style: textTheme.headlineSmall, // Estilo más apropiado
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),

            // Dropdown para seleccionar empleado
            DropdownButtonFormField<String>(
              value: _selectedEmpleado,
              hint: const Text('Seleccionar empleado'),
              icon: const Icon(Icons.arrow_drop_down),
              isExpanded: true, // Ocupa todo el ancho
              decoration: const InputDecoration(
                // labelText: 'Empleado', // O usar hint
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: _empleadosDisponibles.map((String empleado) {
                return DropdownMenuItem<String>(
                  value: empleado,
                  child: Text(empleado),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEmpleado = newValue;
                });
              },
              validator: (value) => value == null ? 'Seleccione un empleado' : null,
            ),
            const SizedBox(height: 16.0),

            // Dropdown para seleccionar insumo/tarea
            DropdownButtonFormField<String>(
              value: _selectedInsumo,
              hint: const Text('Seleccionar insumo/tarea'),
              icon: const Icon(Icons.arrow_drop_down),
              isExpanded: true,
              decoration: const InputDecoration(
                // labelText: 'Insumo/Tarea',
                 prefixIcon: Icon(Icons.build_circle_outlined),
              ),
              items: _insumosDisponibles.map((String insumo) {
                return DropdownMenuItem<String>(
                  value: insumo,
                  child: Text(insumo),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedInsumo = newValue;
                });
              },
               validator: (value) => value == null ? 'Seleccione un insumo/tarea' : null,
            ),
            const SizedBox(height: 32.0),

            // Botón para Iniciar
            ElevatedButton(
              onPressed: (_selectedEmpleado != null && _selectedInsumo != null)
                  ? () {
                      // Navegar a la pantalla del cronómetro/detalle de tarea
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // Pasar datos seleccionados a la siguiente pantalla si es necesario
                          builder: (context) => const TaskTimerScreen(
                            // empleado: _selectedEmpleado!,
                            // insumo: _selectedInsumo!,
                          ),
                        ),
                      );
                    }
                  : null, // Deshabilitado si no hay selección completa
               style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: 14.0),
                 // backgroundColor: Color(0xFF507583), // Color específico anterior
                 // Usa el color primario o secundario del tema
               ),
              child: const Text('Iniciar Orden de Producción'),
            ),
          ],
        ),
      ),
    );
  }

   // Helper Widget para la tarjeta de "Tareas Activas"
   Widget _buildActiveTasksCard(BuildContext context, ThemeData theme) {
    final textTheme = theme.textTheme;

     // Si no hay tareas, mostrar un mensaje
     if (_tareasActivas.isEmpty) {
       return Card(
         elevation: 2.0,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
         child: const Padding(
           padding: EdgeInsets.all(24.0),
           child: Center(
             child: Text(
                'No hay tareas activas en este momento.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
             ),
           ),
         ),
       );
     }

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tareas Activas', // O 'Órdenes con Empleados'
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 16.0),
             // Usar ListView.separated para añadir divisores
             ListView.separated(
               padding: EdgeInsets.zero, // Quitar padding por defecto
               physics: const NeverScrollableScrollPhysics(), // Deshabilitar scroll interno
               shrinkWrap: true, // Ajustar altura al contenido
               itemCount: _tareasActivas.length,
               itemBuilder: (context, index) {
                 final tarea = _tareasActivas[index];
                 return _buildTaskListItem(
                   context,
                   theme,
                   taskName: tarea['task'] ?? 'N/A',
                   employeeName: tarea['employee'] ?? 'N/A',
                   time: tarea['time'] ?? 'N/A',
                 );
               },
                separatorBuilder: (context, index) => const Divider(height: 1), // Divisor sutil
             ),
          ],
        ),
      ),
    );
  }

   // Helper Widget para cada elemento de la lista de tareas activas
   Widget _buildTaskListItem(BuildContext context, ThemeData theme,
       {required String taskName, required String employeeName, required String time}) {
      final textTheme = theme.textTheme;
      final colorScheme = theme.colorScheme;

     return ListTile( // ListTile es ideal para estos elementos
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0), // Ajustar padding
        title: Text(taskName, style: textTheme.titleMedium),
        subtitle: Text(employeeName, style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
        trailing: Text(
           time,
           style: textTheme.bodyLarge?.copyWith(
             color: colorScheme.primary, // Usar color primario del tema
             fontWeight: FontWeight.w500,
           ),
        ),
        onTap: () {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Ver detalles de: $taskName (Pendiente)')),
           );
        },
     );
   }
}