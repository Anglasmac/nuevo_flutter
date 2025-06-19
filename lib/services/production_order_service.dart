// lib/services/production_order_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nuevo_proyecto_flutter/features/production/models/production_order_model.dart';
import 'package:nuevo_proyecto_flutter/services/ase_api_service.dart';

class ProductionOrderService extends BaseApiService {

  Future<List<ProductionOrder>> fetchProductionOrders({List<String>? statuses}) async {
    final Map<String, String> queryParameters = {};
    if (statuses != null && statuses.isNotEmpty) {
      queryParameters['status'] = statuses.join(',');
    }
    
    final Uri url = Uri.parse('$baseUrl/production-orders').replace(queryParameters: queryParameters);
    
    print('ProductionOrderService: GET $url');

    try {
      final response = await http.get(url, headers: commonHeaders);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // El backend puede devolver 'rows' o directamente una lista. Seamos flexibles.
        final List<dynamic> jsonData = responseData['rows'] ?? (responseData is List ? responseData : []);

        print('ProductionOrderService: Se obtuvieron ${jsonData.length} órdenes.');
        
        return jsonData.map((item) => ProductionOrder.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        print('ProductionOrderService Error (fetchProductionOrders): ${response.statusCode} - ${response.body}');
        throw Exception('Fallo al cargar órdenes de producción (Código: ${response.statusCode})\n${response.body}');
      }
    } catch (e) {
      print('ProductionOrderService Exception (fetchProductionOrders): $e');
      throw Exception('Error de conexión al obtener órdenes de producción: $e');
    }
  }

  Future<ProductionOrder> fetchProductionOrderById(int orderId) async {
    final url = Uri.parse('$baseUrl/production-orders/$orderId');
    
    print('ProductionOrderService: GET $url');

    try {
      final response = await http.get(url, headers: commonHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductionOrder.fromJson(data as Map<String, dynamic>);
      } else {
        print('ProductionOrderService Error (fetchProductionOrderById): ${response.statusCode} - ${response.body}');
        throw Exception('Fallo al cargar los detalles de la orden (Código: ${response.statusCode})');
      }
    } catch (e) {
      print('ProductionOrderService Exception (fetchProductionOrderById): $e');
      throw Exception('Error de conexión al obtener la orden.');
    }
  }

  // =======================================================================
  // ==  MÉTODO CORREGIDO PARA ACEPTAR LA OBSERVACIÓN OPCIONAL            ==
  // =======================================================================
  Future<ProductionOrder> updateOrderStatus(
    int orderId, 
    String newStatus, 
    {String? observation} // <-- PARÁMETRO OPCIONAL AÑADIDO
  ) async {
    final url = Uri.parse('$baseUrl/production-orders/$orderId/status');
    
    // Creamos un mapa para el cuerpo de la petición, para más flexibilidad
    final Map<String, dynamic> requestBody = {
      'status': newStatus,
    };

    // Si se proporciona una observación (y no está vacía), la añadimos al cuerpo
    if (observation != null && observation.isNotEmpty) {
      requestBody['observation'] = observation;
    }

    // Codificamos el mapa a un string JSON
    final body = json.encode(requestBody);

    print('ProductionOrderService: PATCH $url con body: $body');
    
    try {
        final response = await http.patch(url, headers: commonHeaders, body: body);
        
        if (response.statusCode == 200) {
            // El backend debería devolver la orden actualizada, así que la parseamos.
            return ProductionOrder.fromJson(json.decode(response.body));
        } else {
             print('ProductionOrderService Error (updateOrderStatus): ${response.statusCode} - ${response.body}');
            throw Exception('Fallo al actualizar el estado de la orden (Código: ${response.statusCode})');
        }
    } catch (e) {
         print('ProductionOrderService Exception (updateOrderStatus): $e');
        throw Exception('Error de conexión al actualizar el estado: $e');
    }
  }
}