import 'dart:convert';
import 'package:flutter/material.dart';

List<Reserva> reservaFromJson(String str) => List<Reserva>.from(json.decode(str).map((x) => Reserva.fromJson(x)));
String reservaToJson(List<Reserva> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Abono {
  final DateTime fecha;
  final double monto;

  Abono({required this.fecha, required this.monto});

  factory Abono.fromJson(Map<String, dynamic> json) {
    final montoValue = json["cantidad"] ?? json["monto"] ?? 0;
    
    return Abono(
      fecha: DateTime.parse(json["fecha"]),
      monto: (montoValue as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    "fecha": fecha.toIso8601String().split('T')[0],
    "cantidad": monto,
  };
}

class Reserva {
  final int? idReservations;
  final DateTime dateTime;
  final int numberPeople;
  final String matter; 
  final String timeDurationR;
  final double decorationAmount;
  final double remaining;
  final String evenType;
  final double totalPay;
  final String status;
  final int idCustomers;
  final List<Abono> abonos;
  final List<int> idAditionalServices;
  final String? notes;
  final Color color;

  // Getters para compatibilidad
  DateTime get eventDateTime => dateTime;
  String get eventName => evenType.isNotEmpty ? evenType : 'Reserva';
  String get location => 'No especificada'; 

  Reserva({
    this.idReservations,
    required this.dateTime,
    required this.numberPeople,
    required this.matter,
    required this.timeDurationR,
    required this.decorationAmount,
    required this.remaining,
    required this.evenType,
    required this.totalPay,
    required this.status,
    required this.idCustomers,
    this.abonos = const [],
    this.idAditionalServices = const [],
    this.notes,
    this.color = Colors.blue,
  });

factory Reserva.fromJson(Map<String, dynamic> json) {
  // ✅ DEBUGGING: Ver TODO lo que llega desde tu API
  print("🔍 ===== RESERVA JSON COMPLETO =====");
  print(json);
  print("🔍 ===== CAMPOS DISPONIBLES =====");
  json.forEach((key, value) {
    print("$key: $value (${value.runtimeType})");
  });
  print("🔍 ================================");
  
  List<Abono> parsedAbonos = [];
  final abonosData = json['pass'] ?? json['abonos'];
  if (abonosData is List) {
    parsedAbonos = abonosData
        .where((item) => item is Map<String, dynamic>)
        .map((item) => Abono.fromJson(item))
        .toList();
  }

  // ✅ BUSCAR SERVICIOS EN TODOS LOS FORMATOS POSIBLES
  List<int> servicesIds = [];
  
  // Revisar TODOS los campos posibles donde pueden venir los servicios
  final possibleServiceFields = [
    'AditionalServices',
    'aditionalServices', 
    'additionalServices',
    'additional_services',
    'services',
    'Services',
    'idAditionalServices',
    'servicios',
    'Servicios'
  ];
  
  for (String field in possibleServiceFields) {
    if (json[field] != null) {
      print("🔍 Campo '$field' encontrado: ${json[field]}");
      
      if (json[field] is List) {
        final services = json[field] as List;
        print("🔍 Es una lista con ${services.length} elementos");
        
        for (var service in services) {
          print("🔍 Elemento del servicio: $service (${service.runtimeType})");
          
          if (service is Map<String, dynamic>) {
            // Es un objeto completo del servicio
            final id = service['idAditionalServices'] ?? 
                      service['id'] ?? 
                      service['ID'] ?? 
                      service['Id'] ?? 0;
            if (id is int && id > 0) {
              servicesIds.add(id);
              print("✅ ID de servicio agregado: $id");
            }
          } else if (service is int) {
            // Es solo el ID
            servicesIds.add(service);
            print("✅ ID directo agregado: $service");
          }
        }
        break; // Salir del loop si encontramos servicios
      }
    }
  }
  
  print("🔍 IDs de servicios finales: $servicesIds");

  // Manejo de fecha/hora
  DateTime parsedDateTime;
  try {
    final dateTimeStr = json["dateTime"];
    if (dateTimeStr is String) {
      parsedDateTime = DateTime.parse(dateTimeStr.split('.')[0]);
    } else {
      parsedDateTime = DateTime.now();
    }
  } catch (e) {
    print("❌ Error parsing dateTime: $e");
    parsedDateTime = DateTime.now();
  }

  final reserva = Reserva(
    idReservations: json["idReservations"],
    dateTime: parsedDateTime,
    numberPeople: json["numberPeople"] ?? 0,
    matter: json["matter"] ?? '',
    timeDurationR: json["timeDurationR"]?.toString() ?? '0',
    decorationAmount: (json["decorationAmount"] as num?)?.toDouble() ?? 0.0,
    remaining: (json["remaining"] as num?)?.toDouble() ?? 0.0,
    evenType: json["evenType"] ?? 'Otro',
    totalPay: (json["totalPay"] as num?)?.toDouble() ?? 0.0,
    status: json["status"] ?? 'pendiente',
    idCustomers: json["idCustomers"],
    abonos: parsedAbonos,
    idAditionalServices: servicesIds,
    notes: json['notes'],
    color: _mapStatusToColor(json["status"]),
  );
  
  print("✅ Reserva creada con ${servicesIds.length} servicios");
  return reserva;
}

  Map<String, dynamic> toJson() {
    // ✅ CORRECCIÓN: Enviar fecha/hora preservando la zona horaria local
    return {
      "idCustomers": idCustomers,
      "dateTime": dateTime.toIso8601String(),
      "numberPeople": numberPeople,
      "matter": matter,
      "timeDurationR": timeDurationR,
      "decorationAmount": decorationAmount,
      "remaining": remaining,
      "evenType": evenType,
      "totalPay": totalPay,
      "status": status,
      if (notes != null) "notes": notes,
      "pass": abonos.map((abono) => abono.toJson()).toList(),
      "idAditionalServices": idAditionalServices,
    };
  }

  static Color _mapStatusToColor(String? status) {
    switch (status) {
      case 'terminada':
        return const Color(0xBB4CAF50);
      case 'anulada':
        return const Color(0xBBF44336);
      case 'pendiente':
        return const Color(0xBBFF9800);
      case 'en_proceso':
        return const Color(0xBBFFEB3B);
      case 'confirmada':
        return const Color(0xBB2196F3);
      default:
        return Colors.grey.shade400;
    }
  }
}