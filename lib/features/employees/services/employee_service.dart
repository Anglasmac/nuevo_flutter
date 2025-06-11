// lib/services/employee_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nuevo_proyecto_flutter/features/employees/models/employee_performance_model.dart';
import 'package:nuevo_proyecto_flutter/features/production/models/production_order_model.dart';
// <-- CORRECCIÓN: Se apunta al archivo correcto de la clase base.
import 'package:nuevo_proyecto_flutter/services/ase_api_service.dart';

class EmployeeService extends BaseApiService {
  
  /// GET /employee/performance/overview - Obtiene la lista de empleados con sus contadores.
  Future<List<EmployeePerformance>> fetchEmployeePerformance() async {
    final Uri url = Uri.parse('$baseUrl/employee/performance/overview');
    print('EmployeeService: GET $url');
    
    try {
      final response = await http.get(url, headers: commonHeaders);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => EmployeePerformance.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        print('EmployeeService Error (fetchEmployeePerformance): ${response.statusCode} - ${response.body}');
        throw Exception('Fallo al cargar rendimiento de empleados (Código: ${response.statusCode})\n${response.body}');
      }
    } catch (e) {
      print('EmployeeService Exception (fetchEmployeePerformance): $e');
      throw Exception('Error de conexión al obtener rendimiento: $e');
    }
  }

  /// GET /production-orders?idEmployeeAssigned=X&status=Y - Obtiene órdenes por empleado y estado.
  Future<List<ProductionOrder>> fetchOrdersForEmployee(int employeeId, {required List<String> statuses}) async {
    // Construimos los query parameters
    final queryParams = {
      'idEmployeeAssigned': employeeId.toString(),
      'status': statuses.join(','),
    };
    final Uri url = Uri.parse('$baseUrl/production-orders').replace(queryParameters: queryParams);
    print('EmployeeService: GET $url');

    try {
      final response = await http.get(url, headers: commonHeaders);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> orderData = jsonData['rows'] ?? [];
        return orderData.map((item) => ProductionOrder.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        print('EmployeeService Error (fetchOrdersForEmployee): ${response.statusCode} - ${response.body}');
        throw Exception('Fallo al cargar órdenes para el empleado (Código: ${response.statusCode})\n${response.body}');
      }
    } catch (e) {
      print('EmployeeService Exception (fetchOrdersForEmployee): $e');
      throw Exception('Error de conexión al obtener órdenes: $e');
    }
  }
}