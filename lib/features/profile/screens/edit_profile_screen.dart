// lib/features/perfil/screens/edit_profile_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Antes era EditWidget
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controladores para los campos del formulario
  late TextEditingController _yourNameController;
  late TextEditingController _cityController;
  late TextEditingController _bioController;

  // Estado para el Dropdown de Estado/Provincia
  String? _selectedState; // Hacerlo nullable para poder tener un hint

  // Lista de opciones para el Dropdown (podría venir de una constante o API)
  final List<String> _stateOptions = [
    // 'State', // Quitamos el valor 'State' como opción seleccionable
    'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado',
    'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho',
    'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana',
    'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota',
    'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada',
    'New Hampshire', 'New Jersey', 'New Mexico', 'New York',
    'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon',
    'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota',
    'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington',
    'West Virginia', 'Wisconsin', 'Wyoming',
    // Añadir otras regiones si aplica
  ];

  // Clave global para el Scaffold (si necesitas acceder al Drawer, etc.)
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Clave global para el Form (para validación)
  final _formKey = GlobalKey<FormState>();

  // Variable para simular si los datos se están guardando
  bool _isSaving = false;

  // Placeholder para la URL de la imagen de perfil
  String _profileImageUrl =
      'https://images.unsplash.com/photo-1536164261511-3a17e671d380?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=630&q=80';

  @override
  void initState() {
    super.initState();
    // nCargar datos del perfil del usuario actual aquí
    // Simulación: Inicializar controladores con datos de ejemplo
    _yourNameController = TextEditingController(text: 'Usuario Ejemplo');
    _cityController = TextEditingController(text: 'Ciudad Ejemplo');
    _bioController =
        TextEditingController(text: 'Esta es una bio de ejemplo corta.');
    _selectedState = 'California'; // Estado inicial de ejemplo
  }

  @override
  void dispose() {
    _yourNameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Función para simular la subida de imagen
  Future<void> _changeProfilePicture() async {
    // nImplementar lógica para seleccionar imagen (image_picker) y subirla (API/Storage)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cambiar foto de perfil (Pendiente)')),
    );
    // Simulación de cambio de imagen
    setState(() {
      _profileImageUrl =
          'https://i.pravatar.cc/150?u=${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  // Función para guardar los cambios del perfil
  Future<void> _saveProfileChanges() async {
    // Validar el formulario
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true); // Mostrar indicador de carga
      FocusScope.of(context).unfocus(); // Ocultar teclado

      // Simular espera de red/guardado
      await Future.delayed(const Duration(seconds: 2));

      // nImplementar lógica real para guardar los datos en API/DB
      if (kDebugMode) {
        print('Guardando cambios:');
      }
      if (kDebugMode) {
        print('  Nombre: ${_yourNameController.text}');
      }
      if (kDebugMode) {
        print('  Ciudad: ${_cityController.text}');
      }
      if (kDebugMode) {
        print('  Estado: $_selectedState');
      }
      if (kDebugMode) {
        print('  Bio: ${_bioController.text}');
      }
      if (kDebugMode) {
        print('  Imagen URL: $_profileImageUrl');
      }

      setState(() => _isSaving = false); // Ocultar indicador de carga

      // Mostrar mensaje de éxito
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Perfil actualizado con éxito'),
            backgroundColor: Colors.green),
      );
      // Opcional: Navegar a otra pantalla después de guardar
      // Navigator.maybePop(context);
    } else {
      // Mensaje si la validación falla
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, corrija los errores'),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // key: _scaffoldKey, // Asignar clave si se usa
      // backgroundColor: Colors.grey[200], // Usar color del tema o específico
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // Usar AppBarTheme del tema
        // backgroundColor: Colors.white,
        // iconTheme: IconThemeData(color: Colors.black),
        // elevation: 0.0,
        title: const Text('Editar Perfil'),
      ),
      body: SafeArea(
        // Asegura que no se solape con notch/barra inferior
        child: SingleChildScrollView(
          // Permite scroll
          padding:
              const EdgeInsets.symmetric(vertical: 24.0), // Padding vertical
          child: Form(
            // Envuelve en Form para validación
            key: _formKey,
            child: Column(
              children: [
                // --- Sección Foto de Perfil ---
                Stack(
                  // Stack para poner el botón de editar sobre la imagen
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60.0, // Tamaño del avatar
                      backgroundColor:
                          Colors.grey.shade300, // Fondo si la imagen falla
                      backgroundImage:
                          NetworkImage(_profileImageUrl), // Carga la imagen
                      onBackgroundImageError: (e, s) =>
                          // ignore: avoid_print
                          print("Error cargando imagen de perfil: $e"),
                    ),
                    // Botón para cambiar foto
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: theme.colorScheme.primary,
                          child: IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: Colors.white, size: 20),
                            tooltip: 'Cambiar foto',
                            onPressed: _changeProfilePicture,
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 24.0),

                // --- Campos del Formulario ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  child: TextFormField(
                    controller: _yourNameController,
                    decoration: const InputDecoration(
                      labelText: 'Tu Nombre *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ciudad',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    textCapitalization: TextCapitalization.words,
                    // No obligatorio, sin validador
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedState, // Valor seleccionado actualmente
                    hint: const Text(
                        'Selecciona tu estado/provincia *'), // Texto si no hay selección
                    isExpanded: true, // Ocupa todo el ancho
                    decoration: const InputDecoration(
                      labelText: 'Estado/Provincia *', // Label
                      prefixIcon: Icon(Icons.map_outlined),
                    ),
                    items: _stateOptions.map((String state) {
                      // Genera las opciones
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(state),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      // Callback cuando cambia la selección
                      setState(() {
                        _selectedState = newValue;
                      });
                    },
                    validator: (value) {
                      // Validación
                      if (value == null) {
                        return 'Selecciona un estado/provincia';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  child: TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Tu Bio (Opcional)',
                      hintText: 'Cuéntanos un poco sobre ti...',
                      prefixIcon: Icon(Icons.info_outline),
                      alignLabelWithHint: true, // Alinea label arriba
                    ),
                    maxLines: 3, // Permite hasta 3 líneas
                    maxLength: 150, // Límite de caracteres
                    textCapitalization: TextCapitalization.sentences,
                    // No obligatorio
                  ),
                ),
                const SizedBox(height: 32.0), // Espacio antes del botón

                // --- Botón de Guardar ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ElevatedButton.icon(
                    icon: _isSaving
                        ? Container(
                            // Indicador de carga dentro del botón
                            width: 20,
                            height: 20,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ))
                        : const Icon(Icons.save_alt_outlined),
                    label: Text(_isSaving ? 'Guardando...' : 'Guardar Cambios'),
                    onPressed: _isSaving
                        ? null
                        : _saveProfileChanges, // Deshabilita si está guardando
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          const Size(double.infinity, 50.0), // Ancho completo
                      // Usa el estilo del tema
                      // backgroundColor: Colors.blue,
                      // textStyle: textTheme.titleMedium?.copyWith(color: Colors.white),
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(12.0),
                      // ),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0), // Espacio inferior
              ],
            ),
          ),
        ),
      ),
    );
  }
}
