import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear y parsear fechas/horas

// Antes era ReservationForm (ya estaba bien nombrado)
class ReservationForm extends StatefulWidget {
  final DateTime? initialDate; // Fecha inicial opcional (viene del calendario)
  // Podrías pasar una Reserva existente si es un formulario de edición
  // final Reserva? existingReserva;

  const ReservationForm({this.initialDate, super.key});

  @override
  State<ReservationForm> createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  final _formKey = GlobalKey<FormState>(); // Clave para validar el formulario

  // Controladores para los campos del formulario
  late TextEditingController _eventNameController;
  late TextEditingController _eventDateController;
  late TextEditingController _eventTimeController;
  late TextEditingController _eventLocationController; // Nuevo campo: Ubicación
  late TextEditingController _observationsController;

  // Variables para guardar la fecha y hora seleccionadas
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();

    // Inicializar fecha y hora seleccionadas
    _selectedDate =
        widget.initialDate ?? DateTime.now(); // Usa la fecha pasada o la actual
    _selectedTime = TimeOfDay.now(); // Hora actual por defecto

    // Inicializar controladores
    _eventNameController = TextEditingController();
    _eventLocationController = TextEditingController();
    _observationsController = TextEditingController();

    // Formatear fecha y hora iniciales para los controladores de texto
    final dateFormatter = DateFormat.yMd(); // Formato corto de fecha
    final timeFormatter = DateFormat.jm(); // Formato de hora AM/PM
    _eventDateController =
        TextEditingController(text: dateFormatter.format(_selectedDate!));
    _eventTimeController = TextEditingController(
        text: timeFormatter.format(DateTime.now().copyWith(
            hour: _selectedTime!.hour,
            minute: _selectedTime!.minute))); // Formatea la hora actual

    // nSi es un formulario de edición, inicializar con datos de existingReserva
    // if (widget.existingReserva != null) {
    //   final reserva = widget.existingReserva!;
    //   _eventNameController.text = reserva.eventName;
    //   _selectedDate = reserva.eventDateTime;
    //   _selectedTime = TimeOfDay.fromDateTime(reserva.eventDateTime);
    //   _eventDateController.text = dateFormatter.format(_selectedDate!);
    //   _eventTimeController.text = timeFormatter.format(reserva.eventDateTime);
    //   _eventLocationController.text = reserva.location;
    //   _observationsController.text = reserva.notes;
    // }
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
        _eventDateController.text = DateFormat.yMd()
            .format(_selectedDate!); // Actualiza el campo de texto
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
        final now = DateTime.now();
        final dt = DateTime(now.year, now.month, now.day, _selectedTime!.hour,
            _selectedTime!.minute);
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

  void _saveForm() {
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

      // 4. Crear el objeto Reserva (o actualizar si es edición)
      // final nuevaReserva = Reserva(
      //    id: widget.existingReserva?.id ?? DateTime.now().millisecondsSinceEpoch.toString(), // Reusa ID o crea nuevo
      //    eventName: _eventNameController.text.trim(),
      //    eventDateTime: eventDateTime,
      //    location: _eventLocationController.text.trim(),
      //    notes: _observationsController.text.trim(),
      //    color: widget.existingReserva?.color ?? Colors.blue // Reusa color o usa default
      // );

      // 5. nEnviar la reserva a la API o base de datos
      if (kDebugMode) {
        print('Guardando reserva:');
      }
      if (kDebugMode) {
        print('  Nombre: ${_eventNameController.text.trim()}');
      }
      if (kDebugMode) {
        print('  Fecha y Hora: $eventDateTime');
      }
      if (kDebugMode) {
        print('  Ubicación: ${_eventLocationController.text.trim()}');
      }
      if (kDebugMode) {
        print('  Notas: ${_observationsController.text.trim()}');
      }

      // 6. Mostrar mensaje de éxito y cerrar (opcionalmente devolver true)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Reserva guardada con éxito'),
            backgroundColor: Colors.green),
      );
      // Cerrar la pantalla del formulario devolviendo 'true' para indicar que se guardó algo
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
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
    Theme.of(context);

    return Form(
      // Envuelve todo en un widget Form
      key: _formKey, // Asigna la clave global
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Estira los botones al final
        children: [
          // --- Campo Nombre del Evento ---
          TextFormField(
            controller: _eventNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del evento *', // Indica campo obligatorio
              prefixIcon: Icon(Icons.event_note_outlined),
            ),
            textCapitalization:
                TextCapitalization.sentences, // Primera letra mayúscula
            validator: (value) {
              // Regla de validación
              if (value == null || value.trim().isEmpty) {
                return 'El nombre del evento es obligatorio';
              }
              if (value.length < 3) {
                return 'El nombre debe tener al menos 3 caracteres';
              }
              return null; // Válido
            },
          ),
          const SizedBox(height: 16),

          // --- Campos Fecha y Hora (lado a lado) ---
          Row(
            crossAxisAlignment: CrossAxisAlignment
                .start, // Alinea arriba por si hay errores de validación
            children: [
              // Campo Fecha (solo lectura, se actualiza con DatePicker)
              Expanded(
                child: TextFormField(
                  controller: _eventDateController,
                  readOnly: true, // No se puede escribir directamente
                  decoration: InputDecoration(
                      labelText: 'Fecha *',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      suffixIcon: IconButton(
                        // Icono para abrir DatePicker
                        icon: const Icon(Icons.edit_calendar_outlined),
                        tooltip: 'Seleccionar Fecha',
                        onPressed: () => _selectDate(context),
                      )),
                  onTap: () =>
                      _selectDate(context), // Abrir también al tocar el campo
                  validator: (value) {
                    if (_selectedDate == null) {
                      return 'Seleccione una fecha';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Campo Hora (solo lectura, se actualiza con TimePicker)
              Expanded(
                child: TextFormField(
                  controller: _eventTimeController,
                  readOnly: true,
                  decoration: InputDecoration(
                      labelText: 'Hora *',
                      prefixIcon: const Icon(Icons.access_time_outlined),
                      suffixIcon: IconButton(
                        // Icono para abrir TimePicker
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
              alignLabelWithHint:
                  true, // Alinea el label arriba para multilínea
            ),
            maxLines: 3, // Permite hasta 3 líneas visibles
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24), // Espacio antes de los botones

          // --- Botones de Acción (Guardar y Limpiar) ---
          Row(
            mainAxisAlignment:
                MainAxisAlignment.end, // Alinea botones a la derecha
            children: [
              // Botón Limpiar
              TextButton(
                onPressed: _clearForm,
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                child: const Text('Limpiar'),
              ),
              const SizedBox(width: 12),
              // Botón Guardar
              ElevatedButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar Reserva'),
                onPressed: _saveForm, // Llama a la función de guardado
                // style: ElevatedButton.styleFrom(backgroundColor: Colors.green), // Color específico si quieres
              ),
            ],
          ),
        ],
      ),
    );
  }
}
