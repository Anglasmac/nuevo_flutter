// lib/features/home/widgets/notification_card.dart
import 'package:flutter/material.dart';

// Widget específico para mostrar la tarjeta de notificación en la LandingScreen
class NotificationCard extends StatelessWidget {
  final String userName;
  final String notificationText;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final String imageUrl; // URL o asset de la imagen

  const NotificationCard({
    super.key,
    required this.userName,
    required this.notificationText,
    required this.buttonText,
    required this.onButtonPressed,
    this.imageUrl = 'lib/assets/images/login.jpg', // Imagen por defecto
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4.0, // Un poco más de elevación para destacarla
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen destacada
          Hero(
            tag: 'notificationImage', // Tag único
            child: Image.asset(
              imageUrl, // Usa la imagen pasada como parámetro
              width: double.infinity,
              height: 150.0,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: Center(child: Icon(Icons.image_not_supported, color: Colors.grey[600]))
              ),
            ),
          ),
          // Contenido de texto
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saludo o título principal
                Text(
                  'Hola, $userName', // Saludo personalizado
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                // Texto de la notificación (ahora dinámico)
                Text(
                  notificationText,
                  style: theme.textTheme.bodyMedium,
                ),
                 const SizedBox(height: 16.0),
                 // Botón de acción
                 Align(
                   alignment: Alignment.centerRight,
                   child: TextButton(
                     onPressed: onButtonPressed, // Usa el callback pasado
                     child: Text(buttonText), // Texto del botón dinámico
                   ),
                 )
              ],
            ),
          ),
        ],
      ),
    );
  }
}