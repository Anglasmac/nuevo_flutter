// lib/features/auth/screens/login_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/features/auth/services/auth_service.dart'; // Asegúrate que la ruta sea correcta
import 'package:nuevo_proyecto_flutter/features/home/screens/home_screen.dart';
import 'package:nuevo_proyecto_flutter/features/employees/screens/empleados_task_screen.dart';
// Importa el modelo User si necesitas acceder a más datos del usuario después del login
// import 'package:nuevo_proyecto_flutter/features/auth/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController(); // Idealmente, este es el email
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Instancia del servicio
  final _formKey = GlobalKey<FormState>(); // Para validación del formulario

  bool _passwordVisible = false;
  bool _isLoading = false; // Para mostrar un indicador de carga

  Future<void> _loginUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _usernameController.text.trim();
        final password = _passwordController.text;

        final loginResponse = await _authService.login(email, password);

        // Login exitoso
        // Ahora usamos el getter 'roleName' de nuestro modelo User
        if (kDebugMode) {
          print("Login exitoso: Usuario ${loginResponse.user.email}, Rol ID: ${loginResponse.user.idRole}, Rol Nombre: ${loginResponse.user.roleName}");
        }
        
        if (!mounted) return;

        // Navegación basada en el getter roleName
        // Convertimos a minúsculas para una comparación insensible a mayúsculas/minúsculas
        final String userRoleName = loginResponse.user.roleName.toLowerCase();

        if (userRoleName == "admin") { // Comparando con el string del getter
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (userRoleName == "employee" || userRoleName == "user") { // Ajusta 'employee' y 'user' según los strings que devuelve tu getter roleName
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EmpleadosTaskScreen()),
          );
        } else {
          // Rol desconocido o no manejado
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rol de usuario no reconocido: ${loginResponse.user.roleName}'), // Muestra el roleName
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }

      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8), // Considera usar theme.colorScheme.background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form( // Envuelve tu columna con un Form widget
              key: _formKey, // Asigna la GlobalKey
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 180.0,
                    height: 180.0,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: Image.asset(
                      'assets/images/fipModificado.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.business_center, size: 80, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    'Inicio de Sesión',
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface), // Ajustado
                  ),
                  const SizedBox(height: 32.0),
                  Material(
                    color: colorScheme.surface,
                    elevation: 2.0,
                    borderRadius: BorderRadius.circular(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Email', // Cambiado de 'Usuario' a 'Email'
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) { // Validador simple
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, ingresa tu email.';
                              }
                              if (!value.contains('@')) { // Validación muy básica de email
                                return 'Por favor, ingresa un email válido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
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
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (!_isLoading) _loginUser();
                            },
                            validator: (value) { // Validador simple
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingresa tu contraseña.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32.0),
                          _isLoading
                              ? const CircularProgressIndicator() // Muestra indicador de carga
                              : ElevatedButton(
                                  onPressed: _loginUser,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 48),
                                  ),
                                  child: const Text('Iniciar sesión'),
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  TextButton(
                    onPressed: _isLoading ? null : () { // Deshabilita si está cargando
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
      ),
    );
  }
}