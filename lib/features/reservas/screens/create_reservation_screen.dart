// lib/features/reservas/screens/create_reservation_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Ajusta estas rutas según tu estructura y nombre de paquete
import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart';
import 'package:nuevo_proyecto_flutter/features/reservas/widgets/reservation_form.dart';
import 'package:nuevo_proyecto_flutter/services/api_service.dart';


class CreateReservationScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const CreateReservationScreen({this.selectedDate, super.key});

  @override
  State<CreateReservationScreen> createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final ApiService _apiService = ApiService();
  bool _isSaving = false;

  // Este método será llamado por ReservationFormWidget cuando el usuario guarde
  // O puedes mover la lógica de guardado aquí si ReservationFormWidget solo devuelve los datos.
  Future<void> _handleSaveReservation(Reserva formData) async {
    setState(() {
      _isSaving = true;
    });

    // Construye el objeto Reserva con los datos del formulario
    // El ID será null si el backend lo genera.
    // El color puede ser uno por defecto o seleccionado en el form.
    final Reserva newReservationToApi = Reserva(
      eventName: formData.eventName,
      eventDateTime: formData.eventDateTime, // Asegúrate que el form provea la fecha y hora correctas
      location: formData.location,
      notes: formData.notes,
      color: formData.color, // O un color por defecto si no se selecciona en el form
    );

    try {
      final Reserva createdReservation = await _apiService.createReservation(newReservationToApi);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservación "${createdReservation.eventName}" creada con ID: ${createdReservation.id}')),
      );
      Navigator.of(context).pop(true); // Devuelve true para indicar éxito y recargar en la pantalla anterior

    } catch (e) {
      print("Error al crear reserva en pantalla: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear reservación: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedDate == null 
            ? 'Crear Reserva' 
            : 'Crear Reserva para ${DateFormat.yMd().format(widget.selectedDate!)}'),
        leading: IconButton(
           icon: const Icon(Icons.close),
           tooltip: 'Cancelar',
           onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Stack( // Usamos Stack para superponer el indicador de carga
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ReservationForm( // Asume que ReservationForm tiene un callback onSave
              initialDate: widget.selectedDate,
              // El onSave de ReservationForm debería devolver un objeto Reserva poblado
              onSave: (Reserva reservaDelFormulario) { 
                _handleSaveReservation(reservaDelFormulario);
              },
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}