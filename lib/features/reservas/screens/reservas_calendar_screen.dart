import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Importa TableCalendar
import 'package:intl/intl.dart'; // Para formatear títulos de mes/semana

// Importa la pantalla de creación y el widget de tarjeta
import 'package:nuevo_proyecto_flutter/features/reservas/screens/create_reservation_screen.dart'; // <- Reemplaza
import 'package:nuevo_proyecto_flutter/features/reservas/widgets/reservation_card.dart';      // <- Reemplaza
import 'package:nuevo_proyecto_flutter/features/reservas/models/reserva_model.dart';         // <- Reemplaza (Importa el modelo)

// Antes era ReservasWidget
class ReservasCalendarScreen extends StatefulWidget {
  const ReservasCalendarScreen({super.key});

  @override
  State<ReservasCalendarScreen> createState() => _ReservasCalendarScreenState();
}

class _ReservasCalendarScreenState extends State<ReservasCalendarScreen> {
  // --- Estado del Calendario ---
  CalendarFormat _calendarFormat = CalendarFormat.month; // Formato inicial
  DateTime _focusedDay = DateTime.now(); // Día que el calendario está mostrando/enfocado
  DateTime? _selectedDay; // Día seleccionado por el usuario (nullable)
   // Mapa para almacenar eventos por día (Reemplazar con carga real)
   Map<DateTime, List<Reserva>> _events = {};

  // Lista de reservas para el día seleccionado
  List<Reserva> _selectedDayReservas = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // Seleccionar el día actual al inicio
    // Cargar eventos (simulado)
    _loadEvents();
    // Obtener eventos para el día seleccionado inicialmente
    _updateSelectedDayReservas(_selectedDay!);
  }

 // --- Carga y Manejo de Eventos (Simulado) ---
 void _loadEvents() {
    // Crear algunas reservas de ejemplo:
     final today = DateTime.now();
     final tomorrow = today.add(const Duration(days: 1));
     final dayAfter = today.add(const Duration(days: 2));
     final yesterday = today.subtract(const Duration(days: 1));

     // Normalizar fechas a medianoche para usar como claves en el mapa
      DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

     setState(() {
        _events = {
           dateOnly(today): [
             Reserva(id: '1', eventName: 'Reunión Equipo', eventDateTime: today.copyWith(hour: 10, minute: 0), color: Colors.blueAccent),
             Reserva(id: '2', eventName: 'Almuerzo Cliente', eventDateTime: today.copyWith(hour: 13, minute: 30), color: Colors.orangeAccent),
           ],
           dateOnly(tomorrow): [
             Reserva(id: '3', eventName: 'Presentación Proyecto', eventDateTime: tomorrow.copyWith(hour: 9, minute: 0), color: Colors.green),
           ],
           dateOnly(dayAfter): [
              Reserva(id: '4', eventName: 'Taller Flutter', eventDateTime: dayAfter.copyWith(hour: 15, minute: 0), color: Colors.purpleAccent),
              Reserva(id: '5', eventName: 'Cena Aniversario', eventDateTime: dayAfter.copyWith(hour: 20, minute: 0), color: Colors.pinkAccent),
           ],
           dateOnly(yesterday): [
              Reserva(id: '6', eventName: 'Entrega Informe', eventDateTime: yesterday.copyWith(hour: 17, minute: 0), color: Colors.teal),
           ]
        };
     });
 }

  // Obtener la lista de eventos para un día específico
  List<Reserva> _getEventsForDay(DateTime day) {
    // Normaliza el día a medianoche para buscar en el mapa
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // Actualizar la lista de reservas mostrada debajo del calendario
  void _updateSelectedDayReservas(DateTime day) {
     setState(() {
       _selectedDayReservas = _getEventsForDay(day);
       // Ordenar las reservas por hora
       _selectedDayReservas.sort((a, b) => a.eventDateTime.compareTo(b.eventDateTime));
     });
  }

  // --- Callbacks del Calendario ---
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) { // Evita re-cargas innecesarias si se toca el mismo día
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay; // Actualiza el día enfocado también
        _calendarFormat = CalendarFormat.week; // Opcional: Cambiar a vista semanal al seleccionar un día
      });
       _updateSelectedDayReservas(selectedDay); // Actualiza la lista de eventos
    }
     // Opcional: Navegar a crear reserva al tocar un día (quizás mejor con botón)
     // Navigator.push(context, MaterialPageRoute(builder: (context) => CreateReservationScreen(selectedDate: selectedDay)));
  }

   void _onPageChanged(DateTime focusedDay) {
      // Actualiza el día enfocado cuando el usuario cambia de mes/semana
      _focusedDay = focusedDay;
      // No es necesario llamar a setState aquí si TableCalendar lo maneja internamente
   }

   void _onFormatChanged(CalendarFormat format) {
      if (_calendarFormat != format) {
         setState(() {
            _calendarFormat = format; // Cambia entre Mes, 2 Semanas, Semana
         });
      }
   }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
       // No necesita GestureDetector si no hay TextFields
       appBar: AppBar(
         title: const Text('Calendario de Reservas'),
         actions: [
           // Botón para ir al día de hoy
            IconButton(
               icon: const Icon(Icons.today_outlined),
               tooltip: 'Ir a Hoy',
               onPressed: () {
                  setState(() {
                    _focusedDay = DateTime.now();
                    _selectedDay = _focusedDay;
                  });
                   _updateSelectedDayReservas(_selectedDay!);
               },
            ),
         ],
         // elevation: 0.0, // Usa el del tema
       ),
       body: Column(
         children: [
           // --- El Calendario ---
           TableCalendar<Reserva>( // Especifica el tipo de evento si usas eventLoader
             locale: Localizations.localeOf(context).toString(), // Para formato de idioma correcto
             firstDay: DateTime.utc(2020, 1, 1),   // Límite inferior
             lastDay: DateTime.utc(2030, 12, 31), // Límite superior
             focusedDay: _focusedDay, // Día que el calendario muestra inicialmente
             selectedDayPredicate: (day) {
               // Determina qué día está visualmente seleccionado
               return isSameDay(_selectedDay, day);
             },
             calendarFormat: _calendarFormat, // Formato actual (mes, semana)
             eventLoader: _getEventsForDay, // Función que devuelve eventos para un día
             startingDayOfWeek: StartingDayOfWeek.monday, // Empezar semana en Lunes

             // --- Callbacks ---
             onDaySelected: _onDaySelected,
             onPageChanged: _onPageChanged,
             onFormatChanged: _onFormatChanged,

             // --- Estilos del Calendario (Personalización) ---
             calendarStyle: CalendarStyle(
               // Estilo para días fuera del mes actual
               outsideDaysVisible: false,
               // Marcador de hoy
               todayDecoration: BoxDecoration(
                 color: theme.colorScheme.primary.withOpacity(0.3),
                 shape: BoxShape.circle,
               ),
               todayTextStyle: TextStyle(color: theme.colorScheme.onPrimary.withOpacity(0.9)),
               // Marcador del día seleccionado
               selectedDecoration: BoxDecoration(
                 color: theme.colorScheme.primary,
                 shape: BoxShape.circle,
               ),
               selectedTextStyle: TextStyle(color: theme.colorScheme.onPrimary),
               // Marcadores de eventos (puntos debajo del día)
               markersMaxCount: 1, // Mostrar solo 1 punto aunque haya más eventos
               markerDecoration: BoxDecoration(
                  color: theme.colorScheme.secondary, // Color de los puntos de evento
                  shape: BoxShape.circle,
               ),
               // Estilo fines de semana
               weekendTextStyle: TextStyle(color: Colors.redAccent[100]),
             ),
             headerStyle: HeaderStyle(
               titleCentered: true, // Centrar título (Mes/Año)
               formatButtonVisible: true, // Mostrar botón para cambiar formato (Mes/Semana)
               formatButtonShowsNext: false, // El botón muestra el formato actual, no el siguiente
               formatButtonDecoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.primary),
                  borderRadius: BorderRadius.circular(20),
               ),
               formatButtonTextStyle: TextStyle(color: theme.colorScheme.primary),
                titleTextStyle: textTheme.titleMedium!, // Estilo para Mes/Año
             ),
             daysOfWeekStyle: DaysOfWeekStyle( // Estilo para los nombres de los días (L, M, X...)
               weekendStyle: TextStyle(color: Colors.redAccent[100]), // Color fines de semana
             ),
           ),
           const Divider(height: 1), // Separador

           // --- Lista de Reservas para el Día Seleccionado ---
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
                   // Opcional: Contador de eventos
                   if (_selectedDayReservas.isNotEmpty)
                     Text('${_selectedDayReservas.length} evento(s)', style: textTheme.bodySmall)
                ],
             ),
           ),
           Expanded( // Ocupa el espacio restante para la lista
             child: _selectedDayReservas.isEmpty
                 ? Center(
                     child: Text(
                       'No hay reservas para este día.',
                       style: textTheme.bodyLarge?.copyWith(color: Colors.grey),
                     )
                   )
                 : ListView.builder(
                     padding: const EdgeInsets.only(bottom: 80), // Padding inferior para que no quede oculto por FAB
                     itemCount: _selectedDayReservas.length,
                     itemBuilder: (context, index) {
                       final reserva = _selectedDayReservas[index];
                       return ReservationCard( // Usa el widget extraído
                          reserva: reserva,
                          onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ver/Editar reserva: ${reserva.eventName} (Pendiente)')),
                              );
                          },
                       );
                     },
                   ),
           ),
         ],
       ),
       floatingActionButton: FloatingActionButton.extended( // Botón extendido
         onPressed: () {
           // Navegar al formulario de creación de reserva
           Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => CreateReservationScreen(
                // Pasa la fecha seleccionada al formulario
                selectedDate: _selectedDay ?? DateTime.now(),
             )),
             // Opcional: Refrescar eventos después de volver de la creación
           ).then((nuevaReservaCreada) {
               if (nuevaReservaCreada == true) { // Asume que la pantalla de creación devuelve true si se creó algo
                  _loadEvents(); // Vuelve a cargar los eventos
                   _updateSelectedDayReservas(_selectedDay!); // Actualiza la lista del día actual
               }
           });
         },
         label: const Text('Crear Reserva'), // Texto del botón
         icon: const Icon(Icons.add),      // Icono del botón
         tooltip: 'Crear Nueva Reserva',
       ),
    );
  }
}