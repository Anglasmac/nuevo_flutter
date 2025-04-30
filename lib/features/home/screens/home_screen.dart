// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
// Importa las diferentes pantallas que mostrarás en el BottomNavBar
import 'package:nuevo_proyecto_flutter/features/home/screens/landing_screen.dart';         // <- Reemplaza
import 'package:nuevo_proyecto_flutter/features/supplier/screens/insumos_list_screen.dart';   // <- Reemplaza
// import 'package:nuevo_proyecto_flutter/features/empleados/screens/empleados_list_screen.dart'; // <- Reemplaza (Asume que tienes una lista de empleados)
import 'package:nuevo_proyecto_flutter/features/reservas/screens/reservas_calendar_screen.dart'; // <- Reemplaza
import 'package:nuevo_proyecto_flutter/features/production/screens/order_production_screen.dart'; // <- Reemplaza

// Antes era PaginaPrincipalWidget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Índice de la pantalla activa

  // Lista de las pantallas principales correspondientes a cada item del BottomNavBar
  // Asegúrate de que el orden coincida con los BottomNavigationBarItem
  static const List<Widget> _widgetOptions = <Widget>[
    LandingScreen(),        // Índice 0: Inicio
    InsumosListScreen(),    // Índice 1: Insumo
    // EmpleadoListScreen(), // Índice 2: Empleado (Necesitas crear esta pantalla) - Comentado por ahora
     PlaceholderWidget(color: Colors.orange, text: 'Pantalla Empleados (Pendiente)'), // Placeholder temporal
    ReservasCalendarScreen(),// Índice 3: Reservas
    OrderProductionScreen(), // Índice 4: Producción
  ];

  void _onItemTapped(int index) {
    // No permitir seleccionar el índice 2 si la pantalla no existe aún
    if (index == 2 && _widgetOptions[index] is PlaceholderWidget) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pantalla de Empleados no implementada todavía.')),
       );
       return; // No cambia el índice
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El AppBar se manejará dentro de cada pantalla individual (_widgetOptions[selectedIndex])
      // ya que cada una podría necesitar un AppBar diferente.
      body: Center(
        // Muestra la pantalla seleccionada
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // Icono diferente cuando está activo
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined), // Icono más representativo para insumos
            activeIcon: Icon(Icons.inventory_2),
            label: 'Insumos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline), // Icono para empleados
            activeIcon: Icon(Icons.people),
            label: 'Empleados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined), // Icono para reservas
            activeIcon: Icon(Icons.calendar_month),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.factory_outlined), // Icono para producción/órdenes
            activeIcon: Icon(Icons.factory),
            label: 'Producción',
          ),
        ],
        currentIndex: _selectedIndex,
        // Los colores y estilos se toman del BottomNavigationBarThemeData en AppTheme
        // selectedItemColor: Colors.amber[800], // Puedes sobreescribir aquí si quieres
        // unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Para que todos los labels se vean siempre
        // type: BottomNavigationBarType.shifting, // Efecto de animación y cambio de color de fondo
      ),
    );
  }
}

// Widget Placeholder simple para pantallas no implementadas
class PlaceholderWidget extends StatelessWidget {
  final Color color;
  final String text;
  const PlaceholderWidget({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Añadimos Scaffold para que tenga AppBar si es necesario
      appBar: AppBar(title: Text(text)),
      body: Container(
        color: color.withOpacity(0.3),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}