class User {
  final int idUsers; // Corresponde a idUsers
  final String documentType; // Corresponde a document_type
  final String document;
  final String cellphone;
  final String fullName; // Corresponde a full_name
  final String email;
  // La contraseña no se suele enviar de vuelta al cliente después del login
  // final String password; // Usualmente no se incluye en la respuesta del login
  final int idRole; // Corresponde a idRole
  final bool status;

  // Opcional: Si tu API también devuelve los datos del rol anidados
  // final RoleModel? role; // Si la API anida la info del rol

  User({
    required this.idUsers,
    required this.documentType,
    required this.document,
    required this.cellphone,
    required this.fullName,
    required this.email,
    required this.idRole,
    required this.status,
    // this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Es importante manejar valores nulos o tipos incorrectos que puedan venir de la API
    return User(
      idUsers: json['idUsers'] as int? ?? 0, // Proporciona un valor por defecto si es nulo
      documentType: json['document_type'] as String? ?? '',
      document: json['document'] as String? ?? '',
      cellphone: json['cellphone'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'Usuario Desconocido',
      email: json['email'] as String? ?? '',
      idRole: json['idRole'] as int? ?? 0, // O un ID de rol por defecto/inválido
      status: json['status'] as bool? ?? false,
      // Si el rol viene anidado:
      // role: json['Role'] != null ? RoleModel.fromJson(json['Role'] as Map<String, dynamic>) : null,
      // o si el nombre del campo es 'role' (minúscula):
      // role: json['role'] != null ? RoleModel.fromJson(json['role'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Este método es útil si necesitas enviar el objeto User de vuelta a la API,
    // por ejemplo, al actualizar el perfil del usuario.
    return {
      'idUsers': idUsers,
      'document_type': documentType,
      'document': document,
      'cellphone': cellphone,
      'full_name': fullName,
      'email': email,
      'idRole': idRole,
      'status': status,
      // 'Role': role?.toJson(), // Si tienes el objeto RoleModel
    };
  }

  // Un getter para facilitar la lógica de roles si solo tienes idRole
  // Necesitarías mapear idRole a un nombre de rol más descriptivo
  // Esto es un EJEMPLO, deberías tener una forma más robusta de manejar roles.
  String get roleName {
    // Supongamos: 1 = admin, 2 = user/employee
    if (idRole == 1) { // Ajusta estos IDs a los de tu base de datos
      return 'admin';
    } else if (idRole == 2) {
      return 'employee'; // O 'user'
    }
    return 'unknown'; // Rol por defecto o desconocido
  }
}

// Si tu API devuelve los datos del rol anidados (ejemplo)
// Deberías crear un `role_model.dart` similar.
/*
class RoleModel {
  final int idRole;
  final String roleName;
  // otros campos del rol...

  RoleModel({required this.idRole, required this.roleName});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      idRole: json['idRole'] as int? ?? 0,
      roleName: json['roleName'] as String? ?? 'default_role',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRole': idRole,
      'roleName': roleName,
    };
  }
}
*/