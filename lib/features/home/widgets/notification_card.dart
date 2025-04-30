// lib/features/home/widgets/notification_card.dart
import 'package:flutter/material.dart';

// Widget específico para mostrar la tarjeta de notificación en la LandingScreen
class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Acceder al tema

    return Card( // Envuelve en una Card para darle elevación y forma
      elevation: 2.0,
      margin: EdgeInsets.zero, // Quitamos el margen por defecto de Card si el padding se maneja afuera
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias, // Para que la imagen respete los bordes redondeados
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen destacada
          // Usar Hero si planeas una transición animada a otra pantalla con la misma imagen
          Hero(
            tag: 'notificationImage', // Un tag único para la animación Hero
            child: Image.asset(
              'assets/images/comida2.jpg', // Verifica esta ruta en tu pubspec.yaml
              width: double.infinity, // Ocupa todo el ancho de la Card
              height: 150.0, // Altura fija para la imagen
              fit: BoxFit.cover, // Escala la imagen para cubrir el espacio
              errorBuilder: (context, error, stackTrace) => Container( // Placeholder si la imagen falla
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey))
              ),
            ),
          ),
          // Contenido de texto debajo de la imagen
          Padding(
            padding: const EdgeInsets.all(16.0), // Padding interno para el texto
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saludo o título principal de la notificación
                Text(
                  'Bienvenida, Lina', // Podría venir de los datos del usuario
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600), // Estilo del tema
                ),
                const SizedBox(height: 8.0), // Espacio entre textos
                // Texto de la notificación
                Text(
                  'Notificación: Hay nuevas órdenes de producción listas para revisar en la sección correspondiente.', // Texto más detallado
                  style: theme.textTheme.bodyMedium, // Estilo del tema para cuerpo de texto
                ),
                 const SizedBox(height: 12.0),
                 // Opcional: Botón de acción dentro de la tarjeta
                 Align(
                   alignment: Alignment.centerRight,
                   child: TextButton(
                     onPressed: () {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Ir a Órdenes (Pendiente)')),
                       );
                     },
                     child: const Text('Ver Órdenes'),
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