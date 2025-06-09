// lib/features/reservas/widgets/reservation_form.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart';

class ReservationForm extends StatefulWidget {
  final DateTime? initialDate;
  final Reserva? existingReserva;
  final Function(Reserva reservaData) onSave;

  const ReservationForm({
    this.initialDate,
    this.existingReserva,
    required this.onSave,
    super.key,
  });

  @override
  State<ReservationForm> createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _eventNameController;
  late TextEditingController _eventDateController;
  late TextEditingController _eventTimeController;
  late TextEditingController _eventLocationController;
  late TextEditingController _observationsController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();

    _eventNameController = TextEditingController();
    _eventLocationController = TextEditingController();
    _observationsController = TextEditingController();

    final dateFormatter = DateFormat.yMd();
    final timeFormatter = DateFormat.jm();

    if (widget.existingReserva != null) {
      // --- MODO EDICIÓN ---
      final reserva = widget.existingReserva!;
      _eventNameController.text = reserva.eventName;
      
      // ===== CORRECCIÓN 1 =====
      // Usamos el getter `reservationDate` que es el nombre correcto en el modelo.
      _selectedDate = reserva.reservationDate; 
      _selectedTime = TimeOfDay.fromDateTime(reserva.reservationDate);
      _eventDateController = TextEditingController(text: dateFormatter.format(_selectedDate!));
      _eventTimeController = TextEditingController(text: timeFormatter.format(reserva.reservationDate));
      
      _eventLocationController.text = reserva.location ?? '';
      _observationsController.text = reserva.notes ?? '';
    } else {
      // --- MODO CREACIÓN ---
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedTime = TimeOfDay.now();
      _eventDateController = TextEditingController(text: dateFormatter.format(_selectedDate!));
      final initialDateTimeForTimeCtrl = DateTime.now().copyWith(
          hour: _selectedTime!.hour, minute: _selectedTime!.minute);
      _eventTimeController = TextEditingController(text: timeFormatter.format(initialDateTimeForTimeCtrl));
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDateController.dispose();
    _eventTimeController.dispose();
    _eventLocationController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _eventDateController.text = DateFormat.yMd().format(_selectedDate!);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        final now = DateTime.now();
        final dt = DateTime(now.year, now.month, now.day, _selectedTime!.hour, _selectedTime!.minute);
        _eventTimeController.text = DateFormat.jm().format(dt);
      });
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _eventNameController.clear();
    _eventLocationController.clear();
    _observationsController.clear();
    setState(() {
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedTime = TimeOfDay.now();
      _eventDateController.text = DateFormat.yMd().format(_selectedDate!);
      final now = DateTime.now();
      _eventTimeController.text = DateFormat.jm().format(now.copyWith(
          hour: _selectedTime!.hour, minute: _selectedTime!.minute));
    });
    FocusScope.of(context).unfocus();
  }

  void _submitFormForSave() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor, seleccione fecha y hora'),
              backgroundColor: Colors.orangeAccent),
        );
        return;
      }

      final DateTime combinedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // ===== CORRECCIÓN 2 =====
      // Al crear el objeto Reserva, usamos el parámetro `reservationDate:`
      final Reserva reservaParaGuardar = Reserva(
         id: widget.existingReserva?.id,
         eventName: _eventNameController.text.trim(),
         reservationDate: combinedDateTime, // Usamos el nombre de parámetro correcto
         location: _eventLocationController.text.trim().isNotEmpty 
                    ? _eventLocationController.text.trim() 
                    : null,
         notes: _observationsController.text.trim().isNotEmpty 
                  ? _observationsController.text.trim() 
                  : null,
         color: widget.existingReserva?.color ?? Colors.blue,
      );

      if (kDebugMode) {
        print('Datos del formulario listos para guardar:');
        print('  ID: ${reservaParaGuardar.id}');
        print('  Nombre: ${reservaParaGuardar.eventName}');
        // Usamos la propiedad correcta para imprimir también
        print('  Fecha y Hora: ${reservaParaGuardar.reservationDate}');
        print('  Ubicación: ${reservaParaGuardar.location}');
        print('  Notas: ${reservaParaGuardar.notes}');
        print('  Color: ${reservaParaGuardar.color}');
      }

      widget.onSave(reservaParaGuardar);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, corrija los errores en el formulario'),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _eventNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del evento *',
              prefixIcon: Icon(Icons.event_note_outlined),
            ),
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre del evento es obligatorio';
              }
              if (value.trim().length < 3) {
                return 'El nombre debe tener al menos 3 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _eventDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                      labelText: 'Fecha *',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.edit_calendar_outlined),
                        tooltip: 'Seleccionar Fecha',
                        onPressed: () => _selectDate(context),
                      )),
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (_selectedDate == null) {
                      return 'Seleccione una fecha';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _eventTimeController,
                  readOnly: true,
                  decoration: InputDecoration(
                      labelText: 'Hora *',
                      prefixIcon: const Icon(Icons.access_time_outlined),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Seleccionar Hora',
                        onPressed: () => _selectTime(context),
                      )),
                  onTap: () => _selectTime(context),
                  validator: (value) {
                    if (_selectedTime == null) {
                      return 'Seleccione una hora';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _eventLocationController,
            decoration: const InputDecoration(
              labelText: 'Ubicación (Opcional)',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _observationsController,
            decoration: const InputDecoration(
              labelText: 'Observaciones (Opcional)',
              prefixIcon: Icon(Icons.notes_outlined),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _clearForm,
                style: TextButton.styleFrom(foregroundColor: theme.textTheme.bodyLarge?.color?.withOpacity(0.7) ?? Colors.grey[600]),
                child: const Text('Limpiar'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: Text(widget.existingReserva == null ? 'Guardar Reserva' : 'Actualizar Reserva'),
                onPressed: _submitFormForSave,
              ),
            ],
          ),
        ],
      ),
    );
  }
}