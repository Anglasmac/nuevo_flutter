// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/features/home/screens/landing_screen.dart';
import 'package:nuevo_proyecto_flutter/features/employees/screens/employee_list_screen.dart';
// ¡CAMBIO! Importamos la nueva pantalla de lista de productos
import 'package:nuevo_proyecto_flutter/features/product/screens/products_list_screen.dart'; 
import 'package:nuevo_proyecto_flutter/features/reservas/screens/reservas_calendar_screen.dart';
import 'package:nuevo_proyecto_flutter/features/production/screens/order_production_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    LandingScreen(),        // Índice 0: Inicio
    ProductsListScreen(), 
    EmployeeListScreen(),  // ¡CAMBIO! Índice 1: Ahora es la lista de Productos
    ReservasCalendarScreen(),
    OrderProductionScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2 && _widgetOptions[index] is PlaceholderWidget) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pantalla de Empleados no implementada todavía.')),
       );
       return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          // --- SECCIÓN CAMBIADA ---
          BottomNavigationBarItem(
            icon: Icon(Icons.cake_outlined), // Icono para productos
            activeIcon: Icon(Icons.cake),
            label: 'Productos', // Texto cambiado
          ),
          // --- FIN SECCIÓN CAMBIADA ---
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Empleados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.factory_outlined),
            activeIcon: Icon(Icons.factory),
            label: 'Producción',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// Widget Placeholder, no necesita cambios
class PlaceholderWidget extends StatelessWidget {
  final Color color;
  final String text;
  const PlaceholderWidget({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(text)),
      body: Container(
        color: color.withOpacity(0.3),
        child: Center(
          child: Text(text, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}