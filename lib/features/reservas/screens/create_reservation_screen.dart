// lib/features/reservas/screens/create_reservation_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  Future<void> _handleSaveReservation(Reserva formData) async {
    setState(() {
      _isSaving = true;
    });

    // ===== CORRECCIÓN 3 =====
    // Aquí construimos el objeto final para la API. Ya viene bien construido
    // desde el `ReservationForm`, así que solo lo pasamos.
    // Si necesitáramos reconstruirlo, usaríamos `reservationDate:`
    final Reserva newReservationToApi = Reserva(
      eventName: formData.eventName,
      reservationDate: formData.reservationDate, // Usamos el nombre de parámetro correcto
      location: formData.location,
      notes: formData.notes,
      color: formData.color,
    );

    try {
      final Reserva createdReservation = await _apiService.createReservation(newReservationToApi);
      
      if (!mounted) return; // Buena práctica: verificar si el widget sigue en pantalla

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservación "${createdReservation.eventName}" creada con éxito.')),
      );
      Navigator.of(context).pop(true);

    } catch (e) {
      if (!mounted) return;
      
      print("Error al crear reserva en pantalla: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear reservación: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ReservationForm(
              initialDate: widget.selectedDate,
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