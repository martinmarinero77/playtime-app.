// ignore_for_file: use_build_context_synchronously

import 'package:playtime/src/widget/reserva_card.dart';
import 'package:playtime/src/controllers/equipo_controller.dart';
import 'package:playtime/src/pages/equipo_reserva_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playtime/src/controllers/reserva_controller.dart';
import 'package:playtime/src/models/reserva_model.dart';

class UserReservasPage extends StatefulWidget {
  const UserReservasPage({super.key});

  @override
  _UserReservasPageState createState() => _UserReservasPageState();
}

class _UserReservasPageState extends State<UserReservasPage> {
  final ReservaController _reservaController = ReservaController();
  final EquipoController _equipoController = EquipoController();
  late Stream<List<ReservaModel>> _reservasStream;
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadReservas();
  }

  void _loadReservas() {
    if (_user != null && _user.email != null) {
      setState(() {
        _reservasStream = _reservaController.getReservasForUserStream(_user.email!);
      });
    } else {
      setState(() {
        _reservasStream = Stream.value([]);
      });
    }
  }

  Future<void> _navigateToEquipoPage(ReservaModel reserva) async {
    final currentUser = _user;
    if (currentUser == null) return;

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
                'Preparando equipo...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      String? equipoId = reserva.equipoId;
      ReservaModel reservaActualizada = reserva;

      if (equipoId == null || equipoId.isEmpty) {
        equipoId = await _equipoController.createEquipoForReserva(
          reserva.id,
          currentUser.uid,
        );
        
        reservaActualizada = ReservaModel(
          id: reserva.id,
          usuarioId: reserva.usuarioId,
          complejoId: reserva.complejoId,
          complejoNombre: reserva.complejoNombre,
          canchaNumero: reserva.canchaNumero,
          canchaDeporte: reserva.canchaDeporte,
          canchaCapacidad: reserva.canchaCapacidad,
          horaInicio: reserva.horaInicio,
          estado: reserva.estado,
          equipoId: equipoId,
          miembros: reserva.miembros,
        );
        
        // No need to call _loadReservas(); Stream will update
      }

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EquipoReservaPage(reserva: reservaActualizada),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear el equipo: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _cancelarReserva(ReservaModel reserva) async {
    if (_user?.uid != reserva.usuarioId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.lock_person, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Solo el creador de la reserva puede cancelarla.')),
            ],
          ),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final canCancel = DateTime.now().isBefore(
      reserva.horaInicio.subtract(const Duration(hours: 1)),
    );

    if (canCancel) {
      final bool? didConfirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 28),
              SizedBox(width: 12),
              Text('Confirmar Cancelación'),
            ],
          ),
          content: Text(
            '¿Estás seguro de que deseas cancelar esta reserva?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Sí, Cancelar'),
            ),
          ],
        ),
      );

      if (didConfirm == true) {
        try {
          await _reservaController.cancelarReserva(reserva.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Reserva cancelada exitosamente'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // No need to call _loadReservas(); Stream will update
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cancelar la reserva: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.block, color: Colors.red[700], size: 28),
              SizedBox(width: 12),
              Text('No se puede cancelar'),
            ],
          ),
          content: Text(
            'Lo sentimos, no puedes cancelar una reserva cuando falta menos de 1 hora para su inicio.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }

  void _salirDelEquipo(ReservaModel reserva) async {
    if (_user == null) return;
    if (reserva.equipoId == null || reserva.equipoId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: No se encontró el equipo asociado a esta reserva.')),
      );
      return;
    }

    final bool? didConfirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Salir del Equipo'),
        content: Text('¿Estás seguro de que quieres salir de esta reserva?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Sí, Salir')),
        ],
      ),
    );

    if (didConfirm == true) {
      try {
        await _equipoController.removeJugadorFromEquipo(reserva.equipoId!, _user.uid);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Has salido del equipo exitosamente.'), backgroundColor: Colors.green),
        );
        // No need to call _loadReservas(); Stream will update
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al salir del equipo: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _navigarABuscarCanchas() {
    Navigator.pushNamed(context, 'complexes');
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 80, color: Colors.grey[400]),
              SizedBox(height: 24),
              Text(
                'Necesitas iniciar sesión',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Inicia sesión para ver tus reservas',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mis Reservas',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Gestioná tus partidos',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nueva Reserva',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[600]!, Colors.blue[700]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _navigarABuscarCanchas,
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.add_circle_outline,
                                          size: 48,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Reservar una Cancha',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Buscá y reservá canchas disponibles en tu zona',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Buscar Canchas',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward,
                                              color: Colors.blue[700],
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            'Reservas Activas',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 12),
                          StreamBuilder<List<ReservaModel>>(
                            stream: _reservasStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Container(
                                  padding: EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.error_outline, 
                                           size: 48, 
                                           color: Colors.red[400]),
                                      SizedBox(height: 12),
                                      Text(
                                        'Error al cargar reservas',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red[900],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      SelectableText(
                                        '${snapshot.error}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.blue[600]!,
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Cargando reservas...',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Container(
                                  padding: EdgeInsets.all(32),
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
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.event_busy,
                                          size: 64,
                                          color: Colors.grey[300],
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'No hay reservas activas',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '¡Reservá tu cancha!',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final reservas = snapshot.data!;
                              return Column(
                                children: reservas.map((reserva) {
                                  final bool esCreador = _user.uid == reserva.usuarioId;
                                  return ReservaCard(
                                    reserva: reserva,
                                    actions: esCreador
                                        ? _buildCreatorActions(reserva)
                                        : _buildMemberActions(reserva),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCreatorActions(ReservaModel reserva) {
    return [
      Expanded(
        child: ElevatedButton.icon(
          icon: Icon(Icons.group, size: 20),
          label: Text('Armar Equipo'),
          onPressed: () => _navigateToEquipoPage(reserva),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      SizedBox(width: 12),
      Expanded(
        child: OutlinedButton.icon(
          icon: Icon(Icons.cancel, size: 20),
          label: Text('Cancelar'),
          onPressed: () => _cancelarReserva(reserva),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red[600],
            side: BorderSide(color: Colors.red[600]!, width: 1.5),
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildMemberActions(ReservaModel reserva) {
    return [
      Expanded(
        child: ElevatedButton.icon(
          icon: Icon(Icons.group, size: 20),
          label: Text('Ver Equipos'),
          onPressed: () => _navigateToEquipoPage(reserva),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      SizedBox(width: 12),
      Expanded(
        child: OutlinedButton.icon(
          icon: Icon(Icons.exit_to_app, size: 20),
          label: Text('Salir'),
          onPressed: () => _salirDelEquipo(reserva),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange[800],
            side: BorderSide(color: Colors.orange[800]!, width: 1.5),
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    ];
  }
}