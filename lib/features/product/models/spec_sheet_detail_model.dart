// lib/features/product/models/spec_sheet_detail_model.dart

// Modelo para los insumos de la ficha (Sin cambios)
class SpecSheetSupplyModel {
  final String supplyName;
  final double quantity;
  final String unitOfMeasure;

  SpecSheetSupplyModel({
    required this.supplyName,
    required this.quantity,
    required this.unitOfMeasure,
  });

  factory SpecSheetSupplyModel.fromJson(Map<String, dynamic> json) {
    final supplyData = json['supply'] as Map<String, dynamic>?;

    return SpecSheetSupplyModel(
      supplyName: supplyData?['supplyName'] ?? 'Insumo no encontrado',
      quantity: double.tryParse(json['quantity']?.toString() ?? '0.0') ?? 0.0,
      unitOfMeasure: json['unitOfMeasure'] ?? '',
    );
  }
}

// Modelo para los procesos (pasos) de la ficha (Sin cambios)
class SpecSheetProcessModel {
  final int order;
  final String processName;
  final int? estimatedTimeMinutes;

  SpecSheetProcessModel({
    required this.order,
    required this.processName,
    this.estimatedTimeMinutes,
  });

  factory SpecSheetProcessModel.fromJson(Map<String, dynamic> json) {
    final processData = json['masterProcessData'] as Map<String, dynamic>?; // Corregido para coincidir con tu backend

    return SpecSheetProcessModel(
      order: json['processOrder'] ?? 0,
      processName: json['processNameOverride'] ?? processData?['processName'] ?? 'Paso sin nombre',
      estimatedTimeMinutes: json['estimatedTimeMinutes'],
    );
  }
}

// =========================================================================
// == MODELO PRINCIPAL CORREGIDO: AÑADIMOS LOS CAMPOS QUE FALTABAN         ==
// =========================================================================
class SpecSheetDetailModel {
  final int id;
  final String versionName;
  final String? description;
  final bool status; // <-- CAMPO AÑADIDO
  final DateTime? dateEffective; // <-- CAMPO AÑADIDO
  final double quantityBase; // <-- CAMPO AÑADIDO
  final String? unitOfMeasure; // <-- CAMPO AÑADIDO
  final List<SpecSheetProcessModel> processes;
  final List<SpecSheetSupplyModel> supplies;

  SpecSheetDetailModel({
    required this.id,
    required this.versionName,
    this.description,
    required this.status, // <-- CAMPO AÑADIDO
    this.dateEffective, // <-- CAMPO AÑADIDO
    required this.quantityBase, // <-- CAMPO AÑADIDO
    this.unitOfMeasure, // <-- CAMPO AÑADIDO
    required this.processes,
    required this.supplies,
  });

  // --- FACTORY CONSTRUCTOR CORREGIDO ---
  factory SpecSheetDetailModel.fromJson(Map<String, dynamic> json) {
    // Mapeamos las listas de procesos e insumos (tu código original estaba bien)
    var processList = <SpecSheetProcessModel>[];
    if (json['specSheetProcesses'] != null) { // Ajustado a la respuesta real del backend
      processList = (json['specSheetProcesses'] as List)
          .map((p) => SpecSheetProcessModel.fromJson(p))
          .toList();
    }

    var supplyList = <SpecSheetSupplyModel>[];
    if (json['specSheetSupplies'] != null) { // Ajustado a la respuesta real del backend
      supplyList = (json['specSheetSupplies'] as List)
          .map((s) => SpecSheetSupplyModel.fromJson(s))
          .toList();
    }
    
    // Parseo seguro de los nuevos campos
    DateTime? effectiveDate;
    if (json['dateEffective'] != null) {
      effectiveDate = DateTime.tryParse(json['dateEffective']);
    }

    return SpecSheetDetailModel(
      id: json['idSpecSheet'] ?? 0,
      versionName: json['versionName'] ?? 'Ficha sin nombre',
      description: json['description'],
      
      // --- Parseo de los campos que faltaban ---
      status: json['status'] ?? false,
      dateEffective: effectiveDate,
      quantityBase: double.tryParse(json['quantityBase']?.toString() ?? '0.0') ?? 0.0,
      unitOfMeasure: json['unitOfMeasure'],

      processes: processList,
      supplies: supplyList,
    );
  }
}