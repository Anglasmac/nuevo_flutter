// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Importa el paquete provider
import 'package:nuevo_proyecto_flutter/app/my_app.dart';
import 'package:nuevo_proyecto_flutter/features/auth/provider/auth_provider.dart'; // 2. Importa tu AuthProvider

void main() async { // 3. Haz que la función main sea async
  // 4. Asegúrate de que los widgets estén inicializados antes de cualquier otra cosa.
  // Es crucial para operaciones async antes de runApp, como el chequeo de sesión.
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // No necesitas inicializar Firebase aquí a menos que lo uses, pero el patrón es correcto.

  // 5. Envuelve tu app con el Provider
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}