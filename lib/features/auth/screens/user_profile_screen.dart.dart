// lib/features/auth/screens/user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nuevo_proyecto_flutter/features/auth/provider/auth_provider.dart';
import 'package:nuevo_proyecto_flutter/services/user_service.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos 'watch' para que la UI se reconstruya si el usuario cambia.
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    // Si el usuario aún no está cargado o es nulo, mostramos un mensaje.
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mi Perfil')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_outlined, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text("No se pudo cargar la información del perfil."),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileHeader(context, user),
          const SizedBox(height: 24),
          _buildInfoCard(context, user),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.lock_reset),
            label: const Text('Cambiar Contraseña'),
            onPressed: () => _showEditPasswordDialog(context, user.idUsers),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.fullName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, dynamic user) {
    return Card(
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildProfileInfoTile(
            context,
            icon: Icons.badge_outlined,
            title: 'Rol de Usuario',
            subtitle: user.roleName.toUpperCase(),
          ),
          const Divider(height: 1),
          _buildProfileInfoTile(
            context,
            icon: Icons.credit_card_outlined,
            title: 'Documento',
            subtitle: '${user.documentType} ${user.document}',
          ),
          const Divider(height: 1),
          _buildProfileInfoTile(
            context,
            icon: Icons.phone_android_outlined,
            title: 'Celular',
            subtitle: user.cellphone.isNotEmpty ? user.cellphone : 'No registrado',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoTile(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  void _showEditPasswordDialog(BuildContext context, int userId) {
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();
    final userService = UserService();

    showDialog(
      context: context,
      barrierDismissible: false, // El usuario debe presionar un botón para cerrar.
      builder: (dialogContext) {
        // Usamos StatefulBuilder para manejar el estado de carga del botón.
        return StatefulBuilder(
          builder: (context, setState) {
            bool isLoading = false;
            return AlertDialog(
              title: const Text('Editar Contraseña'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nueva Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la nueva contraseña';
                    }
                    if (value.length < 6) { // Ejemplo de validación
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setState(() => isLoading = true);
                      try {
                        await userService.updatePassword(userId, passwordController.text);
                        // Usamos el 'dialogContext' para cerrar el diálogo
                        Navigator.of(dialogContext).pop(); 
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contraseña actualizada con éxito'), backgroundColor: Colors.green),
                        );
                      } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red),
                         );
                      } finally {
                         // Aseguramos que el estado de carga se desactive
                         setState(() => isLoading = false);
                      }
                    }
                  },
                  child: isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}