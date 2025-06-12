class Cliente {
  final int id;
  final String fullName;

  Cliente({required this.id, required this.fullName});

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(id: json['idCustomers'], fullName: json['fullName']);
  }
}