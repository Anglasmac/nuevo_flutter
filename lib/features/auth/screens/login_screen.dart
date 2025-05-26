// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
// Importa las pantallas a las que navegas DESPUÉS del login
import 'package:nuevo_proyecto_flutter/features/home/screens/home_screen.dart'; // <- Reemplaza
import 'package:nuevo_proyecto_flutter/features/employees/screens/empleados_task_screen.dart'; // <- Reemplaza
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nuevo_proyecto_flutter/services/api_service.dart';

// Antes era LoginWidget
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;

  final ApiService _apiService = ApiService(); // Instancia de ApiService

  Future<void> _login(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('http://localhost:3000/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Respuesta login: $data'); // <-- Imprime el JSON recibido

        // Validar que el token no sea null y sea String
        final dynamic tokenRaw = data['token'];
        final String? token = (tokenRaw != null && tokenRaw is String) ? tokenRaw : null;

        if (token == null || token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se recibió un token válido del servidor. Respuesta: $data'),
              backgroundColor: Colors.redAccent,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        _apiService.setAuthToken(token);

        // Validar el rol de usuario
        final dynamic user = data['user'];
        String? role;
        if (user != null && user is Map && user['role'] != null && user['role'] is Map) {
          final dynamic roleName = user['role']['name'];
          if (roleName != null && roleName is String) {
            role = roleName;
          }
        }

        if (role == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (role != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EmpleadosTaskScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo determinar el rol del usuario. Respuesta: $data'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de autenticación: ${response.body}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _validateCredentials(String email, String password) {
    _login(email, password);
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                          controller: _emailController,
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
                                _emailController.text.trim(), // trim() quita espacios
                                _passwordController.text,
                             );
                          },
                        ),
                        const SizedBox(height: 32.0),

                        // Botón de iniciar sesión
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  _validateCredentials(
                                    _emailController.text.trim(),
                                    _passwordController.text,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48), // Ancho completo, altura fija
                            // backgroundColor: const Color.fromARGB(255, 155, 14, 14), // Color específico anterior
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Iniciar sesión'), // Estilo del texto se hereda del tema
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