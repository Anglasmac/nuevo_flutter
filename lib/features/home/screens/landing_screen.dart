// lib/features/home/screens/landing_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Asegúrate que <your_app_name> sea el nombre correcto de tu paquete (de pubspec.yaml)
// *** IMPORTANTE: Cambia <your_app_name> por el nombre real de tu paquete ***
import 'package:nuevo_proyecto_flutter/features/home/widgets/notification_card.dart';

// Antes era LandingPageScreen
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Accede al tema aquí para usarlo dentro del build
    final theme = Theme.of(context);

    return Scaffold(
      // No definimos backgroundColor aquí para usar el del tema global
      appBar: AppBar(
        // backgroundColor: Colors.white, // Usa el color del tema
        automaticallyImplyLeading: false, // No muestra botón de atrás
        title: const Text('Dashboard'), // Título más descriptivo
        actions: [
          // Botón de Notificaciones (Ejemplo)
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notificaciones', // Ayuda visual
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Mostrar Notificaciones (Pendiente)')),
              );
            },
          ),
          // Menú desplegable para opciones como Cerrar Sesión
          PopupMenuButton<String>(
            icon: const Icon(
                Icons.person_outline), // Icono de perfil o configuración
            tooltip: 'Opciones de Usuario',
            onSelected: (String result) {
              switch (result) {
                case 'profile':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ir a Perfil (Pendiente)')),
                  );
                  break;
                case 'settings':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Ir a Configuración (Pendiente)')),
                  );
                  break;
                case 'logout':
                  // Por ejemplo, limpiar tokens, navegar a LoginScreen
                  // Asegúrate de tener una ruta '/login' definida o usa Navigator.pushReplacement
                   try {
                     Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Cerrando sesión... (Simulado)')),
                     );
                   } catch (e) {
                      if (kDebugMode) {
                        print("Error al navegar a /login: $e. Asegúrate que la ruta esté definida.");
                      }
                      // Considera navegar a LoginScreen directamente si las rutas nombradas fallan
                      // Navigator.of(context).pushAndRemoveUntil(
                      //   MaterialPageRoute(builder: (context) => const LoginScreen()), // Asume que tienes LoginScreen importado
                      //   (route) => false
                      // );
                   }
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(
                  // Usar ListTile para mejor formato
                  leading: Icon(Icons.account_circle_outlined),
                  title: Text('Mi Perfil'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Configuración'),
                ),
              ),
              const PopupMenuDivider(), // Separador visual
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.redAccent),
                  title: Text('Cerrar sesión',
                      style: TextStyle(color: Colors.redAccent)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8), // Pequeño espacio al final
        ],
      ),
      body: SafeArea( // SafeArea para evitar solapamiento con notch/barra de estado
        child: SingleChildScrollView( // Permite scroll si el contenido crece
          padding: const EdgeInsets.all(16.0), // Padding uniforme
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Sección de Bienvenida y Notificación Principal ---
              const NotificationCard(), // Usamos el widget extraído

              const SizedBox(height: 24), // Espacio mayor entre secciones

              // --- Otras Secciones del Dashboard (Ejemplos) ---

              // Ejemplo: Resumen Rápido (Podrían ser Cards)
              Text(
                 'Resumen Rápido',
                 style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600) // Usa la variable theme
              ),
              const SizedBox(height: 12),
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    // *** LLAMADA AL MÉTODO ***
                    Expanded(child: _buildSummaryCard(context, Icons.inventory_outlined, 'Insumos Activos', '15')),
                    const SizedBox(width: 12),
                     // *** LLAMADA AL MÉTODO ***
                    Expanded(child: _buildSummaryCard(context, Icons.people_alt_outlined, 'Empleados', '8')),
                 ],
              ),
               const SizedBox(height: 16),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                     // *** LLAMADA AL MÉTODO ***
                    Expanded(child: _buildSummaryCard(context, Icons.calendar_month_outlined, 'Reservas Hoy', '3')),
                    const SizedBox(width: 12),
                     // *** LLAMADA AL MÉTODO ***
                    Expanded(child: _buildSummaryCard(context, Icons.construction_outlined, 'Órdenes Prog.', '5')),
                 ],
               ),


              const SizedBox(height: 24),

              // Ejemplo: Acciones Rápidas (Botones)
              Text(
                 'Acciones Rápidas',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600) // Usa la variable theme
               ),
              const SizedBox(height: 12),
               Wrap( // Wrap permite que los botones se ajusten si no caben en una línea
                 spacing: 12.0, // Espacio horizontal
                 runSpacing: 12.0, // Espacio vertical
                 children: [
                   ElevatedButton.icon(
                     onPressed: () {},
                     icon: const Icon(Icons.add_circle_outline),
                     label: const Text('Nueva Orden'),
                   ),
                    ElevatedButton.icon(
                     onPressed: () {},
                     icon: const Icon(Icons.event_available),
                     label: const Text('Nueva Reserva'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green), // Estilo diferente
                   ),
                   // Añadir más botones si es necesario
                 ],
               )
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget para las tarjetas de resumen (ejemplo)
  Widget _buildSummaryCard(
      BuildContext context, IconData icon, String title, String value) {
    final theme = Theme.of(context); // Accede al tema aquí también
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(title,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(value,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}