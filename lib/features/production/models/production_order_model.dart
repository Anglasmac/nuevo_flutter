// lib/features/production/models/production_order_model.dart

class ProductionOrder {
  final int idProductionOrder;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? idEmployeeAssigned;
  final String? nameClient;

  // ==================== NUEVO CAMPO AÑADIDO ====================
  // Nombre del producto en el momento en que se creó la orden.
  final String? productNameSnapshot;
  // ==========================================================

  ProductionOrder({
    required this.idProductionOrder,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.idEmployeeAssigned,
    this.nameClient,
    this.productNameSnapshot, // <--- Añadido al constructor
  });

  /// Factory constructor para crear una instancia de ProductionOrder desde JSON.
  factory ProductionOrder.fromJson(Map<String, dynamic> json) {
    return ProductionOrder(
      idProductionOrder: json['idProductionOrder'] as int,
      status: json['status'] as String,
      
      createdAt: json['createdAt'] == null ? null : DateTime.tryParse(json['createdAt'].toString()),
      updatedAt: json['updatedAt'] == null ? null : DateTime.tryParse(json['updatedAt'].toString()),
      
      idEmployeeAssigned: json['idEmployeeAssigned'] as int?,

      // Asegúrate que 'nameClient' coincida con la clave que envía tu API.
      nameClient: json['nameClient'] as String?,

      // ==================== LÓGICA DE PARSEO DEL NUEVO CAMPO ====================
      // ¡IMPORTANTE! La clave 'productNameSnapshot' debe coincidir con la que envía tu API.
      productNameSnapshot: json['productNameSnapshot'] as String?,
      // =========================================================================
    );
  }

  /// Convierte la instancia de ProductionOrder a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'idProductionOrder': idProductionOrder,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'idEmployeeAssigned': idEmployeeAssigned,
      'nameClient': nameClient,
      'productNameSnapshot': productNameSnapshot, // <-- Añadido al JSON
    };
  }
}