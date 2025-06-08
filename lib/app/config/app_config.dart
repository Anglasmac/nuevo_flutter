// lib/app/config/app_config.dart
class AppConfig {
  // IMPORTANTE:
  // Si tu backend corre en localhost y pruebas en un emulador Android,
  // usa 10.0.2.2 en lugar de localhost.
  // Si pruebas en un emulador iOS o dispositivo físico en la misma red,
  // usa la IP de tu máquina en la red local (ej. 192.168.1.X).
  // Si tu API está desplegada, usa la URL desplegada.
  //static const String apiBaseUrl = "http://10.0.2.2:3000"; // Ejemplo para emulador Android
  static const String apiBaseUrl = "http://localhost:3000"; // Si pruebas en web o desktop
  // static const String apiBaseUrl = "https://tu-api-desplegada.com";
}