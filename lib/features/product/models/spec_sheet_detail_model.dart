// lib/features/product/models/spec_sheet_detail_model.dart

// Modelo para los insumos de la ficha
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
    // El backend debe hacer un JOIN para traer el nombre del insumo en `supply.supplyName`
    final supplyData = json['supply'] as Map<String, dynamic>?;

    return SpecSheetSupplyModel(
      supplyName: supplyData?['supplyName'] ?? 'Insumo no encontrado',
      quantity: double.tryParse(json['quantity']?.toString() ?? '0.0') ?? 0.0,
      unitOfMeasure: json['unitOfMeasure'] ?? '',
    );
  }
}

// Modelo para los procesos (pasos) de la ficha
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
     // El backend debe hacer un JOIN para traer el nombre del proceso en `process.processName`
    final processData = json['process'] as Map<String, dynamic>?;

    return SpecSheetProcessModel(
      order: json['processOrder'] ?? 0,
      processName: json['processNameOverride'] ?? processData?['processName'] ?? 'Paso sin nombre',
      estimatedTimeMinutes: json['estimatedTimeMinutes'],
    );
  }
}

// Modelo principal que contiene toda la información de la ficha
class SpecSheetDetailModel {
  final int id;
  final String versionName;
  final String? description;
  final List<SpecSheetProcessModel> processes;
  final List<SpecSheetSupplyModel> supplies;

  SpecSheetDetailModel({
    required this.id,
    required this.versionName,
    this.description,
    required this.processes,
    required this.supplies,
  });

  factory SpecSheetDetailModel.fromJson(Map<String, dynamic> json) {
    // Mapeamos las listas de procesos e insumos
    var processList = <SpecSheetProcessModel>[];
    if (json['processes'] != null) {
      processList = (json['processes'] as List)
          .map((p) => SpecSheetProcessModel.fromJson(p))
          .toList();
    }

    var supplyList = <SpecSheetSupplyModel>[];
    if (json['supplies'] != null) {
      supplyList = (json['supplies'] as List)
          .map((s) => SpecSheetSupplyModel.fromJson(s))
          .toList();
    }

    return SpecSheetDetailModel(
      id: json['idSpecSheet'],
      versionName: json['versionName'] ?? 'Ficha sin nombre',
      description: json['description'],
      processes: processList,
      supplies: supplyList,
    );
  }
}