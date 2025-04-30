// lib/features/empleados/screens/task_timer_screen.dart
import 'dart:async'; // Necesario para Timer
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Antes era InicioderendimientoWidget
class TaskTimerScreen extends StatefulWidget {
  // Puedes pasar datos necesarios a esta pantalla, como el ID de la tarea o el empleado
  // final String? taskId;
  // final String? empleado;
  // final String? insumo;

  const TaskTimerScreen({
    super.key,
    // this.taskId,
    // this.empleado,
    // this.insumo,
  });

  @override
  State<TaskTimerScreen> createState() => _TaskTimerScreenState();
}

class _TaskTimerScreenState extends State<TaskTimerScreen> {
  Timer? _timer; // Hacerlo nullable
  int _elapsedSeconds = 0; // Tiempo transcurrido en segundos
  bool _isRunning = false; // Indica si el cronómetro está activo
  bool _isPaused = false;  // Indica si está pausado
  bool _showNextStepOptions = false; // Controla visibilidad de opciones post-parada

  @override
  void initState() {
    super.initState();
    // Podrías iniciar el timer automáticamente si es necesario
    // _startTimer();
  }

  // Iniciar o reanudar el cronómetro
  void _startOrResumeTimer() {
    if (_isRunning && !_isPaused) return; // Ya está corriendo

    setState(() {
      _isRunning = true;
      _isPaused = false;
      _showNextStepOptions = false; // Ocultar opciones al iniciar/reanudar
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) { // Solo incrementa si no está pausado
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

 // Pausar el cronómetro
 void _pauseTimer() {
   if (!_isRunning || _isPaused) return; // No se puede pausar si no corre o ya está pausado
    setState(() {
      _isPaused = true;
      // No detenemos el _timer, solo dejamos de incrementar _elapsedSeconds
    });
 }

  // Detener y resetear el cronómetro
  void _stopAndResetTimer() {
    _timer?.cancel(); // Cancela el timer si existe
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _elapsedSeconds = 0; // Resetea el tiempo
      _showNextStepOptions = true; // Muestra opciones después de detener (o podrías resetearlas también)
    });
  }

 // Detener el cronómetro (finalizar tarea) y mostrar opciones
 void _completeTask() {
   _timer?.cancel();
   setState(() {
     _isRunning = false;
     _isPaused = false; // Asegura que no esté pausado
     _showNextStepOptions = true; // Muestra opciones como "Guardar", "Descartar"
   });
   // Aquí podrías guardar el tiempo _elapsedSeconds asociado a la tarea/empleado
   if (kDebugMode) {
     
    print('Tarea completada en: $_formattedTime');
     
   }
 }

  // Formatear los segundos a "HH:MM:SS" o "MM:SS"
  String get _formattedTime {
    final duration = Duration(seconds: _elapsedSeconds);
    // Para formato MM:SS
     String twoDigits(int n) => n.toString().padLeft(2, '0');
     final minutes = twoDigits(duration.inMinutes.remainder(60));
     final seconds = twoDigits(duration.inSeconds.remainder(60));
     // return '$minutes:$seconds';

     // Para formato HH:MM:SS (descomenta si prefieres este)
     final hours = twoDigits(duration.inHours);
     return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel(); // Asegura cancelar el timer al salir de la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Datos de ejemplo (deberían venir de fuera o cargarse)
    const String nombreEmpleado = 'Juan Pérez';
    const String puestoEmpleado = 'Auxiliar de cocina';
    const String imagenEmpleadoUrl = 'https://images.unsplash.com/photo-1621523379741-0db8b7c11ac2?w=500&h=500&fit=crop'; // Usa fit=crop
    const String tituloTarea = 'Preparación Solomillo';
    const String descripcionTarea = 'Realizar una evaluación completa del estado actual del equipo, identificando posibles problemas y necesidades de mantenimiento.'; // Texto de ejemplo anterior
    const String tiempoEstimado = '5 min';

    return Scaffold(
       // backgroundColor: const Color(0xFFF1F4F8), // Usa el del tema o específico
       backgroundColor: theme.scaffoldBackgroundColor,
       // No usamos AppBar aquí, el diseño original tiene una cabecera personalizada
       body: SingleChildScrollView( // Permite scroll si el contenido es largo
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             // --- Cabecera Personalizada ---
             _buildHeader(context, theme, nombreEmpleado, puestoEmpleado, imagenEmpleadoUrl),

             // --- Contenido Principal (Tarjeta Blanca) ---
             Container(
               // No necesita width: MediaQuery...width, Column ya lo hace
               decoration: BoxDecoration(
                 color: colorScheme.surface, // Color de superficie del tema
                 // Redondear solo esquina superior izquierda si es el diseño deseado
                 borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32.0),
                    topRight: Radius.circular(32.0), // Añadido para simetría
                 ),
                  boxShadow: [ // Sombra sutil para destacar sobre el fondo
                      BoxShadow(
                         color: Colors.black.withOpacity(0.05),
                         blurRadius: 10,
                         offset: const Offset(0, -5), // Sombra hacia arriba
                      )
                   ]
               ),
               child: Padding(
                 padding: const EdgeInsets.all(24.0),
                 child: Column(
                   mainAxisSize: MainAxisSize.min, // Ajustar al contenido
                   children: [
                     // --- Tarjeta Interna (Gris Claro) con Detalles y Cronómetro ---
                      _buildTaskDetailsCard(
                         context,
                         theme,
                         tituloTarea,
                         descripcionTarea,
                         tiempoEstimado
                      ),

                      const SizedBox(height: 24),

                     // --- Botones de Acción Post-Parada (si _showNextStepOptions es true) ---
                      if (_showNextStepOptions)
                       _buildPostStopActions(context, theme),

                   ],
                 ),
               ),
             ),
           ],
         ),
       ),
    );
  }

   // Helper: Cabecera personalizada con gradiente
   Widget _buildHeader(BuildContext context, ThemeData theme, String nombre, String puesto, String imageUrl) {
     return Container(
        width: double.infinity, // Ocupa todo el ancho
        height: 180.0, // Altura fija
        padding: const EdgeInsets.all(24.0).copyWith(top: MediaQuery.of(context).padding.top + 16), // Añade padding superior para status bar
        decoration: const BoxDecoration(
           // Usa colores del tema para el gradiente o los específicos anteriores
          gradient: LinearGradient(
            // colors: [colorScheme.primary, colorScheme.secondary], // Ejemplo con tema
            colors: [Color(0xFFFF6A73), Color(0xFFF83B46)], // Colores específicos anteriores
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             // Botón de regreso (Importante si esta pantalla no es la raíz)
             // Puede ser un IconButton o un BackButton
              BackButton(color: Colors.white, onPressed: () => Navigator.maybePop(context)), // Permite volver

             const Spacer(), // Empuja el contenido hacia abajo

             // Información del empleado
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               crossAxisAlignment: CrossAxisAlignment.end, // Alinea al final
               children: [
                 Column(
                   mainAxisSize: MainAxisSize.min,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       nombre, // Nombre del empleado
                       style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
                     ),
                     Text(
                       puesto, // Puesto del empleado
                       style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.8)),
                     ),
                   ],
                 ),
                 // Imagen de perfil del empleado
                 CircleAvatar( // Usar CircleAvatar es más estándar
                    radius: 30.0,
                    backgroundColor: Colors.white.withOpacity(0.3), // Fondo semitransparente
                    backgroundImage: NetworkImage(imageUrl), // Imagen
                     // Añadir un fallback por si la imagen no carga
                     // ignore: avoid_print
                     onBackgroundImageError: (exception, stackTrace) => print("Error cargando imagen: $exception"),
                     child: imageUrl.isEmpty ? const Icon(Icons.person, size: 30, color: Colors.white,) : null, // Icono si no hay imagen
                 ),
               ],
             ),
           ],
        ),
     );
   }

  // Helper: Tarjeta interna con detalles y cronómetro
   Widget _buildTaskDetailsCard(BuildContext context, ThemeData theme, String titulo, String descripcion, String tiempoEstimado) {
     final colorScheme = theme.colorScheme;
     final textTheme = theme.textTheme;

     return Card( // Usar Card para la estructura interna
       elevation: 0.0, // Sin sombra adicional si ya está dentro de otro contenedor con sombra
       // color: const Color(0xFFF1F4F8), // Color gris claro específico anterior
       color: Theme.of(context).colorScheme.surface == Colors.white ? Colors.grey[100] : Colors.grey[800], // Color según tema
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
       child: Padding(
         padding: const EdgeInsets.all(20.0),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             // --- Título y Botón Iniciar/Pausar/Detener ---
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Expanded( // Para que el título no desborde si es largo
                    child: Text(
                      titulo,
                      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                 ),
                 const SizedBox(width: 16),
                 // Botón principal de control del timer
                  ElevatedButton.icon(
                    // Cambia icono y texto según el estado
                     icon: Icon(_isRunning && !_isPaused ? Icons.pause : Icons.play_arrow),
                     label: Text(_isRunning ? (_isPaused ? 'Reanudar' : 'Pausar') : 'Iniciar'),
                     onPressed: _isRunning ? (_isPaused ? _startOrResumeTimer : _pauseTimer) : _startOrResumeTimer,
                     style: ElevatedButton.styleFrom(
                       // Color diferente según estado
                       backgroundColor: _isRunning && !_isPaused ? Colors.orangeAccent : colorScheme.primary,
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Más pequeño
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                     ),
                  ),
               ],
             ),
             const SizedBox(height: 24),

             // --- Cronómetro ---
             Center( // Centrar el cronómetro
               child: Text(
                 _formattedTime, // Tiempo formateado
                 style: textTheme.displayMedium?.copyWith(
                     fontWeight: FontWeight.bold,
                     color: colorScheme.primary, // Color destacado
                     fontFeatures: const [FontFeature.tabularFigures()] // Asegura ancho fijo para números
                 ),
               ),
             ),
             const SizedBox(height: 16),

            // Botón secundario para Finalizar Tarea (visible solo si está corriendo)
             if (_isRunning)
               Center(
                 child: TextButton.icon(
                   icon: const Icon(Icons.stop_circle_outlined, color: Colors.redAccent),
                   label: const Text('Finalizar Tarea', style: TextStyle(color: Colors.redAccent)),
                   onPressed: _completeTask, // Llama a la función para completar
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
                 ),
               ),

             const Divider(height: 32),

             // --- Descripción de la Tarea ---
             Text(
               'Descripción:',
               style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
             ),
             const SizedBox(height: 8),
             Text(
               descripcion,
               style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
             ),
             const SizedBox(height: 16),

             // --- Tiempo Estimado ---
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                  Text(
                    'Tiempo estimado:',
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                 Text(
                   tiempoEstimado,
                   style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                 ),
               ],
             ),
           ],
         ),
       ),
     );
   }

  // Helper: Botones de acción después de detener/completar
   Widget _buildPostStopActions(BuildContext context, ThemeData theme) {
     return Column(
        children: [
           Text(
             'Tarea Finalizada en: $_formattedTime', // Muestra el tiempo final
             style: theme.textTheme.titleMedium,
           ),
           const SizedBox(height: 16),
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribuye los botones
              children: [
                 ElevatedButton.icon(
                    icon: const Icon(Icons.save_alt_outlined),
                    label: const Text('Guardar'),
                    onPressed: () {
                       if (kDebugMode) {
                         print('Guardando tiempo...');
                       }
                       Navigator.maybePop(context); // Volver a la pantalla anterior (opcional)
                    },
                     style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                 ),
                 ElevatedButton.icon(
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Descartar'),
                    onPressed: () {
                       if (kDebugMode) {
                         print('Descartando tiempo...');
                       }
                       _stopAndResetTimer(); // Resetea todo para empezar de nuevo (o podrías volver atrás)
                       setState(() { _showNextStepOptions = false; }); // Oculta los botones de nuevo
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                 ),
               ],
            )
        ],
     );
   }
}