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

  // Estado del formulario
  bool _isLoading = true;
  List<Cliente> _clientes = [];
  Cliente? _selectedCliente;
  List<ServicioAdicional> _allServices = [];
  List<ServicioAdicional> _selectedServicios = [];
  List<Reserva> _allReservations = [];
  Key _multiSelectKey = UniqueKey();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  List<Abono> _abonos = [];
  String _selectedStatus = 'pendiente';
  
  // ✅ NUEVA VARIABLE: Para evitar actualizaciones automáticas
  bool _isUpdatingForm = false;
  
  // Controladores
  late TextEditingController _peopleController;
  late TextEditingController _durationController;
  late TextEditingController _eventTypeController;
  late TextEditingController _totalPayController;
  late TextEditingController _notesController;
  late TextEditingController _manualAbonoMontoController;
  late TextEditingController _additionalServiceAmountController;

  // Estado para UI de Abonos
  DateTime _manualAbonoFecha = DateTime.now();
  
  // Variables calculadas
  double _decorationAmount = 0.0;
  double _remaining = 0.0;
  bool _showDecorationAmountField = false;
  bool _showAdditionalServiceAmountField = false;
  
  @override
  void initState() {
    super.initState();
    _peopleController = TextEditingController();
    _durationController = TextEditingController();
    _eventTypeController = TextEditingController();
    _totalPayController = TextEditingController();
    _notesController = TextEditingController();
    // ✅ CAMBIO 1: Inicializar campo vacío en lugar de "50000"
    _manualAbonoMontoController = TextEditingController(text: "");
    _additionalServiceAmountController = TextEditingController();
    _loadInitialData();
  }
  
  @override
  void dispose() {
    _peopleController.dispose();
    _durationController.dispose();
    _eventTypeController.dispose();
    _totalPayController.dispose();
    _notesController.dispose();
    _manualAbonoMontoController.dispose();
    _additionalServiceAmountController.dispose();
    super.dispose();
  }

  void _setupNewReservationForm() {
    _selectedDate = widget.initialDate ?? DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
    
    if(_abonos.isEmpty) {
      _abonos = [Abono(fecha: DateTime.now(), monto: 50000)];
    }
    _eventTypeController.text = "Cumpleaños";
    // ✅ CAMBIO 2: No llenar automáticamente el campo de monto manual
    // _manualAbonoMontoController.text = "50000"; // ❌ REMOVIDO
  }

  bool _checkTimeConflict(DateTime newStartTime, String durationStr) {
    if (durationStr.isEmpty) return false;

    final double? durationHours = double.tryParse(durationStr.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (durationHours == null) return false;

    final newEndTime = newStartTime.add(Duration(minutes: (durationHours * 60).round()));
    
    for (final existingReserva in _allReservations) {
      if (widget.existingReserva != null && 
          widget.existingReserva!.idReservations == existingReserva.idReservations) {
        continue;
      }
      
      final double? existingDurationHours = double.tryParse(
        existingReserva.timeDurationR.replaceAll(RegExp(r'[^0-9.]'), '')
      );
      if (existingDurationHours == null) continue;

      final existingStartTime = existingReserva.dateTime;
      final existingEndTime = existingStartTime.add(
        Duration(minutes: (existingDurationHours * 60).round())
      );

      if (newStartTime.isBefore(existingEndTime) && newEndTime.isAfter(existingStartTime)) {
        return true;
      }
    }
    
    return false;
  }

  bool _checkDuplicateReservation(int clientId, DateTime dateTime) {
    final reservationDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    for (final existingReserva in _allReservations) {
      if (widget.existingReserva != null && 
          widget.existingReserva!.idReservations == existingReserva.idReservations) {
        continue;
      }
      
      if (existingReserva.idCustomers == clientId) {
        final existingDate = DateTime(
          existingReserva.dateTime.year,
          existingReserva.dateTime.month,
          existingReserva.dateTime.day
        );
        
        if (reservationDate.isAtSameMomentAs(existingDate)) {
          return true;
        }
      }
    }
    
    return false;
  }

  // ✅ MÉTODO CORREGIDO: Cargar servicios desde el backend individual
  Future<void> _populateFormFromExistingReserva(Reserva res) async {
    print("🔄 ===== CARGANDO RESERVA EXISTENTE =====");
    print("🔄 ID Reserva: ${res.idReservations}");
    print("🔄 IDs de servicios en reserva: ${res.idAditionalServices}");
    print("🔄 Total servicios disponibles: ${_allServices.length}");
    
    _isUpdatingForm = true;
    
    // ✅ ARREGLAR FECHA/HORA - Usar UTC para evitar conversiones
    final DateTime originalDateTime = res.dateTime;
    _selectedDate = DateTime(originalDateTime.year, originalDateTime.month, originalDateTime.day);
    _selectedTime = TimeOfDay(hour: originalDateTime.hour, minute: originalDateTime.minute);
    
    print("📅 Fecha original: ${res.dateTime}");
    print("📅 Fecha seleccionada: $_selectedDate");
    print("🕐 Hora seleccionada: $_selectedTime");
    
    // Llenar campos básicos
    _peopleController.text = res.numberPeople.toString();
    _durationController.text = res.timeDurationR;
    _eventTypeController.text = res.evenType;
    _notesController.text = res.matter;
    _selectedStatus = res.status;

    // Buscar cliente
    try {
      _selectedCliente = _clientes.firstWhere((c) => c.id == res.idCustomers);
      print("✅ Cliente encontrado: ${_selectedCliente?.fullName} (ID: ${_selectedCliente?.id})");
    } catch (e) {
      print("❌ Cliente con ID ${res.idCustomers} no encontrado");
      _selectedCliente = null;
    }
    
    // ✅ CARGAR SERVICIOS DESDE BACKEND INDIVIDUAL
    _selectedServicios.clear();
    
    if (res.idReservations != null) {
      print("🔄 Cargando servicios desde backend para reserva ${res.idReservations}...");
      try {
        final serviceIds = await _apiService.fetchServiceIdsForReservation(res.idReservations!);
        print("🔍 IDs de servicios obtenidos del backend: $serviceIds");
        
        // Buscar cada servicio por ID
        for (int serviceId in serviceIds) {
          try {
            final service = _allServices.firstWhere((s) => s.id == serviceId);
            _selectedServicios.add(service);
            print("✅ Servicio encontrado: ${service.name} (ID: ${service.id})");
          } catch (e) {
            print("❌ Servicio con ID $serviceId no encontrado en lista local");
          }
        }
      } catch (e) {
        print("❌ Error cargando servicios desde backend: $e");
      }
    }
    
    print("✅ Total servicios cargados en formulario: ${_selectedServicios.length}");
    print("✅ Servicios cargados: ${_selectedServicios.map((s) => '${s.name}(ID:${s.id})').join(', ')}");
    
    // Cargar abonos
    _abonos = List.from(res.abonos);
    if (_abonos.isEmpty) {
      _abonos = [Abono(fecha: DateTime.now(), monto: 50000)];
    }
    
    _totalPayController.text = res.totalPay.toStringAsFixed(0);
    _remaining = res.remaining;
    _decorationAmount = res.decorationAmount;

    // Calcular monto de servicio adicional
    final double servicePrice = _selectedServicios.fold(0, (sum, service) {
        return sum + (service.price * res.numberPeople);
    });
    final double deducedAdditionalAmount = res.totalPay - servicePrice - res.decorationAmount;
    
    if (deducedAdditionalAmount > 0) {
        _additionalServiceAmountController.text = deducedAdditionalAmount.toStringAsFixed(0);
    }
    
    _multiSelectKey = UniqueKey(); 
    _updateDynamicFieldsVisibility();
    _isUpdatingForm = false;
    
    setState(() {
      print("🔄 Estado actualizado - Servicios en formulario: ${_selectedServicios.length}");
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          print("🔄 Segundo rebuild forzado");
        });
      }
    });
    
    print("🔄 ===== FIN CARGA RESERVA EXISTENTE =====");
  }

  // ✅ MÉTODO CORREGIDO: Cargar datos iniciales
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    try {
      print("🔄 Iniciando carga de datos...");
      
      _clientes = await _apiService.fetchClientes();
      _allServices = await _apiService.fetchServiciosAdicionales();
      _allReservations = await _apiService.fetchReservations();

      setState(() {});
      await Future.delayed(const Duration(milliseconds: 100));

      if (widget.existingReserva != null) {
        await _populateFormFromExistingReserva(widget.existingReserva!);
      } else {
        _setupNewReservationForm();
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      print("❌ Error cargando datos: $e");
      setState(() => _isLoading = false);
    }
  }

  void _updateDynamicFieldsVisibility() {
    bool tieneDecoracion = _selectedServicios.any((s) => s.name.toLowerCase().contains("decoracion"));
    bool tieneOtrosServicios = _selectedServicios.any((s) => !s.name.toLowerCase().contains("decoracion"));
    bool esCumpleanos = _eventTypeController.text.toLowerCase().contains("cumpleaños");

    _showDecorationAmountField = tieneDecoracion && !esCumpleanos;
    _showAdditionalServiceAmountField = tieneOtrosServicios;
  }

  void _recalculateAllCosts() {
    if (_isUpdatingForm) return; // Evitar cálculos durante carga inicial
    
    setState(() {
      _updateDynamicFieldsVisibility();

      final int people = int.tryParse(_peopleController.text) ?? 0;
      
      double servicePrice = 0;
      if (people > 0) {
        servicePrice = _selectedServicios.fold(0, (sum, service) => sum + (service.price * people));
      }
      
      _decorationAmount = _showDecorationAmountField 
        ? ((people >= 2 && people <= 15) ? 70000 : (people >= 16) ? 90000 : 0)
        : 0.0;
      
      final double additionalAmount = _showAdditionalServiceAmountField 
          ? (double.tryParse(_additionalServiceAmountController.text) ?? 0.0) 
          : 0.0;
      
      if (!_showAdditionalServiceAmountField) {
        _additionalServiceAmountController.clear();
      }
      
      double calculatedTotal = servicePrice + _decorationAmount + additionalAmount;
      _totalPayController.text = calculatedTotal.toStringAsFixed(0);
      
      final double totalAbonos = _abonos.fold(0, (sum, abono) => sum + abono.monto);
      _remaining = calculatedTotal - totalAbonos;
    });
  }

  void _addManualAbono() {
    final double? monto = double.tryParse(_manualAbonoMontoController.text);
    if (monto == null || monto < 50000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El monto mínimo del abono es de 50,000'))
      );
      return;
    }
    
    if (_manualAbonoFecha.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha del abono no puede ser futura'))
      );
      return;
    }
    
    if (_selectedDate != null && _manualAbonoFecha.isAfter(_selectedDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El abono debe ser antes o el mismo día de la reserva'))
      );
      return;
    }
    
    _abonos.add(Abono(fecha: _manualAbonoFecha, monto: monto));
    // ✅ CAMBIO 3: Limpiar el campo después de agregar, no rellenar con "50000"
    _manualAbonoMontoController.text = "";
    _recalculateAllCosts();
    
    FocusScope.of(context).unfocus();
  }

  String? _validateDateTime() {
    if (_selectedDate == null || _selectedTime == null) {
      return 'Fecha y hora son requeridas';
    }

    final combinedDateTime = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _selectedTime!.hour, _selectedTime!.minute
    );

    if (_selectedTime!.hour < 12 || _selectedTime!.hour >= 21) {
      return 'El horario para reservas es únicamente de 12:00 PM a 9:00 PM';
    }

    if (widget.existingReserva == null && combinedDateTime.isBefore(DateTime.now())) {
      return 'La fecha y hora no pueden ser en el pasado';
    }

    if (_checkTimeConflict(combinedDateTime, _durationController.text)) {
      return 'Ya existe una reserva en esta hora. Por favor, seleccione otra hora';
    }

    if (_selectedCliente != null && _checkDuplicateReservation(_selectedCliente!.id, combinedDateTime)) {
      return 'Este cliente ya tiene una reserva en esta fecha';
    }

    return null;
  }

  // ✅ MÉTODO ÚNICO CORREGIDO: _submitForm
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrige los errores en el formulario.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    if (_selectedCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un cliente'))
      );
      return;
    }

    final dateTimeError = _validateDateTime();
    if (dateTimeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dateTimeError), backgroundColor: Colors.redAccent)
      );
      return;
    }

    if (_selectedServicios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar al menos un servicio'))
      );
      return;
    }
    
    final List<Abono> abonosParaGuardar = List.from(_abonos);

    if (_manualAbonoMontoController.text.isNotEmpty) {
      final double? monto = double.tryParse(_manualAbonoMontoController.text);
      if (monto != null && monto >= 50000) {
        abonosParaGuardar.add(Abono(fecha: _manualAbonoFecha, monto: monto));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El monto del abono no es válido. Debe ser un número de al menos 50,000.'),
            backgroundColor: Colors.orangeAccent,
          )
        );
        return;
      }
    }

    if (abonosParaGuardar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La reserva debe tener al menos un abono.'))
      );
      return;
    }

    final totalPagoNum = double.tryParse(_totalPayController.text) ?? 0;
    final totalAbonosNum = abonosParaGuardar.fold(0.0, (sum, abono) => sum + abono.monto);

    if (totalAbonosNum > totalPagoNum && totalPagoNum > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Los abonos no pueden superar el total a pagar'))
      );
      return;
    }

    // ✅ PRESERVAR FECHA/HORA EXACTA - Crear DateTime en UTC
    final DateTime combinedDateTime = DateTime.utc(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    print("💾 Guardando con fecha/hora: $combinedDateTime");
    print("💾 Guardando reserva con servicios: ${_selectedServicios.map((s) => s.id).toList()}");

    final reservaParaGuardar = Reserva(
      idReservations: widget.existingReserva?.idReservations,
      dateTime: combinedDateTime, // ✅ Usar UTC
      idCustomers: _selectedCliente!.id,
      numberPeople: int.parse(_peopleController.text),
      evenType: _eventTypeController.text,
      matter: _notesController.text, 
      timeDurationR: _durationController.text,
      idAditionalServices: _selectedServicios.map((s) => s.id).toList(), 
      decorationAmount: _decorationAmount,
      totalPay: totalPagoNum,
      abonos: abonosParaGuardar,
      remaining: totalPagoNum - totalAbonosNum, 
      status: _selectedStatus,
      notes: _notesController.text 
    );
    
    widget.onSave(reservaParaGuardar);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: 'COP ', decimalDigits: 0);
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('1. Cliente y Evento'),
            _buildClientDisplay(),
            const SizedBox(height: 16),
            _buildEventTypeSelector(),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildDateTimePicker(label: 'Fecha *', onTap: _selectDate)),
              const SizedBox(width: 12),
              Expanded(child: _buildDateTimePicker(label: 'Hora *', onTap: _selectTime)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildTextField(
                _peopleController,
                'Nº Personas *',
                keyboardType: TextInputType.number,
                isRequired: true,
                onChanged: (value) => _recalculateAllCosts(), 
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(
                _durationController, 
                'Duración (Horas) *', 
                keyboardType: TextInputType.number, 
                isRequired: true
              )),
            ]),
            
            _buildSectionHeader('2. Servicios y Costos'),
            _buildServicesDisplay(),
            const SizedBox(height: 16),
            
            if (_showDecorationAmountField) ...[
              _buildReadOnlyField('Monto Decoración', currencyFormatter.format(_decorationAmount)),
              const SizedBox(height: 16),
            ],
            if (_showAdditionalServiceAmountField) ...[
              _buildTextField(
                _additionalServiceAmountController,
                'Monto Servicio Adicional',
                keyboardType: TextInputType.number,
                onChanged: (value) => _recalculateAllCosts(),
              ),
              const SizedBox(height: 16),
            ],
            
            _buildTextField(
              _totalPayController, 
              'Total a Pagar (auto)', 
              keyboardType: TextInputType.number, 
              isRequired: true, 
              isReadOnly: true
            ),
            
            _buildSectionHeader('3. Pago y Estado'),
            ..._buildAbonosList(), 
            _buildAbonoAdder(), 
            _buildReadOnlyField('Restante por Pagar', currencyFormatter.format(_remaining), isBold: true),
            const SizedBox(height: 16),
            _buildStatusSelector(),
            const SizedBox(height: 16),
            _buildTextField(_notesController, 'Observaciones', maxLines: 3),

            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt),
              label: Text(widget.existingReserva == null ? 'Crear Reserva' : 'Actualizar Reserva'),
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGETS BUILDERS

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
  
  // ✅ CAMBIO 4: Mostrar solo el nombre del cliente, sin email
 // ✅ REEMPLAZAR TODO EL MÉTODO _buildClientDisplay() CON ESTO:
Widget _buildClientDisplay() {
  if (_clientes.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'No hay clientes disponibles. Verifique la conexión.',
        style: TextStyle(color: Colors.orange),
      ),
    );
  }
  
  return DropdownButtonFormField<Cliente>(
    value: _selectedCliente,
    decoration: const InputDecoration(
      labelText: 'Cliente *',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.person),
    ),
    items: _clientes.map((cliente) => DropdownMenuItem<Cliente>(
      value: cliente,
      child: Text(
        cliente.fullName,
        overflow: TextOverflow.ellipsis,
      ),
    )).toList(),
    onChanged: (Cliente? newValue) {
      setState(() {
        _selectedCliente = newValue;
      });
    },
    validator: (value) => value == null ? 'Debe seleccionar un cliente' : null,
  );
}


  Widget _buildServicesDisplay() {
    print("🔍 _buildServicesDisplay llamado - Servicios: ${_selectedServicios.length}");
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedServicios.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedServicios.length} servicio(s) seleccionado(s)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _showServiceSelector(),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Cambiar'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _selectedServicios.map((servicio) => Chip(
                    label: Text(servicio.name),
                    backgroundColor: Colors.green.shade100,
                  )).toList(),
                ),
                if (_selectedServicios.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'IDs: ${_selectedServicios.map((s) => s.id).join(', ')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'No hay servicios seleccionados',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _showServiceSelector(),
                  icon: const Icon(Icons.add_business),
                  label: const Text('Seleccionar Servicios'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showServiceSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Servicios'),
        content: SizedBox(
          width: double.maxFinite,
          child: MultiSelectDialogField<ServicioAdicional>(
            items: _allServices.map((s) => MultiSelectItem(s, s.name)).toList(),
            initialValue: _selectedServicios,
            title: const Text("Servicios Disponibles"),
            buttonText: const Text("Seleccionar..."),
            onConfirm: (results) {
              setState(() {
                _selectedServicios = results;
                _updateDynamicFieldsVisibility();
                _recalculateAllCosts();
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEventTypeSelector() {
    return DropdownButtonFormField<String>(
      value: _eventTypeController.text.isNotEmpty ? _eventTypeController.text : null,
      items: ["Cumpleaños", "Boda", "Aniversario", "Bautizo", "Graduación", "Empresarial", "Despedida", "Baby Shower", "Fiesta Infantil", "Reunión Familiar", "Conferencia", "Otro"]
          .map((label) => DropdownMenuItem(child: Text(label), value: label))
          .toList(),
      onChanged: (value) {
        if(value != null) {
          _eventTypeController.text = value;
          _recalculateAllCosts();
        }
      },
      decoration: const InputDecoration(
        labelText: 'Tipo de Evento *', 
        border: OutlineInputBorder(), 
        prefixIcon: Icon(Icons.celebration_outlined)
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Seleccione un tipo' : null,
    );
  }

  List<Widget> _buildAbonosList() {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: 'COP ', decimalDigits: 0);
    return _abonos.map((abono) {
      return ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(currencyFormatter.format(abono.monto)),
        subtitle: Text(DateFormat.yMMMd('es_CO').format(abono.fecha)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            if (_abonos.length > 1) {
              setState(() {
                _abonos.remove(abono);
                _recalculateAllCosts();
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No se puede eliminar el único abono de la reserva.'))
              );
            }
          },
        ),
      );
    }).toList();
  }
  
  Widget _buildAbonoAdder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _buildDateTimePicker(
              label: 'Fecha Abono',
              onTap: (ctx) async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: _manualAbonoFecha,
                  firstDate: DateTime(2020),
                  lastDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1))
                );
                if (picked != null) setState(() => _manualAbonoFecha = picked);
              },
              isAbonoDate: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: _buildTextField(
              _manualAbonoMontoController,
              'Monto',
              keyboardType: TextInputType.number,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_card, color: Colors.blue),
            onPressed: _addManualAbono,
            tooltip: 'Agregar Abono',
            padding: const EdgeInsets.only(top: 8, left: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      items: ['pendiente', 'confirmada', 'en_proceso', 'terminada', 'anulada']
          .map((label) => DropdownMenuItem(child: Text(label.capitalize()), value: label))
          .toList(),
      onChanged: (value) => setState(() => _selectedStatus = value!),
      decoration: const InputDecoration(
        labelText: 'Estado *', 
        border: OutlineInputBorder(), 
        prefixIcon: Icon(Icons.flag_outlined)
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    { 
      bool isRequired = false, 
      TextInputType? keyboardType, 
      int? maxLines = 1, 
      bool isReadOnly = false,
      void Function(String)? onChanged, 
    }
  ) {
    return TextFormField(
      controller: controller,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: isReadOnly,
        fillColor: isReadOnly ? Colors.grey.shade200 : null,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'Este campo es obligatorio';
        }
        if (keyboardType == TextInputType.number && value != null && value.isNotEmpty) {
          final num? parsed = num.tryParse(value);
          if (parsed == null || parsed <= 0) {
            return 'Debe ser un número mayor a 0';
          }
        }
        return null;
      },
    );
  }

  Widget _buildReadOnlyField(String label, String value, {bool isBold = false}) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
      child: Text(
        value, 
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal, 
          fontSize: 16
        )
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required Future<void> Function(BuildContext) onTap,
    bool isAbonoDate = false,
  }) {
    String textToShow = 'Seleccionar...';
    bool isDate = label.contains('Fecha');
    DateTime? currentDate = isDate ? (isAbonoDate ? _manualAbonoFecha : _selectedDate) : null;
    TimeOfDay? currentTime = !isDate ? _selectedTime : null;
    
    if (isDate && currentDate != null) {
      textToShow = DateFormat.yMd('es_CO').format(currentDate);
    } else if (!isDate && currentTime != null) {
      final now = DateTime.now();
      textToShow = DateFormat.jm('es_CO').format(
        now.copyWith(hour: currentTime.hour, minute: currentTime.minute)
      );
    }

    return FormField<String>(
      validator: (value) {
        if (isAbonoDate) return null;
        if (!label.contains('*')) return null;
        if (isDate && _selectedDate == null) return 'Obligatorio';
        if (!isDate) {
          if (_selectedTime == null) return 'Obligatorio';
          if (_selectedTime!.hour < 12 || _selectedTime!.hour >= 21) {
            return 'Horario 12pm-9pm';
          }
        }
        return null;
      },
      builder: (state) => InkWell(
        onTap: () async {
          await onTap(context);
          state.didChange(null);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            errorText: state.errorText,
          ),
          child: Text(textToShow),
        ),
      ),
    );
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context, 
      initialTime: _selectedTime ?? TimeOfDay.now()
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}