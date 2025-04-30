// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
// Importa las pantallas a las que navegas DESPUÉS del login
import 'package:nuevo_proyecto_flutter/features/home/screens/home_screen.dart'; // <- Reemplaza
import 'package:nuevo_proyecto_flutter/features/employees/screens/empleados_task_screen.dart'; // <- Reemplaza

// Antes era LoginWidget
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  void _validateCredentials(String username, String password) {
    // --- Lógica de Autenticación Real (Reemplazar) ---
    // Aquí deberías llamar a tu servicio de autenticación (API, Firebase Auth, etc.)
    // Por ahora, usamos la lógica de ejemplo:

    if (username == "admin" && password == "1234") {
      // Navega a la pantalla de Admin (HomeScreen en este caso)
      // pushReplacement evita que el usuario pueda volver al login con el botón "atrás"
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()), // Usa la pantalla correcta
      );
    } else if (username == "user" && password == "abcd") {
      // Navega a la pantalla de Empleado
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EmpleadosTaskScreen()), // Usa la pantalla correcta
      );
    } else {
      // Muestra error si las credenciales son incorrectas
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciales incorrectas'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el tema actual para colores y estilos
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Usa el color de fondo del tema, o uno específico si prefieres
      // backgroundColor: colorScheme.background, // Color del tema
      backgroundColor: const Color(0xFFF1F4F8), // Color específico anterior

      body: SafeArea(
        child: Center( // Centra el contenido verticalmente
          child: SingleChildScrollView( // Permite scroll si el contenido no cabe
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Imagen de la aplicación
                Container(
                  width: 180.0, // Ajusta tamaño si es necesario
                  height: 180.0,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    // Considera un color de fondo o borde si la imagen no llena el círculo
                    // color: Colors.grey[300],
                  ),
                  child: Image.asset(
                    'assets/images/IconoFIP.png', // Verifica esta ruta en tu pubspec.yaml
                    fit: BoxFit.cover,
                    // Añade un errorBuilder por si la imagen no carga
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.business_center, size: 80, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24.0), // Espaciado
                Text(
                  'Inicio de Sesión',
                  style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600), // Usa estilo del tema
                ),
                const SizedBox(height: 32.0),

                // Contenedor del formulario con sombra y bordes redondeados
                Material(
                  color: colorScheme.surface, // Color de superficie del tema (Blanco en light, gris oscuro en dark)
                  elevation: 2.0,
                  borderRadius: BorderRadius.circular(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Para que la columna no ocupe todo el alto
                      children: [
                        // Campo de texto para el usuario
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Usuario',
                            prefixIcon: Icon(Icons.person_outline), // Icono útil
                          ),
                          keyboardType: TextInputType.emailAddress, // O text, según el tipo de usuario
                          textInputAction: TextInputAction.next, // Va al siguiente campo al presionar Enter/Next
                        ),
                        const SizedBox(height: 16.0),

                        // Campo de texto para la contraseña
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible, // Oculta el texto
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline), // Icono útil
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                          textInputAction: TextInputAction.done, // Indica que es el último campo
                          onFieldSubmitted: (_) { // Permite iniciar sesión al presionar Enter/Done en el teclado
                             _validateCredentials(
                                _usernameController.text.trim(), // trim() quita espacios
                                _passwordController.text,
                             );
                          },
                        ),
                        const SizedBox(height: 32.0),

                        // Botón de iniciar sesión
                        ElevatedButton(
                          onPressed: () {
                            // Obtener y validar las credenciales
                            _validateCredentials(
                              _usernameController.text.trim(),
                              _passwordController.text,
                            );
                          },
                          // Usa el estilo del tema o personaliza
                           style: ElevatedButton.styleFrom(
                             minimumSize: const Size(double.infinity, 48), // Ancho completo, altura fija
                             // backgroundColor: const Color.fromARGB(255, 155, 14, 14), // Color específico anterior
                           ),
                          child: const Text('Iniciar sesión'), // Estilo del texto se hereda del tema
                        ),
                      ],
                    ),
                  ),
                ),
                // Opcional: Añadir enlace para "Olvidó su contraseña" o "Registrarse"
                 const SizedBox(height: 24.0),
                 TextButton(
                   onPressed: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Funcionalidad "Olvidé contraseña" no implementada')),
                     );
                   },
                   child: const Text('¿Olvidaste tu contraseña?'),
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}