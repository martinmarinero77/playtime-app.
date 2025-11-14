import 'package:flutter/material.dart';
import 'package:playtime/src/models/complex_model.dart';
import 'package:playtime/src/controllers/complex_controller.dart';
import 'package:playtime/src/pages/complex_detail_page.dart';

// ===================
// PÁGINA: Lista de Complejos Deportivos
// Muestra todos los complejos con búsqueda y filtros
// ===================
class ComplexListPage extends StatefulWidget {
  const ComplexListPage({super.key});

  @override
  _ComplexListPageState createState() => _ComplexListPageState();
}

class _ComplexListPageState extends State<ComplexListPage> {
  // CONTROLADORES
  final ComplexController _complexController = ComplexController();
  final TextEditingController _searchController = TextEditingController();
  
  // ESTADO
  late Future<List<ComplexModel>> _complexesFuture;
  String _searchQuery = '';
  String? _selectedSport; // Filtro por deporte - null = todos

  @override
  void initState() {
    super.initState();
    _complexesFuture = _complexController.getComplexes();
  }

  // ===================
  // FUNCIÓN: Obtener lista de deportes únicos
  // ===================
  List<String> _getSportsFromComplexes(List<ComplexModel> complexes) {
    final Set<String> allSports = {};
    for (var complex in complexes) {
      allSports.addAll(complex.sports);
    }
    final sportsList = allSports.toList();
    sportsList.sort();
    return sportsList;
  }

  // ===================
  // FUNCIÓN: Filtrar complejos por búsqueda y deporte
  // ===================
  List<ComplexModel> _filterComplexes(List<ComplexModel> complexes) {
    var filtered = complexes;

    // Filtrar por texto de búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((complex) {
        final name = complex.name.toLowerCase();
        final city = complex.city.toLowerCase();
        final address = complex.address.toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return name.contains(query) || 
               city.contains(query) || 
               address.contains(query);
      }).toList();
    }

    // Filtrar por deporte seleccionado
    if (_selectedSport != null) {
      filtered = filtered.where((complex) {
        return complex.sports.contains(_selectedSport);
      }).toList();
    }

    return filtered;
  }

  // ===================
  // FUNCIÓN: Navegar al detalle del complejo
  // ===================
  void _navigateToComplexDetail(ComplexModel complex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComplexDetailPage(complex: complex),
      ),
    );
  }

  // ===================
  // FUNCIÓN: Agregar nuevo complejo (placeholder)
  // AQUÍ AGREGAR: Navegación a página de crear complejo
  // ===================
  void _addNewComplex() {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => AddComplexPage()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función de agregar complejo en desarrollo'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // ===================
            // HEADER CON GRADIENTE AZUL
            // ===================
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[800]!],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Título y botón volver
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Complejos Deportivos',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Encontrá el lugar perfecto',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Ícono decorativo
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.stadium,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Barra de búsqueda
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre, ciudad...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.search, color: Colors.blue[600]),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===================
            // FILTROS POR DEPORTE
            // ===================
            FutureBuilder<List<ComplexModel>>(
              future: _complexesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SizedBox.shrink();
                }

                final sports = _getSportsFromComplexes(snapshot.data!);
                if (sports.isEmpty) return SizedBox.shrink();

                return Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.filter_list, color: Colors.blue[700], size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Filtrar por deporte',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Chip "Todos"
                            Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text('Todos'),
                                selected: _selectedSport == null,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedSport = null;
                                  });
                                },
                                backgroundColor: Colors.grey[100],
                                selectedColor: Colors.blue[600],
                                labelStyle: TextStyle(
                                  color: _selectedSport == null
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                checkmarkColor: Colors.white,
                              ),
                            ),
                            // Chips por cada deporte
                            ...sports.map((sport) {
                              return Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(sport),
                                  selected: _selectedSport == sport,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedSport = selected ? sport : null;
                                    });
                                  },
                                  backgroundColor: Colors.grey[100],
                                  selectedColor: Colors.blue[600],
                                  labelStyle: TextStyle(
                                    color: _selectedSport == sport
                                        ? Colors.white
                                        : Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  checkmarkColor: Colors.white,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // ===================
            // LISTA DE COMPLEJOS
            // ===================
            Expanded(
              child: FutureBuilder<List<ComplexModel>>(
                future: _complexesFuture,
                builder: (context, snapshot) {
                  // Estado de carga
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Cargando complejos...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Estado de error
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                          SizedBox(height: 16),
                          Text(
                            'Error al cargar complejos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  // Sin datos
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stadium, size: 80, color: Colors.grey[300]),
                          SizedBox(height: 16),
                          Text(
                            'No hay complejos disponibles',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Vuelve más tarde',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filtrar complejos
                  final filteredComplexes = _filterComplexes(snapshot.data!);

                  // Sin resultados después de filtrar
                  if (filteredComplexes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                          SizedBox(height: 16),
                          Text(
                            'No se encontraron resultados',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Intentá con otra búsqueda o filtro',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 16),
                          // Botón para limpiar filtros
                          if (_searchQuery.isNotEmpty || _selectedSport != null)
                            ElevatedButton.icon(
                              icon: Icon(Icons.clear_all),
                              label: Text('Limpiar filtros'),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                  _selectedSport = null;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  // Mostrar lista de complejos
                  return Column(
                    children: [
                      // Contador de resultados
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              '${filteredComplexes.length} ${filteredComplexes.length == 1 ? 'complejo encontrado' : 'complejos encontrados'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Lista
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: filteredComplexes.length,
                          itemBuilder: (context, index) {
                            final complex = filteredComplexes[index];
                            return _buildComplexCard(complex);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // Botón flotante para agregar complejo
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewComplex,
        icon: Icon(Icons.add),
        label: Text('Agregar Complejo'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
    );
  }

  // ===================
  // WIDGET: Card de Complejo
  // Card individual para cada complejo deportivo
  // ===================
  Widget _buildComplexCard(ComplexModel complex) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToComplexDetail(complex),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con nombre e ícono
                Row(
                  children: [
                    // Ícono del complejo
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[400]!, Colors.blue[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.stadium,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    
                    // Nombre del complejo
                    Expanded(
                      child: Text(
                        complex.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    
                    // Flecha
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Ubicación
                Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.red[400]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${complex.address}, ${complex.city}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                
                // Teléfono
                Row(
                  children: [
                    Icon(Icons.phone, size: 18, color: Colors.green[400]),
                    SizedBox(width: 8),
                    Text(
                      complex.phone,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                
                // Deportes disponibles
                if (complex.sports.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sports_soccer, size: 16, color: Colors.blue[600]),
                          SizedBox(width: 6),
                          Text(
                            'Deportes disponibles:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: complex.sports.map((sport) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.blue[200]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              sport,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue[700],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
                      SizedBox(width: 6),
                      Text(
                        'No hay deportes especificados',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 12),
                
                // Botón "Ver canchas"
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility, size: 18, color: Colors.blue[700]),
                      SizedBox(width: 8),
                      Text(
                        'Ver canchas disponibles',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}