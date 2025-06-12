class ServicioAdicional {
  final int id;
  final String name;

  ServicioAdicional({required this.id, required this.name});

  factory ServicioAdicional.fromJson(Map<String, dynamic> json) {
    return ServicioAdicional(id: json['idAditionalServices'], name: json['name']);
  }
}