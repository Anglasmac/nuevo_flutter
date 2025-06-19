// lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nuevo_proyecto_flutter/features/auth/provider/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Los controllers y keys se mantienen igual.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// La lógica de login sigue usando el AuthProvider, esto no cambia.
  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Si el login es exitoso, el AuthWrapper se encarga de la navegación.
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

  /// La función para mostrar errores se mantiene igual.
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

  // --- BUILD METHOD RESTAURADO A TU ESTILO ORIGINAL ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Usamos el color de fondo de tu tema.
      backgroundColor: colorScheme.surface, 
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Logo con Hero Animation
                Hero(
                  tag: 'app-logo',
                  child: Image.asset('lib/assets/images/fipModificado.png', height: 180),
                ),
                const SizedBox(height: 24.0),

                // 2. Título "Inicio de Sesión"
                Text(
                  'Inicio de Sesión',
                  style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 32.0),

                // 3. Card/Material para agrupar el formulario
                Material(
                  color: colorScheme.background,
                  elevation: 0, // Sin sombra
                  borderRadius: BorderRadius.circular(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Campo de Email
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || !value.contains('@')) {
                                return 'Ingresa un email válido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),

                          // Campo de Contraseña
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_passwordVisible 
                                    ? Icons.visibility_outlined 
                                    : Icons.visibility_off_outlined),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _isLoading ? null : _loginUser(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa tu contraseña.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32.0),

                          // Botón de Iniciar Sesión o Indicador de Carga
                          _isLoading
                              ? const CircularProgressIndicator()
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
                ),
                const SizedBox(height: 24.0),

                // 4. Botón "¿Olvidaste tu contraseña?"
                TextButton(
                  onPressed: _isLoading 
                      ? null 
                      : () => _showErrorSnackBar('Funcionalidad no implementada.'),
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