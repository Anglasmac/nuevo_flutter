// lib/app/my_app.dart
import 'package:flutter/material.dart';
// Asegúrate que la ruta de importación sea la correcta para tu proyecto
import 'package:nuevo_proyecto_flutter/app/theme/app_theme.dart'; 
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nuevo_proyecto_flutter/features/auth/screens/login_screen.dart';
// Importa tus rutas si las implementas
// import 'package:template_flutter_web/app/routes/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Tracker App', 
      theme: AppTheme.lightTheme, // CAMBIO: Sin paréntesis, ya que es un getter
      darkTheme: AppTheme.darkTheme, // CAMBIO: Sin paréntesis, ya que es un getter
      themeMode: ThemeMode.system, // Esto está bien. Si el sistema pide oscuro, obtendrá lightTheme.
      debugShowCheckedModeBanner: false,
       localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),       // Inglés (buena práctica tenerlo como fallback)
        Locale('es', 'CO'),    // Español de Colombia
      ],
      // Establece el idioma por defecto de la aplicación
      locale: const Locale('es', 'CO'),
      home: const LoginScreen(), 
      // --- Opciones de Navegación (descomenta si usas rutas nombradas) ---
      // initialRoute: AppRouter.initialRoute, 
      // routes: AppRouter.routes,             
      // onGenerateRoute: AppRouter.onGenerateRoute, 
    );
  }
}