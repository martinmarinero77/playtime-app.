import 'package:cloud_firestore/cloud_firestore.dart';

class ReservaModel {
  final String id;
  final String usuarioId;
  final String complejoId;
  final String complejoNombre;
  final int canchaNumero;
  final String canchaDeporte;
  final int canchaCapacidad;
  final DateTime horaInicio;
  final String estado;
  final String? equipoId;
  final List<String> miembros; // Lista de emails de los participantes

  ReservaModel({
    required this.id,
    required this.usuarioId,
    required this.complejoId,
    required this.complejoNombre,
    required this.canchaNumero,
    required this.canchaDeporte,
    required this.canchaCapacidad,
    required this.horaInicio,
    required this.estado,
    this.equipoId,
    required this.miembros,
  });

  factory ReservaModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReservaModel(
      id: doc.id,
      usuarioId: data['usuarioId'] ?? '',
      complejoId: data['complejoId'] ?? '',
      complejoNombre: data['complejoNombre'] ?? 'Nombre no disponible',
      canchaNumero: data['canchaNumero'] ?? 0,
      canchaDeporte: data['canchaDeporte'] ?? '',
      canchaCapacidad: data['canchaCapacidad'] ?? 0,
      horaInicio: (data['horaInicio'] as Timestamp).toDate(),
      estado: data['estado'] ?? '',
      equipoId: data['equipoId'],
      miembros: List<String>.from(data['miembros'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'complejoId': complejoId,
      'complejoNombre': complejoNombre,
      'canchaNumero': canchaNumero,
      'canchaDeporte': canchaDeporte,
      'canchaCapacidad': canchaCapacidad,
      'horaInicio': horaInicio,
      'estado': estado,
      'equipoId': equipoId,
      'miembros': miembros,
    };
  }
}