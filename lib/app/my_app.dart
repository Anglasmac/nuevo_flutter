// lib/app/my_app.dart
import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/app/theme/app_theme.dart'; // <- Reemplaza nuevo_proyecto_flutter
import 'package:nuevo_proyecto_flutter/features/auth/screens/login_screen.dart'; // <- Reemplaza <your_app_name>
// Importa tus rutas si las implementas
// import 'package:template_flutter_web/app/routes/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Tracker App', // Cambia el título de tu app
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context), // Opcional: si tienes tema oscuro
      themeMode: ThemeMode.system, // O ThemeMode.light / ThemeMode.dark
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(), // Pantalla inicial
      // --- Opciones de Navegación (descomenta si usas rutas nombradas) ---
      // initialRoute: AppRouter.initialRoute, // Si usas rutas nombradas
      // routes: AppRouter.routes,             // Si usas rutas nombradas simples
      // onGenerateRoute: AppRouter.onGenerateRoute, // Si usas rutas generadas
    );
  }
}