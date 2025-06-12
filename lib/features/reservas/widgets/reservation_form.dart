import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart';
import 'package:nuevo_proyecto_flutter/services/api_service.dart';
import 'package:nuevo_proyecto_flutter/features/clientes/models/cliente_model.dart';
import 'package:nuevo_proyecto_flutter/features/servicios/models/servicio_model.dart';

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
  final _apiService = ApiService();

  List<Cliente> _clientes = [];
  List<ServicioAdicional> _serviciosAdicionales = [];
  
  Cliente? _selectedCliente;
  List<ServicioAdicional> _selectedServicios = [];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedStatus = 'pendiente';
  List<Abono> _abonos = [];
  
  late TextEditingController _peopleController;
  late TextEditingController _durationController;
  late TextEditingController _eventTypeController;
  late TextEditingController _manualAbonoMontoController;
  late TextEditingController _notesController;
  late TextEditingController _totalPayController;
  DateTime _manualAbonoFecha = DateTime.now();

  double _decorationAmount = 0.0;
  double _remaining = 0.0;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _peopleController = TextEditingController();
    _durationController = TextEditingController();
    _eventTypeController = TextEditingController();
    _manualAbonoMontoController = TextEditingController();
    _notesController = TextEditingController();
    _totalPayController = TextEditingController();

    _peopleController.addListener(_calculateCosts);
    _totalPayController.addListener(_calculateCosts);
    
    _loadInitialData();
  }
  
  @override
  void dispose() {
    _peopleController.dispose();
    _durationController.dispose();
    _eventTypeController.dispose();
    _manualAbonoMontoController.dispose();
    _notesController.dispose();
    _totalPayController.dispose();
    super.dispose();
  }
  
  Future<void> _loadInitialData() async {
    setState(() { _isLoading = true; });
    try {
      final results = await Future.wait([
        _apiService.fetchClientes(),
        _apiService.fetchServiciosAdicionales(),
      ]);
      _clientes = results[0] as List<Cliente>;
      _serviciosAdicionales = results[1] as List<ServicioAdicional>;

      if (widget.existingReserva != null) {
        final res = widget.existingReserva!;
        _peopleController.text = res.numberPeople.toString();
        _durationController.text = res.timeDurationR;
        _eventTypeController.text = res.evenType;
        _totalPayController.text = res.totalPay.toString();
        _selectedStatus = res.status;
        _abonos = List.from(res.abonos);
        _notesController.text = res.notes ?? '';
        
        if (_clientes.isNotEmpty) {
           try {
             _selectedCliente = _clientes.firstWhere((c) => c.id == res.idCustomers);
           } catch (e) {
             print("Advertencia: El cliente con ID ${res.idCustomers} no se encontró.");
             _selectedCliente = null;
           }
        }
       
        _selectedDate = res.dateTime;
        _selectedTime = TimeOfDay.fromDateTime(res.dateTime);
        // TODO: Cargar _selectedServicios a partir de res.pass
      } else {
        _selectedDate = widget.initialDate ?? DateTime.now();
        _selectedTime = TimeOfDay.now();
        _abonos.add(Abono(fecha: DateTime.now(), monto: 50000));
        _calculateCosts();
        _totalPayController.text = _decorationAmount.toString();
      }
      
      _calculateCosts();

    } catch (e) {
      print("Error cargando datos: $e");
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  void _calculateCosts() {
    final int people = int.tryParse(_peopleController.text) ?? 0;
    
    _decorationAmount = (people >= 2 && people <= 15) ? 70000 
                      : (people >= 16 && people <= 40) ? 90000 
                      : 0;
    
    final double abonosTotal = _abonos.fold(0, (sum, item) => sum + item.monto);
    final double totalIngresado = double.tryParse(_totalPayController.text) ?? 0.0;
    
    if (_totalPayController.text.isEmpty) {
        _totalPayController.text = _decorationAmount.toString();
    }

    _remaining = totalIngresado - abonosTotal;
    
    if (mounted) setState(() {});
  }
  
  void _addManualAbono() {
    final double? monto = double.tryParse(_manualAbonoMontoController.text);
    if (monto != null && monto >= 50000) {
      setState(() {
        _abonos.add(Abono(fecha: _manualAbonoFecha, monto: monto));
        _manualAbonoMontoController.clear();
        _calculateCosts();
      });
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El monto debe ser al menos 50,000'), backgroundColor: Colors.orange),
      );
    }
  }
  
  Future<void> _selectManualAbonoDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _manualAbonoFecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _manualAbonoFecha = picked);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCliente == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debe seleccionar un cliente')));
        return;
      }
      final combinedDateTime = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        _selectedTime!.hour, _selectedTime!.minute
      );
      
      final reservaParaGuardar = Reserva(
        idReservations: widget.existingReserva?.idReservations,
        dateTime: combinedDateTime,
        numberPeople: int.parse(_peopleController.text),
        matter: _eventTypeController.text,
        timeDurationR: _durationController.text,
        pass: _selectedServicios.map((s) => s.id).toList(), 
        decorationAmount: _decorationAmount,
        remaining: _remaining,
        evenType: _eventTypeController.text,
        totalPay: double.parse(_totalPayController.text),
        status: _selectedStatus,
        idCustomers: _selectedCliente!.id,
        abonos: _abonos,
        notes: _notesController.text
      );
      widget.onSave(reservaParaGuardar);
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020), lastDate: DateTime(2030),
    );
    if (picked != null) setState(() { _selectedDate = picked; });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime ?? TimeOfDay.now());
    if (picked != null) setState(() { _selectedTime = picked; });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    
    return Form(
      key: _formKey,
      // ✅ Usamos Column porque el padre (SingleChildScrollView) ya se encarga del scroll.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Cliente y Reserva', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          DropdownButtonFormField<Cliente>(
            value: _selectedCliente,
            items: _clientes.map((cliente) => DropdownMenuItem(value: cliente, child: Text(cliente.fullName))).toList(),
            onChanged: (value) => setState(() => _selectedCliente = value),
            decoration: const InputDecoration(labelText: 'Cliente *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)),
            validator: (value) => value == null ? 'Seleccione un cliente' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(_eventTypeController, 'Tipo de Evento *', Icons.celebration_outlined, isRequired: true),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _buildDateTimePicker(label: 'Fecha *', onTap: _selectDate)),
            const SizedBox(width: 12),
            Expanded(child: _buildDateTimePicker(label: 'Hora *', onTap: _selectTime)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _buildTextField(_peopleController, 'Nº Personas *', Icons.people_outline, keyboardType: TextInputType.number, isRequired: true, onChanged: (_) => _calculateCosts())),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(_durationController, 'Duración *', Icons.timer_outlined, isRequired: true, hint: 'ej. 2 horas')),
          ]),
          
          const SizedBox(height: 24),
          Text('Servicios y Costos', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          MultiSelectDialogField<ServicioAdicional>(
            items: _serviciosAdicionales.map((s) => MultiSelectItem(s, s.name)).toList(),
            initialValue: _selectedServicios,
            title: const Text("Servicios"),
            selectedColor: Theme.of(context).primaryColor,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
            buttonIcon: const Icon(Icons.add_box_outlined),
            buttonText: const Text("Seleccionar Servicios Adicionales..."),
            onConfirm: (results) => setState(() {
              _selectedServicios = results;
              _calculateCosts();
            }),
            chipDisplay: MultiSelectChipDisplay(
              onTap: (value) => setState(() {
                _selectedServicios.remove(value);
                _calculateCosts();
              }),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            TextEditingController(text: NumberFormat.currency(locale: 'es_CO', symbol: 'COP ', decimalDigits: 0).format(_decorationAmount)),
            'Monto Decoración (auto)', Icons.park_outlined,
            isReadOnly: true
          ),
          const SizedBox(height: 16),
          _buildTextField(_totalPayController, 'Total a Pagar (editable) *', Icons.monetization_on_outlined, keyboardType: TextInputType.number, isRequired: true),
          
          const SizedBox(height: 24),
          Text('Pago y Estado', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          
          Column(
            children: _abonos.map((abono) => ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green.shade600),
              title: Text(NumberFormat.currency(locale: 'es_CO', symbol: 'COP ').format(abono.monto)),
              subtitle: Text(DateFormat.yMMMd('es_CO').format(abono.fecha)),
              trailing: (abono.monto == 50000 && widget.existingReserva == null)
                ? const Text("Inicial", style: TextStyle(color: Colors.grey))
                : IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => setState(() { _abonos.remove(abono); _calculateCosts(); })),
            )).toList(),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 3, child: _buildDateTimePicker(label: 'Fecha Abono', forAbono: true, onTap: _selectManualAbonoDate)),
              const SizedBox(width: 12),
              Expanded(flex: 4, child: _buildTextField(_manualAbonoMontoController, 'Monto Abono', Icons.attach_money, keyboardType: TextInputType.number, hint: 'Mín. 50,000')),
              IconButton(icon: const Icon(Icons.add_card, color: Colors.blue), onPressed: _addManualAbono, tooltip: 'Agregar Abono'),
            ]),
          ),
          
          ListTile(title: const Text('Restante por Pagar', style: TextStyle(fontWeight: FontWeight.bold)), trailing: Text(NumberFormat.currency(locale: 'es_CO', symbol: 'COP ').format(_remaining), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.secondary))),
          
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            items: ['pendiente', 'confirmada', 'en_proceso', 'terminada', 'anulada'].map((label) => DropdownMenuItem(child: Text(label[0].toUpperCase() + label.substring(1)), value: label)).toList(),
            onChanged: (value) => setState(() => _selectedStatus = value!),
            decoration: const InputDecoration(labelText: 'Estado *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.flag_outlined)),
          ),
          const SizedBox(height: 16),
          _buildTextField(_notesController, 'Observaciones (Opcional)', Icons.notes_outlined, maxLines: 3),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.save_outlined),
            label: Text(widget.existingReserva == null ? 'Crear Reserva' : 'Actualizar Reserva'),
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isRequired = false, TextInputType? keyboardType, int? maxLines = 1, String? hint, Function(String)? onChanged, bool isReadOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: isReadOnly,
        fillColor: isReadOnly ? Colors.grey.shade200 : null,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) return 'Campo obligatorio';
        return null;
      },
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required Future<void> Function(BuildContext) onTap,
    bool forAbono = false,
  }) {
    String textToShow = 'Seleccionar...';
    IconData icon = Icons.help_outline;
    bool isDate = label.contains('Fecha');
    DateTime? currentDate = isDate ? (forAbono ? _manualAbonoFecha : _selectedDate) : null;
    TimeOfDay? currentTime = !isDate ? _selectedTime : null;
    
    if (isDate && currentDate != null) {
      textToShow = DateFormat.yMd('es_CO').format(currentDate);
      icon = Icons.calendar_today_outlined;
    } else if (!isDate && currentTime != null) {
      final now = DateTime.now();
      textToShow = DateFormat.jm('es_CO').format(now.copyWith(hour: currentTime.hour, minute: currentTime.minute));
      icon = Icons.access_time_outlined;
    }

    return FormField<String>(
      validator: (value) {
        if (forAbono) return null; // La fecha del abono manual no es obligatoria para el form principal.
        if (!label.contains('*')) return null;

        if (isDate && _selectedDate == null) return 'Campo obligatorio';
        if (!isDate) {
          if (_selectedTime == null) return 'Campo obligatorio';
          if (_selectedTime!.hour < 12 || _selectedTime!.hour >= 21) return 'Horario no válido';
        }
        return null;
      },
      builder: (FormFieldState<String> state) {
        return InkWell(
          onTap: () async {
            await onTap(context);
            state.didChange(null);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              border: const OutlineInputBorder(),
              errorText: state.errorText,
            ),
            child: Text(textToShow),
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return "";
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}