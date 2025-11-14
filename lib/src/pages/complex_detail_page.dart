import 'package:playtime/src/models/reserva_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playtime/src/models/complex_model.dart';
import 'package:playtime/src/models/field_model.dart';
import 'package:playtime/src/controllers/complex_controller.dart';
import 'package:playtime/src/controllers/reserva_controller.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

// ===================
// PÁGINA: Detalle de Complejo Deportivo
// Muestra canchas disponibles, permite filtrar por deporte y reservar
// ===================
class ComplexDetailPage extends StatefulWidget {
  final ComplexModel complex;

  const ComplexDetailPage({super.key, required this.complex});

  @override
  _ComplexDetailPageState createState() => _ComplexDetailPageState();
}

class _ComplexDetailPageState extends State<ComplexDetailPage> {
  // CONTROLADORES
  final ComplexController _complexController = ComplexController();
  final DatePickerController _datePickerController = DatePickerController();
  
  // ESTADO
  late Future<List<FieldModel>> _fieldsFuture;
  DateTime _selectedValue = DateTime.now();
  String? _selectedSport; // Filtro por deporte - null = todos

  @override
  void initState() {
    super.initState();
    _fieldsFuture = _complexController.getFieldsForComplex(widget.complex.id);
  }

  // ===================
  // FUNCIÓN: Obtener lista de deportes únicos
  // ===================
  List<String> _getSportsFromFields(List<FieldModel> fields) {
    final sports = fields.map((f) => f.sport).toSet().toList();
    sports.sort();
    return sports;
  }

  // ===================
  // FUNCIÓN: Filtrar canchas por deporte seleccionado
  // ===================
  List<FieldModel> _filterFieldsBySport(List<FieldModel> fields) {
    if (_selectedSport == null) return fields;
    return fields.where((f) => f.sport == _selectedSport).toList();
  }

  // ===================
  // FUNCIÓN: Mostrar calendario emergente y actualizar fecha
  // ===================
  Future<void> _selectDateFromCalendar() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedValue,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedValue) {
      setState(() {
        _selectedValue = picked;
      });
      // Animar el DatePickerTimeline a la fecha seleccionada
      _datePickerController.animateToDate(picked);
    }
  }

  // ===================
  // FUNCIÓN: Mostrar modal de selección de horario
  // ===================
  void _showBookingSheet(BuildContext context, FieldModel field) {
    final timeSlots = List.generate(9, (index) => '${15 + index}:00 Hs');
    final reservaController = ReservaController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: FutureBuilder<List<ReservaModel>>(
            future: reservaController.getReservasForFieldAndDate(
              widget.complex.id,
              field.number,
              _selectedValue,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Cargando horarios...',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                        SizedBox(height: 16),
                        Text(
                          'Error al cargar horarios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final bookedHours = snapshot.data?.map((reserva) => reserva.horaInicio.hour).toList() ?? [];

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Indicador visual superior
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      // Header con info de la cancha
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.sports_soccer,
                              color: Colors.blue[700],
                              size: 32,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cancha ${field.number}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${field.sport} • ${field.type}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Precio
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '\$${field.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      
                      // Título de horarios
                      Text(
                        'Seleccionar Horario',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Grid de horarios
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2,
                        ),
                        itemCount: timeSlots.length,
                        itemBuilder: (context, index) {
                          final time = timeSlots[index];
                          final hour = int.parse(time.split(':')[0]);
                          final isBooked = bookedHours.contains(hour);

                          // Verificar si es pasado para hoy
                          final now = DateTime.now();
                          final isToday = _selectedValue.year == now.year &&
                              _selectedValue.month == now.month &&
                              _selectedValue.day == now.day;
                          final isPast = isToday && hour <= now.hour;

                          final isDisabled = isBooked || isPast;

                          return InkWell(
                            onTap: isDisabled
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    _confirmarReserva(context, field, time);
                                  },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDisabled
                                    ? Colors.grey[200]
                                    : Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDisabled
                                      ? Colors.grey[300]!
                                      : Colors.blue[200]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDisabled
                                          ? Colors.grey[500]
                                          : Colors.blue[700],
                                    ),
                                  ),
                                  if (isBooked)
                                    Text(
                                      'Ocupado',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  if (isPast && !isBooked)
                                    Text(
                                      'Pasado',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Widget auxiliar para la leyenda

  // ===================
  // FUNCIÓN: Confirmar reserva
  // ===================
  void _confirmarReserva(BuildContext context, FieldModel field, String time) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Text('Necesitas iniciar sesión para reservar'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.blue[700], size: 28),
            SizedBox(width: 12),
            Text('Confirmar Reserva'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Deseas reservar esta cancha?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.sports, 'Cancha ${field.number}'),
                  SizedBox(height: 8),
                  _buildInfoRow(Icons.access_time, '$time hs'),
                  SizedBox(height: 8),
                  _buildInfoRow(Icons.attach_money, '\$${field.price.toStringAsFixed(0)}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _crearReserva(field, time, user.uid, user.email!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }

  // ===================
  // FUNCIÓN: Crear reserva en la base de datos
  // ===================
  void _crearReserva(FieldModel field, String time, String userId, String userEmail) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
              SizedBox(height: 16),
              Text(
                'Creando reserva...',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final reservaController = ReservaController();
      final hour = int.parse(time.split(':')[0]);
      final bookingTime = DateTime(
        _selectedValue.year,
        _selectedValue.month,
        _selectedValue.day,
        hour,
      );

      await reservaController.crearReserva(
        usuarioId: userId,
        usuarioEmail: userEmail,
        complejoId: widget.complex.id,
        complejoNombre: widget.complex.name,
        canchaNumero: field.number,
        canchaDeporte: field.sport,
        canchaCapacidad: field.capacity,
        horaInicio: bookingTime,
      );

      Navigator.pop(context); // Cerrar loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.celebration, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('¡Reserva confirmada para las $time! 🎉'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
              child: Column(
                children: [
                  // Barra superior con botón volver
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
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
                                widget.complex.name,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Seleccioná tu cancha',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Info del complejo
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRowHeader(Icons.location_on, 
                            '${widget.complex.address}, ${widget.complex.city}'),
                        SizedBox(height: 8),
                        _buildInfoRowHeader(Icons.phone, widget.complex.phone),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===================
            // CONTENIDO SCROLLEABLE
            // ===================
            Expanded(
              child: FutureBuilder<List<FieldModel>>(
                future: _fieldsFuture,
                builder: (context, snapshot) {
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
                            'Cargando canchas...',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('No hay canchas disponibles para este complejo.'),
                    );
                  }

                  final allFields = snapshot.data!;
                  final sports = _getSportsFromFields(allFields);
                  final filteredFields = _filterFieldsBySport(allFields);
                  
                  filteredFields.sort((a, b) => a.number.compareTo(b.number));

                  return CustomScrollView(
                    slivers: [
                      // --- Selector de Fecha ---
                      SliverToBoxAdapter(
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: Text(
                                  'Seleccionar Fecha',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DatePicker(
                                        DateTime.now(),
                                        controller: _datePickerController,
                                        initialSelectedDate: _selectedValue,
                                        selectionColor: Colors.blue[600]!,
                                        selectedTextColor: Colors.white,
                                        locale: 'es_ES',
                                        height: 100,
                                        daysCount: 5, // Muestra 5 días
                                        onDateChange: (date) {
                                          setState(() {
                                            _selectedValue = date;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[300]!)
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.calendar_month, color: Colors.blue[700]),
                                        onPressed: _selectDateFromCalendar,
                                        tooltip: 'Seleccionar otra fecha',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),

                      // --- Filtros por Deporte ---
                      if (sports.length > 1)
                        SliverToBoxAdapter(
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Filtrar por deporte',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 12),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: FilterChip(
                                          label: Text('Todos'),
                                          selected: _selectedSport == null,
                                          onSelected: (selected) {
                                            setState(() { _selectedSport = null; });
                                          },
                                          backgroundColor: Colors.grey[100],
                                          selectedColor: Colors.blue[600],
                                          labelStyle: TextStyle(color: _selectedSport == null ? Colors.white : Colors.grey[700]),
                                          checkmarkColor: Colors.white,
                                        ),
                                      ),
                                      ...sports.map((sport) {
                                        return Padding(
                                          padding: EdgeInsets.only(right: 8),
                                          child: FilterChip(
                                            label: Text(sport),
                                            selected: _selectedSport == sport,
                                            onSelected: (selected) {
                                              setState(() { _selectedSport = selected ? sport : null; });
                                            },
                                            backgroundColor: Colors.grey[100],
                                            selectedColor: Colors.blue[600],
                                            labelStyle: TextStyle(color: _selectedSport == sport ? Colors.white : Colors.grey[700]),
                                            checkmarkColor: Colors.white,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      // --- Lista de Canchas ---
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                        sliver: filteredFields.isEmpty
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 50),
                                    Icon(Icons.filter_list_off, size: 64, color: Colors.grey[300]),
                                    SizedBox(height: 16),
                                    Text(
                                      'No hay canchas de ${_selectedSport ?? 'este tipo'}',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                                    ),
                                    SizedBox(height: 8),
                                    Text('Probá con otro deporte o fecha', style: TextStyle(color: Colors.grey[500])),
                                  ],
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final field = filteredFields[index];
                                  return _buildCanchaCard(field);
                                },
                                childCount: filteredFields.length,
                              ),
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
    );
  }

  // ===================
  // WIDGET: Info row para header
  // ===================
  Widget _buildInfoRowHeader(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ===================
  // WIDGET: Card de Cancha
  // Card individual para cada cancha
  // ===================
  Widget _buildCanchaCard(FieldModel field) {
    // Mapeo de deportes a colores
    final sportColors = {
      'Fútbol': Colors.green,
      'Pádel': Colors.blue,
      'Tenis': Colors.orange,
      'Básquet': Colors.red,
      'Vóley': Colors.purple,
    };

    final MaterialColor sportColor = sportColors[field.sport] ?? Colors.blue;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
          onTap: () => _showBookingSheet(context, field),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Número de cancha
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [sportColor.shade400, sportColor.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      field.number.toString(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                
                // Información de la cancha
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Deporte y tipo
                      Text(
                        field.sport,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        field.type,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      // Capacidad
                      Row(
                        children: [
                          Icon(Icons.people, size: 16, color: Colors.grey[500]),
                          SizedBox(width: 4),
                          Text(
                            '${field.capacity} jugadores',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Precio y botón
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Precio
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '\$${field.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          Text(
                            'por hora',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    // Botón reservar
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sportColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Reservar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}