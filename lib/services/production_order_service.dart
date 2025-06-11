// lib/services/production_order_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nuevo_proyecto_flutter/features/production/models/production_order_model.dart';
// <-- CORRECCIÓN: El nombre del archivo importado es ahora 'base_api_service.dart'.
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
        final List<dynamic> jsonData = responseData['rows'] ?? [];

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

  Future<ProductionOrder> updateOrderStatus(int orderId, String newStatus) async {
    final url = Uri.parse('$baseUrl/production-orders/$orderId/status');
    final body = json.encode({'status': newStatus});

    print('ProductionOrderService: PATCH $url con estado: $newStatus');
    
    try {
        final response = await http.patch(url, headers: commonHeaders, body: body);
        
        if (response.statusCode == 200) {
            return ProductionOrder.fromJson(json.decode(response.body));
        } else {
            throw Exception('Fallo al actualizar el estado de la orden (Código: ${response.statusCode})');
        }
    } catch (e) {
        throw Exception('Error de conexión al actualizar el estado: $e');
    }
  }
}