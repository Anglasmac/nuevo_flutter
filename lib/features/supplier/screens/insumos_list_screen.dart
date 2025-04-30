import 'package:flutter/material.dart';
import 'package:nuevo_proyecto_flutter/features/supplier/models/insumo_model.dart'; // <- Reemplaza e importa el modelo
import 'package:nuevo_proyecto_flutter/features/supplier/screens/insumo_detail_screen.dart'; // <- Reemplaza e importa pantalla detalle

// Antes era InsumosPage
class InsumosListScreen extends StatefulWidget {
  const InsumosListScreen({super.key});

  @override
  State<InsumosListScreen> createState() => _InsumosListScreenState();
}

class _InsumosListScreenState extends State<InsumosListScreen> {
  // --- Datos (Reemplazar con carga real desde API/DB) ---
  final List<Insumo> _todosLosInsumos = [
    Insumo(id: '1', nombre: 'Solomillo Res', descripcion: 'Corte premium, 200g', imagenUrl: 'https://via.placeholder.com/150/FF7F7F/FFFFFF?text=Carne', activo: true),
    Insumo(id: '2', nombre: 'Aceite Oliva Virgen Extra', descripcion: 'Botella 500ml', imagenUrl: 'https://via.placeholder.com/150/90EE90/FFFFFF?text=Aceite', activo: true),
    Insumo(id: '3', nombre: 'Sal Marina Gruesa', descripcion: 'Paquete 1kg', imagenUrl: 'https://via.placeholder.com/150/ADD8E6/FFFFFF?text=Sal', activo: false), // Ejemplo inactivo
    Insumo(id: '4', nombre: 'Pimienta Negra Molida', descripcion: 'Frasco 50g', imagenUrl: 'https://via.placeholder.com/150/FFFFE0/000000?text=Pimienta', activo: true),
    Insumo(id: '5', nombre: 'Ajo Fresco', descripcion: 'Cabeza individual', imagenUrl: 'https://via.placeholder.com/150/DDA0DD/FFFFFF?text=Ajo', activo: true),
    Insumo(id: '6', nombre: 'Cebolla Blanca', descripcion: 'Unidad grande', imagenUrl: 'https://via.placeholder.com/150/FA8072/FFFFFF?text=Cebolla', activo: true),
     Insumo(id: '7', nombre: 'Patatas Kennebec', descripcion: 'Bolsa 2kg', imagenUrl: 'https://via.placeholder.com/150/FFD700/000000?text=Patatas', activo: false),
  ];

  // --- Estado de la UI ---
  final TextEditingController _searchController = TextEditingController();
  List<Insumo> _insumosFiltrados = []; // Lista que se muestra en la UI
  String _searchQuery = ''; // Guarda la consulta actual
  final bool _isLoading = false; // Para mostrar indicador de carga (si cargas datos async)
  int _currentPage = 0; // Página actual para paginación
  static const int _itemsPerPage = 5; // Número de items por página

  @override
  void initState() {
    super.initState();
    // Inicialmente, mostrar todos los insumos o cargar los primeros
    // _loadInsumos(); // Descomenta si cargas datos asíncronamente
     _insumosFiltrados = List.from(_todosLosInsumos); // Copia inicial
     _applyFilteringAndPagination(); // Aplica filtro inicial (ninguno) y paginación
  }

  // --- Lógica de Carga y Filtrado ---

  // (Opcional) Función para simular carga asíncrona
  // Future<void> _loadInsumos() async {
  //   setState(() => _isLoading = true);
  //   await Future.delayed(const Duration(seconds: 1)); // Simula espera de red
  //   // Aquí cargarías los datos desde tu fuente (API, DB)
  //   _todosLosInsumos = [ /* ... tus datos cargados ... */ ];
  //   _applyFilteringAndPagination();
  //   setState(() => _isLoading = false);
  // }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _currentPage = 0; // Volver a la primera página al buscar
    _applyFilteringAndPagination();
  }

  void _applyFilteringAndPagination() {
    setState(() {
      // 1. Filtrar
      if (_searchQuery.isEmpty) {
        _insumosFiltrados = List.from(_todosLosInsumos);
      } else {
        final queryLower = _searchQuery.toLowerCase();
        _insumosFiltrados = _todosLosInsumos.where((insumo) {
          return insumo.nombre.toLowerCase().contains(queryLower) ||
                 insumo.descripcion.toLowerCase().contains(queryLower); // Buscar también en descripción
        }).toList();
      }
      // 2. La paginación se aplica directamente en el ListView.builder con _getPaginatedInsumos()
    });
  }

  // Obtener la sublista para la página actual
  List<Insumo> _getPaginatedInsumos() {
    int startIndex = _currentPage * _itemsPerPage;
    // Asegurarse de no exceder los límites de la lista filtrada
    if (startIndex >= _insumosFiltrados.length) {
      return []; // No hay items en esta página
    }
    int endIndex = startIndex + _itemsPerPage;
    // Clamp endIndex al tamaño de la lista
    endIndex = endIndex > _insumosFiltrados.length ? _insumosFiltrados.length : endIndex;
    return _insumosFiltrados.sublist(startIndex, endIndex);
  }

  // Calcular número total de páginas
  int get _totalPages {
     if (_insumosFiltrados.isEmpty) return 1; // Al menos 1 página aunque esté vacía
     return (_insumosFiltrados.length / _itemsPerPage).ceil();
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _goToNextPage() {
    if ((_currentPage + 1) * _itemsPerPage < _insumosFiltrados.length) {
      setState(() {
        _currentPage++;
      });
    }
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Insumo> itemsToShow = _getPaginatedInsumos(); // Obtiene los items para la página actual

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Insumos'),
        actions: [
           IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Añadir Nuevo Insumo',
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Añadir insumo (Pendiente)')),
                 );
              },
           ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Barra de Búsqueda ---
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged, // Llama a la función al cambiar texto
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o descripción...',
                prefixIcon: const Icon(Icons.search),
                // Añadir botón para limpiar búsqueda si hay texto
                 suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Limpiar búsqueda',
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged(''); // Llama con query vacía
                        },
                      )
                    : null,
                // border: OutlineInputBorder(), // Usa el del tema
                // contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Usa el del tema
              ),
            ),
            const SizedBox(height: 16.0),

            // --- Lista de Insumos (o indicador de carga/vacío) ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : itemsToShow.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty
                               ? 'No hay insumos registrados.'
                               : 'No se encontraron insumos para "$_searchQuery"',
                            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: itemsToShow.length,
                          itemBuilder: (context, index) {
                            final insumo = itemsToShow[index];
                            return _buildInsumoCard(context, theme, insumo);
                          },
                        ),
            ),

            // --- Controles de Paginación ---
             if (_totalPages > 1) // Solo mostrar si hay más de 1 página
               Padding(
                 padding: const EdgeInsets.only(top: 16.0),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     IconButton(
                       icon: const Icon(Icons.arrow_back_ios),
                       tooltip: 'Página Anterior',
                       // Deshabilitar si está en la primera página
                       onPressed: _currentPage > 0 ? _goToPreviousPage : null,
                     ),
                     Text(
                       'Página ${_currentPage + 1} de $_totalPages',
                       style: theme.textTheme.bodyMedium,
                     ),
                     IconButton(
                       icon: const Icon(Icons.arrow_forward_ios),
                       tooltip: 'Página Siguiente',
                       // Deshabilitar si está en la última página
                        onPressed: (_currentPage + 1) < _totalPages ? _goToNextPage : null,
                     ),
                   ],
                 ),
               ),
          ],
        ),
      ),
    );
  }

  // Helper Widget para construir cada tarjeta de insumo en la lista
  Widget _buildInsumoCard(BuildContext context, ThemeData theme, Insumo insumo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0), // Espacio vertical entre cards
      child: Card( // Usar Card como base
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // Usa el del tema
        elevation: 3.0, // Sombra sutil
        clipBehavior: Clip.antiAlias, // Para que el onTap funcione bien en toda la Card
        child: InkWell( // Hace la card clickeable
          onTap: () {
            // Navegar a la pantalla de detalles del insumo
            Navigator.push(
              context,
              MaterialPageRoute(
                // Pasa el objeto Insumo completo a la pantalla de detalle
                builder: (context) => InsumoDetailScreen(insumo: insumo),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Padding interno
            child: Row(
              children: [
                // Imagen del Insumo
                ClipRRect( // Redondear imagen
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    insumo.imagenUrl,
                    width: 70.0, // Tamaño fijo para la imagen
                    height: 70.0,
                    fit: BoxFit.cover, // Cubrir el espacio
                     // Placeholder y manejo de error para la imagen
                     loadingBuilder: (context, child, loadingProgress) {
                       if (loadingProgress == null) return child;
                       return Container(
                          width: 70, height: 70, color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2))
                       );
                     },
                     errorBuilder: (context, error, stackTrace) => Container(
                        width: 70, height: 70, color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey, size: 30)
                     ),
                  ),
                ),
                const SizedBox(width: 16.0), // Espacio entre imagen y texto

                // Nombre y Descripción
                Expanded( // Ocupa el espacio restante
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insumo.nombre,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0), // Pequeño espacio
                      Text(
                        insumo.descripcion,
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                         maxLines: 2, // Limita a 2 líneas
                         overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0), // Espacio antes del indicador de estado

                // Indicador de Estado (Activo/Inactivo)
                Column(
                   children: [
                      Tooltip( // Muestra 'Activo' o 'Inactivo' al mantener presionado
                         message: insumo.activo ? 'Activo' : 'Inactivo',
                         child: CircleAvatar(
                            radius: 6.0, // Pequeño círculo indicador
                            backgroundColor: insumo.activo ? Colors.greenAccent[700] : Colors.redAccent,
                         ),
                      ),
                     // Opcional: texto debajo del punto
                      // SizedBox(height: 4),
                      // Text(
                      //   insumo.activo ? 'Activo' : 'Inactivo',
                      //   style: theme.textTheme.labelSmall?.copyWith(
                      //     color: insumo.activo ? Colors.green : Colors.red,
                      //   ),
                      // )
                   ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}