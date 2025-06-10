// lib/services/product_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// CORRECCIÓN: Estandarizamos las rutas de importación para mayor consistencia.
import 'package:nuevo_proyecto_flutter/features/product/models/product_model.dart';
import 'package:nuevo_proyecto_flutter/services/ase_api_service.dart';

class ProductService extends BaseApiService {
  
  // --- MÉTODOS PARA EL ENDPOINT DE PRODUCTOS (/product) ---

  /// GET /product - Obtiene la lista de todos los productos.
  Future<List<Product>> fetchProducts() async {
    // Esta ruta ya es correcta.
    final Uri url = Uri.parse('$baseUrl/product'); 
    print('ProductService: GET $url');
    
    try {
      final response = await http.get(url, headers: commonHeaders);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('ProductService: Fetched ${jsonData.length} products.');
        return jsonData.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        print('ProductService Error (fetchProducts): ${response.statusCode} - ${response.body}');
        throw Exception('Fallo al cargar productos (Código: ${response.statusCode})\n${response.body}');
      }
    } catch (e) {
      print('ProductService Exception (fetchProducts): $e');
      throw Exception('Error de conexión al obtener productos: $e');
    }
  }

  // --- MÉTODOS PARA EL ENDPOINT DE FICHAS TÉCNICAS (/specSheet) ---

  /// GET /specSheet/by-product/:productId - Obtiene las fichas técnicas para un producto específico.
  Future<List<FichaTecnica>> fetchFichasByProductId(int productId) async {
    // CORRECCIÓN: La ruta del backend es '/by-product/:idProduct'.
    final Uri url = Uri.parse('$baseUrl/specSheet/by-product/$productId');
    print('ProductService: GET $url');
    
    try {
      final response = await http.get(url, headers: commonHeaders);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('ProductService: Fetched ${jsonData.length} spec sheets for product $productId.');
        return jsonData.map((item) => FichaTecnica.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        print('ProductService Error (fetchFichasByProductId): ${response.statusCode} - ${response.body}');
        throw Exception('Fallo al cargar fichas técnicas (Código: ${response.statusCode})\n${response.body}');
      }
    } catch (e) {
      print('ProductService Exception (fetchFichasByProductId): $e');
      throw Exception('Error de conexión al obtener fichas técnicas: $e');
    }
  }

  /// PATCH /specSheet/:id/status - Cambia el estado de una ficha técnica.
  Future<void> setFichaStatus(int fichaId, bool newStatus) async {
    // La ruta del backend usa el parámetro ':id' para la ficha.
    final Uri url = Uri.parse('$baseUrl/specSheet/$fichaId/status');
    final String requestBody = json.encode({'status': newStatus});
    
    // CORRECCIÓN: El método en el backend es PATCH, no PUT.
    print('ProductService: PATCH $url with body: $requestBody');
    
    try {
      final response = await http.patch( // <-- CORREGIDO a http.patch
        url,
        headers: commonHeaders, 
        body: requestBody,
      );

      // Un PATCH/PUT exitoso puede devolver 200 (OK) o 204 (No Content).
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('ProductService: Spec sheet $fichaId status updated successfully.');
      } else {
        print('ProductService Error (setFichaStatus): ${response.statusCode} - ${response.body}');
        String errorMessage = 'Error desconocido del servidor.';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? response.body;
        } catch (_) {
          errorMessage = response.body;
        }
        throw Exception('Fallo al actualizar el estado de la ficha: $errorMessage (Código: ${response.statusCode})');
      }
    } catch (e) {
      print('ProductService Exception (setFichaStatus): $e');
      throw Exception('Error de conexión al actualizar el estado de la ficha: $e');
    }
  }
}