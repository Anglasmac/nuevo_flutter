import 'package:flutter/foundation.dart';

class FichaTecnica {
  final int id;
  final String nombre;
  final bool status;

  FichaTecnica({
    required this.id,
    required this.nombre,
    required this.status,
  });

  factory FichaTecnica.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('Datos de Ficha recibidos desde la API: $json');
    }
    return FichaTecnica(
      id: json['idSpecSheet'] as int? ?? 0,
      nombre: json['versionName'] as String? ?? 'Ficha sin nombre',
      status: json['status'] as bool? ?? false,
    );
  }
}

class Product {
  final int id;
  final String nombre;
  final int minimo;
  final int maximo;
  final int specSheetCount;
  // ==================== CAMPO AÑADIDO AQUÍ ====================
  final int? activeSpecSheetId;
  // ==========================================================

  Product({
    required this.id,
    required this.nombre,
    required this.minimo,
    required this.maximo,
    required this.specSheetCount,
    this.activeSpecSheetId, // <-- Añadido al constructor
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['idProduct'] ?? 0,
      nombre: json['productName'] ?? 'Producto Desconocido',
      minimo: json['minStock'] ?? 0,
      maximo: json['maxStock'] ?? 0,
      specSheetCount: int.tryParse(json['specSheetCount']?.toString() ?? '0') ?? 0,
      // Leemos el nuevo campo desde el JSON que envía tu API
      activeSpecSheetId: json['activeSpecSheetId'] as int?,
    );
  }
}