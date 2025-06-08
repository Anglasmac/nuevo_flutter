// lib/features/reservas/widgets/reservation_form.dart
import 'package:flutter/foundation.dart'; // Para kDebugMode
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear y parsear fechas/horas

// Importa tu modelo Reserva
// ¡ASEGÚRATE DE QUE ESTA RUTA Y EL NOMBRE DEL PAQUETE SEAN CORRECTOS!
import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart';

class ReservationForm extends StatefulWidget {
  final DateTime? initialDate; // Fecha inicial opcional (viene del calendario)
  final Reserva? existingReserva; // Para modo edición
  final Function(Reserva reservaData) onSave; // Callback para pasar los datos a guardar

  const ReservationForm({
    this.initialDate,
    this.existingReserva,
    required this.onSave, // Hacer el callback requerido
    super.key,
  });

  @override
  State<ReservationForm> createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  final _formKey = GlobalKey<FormState>(); // Clave para validar el formulario

  // Controladores para los campos del formulario
  late TextEditingController _eventNameController;
  late TextEditingController _eventDateController;
  late TextEditingController _eventTimeController;
  late TextEditingController _eventLocationController;
  late TextEditingController _observationsController;

  // Variables para guardar la fecha y hora seleccionadas
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores
    _eventNameController = TextEditingController();
    _eventLocationController = TextEditingController();
    _observationsController = TextEditingController();

    final dateFormatter = DateFormat.yMd(); // Formato corto de fecha
    final timeFormatter = DateFormat.jm(); // Formato de hora AM/PM

    if (widget.existingReserva != null) {
      // --- MODO EDICIÓN ---
      final reserva = widget.existingReserva!;
      _eventNameController.text = reserva.eventName;
      _selectedDate = reserva.eventDateTime;
      _selectedTime = TimeOfDay.fromDateTime(reserva.eventDateTime);
      _eventDateController = TextEditingController(text: dateFormatter.format(_selectedDate!));
      _eventTimeController = TextEditingController(text: timeFormatter.format(reserva.eventDateTime));
      _eventLocationController.text = reserva.location ?? ''; // Usar '' si es null para el controller
      _observationsController.text = reserva.notes ?? '';   // Usar '' si es null para el controller
    } else {
      // --- MODO CREACIÓN ---
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedTime = TimeOfDay.now(); // Hora actual por defecto
      _eventDateController = TextEditingController(text: dateFormatter.format(_selectedDate!));
      // Formatea la hora actual para el controlador de texto
      final initialDateTimeForTimeCtrl = DateTime.now().copyWith(
          hour: _selectedTime!.hour, minute: _selectedTime!.minute);
      _eventTimeController = TextEditingController(text: timeFormatter.format(initialDateTimeForTimeCtrl));
    }
  }

  @override
  void dispose() {
    // Liberar los controladores
    _eventNameController.dispose();
    _eventDateController.dispose();
    _eventTimeController.dispose();
    _eventLocationController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  // --- Funciones para seleccionar Fecha y Hora ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020), // Límite inferior
      lastDate: DateTime(2030), // Límite superior
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _eventDateController.text = DateFormat.yMd().format(_selectedDate!); // Actualiza el campo de texto
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
        // Formatea la hora seleccionada para el campo de texto
        final now = DateTime.now(); // Se usa solo para obtener el año/mes/día actual para formatear
        final dt = DateTime(now.year, now.month, now.day, _selectedTime!.hour, _selectedTime!.minute);
        _eventTimeController.text = DateFormat.jm().format(dt);
      });
    }
  }

  // --- Funciones del Formulario ---
  void _clearForm() {
    _formKey.currentState?.reset(); // Resetea el estado de validación
    _eventNameController.clear();
    _eventLocationController.clear();
    _observationsController.clear();
    // Restablecer fecha y hora a los valores iniciales o actuales
    setState(() {
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedTime = TimeOfDay.now();
      _eventDateController.text = DateFormat.yMd().format(_selectedDate!);
      final now = DateTime.now();
      _eventTimeController.text = DateFormat.jm().format(now.copyWith(
          hour: _selectedTime!.hour, minute: _selectedTime!.minute));
    });
    FocusScope.of(context).unfocus(); // Oculta el teclado
  }

  void _submitFormForSave() { // Renombrado para claridad, este es el que llama el botón
    // 1. Validar el formulario
    if (_formKey.currentState?.validate() ?? false) {
      // 2. Asegurarse de que se ha seleccionado fecha y hora
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor, seleccione fecha y hora'),
              backgroundColor: Colors.orangeAccent),
        );
        return;
      }

      // 3. Combinar fecha y hora seleccionadas
      final DateTime eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // 4. Crear el objeto Reserva
      final Reserva reservaParaGuardar = Reserva(
         id: widget.existingReserva?.id, // Pasa el ID si es para editar, sino será null
         eventName: _eventNameController.text.trim(),
         eventDateTime: eventDateTime,
         location: _eventLocationController.text.trim().isNotEmpty 
                    ? _eventLocationController.text.trim() 
                    : null, // Guarda null si está vacío
         notes: _observationsController.text.trim().isNotEmpty 
                  ? _observationsController.text.trim() 
                  : null, // Guarda null si está vacío
         color: widget.existingReserva?.color ?? Colors.blue, // Reusa color o usa default
      );

      // 5. Imprimir en debug (como en tu original)
      if (kDebugMode) {
        print('Datos del formulario listos para guardar:');
        print('  ID: ${reservaParaGuardar.id}');
        print('  Nombre: ${reservaParaGuardar.eventName}');
        print('  Fecha y Hora: ${reservaParaGuardar.eventDateTime}');
        print('  Ubicación: ${reservaParaGuardar.location}');
        print('  Notas: ${reservaParaGuardar.notes}');
        print('  Color: ${reservaParaGuardar.color}');
      }

      // 6. LLAMAR AL CALLBACK onSave para que el widget padre (CreateReservationScreen) maneje la API
      widget.onSave(reservaParaGuardar);

      // Los mensajes de éxito/error y el Navigator.pop() ahora se manejarán en CreateReservationScreen
      // después de que la llamada a la API se complete.

    } else {
      // Mensaje si la validación falla
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, corrija los errores en el formulario'),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Obtener el tema para usar sus colores/estilos si es necesario

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Campo Nombre del Evento ---
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

          // --- Campos Fecha y Hora (lado a lado) ---
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
                    if (_selectedDate == null) { // O podrías validar el texto del controller si prefieres
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
                    if (_selectedTime == null) { // O podrías validar el texto del controller
                      return 'Seleccione una hora';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- Campo Ubicación (Opcional) ---
          TextFormField(
            controller: _eventLocationController,
            decoration: const InputDecoration(
              labelText: 'Ubicación (Opcional)',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // --- Campo Observaciones (Opcional, multilínea) ---
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

          // --- Botones de Acción (Guardar y Limpiar) ---
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
                onPressed: _submitFormForSave, // Llama a la función de guardado/submit
                // style: ElevatedButton.styleFrom(backgroundColor: Colors.green), // O usa el color primario del tema
              ),
            ],
          ),
        ],
      ),
    );
  }
}