import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Importa el formulario
import 'package:nuevo_proyecto_flutter/features/reservas/widgets/reservation_form.dart'; // <- Reemplaza

// Antes era CreateReservationPage
class CreateReservationScreen extends StatelessWidget {
  final DateTime? selectedDate; // Recibe la fecha seleccionada del calendario (opcional)

  const CreateReservationScreen({this.selectedDate, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedDate == null ? 'Crear Reserva' : 'Crear Reserva para ${DateFormat.yMd().format(selectedDate!)}'),
        leading: IconButton( // Botón para cerrar (más claro que el back por defecto)
           icon: const Icon(Icons.close),
           tooltip: 'Cancelar',
           onPressed: () => Navigator.maybePop(context), // Cierra la pantalla actual
        ),
      ),
      body: SingleChildScrollView( // Permite scroll en el formulario
         padding: const EdgeInsets.all(16.0),
         child: Column(
           children: [
             // Podrías añadir un título o descripción aquí si quieres
             // const Text(
             //   'Complete los detalles de la reserva:',
             //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
             // ),
             // const SizedBox(height: 20.0),

             // Muestra el formulario, pasando la fecha si existe
             ReservationForm(initialDate: selectedDate),

             // El botón de Guardar/Limpiar está ahora DENTRO del ReservationForm
             // const SizedBox(height: 20),
             // ElevatedButton(
             //   onPressed: () {
             //      // La lógica de guardar ahora está en el formulario
             //     // Quizás aquí podrías cerrar la pantalla si el guardado fue exitoso
             //     // Navigator.pop(context, true); // Devuelve true para indicar éxito
             //   },
             //   child: const Text('Guardar'),
             // ),
           ],
         ),
      ),
    );
  }
}