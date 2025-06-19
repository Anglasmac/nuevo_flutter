// lib/features/production/models/production_order_model.dart

// Modelo para un paso de producción individual.
class ProductionStep {
  final int idProductionOrderDetail;
  final int processOrder;
  final String processName;
  final String status;
  final String? employeeFullName;

  ProductionStep({
    required this.idProductionOrderDetail,
    required this.processOrder,
    required this.processName,
    required this.status,
    this.employeeFullName,
  });

  factory ProductionStep.fromJson(Map<String, dynamic> json) {
    // Busca el nombre del empleado dentro del objeto anidado 'employeeAssigned'.
    final employeeData = json['employeeAssigned'] as Map<String, dynamic>?;

    return ProductionStep(
      idProductionOrderDetail: json['idProductionOrderDetail'] ?? 0,
      processOrder: json['processOrder'] ?? 0,
      processName: json['processNameOverride'] ?? json['MasterProcess']?['processName'] ?? 'Paso sin nombre',
      status: json['status'] ?? 'PENDING',
      employeeFullName: employeeData?['fullName'],
    );
  }
}


// Modelo principal para una orden de producción completa.
class ProductionOrder {
  // --- CAMPOS DE IDENTIFICACIÓN Y ESTADO ---
  final int idProductionOrder;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt; 
  final String? productNameSnapshot;
  final String? nameClient;
  
  // --- EMPLEADO ---
  // El ID del empleado es el que está en la tabla, el fullName viene de la relación.
  final int? idEmployeeAssigned;
  final String? employeeFullName; // Empleado que REGISTRÓ la orden.
  
  // --- DATOS DE PLANIFICACIÓN ---
  final int? initialAmount;
  final double? inputInitialWeight;
  final String? inputInitialWeightUnit;
  
  // --- DATOS DE RESULTADOS/FINALIZACIÓN ---
  final int? finalQuantityProduct;
  final double? finishedProductWeight;
  final String? finishedProductWeightUnit;
  final double? inputFinalWeightUnused;
  final String? inputFinalWeightUnusedUnit;
  final String? observations;

  // --- DATOS RELACIONADOS ---
  final List<ProductionStep> steps;

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
    this.initialAmount,
    this.inputInitialWeight,
    this.inputInitialWeightUnit,
    this.finalQuantityProduct,
    this.finishedProductWeight,
    this.finishedProductWeightUnit,
    this.inputFinalWeightUnused,
    this.inputFinalWeightUnusedUnit,
    this.observations,
    this.steps = const [], // Valor por defecto para la lista de pasos.
  });

  factory ProductionOrder.fromJson(Map<String, dynamic> json) {
    // Función helper para parsear números decimales de forma segura.
    double? tryParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      return double.tryParse(value.toString());
    }

    // Lógica para parsear la lista de pasos (details) si existe.
    var stepList = <ProductionStep>[];
    if (json['details'] != null && json['details'] is List) {
      stepList = (json['details'] as List)
          .map((s) => ProductionStep.fromJson(s as Map<String, dynamic>))
          .toList();
      // Ordena los pasos para asegurar la secuencia correcta en la UI.
      stepList.sort((a, b) => a.processOrder.compareTo(b.processOrder));
    }

    // --- CORRECCIÓN PRECISA Y ROBUSTA AQUÍ ---
    // Intentamos obtener el nombre del empleado de cualquiera de los posibles
    // alias que el backend podría enviar: 'employeeRegistered', 'Employee', o 'employeeAssigned'.
    // El operador '??' (null-aware) pasa al siguiente si el anterior es nulo.
    final String? registeredEmployeeName = json['employeeRegistered']?['fullName'] 
                                         ?? json['Employee']?['fullName'] 
                                         ?? json['employeeAssigned']?['fullName'];

    return ProductionOrder(
      idProductionOrder: json['idProductionOrder'] as int,
      status: json['status'] as String,
      createdAt: json['createdAt'] == null ? null : DateTime.tryParse(json['createdAt'].toString()),
      updatedAt: json['updatedAt'] == null ? null : DateTime.tryParse(json['updatedAt'].toString()),
      completedAt: json['completedAt'] == null ? null : DateTime.tryParse(json['completedAt'].toString()), 
      idEmployeeAssigned: json['idEmployeeAssigned'] as int?,
      nameClient: json['nameClient'] as String?,
      productNameSnapshot: json['productNameSnapshot'] as String?,
      
      // Asignamos el nombre del empleado que encontramos.
      employeeFullName: registeredEmployeeName,

      initialAmount: json['initialAmount'] as int?,
      inputInitialWeight: tryParseDouble(json['inputInitialWeight']),
      inputInitialWeightUnit: json['inputInitialWeightUnit'] as String?,
      finalQuantityProduct: json['finalQuantityProduct'] as int?,
      finishedProductWeight: tryParseDouble(json['finishedProductWeight']),
      finishedProductWeightUnit: json['finishedProductWeightUnit'] as String?,
      inputFinalWeightUnused: tryParseDouble(json['inputFinalWeightUnused']),
      inputFinalWeightUnusedUnit: json['inputFinalWeightUnusedUnit'] as String?,
      observations: json['observations'] as String?,
      
      // Asignamos la lista de pasos parseada.
      steps: stepList, 
    );
  }
}