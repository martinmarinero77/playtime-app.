import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:playtime/src/controllers/complex_controller.dart';
import 'package:playtime/src/controllers/reserva_controller.dart';
import 'package:playtime/src/controllers/user_controller.dart';
import 'package:playtime/src/models/complex_model.dart';
import 'package:playtime/src/pages/equipo_reserva_page.dart';
import 'package:playtime/src/pages/complex_detail_page.dart';
import 'package:playtime/src/models/reserva_model.dart';

class PlayTimeHome extends StatefulWidget {
  const PlayTimeHome({super.key});

  @override
  createState() => _PlayTimeHomeState();
}

class _PlayTimeHomeState extends State<PlayTimeHome> {
  late Future<List<ComplexModel>> _complexesFuture;
  late Stream<List<ReservaModel>> _reservationsStream;

  final ComplexController _complexController = ComplexController();
  final ReservaController _reservaController = ReservaController();
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _complexesFuture = _complexController.getComplexes();
    _loadReservations();
  }

  void _loadReservations() {
    final user = _userController.currentUser;
    if (user != null && user.email != null) {
      setState(() {
        _reservationsStream = _reservaController.getReservasForUserStream(user.email!);
      });
    } else {
      setState(() {
        _reservationsStream = Stream.value([]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          _buildSectionHeader('Acciones Rápidas'),
          SizedBox(height: 16),
          _buildQuickActions(),
          SizedBox(height: 32),
          
          // Featured Complexes
          _buildSectionHeader('Complejos Destacados', showViewAll: true),
          SizedBox(height: 16),
          _buildFeaturedComplexes(),
          SizedBox(height: 32),
          
          // Upcoming Events
          _buildSectionHeader('Próximos Partidos'),
          SizedBox(height: 16),
          _buildUpcomingMatch(),
          SizedBox(height: 100), // Padding for bottom navigation
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showViewAll = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        if (showViewAll)
          GestureDetector(
            onTap: () {
              // Navigate to view all
            },
            child: Text(
              'Ver todas',
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4, // Adjusted for a more compact look
      children: [
        _QuickActionCard(
          icon: Icons.calendar_today,
          label: 'Reservar Cancha',
          color: Colors.blue,
          onTap: () {
            Navigator.pushNamed(context, 'complexes');
          },
        ),
        _QuickActionCard(
          icon: Icons.group,
          label: 'Buscar Jugadores',
          color: Colors.green,
          onTap: () {
            // TODO: Navigate to find players screen
          },
        ),
        _QuickActionCard(
          icon: Icons.emoji_events,
          label: 'Mis Torneos',
          color: Colors.orange,
          onTap: () {
            // TODO: Navigate to tournaments screen
          },
        ),
        _QuickActionCard(
          icon: Icons.location_on,
          label: 'Canchas Cercanas',
          color: Colors.purple,
          onTap: () {
            // TODO: Navigate to nearby fields screen
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedComplexes() {
    return FutureBuilder<List<ComplexModel>>(
      future: _complexesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: SelectableText('Error al cargar los complejos: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay complejos destacados disponibles.'));
        }

        final complexes = snapshot.data!;
        return Column(
          children: complexes.map((complex) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComplexDetailPage(complex: complex),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
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
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[400]!, Colors.blue[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Icon(Icons.sports_soccer, color: Colors.white, size: 32),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              complex.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${complex.address}, ${complex.city}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            if (complex.sports.isNotEmpty)
                              Wrap(
                                spacing: 6.0,
                                runSpacing: 6.0,
                                children: complex.sports.map((sport) => Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    sport,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )).toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildUpcomingMatch() {
    return StreamBuilder<List<ReservaModel>>(
      stream: _reservationsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: SelectableText('Error al cargar los partidos: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16),
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
            child: Center(
              child: Text(
                'No tienes próximos partidos.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          );
        }

        final upcomingMatch = snapshot.data!.first;
        final formattedDate = DateFormat('EEEE d, HH:mm', 'es').format(upcomingMatch.horaInicio);
        final playersCount = upcomingMatch.miembros.length;
        final capacity = upcomingMatch.canchaCapacidad * 2;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EquipoReservaPage(reserva: upcomingMatch),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        upcomingMatch.complejoNombre,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${formattedDate[0].toUpperCase()}${formattedDate.substring(1)} hs',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        'Cancha de ${upcomingMatch.canchaDeporte}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        upcomingMatch.estado.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$playersCount/$capacity jugadores',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double cardHeight = constraints.maxHeight;
          final double iconContainerSize = cardHeight * 0.3; // Reduced size
          final double iconSize = iconContainerSize * 0.6;
          final double fontSize = cardHeight * 0.10; // Reduced size
          final double spacing = cardHeight * 0.1;

          return Container(
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
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
                SizedBox(height: spacing),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}