import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart';
import 'package:nuevo_proyecto_flutter/features/reservas/widgets/reservation_form.dart';
import 'package:nuevo_proyecto_flutter/services/api_service.dart'; // Asegúrate de que este servicio y sus métodos existan.

class CreateReservationScreen extends StatefulWidget {
  final DateTime? selectedDate;
  final Reserva? existingReserva;

  const CreateReservationScreen({
    this.selectedDate,
    this.existingReserva,
    super.key,
  });

  @override
  State<CreateReservationScreen> createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final ApiService _apiService = ApiService();
  bool _isSaving = false;

  /// Maneja la lógica para guardar o actualizar una reserva.
  Future<void> _handleSaveReservation(Reserva formData) async {
    if (_isSaving) return; 

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.existingReserva != null) {
        // --- LÓGICA DE ACTUALIZACIÓN (PUT) ---
        await _apiService.updateReservation(formData.idReservations!, formData);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reserva "${formData.matter}" actualizada con éxito.')),
        );
      } else {
        // --- LÓGICA DE CREACIÓN (POST) ---
        await _apiService.createReservation(formData);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reserva "${formData.matter}" creada con éxito.')),
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = "Ocurrió un error inesperado.";
      final errorString = e.toString();
      if (errorString.contains("errors")) {
        try {
          final jsonErrorString = errorString.substring(errorString.indexOf('{'));
          final decodedError = json.decode(jsonErrorString);
          final List errors = decodedError['errors'];
          if (errors.isNotEmpty) {
            errorMessage = errors[0]['msg'];
          }
        } catch (jsonError) {
          print("No se pudo parsear el JSON de error: $jsonError");
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
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
  } // ✅ LA FUNCIÓN TERMINA AQUÍ

  // ✅ EL MÉTODO BUILD COMIENZA AQUÍ, AL MISMO NIVEL
  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.existingReserva != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Reserva' : 'Crear Reserva'),
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
              existingReserva: widget.existingReserva,
              onSave: _handleSaveReservation,
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
} // ✅ LA CLASE TERMINA AQUÍ