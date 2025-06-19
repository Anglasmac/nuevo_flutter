// lib/features/product/models/product_model.dart

import 'package:flutter/foundation.dart';

// --- CLASE FICHA TECNICA (Sin cambios) ---
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


// --- CLASE PRODUCT (Completamente Corregida) ---
class Product {
  // --- CAMPOS ACTUALIZADOS ---
  // Se añadieron `currentStock` y `stockForSale` para que coincidan con la API.
  final int id;
  final String nombre;
  final int minimo;
  final int maximo;
  final int specSheetCount;
  final int? activeSpecSheetId;
  final int currentStock;
  final double stockForSale;

  Product({
    required this.id,
    required this.nombre,
    required this.minimo,
    required this.maximo,
    required this.specSheetCount,
    this.activeSpecSheetId,
    required this.currentStock,
    required this.stockForSale,
  });

  // --- CONSTRUCTOR fromJson (Completamente Corregido) ---
  // Este constructor ahora es "a prueba de balas" y maneja todos los campos
  // y tipos de datos que tu API está enviando.
  factory Product.fromJson(Map<String, dynamic> json) {
    
    // Helper para convertir cualquier valor a un entero de forma segura.
    // Evita errores si el valor es null, un string, o un double.
    int safeParseInt(dynamic value) {
      if (value == null) return 0;
      return int.tryParse(value.toString()) ?? 0;
    }

    // Helper para convertir un string a un double de forma segura.
    // Clave para el campo 'stockForSale'.
    double safeParseDouble(dynamic value) {
      if (value == null) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }
    
    // Helper para convertir a un entero que puede ser nulo.
    int? safeParseNullableInt(dynamic value) {
      if (value == null) return null;
      return int.tryParse(value.toString());
    }

    // Devuelve un objeto Product con todos los campos parseados de forma segura.
    return Product(
      id: safeParseInt(json['idProduct']),
      nombre: json['productName'] as String? ?? 'Producto Desconocido',
      minimo: safeParseInt(json['minStock']),
      maximo: safeParseInt(json['maxStock']),
      specSheetCount: safeParseInt(json['specSheetCount']),
      activeSpecSheetId: safeParseNullableInt(json['activeSpecSheetId']),
      
      // --- Parseo de los campos que faltaban ---
      currentStock: safeParseInt(json['currentStock']),
      stockForSale: safeParseDouble(json['stockForSale']),
    );
  }
}