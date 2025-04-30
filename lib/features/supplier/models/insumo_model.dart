// lib/features/insumos/models/insumo_model.dart
// Modelo simple para representar un Insumo
class Insumo {
  final String id; // Siempre es bueno tener un ID único
  final String nombre;
  final String descripcion;
  final String imagenUrl;
  final bool activo;

  Insumo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.imagenUrl,
    required this.activo,
  });

  // Opcional: Constructor de fábrica para crear desde un Map (ej: JSON de API)
  factory Insumo.fromMap(Map<String, dynamic> map) {
    return Insumo(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(), // Genera ID si no viene
      nombre: map['nombre'] ?? 'Sin nombre',
      descripcion: map['descripcion'] ?? 'Sin descripción',
      // Asegúrate que el nombre del campo 'imagen' sea correcto
      imagenUrl: map['imagen'] ?? map['imagenUrl'] ?? 'https://via.placeholder.com/150/EEEEEE/999999?text=No+Image', // Placeholder si falta imagen
      activo: map['activo'] ?? false,
    );
  }

  // Opcional: Método para convertir a Map (útil para guardar en DB o enviar a API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'activo': activo,
    };
  }
}