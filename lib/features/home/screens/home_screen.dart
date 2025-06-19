// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/features/home/screens/landing_screen.dart';
import 'package:nuevo_proyecto_flutter/features/employees/screens/employee_list_screen.dart';
// --- CORRECCIÓN DE RUTA ---
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

  // Función centralizada para cambiar de pestaña.
  void _navigateToTab(int index) {
    if (index >= 0 && index < 5) { // 5 es el número de pestañas
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Hacemos la lista de widgets una propiedad de la clase para poder pasar la función `_navigateToTab`.
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Inicializamos la lista aquí para tener acceso a `_navigateToTab`.
    // Pasamos la función como un callback a LandingScreen.
    _widgetOptions = <Widget>[
      LandingScreen(onNavigate: _navigateToTab), // Índice 0
      const ProductsListScreen(),                 // Índice 1
      const EmployeeListScreen(),                 // Índice 2
      const ReservasCalendarScreen(),             // Índice 3
      const OrderProductionScreen(),              // Índice 4
    ];
  }

  // El callback del BottomNavigationBar ahora usa nuestra función centralizada.
  void _onItemTapped(int index) {
     _navigateToTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos la lista de widgets de la clase, que se actualiza con el `_selectedIndex`.
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
          BottomNavigationBarItem(
            icon: Icon(Icons.cake_outlined),
            activeIcon: Icon(Icons.cake),
            label: 'Productos',
          ),
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
        type: BottomNavigationBarType.fixed, // Mantiene los labels visibles
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
      ),
    );
  }
}