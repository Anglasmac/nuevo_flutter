// lib/features/products/models/product_model.dart

class FichaTecnica {
  final int id; // idSpecSheet
  final String nombre; // versionName
  bool activo; // status

  FichaTecnica({
    required this.id,
    required this.nombre,
    required this.activo,
  });

  factory FichaTecnica.fromJson(Map<String, dynamic> json) {
    // El nombre de la ficha puede venir en 'versionName'
    return FichaTecnica(
      id: json['idSpecSheet'] ?? 0,
      nombre: json['versionName'] ?? 'Ficha sin nombre',
      activo: json['status'] ?? false,
    );
  }
}

class Product {
  final int id; // idProduct
  final String nombre; // productName
  final int minimo; // minStock
  final int maximo; // maxStock
  final int specSheetCount; // El contador que viene del backend

  Product({
    required this.id,
    required this.nombre,
    required this.minimo,
    required this.maximo,
    required this.specSheetCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['idProduct'] ?? 0,
      nombre: json['productName'] ?? 'Producto Desconocido',
      minimo: json['minStock'] ?? 0,
      maximo: json['maxStock'] ?? 0,
      // Leemos el contador, casteando a int por seguridad
      specSheetCount: int.tryParse(json['specSheetCount']?.toString() ?? '0') ?? 0,
    );
  }
}