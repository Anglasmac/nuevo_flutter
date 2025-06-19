// lib/services/product_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// Importaciones de los modelos de datos
import 'package:nuevo_proyecto_flutter/features/product/models/product_model.dart';
import 'package:nuevo_proyecto_flutter/features/product/models/spec_sheet_detail_model.dart';

// Importación del servicio base
// ¡OJO! Tu archivo se llama 'ase_api_service.dart', no 'base_api_service.dart'.
import 'package:nuevo_proyecto_flutter/services/ase_api_service.dart';

class ProductService extends BaseApiService {

  /// Obtiene la lista de todos los productos.
  /// Llama al endpoint: GET /product
  Future<List<Product>> fetchProducts() async {
    // --- CORRECCIÓN 1: La URL debe ser '/product' (sin 's') para coincidir con tu backend.
    final url = Uri.parse('$baseUrl/product'); 
    print('[ProductService] Fetching products from: $url');

    try {
      final response = await http.get(url, headers: commonHeaders);
      
      if (kDebugMode) {
        print('[ProductService] Response Status Code: ${response.statusCode}');
        print('[ProductService] Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        // --- CORRECCIÓN 2: El backend ahora devuelve una lista directamente, no un objeto con 'rows'.
        final List<dynamic> productListJson = json.decode(response.body);
        
        if (kDebugMode) {
          print('[ProductService] JSON Decoded successfully. Found ${productListJson.length} items.');
        }

        return productListJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Fallo al cargar los productos (Código: ${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ProductService] EXCEPTION in fetchProducts: $e');
      }
      throw Exception('Error de conexión al obtener productos: $e');
    }
  }

  /// Obtiene la lista de fichas técnicas (versión simple) para un producto específico.
  /// Llama al endpoint: GET /specSheet/by-product/{productId}
  Future<List<FichaTecnica>> fetchFichasByProductId(int productId) async {
    // Nota: Asegúrate de que esta ruta '/specSheet/by-product/:id' exista en tu backend.
    final url = Uri.parse('$baseUrl/specSheet/by-product/$productId');
    try {
      final response = await http.get(url, headers: commonHeaders);
      if (response.statusCode == 200) {
        final List<dynamic> fichaListJson = json.decode(response.body);
        return fichaListJson.map((json) => FichaTecnica.fromJson(json)).toList();
      } else {
        throw Exception('Fallo al cargar las fichas técnicas (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener fichas: $e');
    }
  }

  /// Establece una ficha técnica como la activa para un producto.
  /// Llama al endpoint: PATCH /products/{productId} 
  Future<void> setActiveSpecSheet(int productId, int specSheetId) async {
    // Nota: Asegúrate de que esta ruta '/products/:id' (con 's') exista en tu backend.
    final url = Uri.parse('$baseUrl/products/$productId');
    final body = json.encode({'activeSpecSheetId': specSheetId});

    try {
      final response = await http.patch(url, headers: commonHeaders, body: body);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Fallo al actualizar la ficha activa (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión al activar ficha: $e');
    }
  }
  
  // No necesitas los otros métodos (setFichaStatus, fetchSpecSheetDetails) para solucionar el problema actual,
  // pero los dejo por si los usas en otras pantallas. Solo asegúrate de que sus URLs también coincidan
  // con las rutas reales de tu backend.

  Future<SpecSheetDetailModel> fetchSpecSheetDetails(int specSheetId) async {
    // Nota: Asegúrate de que esta ruta exista en tu backend
    final url = Uri.parse('$baseUrl/specSheet/$specSheetId');
    try {
      final response = await http.get(url, headers: commonHeaders);
      if (response.statusCode == 200) {
        return SpecSheetDetailModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Fallo al cargar los detalles de la ficha (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener detalles de la ficha: $e');
    }
  }
}