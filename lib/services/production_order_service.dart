// lib/services/production_order_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

// 1. Importa el MODELO que este servicio va a utilizar.
//    No se exporta, solo se usa internamente.
import 'package:nuevo_proyecto_flutter/features/production/models/production_order_model.dart'; 

// 2. Importa la clase base para obtener la URL y los headers.
//    Asegúrate de que la ruta a este archivo sea la correcta.
import 'package:nuevo_proyecto_flutter/services/ase_api_service.dart'; 

/// Servicio para gestionar las operaciones de la API relacionadas con las órdenes de producción.
class ProductionOrderService extends BaseApiService {

  /// Obtiene una lista de órdenes de producción desde la API.
  ///
  /// Puede filtrar por uno o más estados si el backend lo soporta.
  /// El backend debe ser capaz de manejar un query parameter como `?status=IN_PROGRESS,PAUSED`
  Future<List<ProductionOrder>> fetchProductionOrders({List<String>? statuses}) async {
    // Construye el mapa de parámetros de consulta si se proporcionan estados.
    final Map<String, String> queryParameters = {};
    if (statuses != null && statuses.isNotEmpty) {
      queryParameters['status'] = statuses.join(',');
    }
    
    // Asume que el endpoint es /production-orders.
    // El método `replace` añade los query parameters a la URL de forma segura.
    final Uri url = Uri.parse('$baseUrl/production-orders').replace(queryParameters: queryParameters);
    
    print('ProductionOrderService: GET $url');

    try {
      final response = await http.get(url, headers: commonHeaders);

      if (response.statusCode == 200) {
        // La mayoría de los frameworks de backend (como NestJS con paginación) devuelven un objeto
        // con una clave 'rows' o 'data' que contiene la lista.
        // Si tu API devuelve directamente una lista `[...]`, cambia la línea de abajo.
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> jsonData = responseData['rows'] ?? []; // Extraemos la lista de 'rows'

        print('ProductionOrderService: Se obtuvieron ${jsonData.length} órdenes.');
        
        // Mapea la lista de JSON a una lista de objetos ProductionOrder.
        return jsonData.map((item) => ProductionOrder.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        // Manejo de errores del servidor.
        print('ProductionOrderService Error (fetchProductionOrders): ${response.statusCode} - ${response.body}');
        throw Exception('Fallo al cargar órdenes de producción (Código: ${response.statusCode})\n${response.body}');
      }
    } catch (e) {
      // Manejo de errores de conexión o parsing.
      print('ProductionOrderService Exception (fetchProductionOrders): $e');
      throw Exception('Error de conexión al obtener órdenes de producción: $e');
    }
  }

  /// Actualiza el estado de una orden de producción específica.
  ///
  /// Recibe el ID de la orden y el nuevo estado (ej: 'COMPLETED', 'PAUSED').
  Future<ProductionOrder> updateOrderStatus(int orderId, String newStatus) async {
    // Asume un endpoint como /production-orders/123/status
    final url = Uri.parse('$baseUrl/production-orders/$orderId/status');
    final body = json.encode({'status': newStatus});

    print('ProductionOrderService: PATCH $url con estado: $newStatus');
    
    try {
        // Usamos PATCH porque es el método HTTP más apropiado para actualizaciones parciales.
        final response = await http.patch(url, headers: commonHeaders, body: body);
        
        if (response.statusCode == 200) {
            // Si la API devuelve la orden actualizada, la parseamos y la retornamos.
            return ProductionOrder.fromJson(json.decode(response.body));
        } else {
            throw Exception('Fallo al actualizar el estado de la orden (Código: ${response.statusCode})');
        }
    } catch (e) {
        throw Exception('Error de conexión al actualizar el estado: $e');
    }
  }

  // Aquí podrías añadir otros métodos del servicio como:
  // - Future<ProductionOrder> fetchOrderById(int orderId)
  // - Future<ProductionOrder> createOrder(ProductionOrder newData)
  // - Future<void> deleteOrder(int orderId)
}