// lib/features/reservas/screens/reservas_calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart';
import 'package:nuevo_proyecto_flutter/features/reservas/screens/create_reservation_screen.dart';
import 'package:nuevo_proyecto_flutter/features/reservas/widgets/reservation_card.dart';
import 'package:nuevo_proyecto_flutter/features/clientes/models/cliente_model.dart';
import 'package:nuevo_proyecto_flutter/services/api_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class ReservasCalendarScreen extends StatefulWidget {
  const ReservasCalendarScreen({super.key});

  @override
  State<ReservasCalendarScreen> createState() => _ReservasCalendarScreenState();
}

class _ReservasCalendarScreenState extends State<ReservasCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final ApiService _apiService = ApiService();
  Map<DateTime, List<Reserva>> _eventsFromApi = {};
  List<Reserva> _selectedDayReservas = [];
  List<Cliente> _clientes = []; // ✅ NUEVO: Lista de clientes
  bool _isLoadingEvents = true;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchAndProcessReservations();
  }

  Future<void> _fetchAndProcessReservations() async {
    setState(() {
      _isLoadingEvents = true;
      _loadingError = null;
    });

    try {
      // ✅ NUEVO: Cargar clientes junto con reservas
      final futures = await Future.wait([
        _apiService.fetchReservations(),
        _apiService.fetchClientes(),
      ]);
      
      final List<Reserva> allReservations = futures[0] as List<Reserva>;
      _clientes = futures[1] as List<Cliente>;
      
      final Map<DateTime, List<Reserva>> groupedEvents = {};

      for (final reserva in allReservations) {
        final dateOnly = DateTime(reserva.dateTime.year, reserva.dateTime.month, reserva.dateTime.day);
        if (groupedEvents[dateOnly] == null) {
          groupedEvents[dateOnly] = [];
        }
        groupedEvents[dateOnly]!.add(reserva);
      }

      if (!mounted) return;

      setState(() {
        _eventsFromApi = groupedEvents;
        if (_selectedDay != null) {
          _updateSelectedDayReservas(_selectedDay!);
        }
        _isLoadingEvents = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingError = "Error al cargar: ${e.toString()}";
        _isLoadingEvents = false;
      });
    }
  }

  List<Reserva> _getEventsForDay(DateTime day) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    return _eventsFromApi[dateOnly] ?? [];
  }

  void _updateSelectedDayReservas(DateTime day) {
    setState(() {
      _selectedDayReservas = _getEventsForDay(day);
      _selectedDayReservas.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _updateSelectedDayReservas(selectedDay);
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
  }

  void _onFormatChanged(CalendarFormat format) {
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
      });
    }
  }

  void _navigateToFormAndRefresh({Reserva? reserva}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReservationScreen(
          selectedDate: reserva?.dateTime ?? _selectedDay,
          existingReserva: reserva,
        ),
      ),
    );

    if (result == true) {
      _fetchAndProcessReservations();
    }
  }

  Future<void> _deleteReservationAndRefresh(int reservationId) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar esta reserva? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eliminando...')));
        await _apiService.deleteReservation(reservationId.toString());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reserva eliminada con éxito.')));
        _fetchAndProcessReservations();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: ${e.toString()}')),
        );
      }
    }
  }

  // ✅ NUEVO: Función para encontrar cliente por ID
  Cliente? _findClienteById(int clienteId) {
    try {
      return _clientes.firstWhere((c) => c.id == clienteId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Reservas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: _fetchAndProcessReservations,
          ),
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Ir a Hoy',
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = _focusedDay;
              });
              if (_selectedDay != null) _updateSelectedDayReservas(_selectedDay!);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<Reserva>(
            locale: 'es_ES',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: _onDaySelected,
            onPageChanged: _onPageChanged,
            onFormatChanged: _onFormatChanged,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonShowsNext: false,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToFormAndRefresh(),
        label: const Text('Crear Reserva'),
        icon: const Icon(Icons.add),
        tooltip: 'Crear Nueva Reserva',
      ),
    );
  }

  Widget _buildEventList() {
    if (_isLoadingEvents) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadingError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_loadingError!, style: const TextStyle(color: Colors.red)),
        )
      );
    }
    if (_selectedDayReservas.isEmpty) {
      return const Center(
        child: Text(
          'No hay reservas para este día.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80.0),
      itemCount: _selectedDayReservas.length,
      itemBuilder: (context, index) {
        final reserva = _selectedDayReservas[index];
        // ✅ CORRECCIÓN: Pasar cliente encontrado a la tarjeta
        final cliente = _findClienteById(reserva.idCustomers);
        
        return ReservationCard(
          reserva: reserva,
          cliente: cliente, // ✅ NUEVO: Pasar cliente
          onTap: () => _navigateToFormAndRefresh(reserva: reserva),
          onDelete: () {
             if (reserva.idReservations != null) {
                _deleteReservationAndRefresh(reserva.idReservations!);
             }
          },
        );
      },
    );
  }
}