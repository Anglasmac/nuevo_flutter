// lib/app/theme/app_theme.dart
import 'package:flutter/material.dart';

// Tu código de AppTheme existente va aquí
class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      hintColor: Colors.blueAccent,
      scaffoldBackgroundColor: Colors.white,
      textTheme: TextTheme(
        displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
        bodyLarge: TextStyle(fontSize: 14, color: Colors.grey[800]),
        bodyMedium: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      appBarTheme:  const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        // Asegúrate de que el estilo del título sea consistente si no usas el TextTheme por defecto
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500) // Ejemplo
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
        surface: Colors.white,
        primary: Colors.blue, // Define el primario explícitamente
        secondary: Colors.blueAccent, // Color del texto sobre el primario
        onSecondary: Colors.white, // Color del texto sobre el secundario
        onSurface: Colors.black, // Color del texto sobre el fondo
        onError: Colors.white, // Color del texto sobre errores
        error: Colors.redAccent, // Color para errores
      ),
      elevatedButtonTheme: ElevatedButtonThemeData( // Estilo global de botones elevados
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // Color de fondo
          foregroundColor: Colors.white, // Color del texto/icono
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Padding
        ),
      ),
      inputDecorationTheme: InputDecorationTheme( // Estilo global para TextFields
         border: OutlineInputBorder(
           borderRadius: BorderRadius.circular(8.0),
           borderSide: BorderSide(color: Colors.grey.shade400),
         ),
         focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(8.0),
           borderSide: const BorderSide(color: Colors.blue, width: 2.0),
         ),
         labelStyle: TextStyle(color: Colors.grey.shade600),
         contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
       bottomNavigationBarTheme: const BottomNavigationBarThemeData( // Estilo para BottomNavBar
         selectedItemColor: Colors.blue,
         unselectedItemColor: Colors.grey,
         showUnselectedLabels: true, // Muestra etiquetas aunque no estén seleccionadas
       ),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    // Define tu tema oscuro aquí si lo necesitas
    return ThemeData(
      brightness: Brightness.dark,
      hintColor: Colors.blueAccent,
      scaffoldBackgroundColor: Colors.grey[900], // Fondo oscuro
      textTheme: const TextTheme( // Textos claros sobre fondo oscuro
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 14, color: Colors.white70),
        bodyMedium: TextStyle(fontSize: 12, color: Colors.white54),
      ),
       appBarTheme: AppBarTheme( // AppBar oscura
        backgroundColor: Colors.grey[850],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey, brightness: Brightness.dark).copyWith(
          surface: Colors.grey[850], // Superficies oscuras
          primary: Colors.blueAccent,
          secondary: Colors.lightBlueAccent,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onError: Colors.black,
          error: Colors.red,
        ),
      elevatedButtonTheme: ElevatedButtonThemeData( // Botones en tema oscuro
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.black, // Texto oscuro sobre botón claro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
       inputDecorationTheme: InputDecorationTheme( // Inputs en tema oscuro
         border: OutlineInputBorder(
           borderRadius: BorderRadius.circular(8.0),
           borderSide: BorderSide(color: Colors.grey.shade700),
         ),
         focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(8.0),
           borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
         ),
         labelStyle: TextStyle(color: Colors.grey.shade400),
          fillColor: Colors.grey[800], // Relleno para inputs
          filled: true,
         contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
       ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData( // BottomNavBar oscuro
         selectedItemColor: Colors.blueAccent,
         unselectedItemColor: Colors.grey[500],
         backgroundColor: Colors.grey[850], // Fondo de la barra
         showUnselectedLabels: true,
       ),
    );
  }
}