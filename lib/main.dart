import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/app/my_app.dart';
// Importar inicializadores si los tienes (Firebase, etc.)

void main() async {
  // WidgetsFlutterBinding.ensureInitialized(); // Si necesitas bindings antes de runApp
  // await Firebase.initializeApp(...); // Ejemplo
  runApp(const MyApp());
}