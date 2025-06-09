// lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/features/home/screens/home_screen.dart';
// --- CAMBIO CLAVE: Importamos la nueva pantalla de lista de empleados ---
import 'package:nuevo_proyecto_flutter/features/employees/screens/employee_list_screen.dart'; 
import 'package:nuevo_proyecto_flutter/features/auth/services/auth_service.dart';
import 'package:nuevo_proyecto_flutter/services/ase_api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _passwordVisible = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Login exitoso, pero no se recibió un token de autenticación.');
      }

      BaseApiService.setAuthToken(token);

      final roleName = await _authService.getRoleName();

      if (!mounted) return;

      _navigateBasedOnRole(roleName);

    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }
  
  void _navigateBasedOnRole(String roleName) {
    Widget targetScreen;

    switch (roleName.toLowerCase()) {
      case "administrador":
        targetScreen = const HomeScreen();
        break;
      // --- CAMBIO CLAVE: Navegamos a la nueva pantalla de lista ---
      case "empleado":
        // Si un empleado inicia sesión, lo llevamos a la lista de rendimiento de empleados.
        // O podrías tener una pantalla específica para "Mi Rendimiento".
        // Por ahora, usamos la lista general que ya creamos.
        targetScreen = const EmployeeListScreen(); 
        break;
      default:
        _showErrorSnackBar('Rol de usuario no reconocido: $roleName');
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  void _showErrorSnackBar(String message) {
    final displayMessage = message.replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(displayMessage),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'app-logo',
                  child: Image.asset('assets/images/IconoFIP.png', height: 180),
                ),
                const SizedBox(height: 24.0),
                Text(
                  'Inicio de Sesión',
                  style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 32.0),
                Material(
                  color: colorScheme.background,
                  elevation: 0,
                  borderRadius: BorderRadius.circular(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || !value.contains('@')) return 'Ingresa un email válido.';
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
                                icon: Icon(_passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _isLoading ? null : _loginUser(),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Ingresa tu contraseña.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32.0),
                          _isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _loginUser,
                                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                                  child: const Text('Iniciar sesión'),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                TextButton(
                  onPressed: _isLoading ? null : () => _showErrorSnackBar('Funcionalidad no implementada.'),
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