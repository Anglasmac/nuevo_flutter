// Reemplaza la clase ServicioAdicional completa para evitar el error JSNull:

class ServicioAdicional {
  final int id;
  final String name;
  final double price;

  ServicioAdicional({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ServicioAdicional.fromJson(Map<String, dynamic> json) {
    // ✅ CORRECCIÓN CRÍTICA: Manejo seguro de valores null
    final dynamic nameValue = json['name'] ?? json['Name'] ?? json['nombre'];
    final dynamic priceValue = json['price'] ?? json['Price'] ?? json['precio'] ?? 0;
    final dynamic idValue = json['idAditionalServices'] ?? json['id'] ?? 0;
    
    // Convertir null a string vacío de forma segura
    String safeName;
    if (nameValue == null) {
      safeName = 'Servicio sin nombre';
    } else {
      safeName = nameValue.toString();
    }
    
    // Convertir precio de forma segura
    double safePrice = 0.0;
    if (priceValue != null) {
      if (priceValue is num) {
        safePrice = priceValue.toDouble();
      } else if (priceValue is String) {
        safePrice = double.tryParse(priceValue) ?? 0.0;
      }
    }
    
    // Convertir ID de forma segura
    int safeId = 0;
    if (idValue != null) {
      if (idValue is num) {
        safeId = idValue.toInt();
      } else if (idValue is String) {
        safeId = int.tryParse(idValue) ?? 0;
      }
    }
    
    print("🔧 Servicio parseado: ID=$safeId, Name='$safeName', Price=$safePrice");
    
    return ServicioAdicional(
      id: safeId,
      name: safeName,
      price: safePrice,
    );
  }

  Map<String, dynamic> toJson() => {
    "idAditionalServices": id,
    "name": name,
    "price": price,
  };

  @override
  String toString() => 'ServicioAdicional(id: $id, name: $name, price: $price)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServicioAdicional &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}