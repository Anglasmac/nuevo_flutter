import 'dart:convert';
import 'package:http/http.dart' as http;

// Importaciones de los modelos de datos
import 'package:nuevo_proyecto_flutter/features/product/models/product_model.dart';
import 'package:nuevo_proyecto_flutter/features/product/models/spec_sheet_detail_model.dart';

// Importación del servicio base
import 'package:nuevo_proyecto_flutter/services/ase_api_service.dart';

class ProductService extends BaseApiService {

  /// Obtiene la lista de todos los productos.
  /// Llama al endpoint: GET /api/products
  Future<List<Product>> fetchProducts() async {
    final url = Uri.parse('$baseUrl/products');
    try {
      final response = await http.get(url, headers: commonHeaders);
      if (response.statusCode == 200) {
        // Asumimos que la respuesta es un objeto con una clave 'rows' que contiene la lista
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> productListJson = responseData['rows'] ?? [];
        return productListJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Fallo al cargar los productos (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener productos: $e');
    }
  }

  /// Obtiene la lista de fichas técnicas (versión simple) para un producto específico.
  /// Llama al endpoint: GET /api/spec-sheets/by-product/{productId}
  Future<List<FichaTecnica>> fetchFichasByProductId(int productId) async {
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
  /// Llama al endpoint: PATCH /api/products/{productId}
  /// Nota: Este es el método robusto que actualiza el 'activeSpecSheetId' en el producto.
  Future<void> setActiveSpecSheet(int productId, int specSheetId) async {
    final url = Uri.parse('$baseUrl/products/$productId');
    final body = json.encode({'activeSpecSheetId': specSheetId});

    try {
      final response = await http.patch(url, headers: commonHeaders, body: body);
      if (response.statusCode != 200) {
        throw Exception('Fallo al actualizar la ficha activa (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión al activar ficha: $e');
    }
  }
  
  /// --- MÉTODO LEGADO / ALTERNATIVO ---
  /// Si prefieres no cambiar el modelo Product, tu servicio llamaría a un endpoint que maneje
  /// la lógica de activar/desactivar en la tabla SpecSheets.
  /// Llama al endpoint: PATCH /api/spec-sheets/{specSheetId}/status
  Future<void> setFichaStatus(int specSheetId, bool newStatus) async {
      // Nota: Este método requiere que el backend se encargue de desactivar las otras fichas del mismo producto.
      final url = Uri.parse('$baseUrl/specSheet/$specSheetId/status'); 
      final body = json.encode({'status': newStatus});

      try {
        final response = await http.patch(url, headers: commonHeaders, body: body);
         if (response.statusCode != 200) {
          throw Exception('Fallo al actualizar el estado de la ficha (Código: ${response.statusCode})');
        }
      } catch (e) {
         throw Exception('Error de conexión al cambiar estado de ficha: $e');
      }
  }


  /// Obtiene los detalles completos (insumos y procesos) de UNA ficha técnica.
  /// Llama al endpoint: GET /api/spec-sheets/{specSheetId}
  Future<SpecSheetDetailModel> fetchSpecSheetDetails(int specSheetId) async {
    final url = Uri.parse('$baseUrl/spec-sheets/$specSheetId');
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