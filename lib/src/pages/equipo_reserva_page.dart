// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playtime/src/models/reserva_model.dart';
import 'package:playtime/src/models/equipo_modelo.dart';
import 'package:playtime/src/models/jugador_modelo.dart';
import 'package:playtime/src/controllers/equipo_controller.dart';
import 'package:playtime/src/controllers/jugador_controller.dart';

class _EquipoConDetalles {
  final Equipo equipo;
  final Map<String, Jugador> perfiles;
  _EquipoConDetalles({required this.equipo, required this.perfiles});
}

class EquipoReservaPage extends StatefulWidget {
  final ReservaModel reserva;
  const EquipoReservaPage({super.key, required this.reserva});

  @override
  _EquipoReservaPageState createState() => _EquipoReservaPageState();
}

class _EquipoReservaPageState extends State<EquipoReservaPage> {
  final EquipoController _equipoController = EquipoController();
  final JugadorController _jugadorController = JugadorController();
  final TextEditingController _emailController = TextEditingController();
  final User? _user = FirebaseAuth.instance.currentUser;

  late Future<_EquipoConDetalles> _pageFuture;
  late final bool _esCreador;

  @override
  void initState() {
    super.initState();
    _esCreador = _user?.uid == widget.reserva.usuarioId;
    _loadAllData();
  }

  void _loadAllData() {
    setState(() {
      _pageFuture = _fetchData();
    });
  }

  Future<_EquipoConDetalles> _fetchData() async {
    final equipo = await _equipoController.getEquipo(widget.reserva.equipoId!);
    if (equipo == null) {
      throw Exception('No se pudo encontrar el equipo.');
    }
    final jugadorIds = equipo.jugadores.map((j) => j.jugadorId).toList();
    final perfiles = await _jugadorController.getMultipleJugadores(jugadorIds);
    return _EquipoConDetalles(equipo: equipo, perfiles: perfiles);
  }

  Future<void> _addJugador() async {
    if (_emailController.text.isEmpty) return;
    final email = _emailController.text.trim();

    try {
      final jugador = await _jugadorController.findJugadorByEmail(email);
      if (jugador == null) {
        throw Exception("No se encontró ningún jugador con ese email.");
      }
      await _equipoController.addJugadorToEquipo(widget.reserva.equipoId!, jugador.id);
      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ ${jugador.nombre} agregado correctamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadAllData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _setCamiseta(String jugadorId, TipoCamiseta camiseta) async {
    try {
      await _equipoController.setJugadorCamiseta(widget.reserva.equipoId!, jugadorId, camiseta);
      final equipoNombre = camiseta == TipoCamiseta.clara ? 'Camiseta Clara' : 'Camiseta Oscura';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Jugador movido a $equipoNombre'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      _loadAllData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar de equipo: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _removeJugador(String jugadorId) async {
    if (!_esCreador) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No tienes permiso para eliminar jugadores.')));
      return;
    }
    if (jugadorId == _user!.uid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No puedes eliminarte a ti mismo.')));
      return;
    }

    final bool? didConfirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 28),
          SizedBox(width: 12),
          Text('Confirmar Eliminación'),
        ]),
        content: Text('¿Estás seguro de que deseas eliminar a este jugador del equipo?', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Sí, Eliminar'),
          ),
        ],
      ),
    );

    if (didConfirm == true) {
      try {
        await _equipoController.removeJugadorFromEquipo(widget.reserva.equipoId!, jugadorId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Jugador eliminado correctamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadAllData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar jugador: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
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
                child: Row(children: [
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
                        Text('Armar Equipos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 4),
                        Text('Organizá los jugadores por camiseta', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.people, color: Colors.white, size: 28),
                  ),
                ]),
              ),
            ),
            Expanded(
              child: FutureBuilder<_EquipoConDetalles>(
                future: _pageFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!)),
                        SizedBox(height: 16),
                        Text('Cargando equipos...', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      ]),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                        SizedBox(height: 16),
                        Text('Error al cargar los datos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                        SizedBox(height: 8),
                        Text('${snapshot.error}', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                      ]),
                    );
                  }

                  final data = snapshot.data!;
                  final equipo = data.equipo;
                  final perfiles = data.perfiles;
                  final jugadoresClaros = equipo.jugadores.where((j) => j.camiseta == TipoCamiseta.clara).toList();
                  final jugadoresOscuros = equipo.jugadores.where((j) => j.camiseta == TipoCamiseta.oscura).toList();
                  final jugadoresIndefinidos = equipo.jugadores.where((j) => j.camiseta == TipoCamiseta.indefinido).toList();

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(children: [
                          Expanded(child: _buildResumenCard('Claros', jugadoresClaros.length, Icons.shield, Colors.blue[600]!)),
                          SizedBox(width: 12),
                          Expanded(child: _buildResumenCard('Oscuros', jugadoresOscuros.length, Icons.shield, Colors.grey[800]!)),
                        ]),
                      ),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _buildEquipoSection('Camiseta Clara', jugadoresClaros, perfiles, Colors.blue[600]!, Icons.shield),
                            SizedBox(height: 16),
                            _buildEquipoSection('Camiseta Oscura', jugadoresOscuros, perfiles, Colors.grey[800]!, Icons.shield),
                            SizedBox(height: 16),
                            if (jugadoresIndefinidos.isNotEmpty)
                              _buildEquipoSection('Sin Equipo Asignado', jugadoresIndefinidos, perfiles, Colors.orange[600]!, Icons.help_outline),
                            SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            _buildAddJugadorSection(),
          ],
        ),
      ),
    );
  }

 //Widget para mostrar el resumen de cada equipo
  Widget _buildResumenCard(String titulo, int cantidad, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 28),
        ),
        SizedBox(height: 12),
        Text(cantidad.toString(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 4),
        Text(titulo, style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
      ]),
    );
  }

 //Widget para mostrar equipos
  Widget _buildEquipoSection(String title, List<JugadorEnEquipo> jugadores, Map<String, Jugador> perfiles, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: 12),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                child: Text('${jugadores.length}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ]),
          ),
          if (jugadores.isEmpty)
            Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(children: [
                  Icon(Icons.sports_soccer, size: 48, color: Colors.grey[300]),
                  SizedBox(height: 12),
                  Text('No hay jugadores en este equipo', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                ]),
              ),
            )
          else
            ...jugadores.map((jugadorEnEquipo) {
              final perfil = perfiles[jugadorEnEquipo.jugadorId];
              return perfil != null ? _buildJugadorTile(perfil, color) : SizedBox.shrink();
            }),
        ],
      ),
    );
  }

 //Widget para mostrar jugadores
  Widget _buildJugadorTile(Jugador jugador, Color teamColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: teamColor.withOpacity(0.2),
          child: Text(
            jugador.nombre.isNotEmpty ? jugador.nombre[0].toUpperCase() : jugador.email[0].toUpperCase(),
            style: TextStyle(color: teamColor, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        title: Text(
          jugador.nombre.isNotEmpty ? '${jugador.nombre} ${jugador.apellido}' : jugador.email,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey[800]),
        ),
        subtitle: jugador.apodo.isNotEmpty
            ? Row(children: [
                Icon(Icons.badge, size: 14, color: Colors.grey[500]),
                SizedBox(width: 4),
                Text(jugador.apodo, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ])
            : Text(jugador.email, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // El botón para cambiar de equipo ahora es visible para todos
            Container(
              decoration: BoxDecoration(color: teamColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: PopupMenuButton<TipoCamiseta>(
                onSelected: (camiseta) => _setCamiseta(jugador.id, camiseta),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: TipoCamiseta.clara,
                    child: Row(children: [Icon(Icons.shield, color: Colors.blue[600], size: 20), SizedBox(width: 12), Text('Camiseta Clara')]),
                  ),
                  PopupMenuItem(
                    value: TipoCamiseta.oscura,
                    child: Row(children: [Icon(Icons.shield, color: Colors.grey[800], size: 20), SizedBox(width: 12), Text('Camiseta Oscura')]),
                  ),
                ],
                icon: Icon(Icons.swap_horiz, color: teamColor),
                tooltip: 'Cambiar equipo',
              ),
            ),
            // El botón para eliminar sigue siendo solo para el creador
            if (_esCreador && jugador.id != _user?.uid)
              Container(
                margin: EdgeInsets.only(left: 4),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: Colors.red[700]),
                  onPressed: () => _removeJugador(jugador.id),
                  tooltip: 'Eliminar jugador',
                ),
              ),
          ],
        ),
      ),
    );
  }

 //Widget para agregar jugadores
  Widget _buildAddJugadorSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email del jugador',
                hintText: 'jugador@email.com',
                prefixIcon: Icon(Icons.person_add, color: Colors.blue[600]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue[600]!, width: 2)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), spreadRadius: 1, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: IconButton(
              icon: Icon(Icons.add_circle, size: 32, color: Colors.white),
              onPressed: _addJugador,
              tooltip: 'Agregar jugador',
            ),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}