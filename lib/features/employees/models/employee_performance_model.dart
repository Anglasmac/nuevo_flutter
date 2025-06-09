class EmployeePerformance {
  final int? idEmployee;
  final String? fullName; // <--- Este es el campo que estamos usando
  final int? completedOrdersCount;
  final int? inProgressOrdersCount;

  EmployeePerformance({
    this.idEmployee,
    this.fullName,
    this.completedOrdersCount,
    this.inProgressOrdersCount,
  });

  factory EmployeePerformance.fromJson(Map<String, dynamic> json) {
    return EmployeePerformance(
      idEmployee: json['idEmployee'] as int?,
      // La clave 'fullName' debe coincidir con la de tu API
      fullName: json['fullName'] as String?,
      completedOrdersCount: int.tryParse(json['completedOrdersCount'].toString() ?? '0'),
      inProgressOrdersCount: int.tryParse(json['inProgressOrdersCount'].toString() ?? '0'),
    );
  }
}