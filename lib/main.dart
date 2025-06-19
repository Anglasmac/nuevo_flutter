// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_proyecto_flutter/features/auth/provider/auth_provider.dart';
import 'package:nuevo_proyecto_flutter/features/auth/screens/login_screen.dart'; // Asegúrate de tener esta pantalla y la ruta correcta
import 'package:nuevo_proyecto_flutter/features/home/screens/home_screen.dart';   // Tu pantalla principal (con la barra de navegación)

void main() async {
  // Asegura la inicialización de los bindings de Flutter.
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa el formateo de fechas para español-Colombia.
  await initializeDateFormatting('es_CO', null);

  // Envuelve la aplicación entera con el ChangeNotifierProvider.
  // Así, AuthProvider estará disponible en todo el árbol de widgets.
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tu Aplicación',
      theme: ThemeData(
        // Aquí puedes definir tu tema global.
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // El punto de entrada ahora es AuthWrapper.
      home: const AuthWrapper(),
      // Define tus rutas principales para una navegación más limpia.
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

/// Un widget que decide qué pantalla mostrar basado en el estado de autenticación.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios en AuthProvider.
    final authProvider = context.watch<AuthProvider>();

    // Mientras el AuthProvider está comprobando el estado inicial, muestra un spinner.
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Si el usuario está autenticado, muéstrale la pantalla principal.
    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } 
    // Si no, muéstrale la pantalla de login.
    else {
      return const LoginScreen();
    }
  }
}