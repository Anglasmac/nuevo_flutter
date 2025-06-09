// lib/app/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Definimos los colores principales de tu marca
  // El color beige ya no se usará como fondo principal, pero lo dejamos por si lo necesitas.
  static const Color _beigeBackground = Color(0xFFd0b88e); 
  static const Color _darkBrownText = Color(0xFF5C4033);
  static const Color _burgundyAccent = Color(0xFF9e3535); 
  static const Color _loginButtonRed = Color(0xFF8C1616);
  static const Color _white = Colors.white;
  static const Color _black = Colors.black;
  static const Color _errorRed = Color(0xFFdc3545);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: _burgundyAccent,
      // <-- CAMBIO 1: El fondo principal ahora es blanco.
      scaffoldBackgroundColor: _white, 
      hintColor: _darkBrownText.withOpacity(0.6),

      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: _burgundyAccent,
        onPrimary: _white,
        secondary: _loginButtonRed,
        onSecondary: _white,
        error: _errorRed,
        onError: _white,
        surface: _white, // Las tarjetas y superficies seguirán siendo blancas, pero se diferenciarán por la sombra (elevation)
        onSurface: _darkBrownText,
      ),

      textTheme: TextTheme(
        displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _darkBrownText),
        displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _darkBrownText),
        displaySmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _darkBrownText),
        titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _darkBrownText),
        titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _darkBrownText),
        titleSmall: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _darkBrownText),
        bodyLarge: const TextStyle(fontSize: 16, color: _darkBrownText),
        bodyMedium: TextStyle(fontSize: 14, color: _darkBrownText.withOpacity(0.85)),
        bodySmall: TextStyle(fontSize: 12, color: _darkBrownText.withOpacity(0.7)),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _white),
        labelMedium: const TextStyle(fontSize: 12, color: _darkBrownText),
        labelSmall: TextStyle(fontSize: 10, color: _darkBrownText.withOpacity(0.7)),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: _white,
        elevation: 1,
        iconTheme: IconThemeData(color: _darkBrownText),
        titleTextStyle: TextStyle(
          color: _darkBrownText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _loginButtonRed,
          foregroundColor: _white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          elevation: 2,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _burgundyAccent,
           textStyle: const TextStyle(fontWeight: FontWeight.w600),
        )
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _burgundyAccent,
          side: const BorderSide(color: _burgundyAccent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: _black, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: _burgundyAccent, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: _errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: _errorRed, width: 2.0),
        ),
        labelStyle: TextStyle(color: _darkBrownText.withOpacity(0.8)),
        hintStyle: TextStyle(color: _darkBrownText.withOpacity(0.5)),
        errorStyle: const TextStyle(color: _errorRed, fontWeight: FontWeight.w500),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _white,
        selectedItemColor: _burgundyAccent,
        unselectedItemColor: _darkBrownText.withOpacity(0.7),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        showUnselectedLabels: true,
        elevation: 4,
      ),

      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: _white,
        surfaceTintColor: _white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: _white,
        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _darkBrownText),
        contentTextStyle: TextStyle(fontSize: 16, color: _darkBrownText.withOpacity(0.85)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),

      // <-- CAMBIO 2: El menú lateral (drawer) también será blanco para mantener la consistencia.
      drawerTheme: const DrawerThemeData(
        backgroundColor: _white,
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: _darkBrownText,
        textColor: _darkBrownText,
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(_burgundyAccent.withOpacity(0.7)),
        // <-- CAMBIO 3: La pista del scrollbar ahora es gris claro para que se vea sobre el fondo blanco.
        trackColor: WidgetStateProperty.all(Colors.grey[200]),
        radius: const Radius.circular(10),
        thickness: WidgetStateProperty.all(6),
        thumbVisibility: WidgetStateProperty.all(false),
      ),
    );
  }

  static ThemeData get darkTheme {
    debugPrint("ADVERTENCIA: Se solicitó el tema oscuro, pero se utiliza el tema claro como fallback.");
    return lightTheme;
  }
}