// lib/features/production/models/production_order_model.dart

class ProductionOrder {
  // Campos existentes
  final int idProductionOrder;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt; 
  final int? idEmployeeAssigned;
  final String? nameClient;
  final String? productNameSnapshot;
  final String? employeeFullName; 
  
  // ==================== INICIO: NUEVOS CAMPOS AÑADIDOS ====================
  // Mapeados desde tu modelo de Sequelize
  
  // --- Planificación ---
  final int? initialAmount;            // Cantidad planeada a producir
  final double? inputInitialWeight;       // Peso inicial del insumo principal
  final String? inputInitialWeightUnit;   // Unidad del peso inicial

  // --- Resultados ---
  final int? finalQuantityProduct;     // Cantidad final REAL obtenida
  final double? finishedProductWeight;    // Peso final REAL del producto
  final String? finishedProductWeightUnit;// Unidad del peso final
  
  // --- Merma (opcional de mostrar, pero bueno tenerlo) ---
  final double? inputFinalWeightUnused;
  final String? inputFinalWeightUnusedUnit;
  
  // --- Otros ---
  final String? observations;

  // El campo `quantityToProduce` que teníamos antes ahora es `initialAmount`
  // para coincidir con tu backend.
  // ===================== FIN: NUEVOS CAMPOS AÑADIDOS ======================

  ProductionOrder({
    required this.idProductionOrder,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.idEmployeeAssigned,
    this.nameClient,
    this.productNameSnapshot,
    this.employeeFullName,
    // Añadir nuevos campos al constructor
    this.initialAmount,
    this.inputInitialWeight,
    this.inputInitialWeightUnit,
    this.finalQuantityProduct,
    this.finishedProductWeight,
    this.finishedProductWeightUnit,
    this.inputFinalWeightUnused,
    this.inputFinalWeightUnusedUnit,
    this.observations,
  });

  factory ProductionOrder.fromJson(Map<String, dynamic> json) {
    // Helper para parsear números que pueden ser string o int/double
    double? tryParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      return double.tryParse(value.toString());
    }

    return ProductionOrder(
      idProductionOrder: json['idProductionOrder'] as int,
      status: json['status'] as String,
      createdAt: json['createdAt'] == null ? null : DateTime.tryParse(json['createdAt'].toString()),
      updatedAt: json['updatedAt'] == null ? null : DateTime.tryParse(json['updatedAt'].toString()),
      completedAt: json['completedAt'] == null ? null : DateTime.tryParse(json['completedAt'].toString()), 
      idEmployeeAssigned: json['idEmployeeAssigned'] as int?,
      nameClient: json['nameClient'] as String?,
      productNameSnapshot: json['productNameSnapshot'] as String?,
      employeeFullName: json['employeeFullName'] as String?,

      // ==================== PARSEO DE NUEVOS CAMPOS ====================
      initialAmount: json['initialAmount'] as int?,
      inputInitialWeight: tryParseDouble(json['inputInitialWeight']),
      inputInitialWeightUnit: json['inputInitialWeightUnit'] as String?,
      
      finalQuantityProduct: json['finalQuantityProduct'] as int?,
      finishedProductWeight: tryParseDouble(json['finishedProductWeight']),
      finishedProductWeightUnit: json['finishedProductWeightUnit'] as String?,

      inputFinalWeightUnused: tryParseDouble(json['inputFinalWeightUnused']),
      inputFinalWeightUnusedUnit: json['inputFinalWeightUnusedUnit'] as String?,
      
      observations: json['observations'] as String?,
      // ===============================================================
    );
  }

  // El método toJson() no es estrictamente necesario para mostrar datos, 
  // pero es buena práctica mantenerlo actualizado si lo usas en otro lugar.
}