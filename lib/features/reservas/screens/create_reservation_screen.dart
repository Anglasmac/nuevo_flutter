import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart';
import 'package:nuevo_proyecto_flutter/features/reservas/widgets/reservation_form.dart';
import 'package:nuevo_proyecto_flutter/services/api_service.dart';

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

  Future<void> _handleSaveReservation(Reserva formData) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final isEditing = widget.existingReserva != null;
      if (isEditing) {
        await _apiService.updateReservation(formData.idReservations!, formData);
      } else {
        await _apiService.createReservation(formData);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reserva ${isEditing ? "actualizada" : "creada"} con éxito.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      
      // ✅ MANEJO DE ERRORES MEJORADO
      String errorMessage = "Ocurrió un error inesperado.";
      final errorString = e.toString();
      
      // Intenta parsear errores específicos del backend
      if (errorString.contains("errors")) {
        try {
          final jsonErrorString = errorString.substring(errorString.indexOf('{'));
          final decodedError = json.decode(jsonErrorString);
          final List errors = decodedError['errors'];
          if (errors.isNotEmpty) {
            errorMessage = errors[0]['msg'];
          }
        } catch (jsonError) {
          print("No se pudo parsear el JSON de error (errors): $jsonError");
        }
      } else if (errorString.contains("message")) {
         try {
          final jsonErrorString = errorString.substring(errorString.indexOf('{'));
          final decodedError = json.decode(jsonErrorString);
          errorMessage = decodedError['message'] ?? errorMessage;
        } catch (jsonError) {
          print("No se pudo parsear el JSON de error (message): $jsonError");
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
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
          ReservationForm(
            initialDate: widget.selectedDate,
            existingReserva: widget.existingReserva,
            onSave: _handleSaveReservation,
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
