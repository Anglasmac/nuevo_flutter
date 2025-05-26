// lib/features/reservas/screens/reservas_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart';
import 'package:nuevo_proyecto_flutter/features/reservas/screens/create_reservation_screen.dart';
import 'package:nuevo_proyecto_flutter/features/reservas/widgets/reservation_card.dart';
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
      _loadingError = null; // Limpiar error anterior
      _eventsFromApi = {};
    });

    try {
      final List<Reserva> allReservations = await _apiService.fetchReservations();
      final Map<DateTime, List<Reserva>> groupedEvents = {};

      for (final reserva in allReservations) {
        final dateOnly = DateTime(reserva.eventDateTime.year, reserva.eventDateTime.month, reserva.eventDateTime.day);
        if (groupedEvents[dateOnly] == null) {
          groupedEvents[dateOnly] = [];
        }
        groupedEvents[dateOnly]!.add(reserva);
      }

      setState(() {
        _eventsFromApi = groupedEvents;
        if (_selectedDay != null) {
          _updateSelectedDayReservas(_selectedDay!);
        }
      });
    } catch (e) {
      print("Error al cargar reservaciones en pantalla: $e");
      setState(() {
        _loadingError = "Error al cargar: ${e.toString()}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar reservaciones: ${e.toString()}')),
      );
    } finally {
      setState(() {
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
      _selectedDayReservas.sort((a, b) => a.eventDateTime.compareTo(b.eventDateTime));
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _calendarFormat = CalendarFormat.week; // Opcional: Cambiar a vista semanal
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

  void _navigateToCreateAndRefresh() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReservationScreen(
          selectedDate: _selectedDay ?? DateTime.now(),
        ),
      ),
    );

    if (result == true) {
      _fetchAndProcessReservations(); // Recargar si se creó una reserva
    }
  }

  Future<void> _deleteReservationAndRefresh(String reservationId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar esta reservación?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Eliminando reservación...')));
        await _apiService.deleteReservation(reservationId);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reservación eliminada exitosamente.')));
        _fetchAndProcessReservations(); // Recargar la lista
      } catch (e) {
        print("Error al eliminar reservación en pantalla: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar reservación: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Reservas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar Reservas',
            onPressed: _fetchAndProcessReservations,
          ),
          IconButton(
            icon: const Icon(Icons.today_outlined),
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
            locale: Localizations.localeOf(context).toString(),
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
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: theme.colorScheme.onPrimary.withOpacity(0.9)),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: theme.colorScheme.onPrimary),
              markerDecoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.redAccent[100]),
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(20),
              ),
              formatButtonTextStyle: TextStyle(color: theme.colorScheme.primary),
              titleTextStyle: textTheme.titleMedium!,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.redAccent[100]),
            ),
          ),
          const Divider(height: 1),
          if (_isLoadingEvents)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_loadingError != null)
             Expanded(child: Center(child: Padding(
               padding: const EdgeInsets.all(16.0),
               child: Text(_loadingError!, style: TextStyle(color: Colors.red, fontSize: 16)),
             )))
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDay != null
                        ? 'Reservas para ${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(_selectedDay!)}'
                        : 'Seleccione un día',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (_selectedDayReservas.isNotEmpty)
                    Text('${_selectedDayReservas.length} evento(s)', style: textTheme.bodySmall)
                ],
              ),
            ),
            Expanded(
              child: _selectedDayReservas.isEmpty
                  ? Center(
                      child: Text(
                        'No hay reservas para este día.',
                        style: textTheme.bodyLarge?.copyWith(color: Colors.grey),
                      ))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80), // Para el FAB
                      itemCount: _selectedDayReservas.length,
                      itemBuilder: (context, index) {
                        final reserva = _selectedDayReservas[index];
                        return ReservationCard(
                          reserva: reserva,
                          onTap: () {
                            // TODO: Implementar navegación a pantalla de detalle/edición
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ver/Editar: ${reserva.eventName}')),
                            );
                          },
                          // Opcional: onDelete para la tarjeta
                          // onDelete: () {
                          //   if (reserva.id != null) {
                          //     _deleteReservationAndRefresh(reserva.id!);
                          //   }
                          // },
                        );
                      },
                    ),
            ),
          ]
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateAndRefresh,
        label: const Text('Crear Reserva'),
        icon: const Icon(Icons.add),
        tooltip: 'Crear Nueva Reserva',
      ),
    );
  }
}