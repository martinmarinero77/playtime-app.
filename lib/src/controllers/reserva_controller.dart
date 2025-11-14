import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:playtime/src/models/reserva_model.dart';

class ReservaController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> crearReserva({
    required String usuarioId,
    required String usuarioEmail, // Email del usuario que crea
    required String complejoId,
    required String complejoNombre,
    required int canchaNumero,
    required String canchaDeporte,
    required int canchaCapacidad,
    required DateTime horaInicio,
  }) async {
    final formattedDate = DateFormat('yyyy-MM-dd-HH').format(horaInicio);
    final docId = '${complejoId}_${canchaNumero}_${canchaDeporte}_${canchaCapacidad}_$formattedDate';
    final docRef = _firestore.collection('reservas').doc(docId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (snapshot.exists) {
        throw Exception('Este horario ya ha sido reservado.');
      }

      transaction.set(docRef, {
        'usuarioId': usuarioId,
        'complejoId': complejoId,
        'complejoNombre': complejoNombre,
        'canchaNumero': canchaNumero,
        'canchaDeporte': canchaDeporte,
        'canchaCapacidad': canchaCapacidad,
        'horaInicio': Timestamp.fromDate(horaInicio),
        'estado': 'confirmada',
        'miembros': [usuarioEmail], // Inicializa la lista de miembros
      });
    });
  }

  Future<List<ReservaModel>> getReservasForFieldAndDate(String complejoId, int canchaNumero, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final querySnapshot = await _firestore
        .collection('reservas')
        .where('complejoId', isEqualTo: complejoId)
        .where('canchaNumero', isEqualTo: canchaNumero)
        .where('horaInicio', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('horaInicio', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return querySnapshot.docs.map((doc) => ReservaModel.fromFirestore(doc)).toList();
  }

  /// Obtiene un stream de todas las reservas donde el usuario es miembro.
  Stream<List<ReservaModel>> getReservasForUserStream(String usuarioEmail) {
    return _firestore
        .collection('reservas')
        .where('miembros', arrayContains: usuarioEmail) // Busca el email en la lista de miembros
        .where('estado', isEqualTo: 'confirmada') // Solo reservas confirmadas
        .where('horaInicio', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('horaInicio', descending: false)
        .snapshots() // Escucha cambios en tiempo real
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) => ReservaModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> cancelarReserva(String reservaId) async {
    await _firestore.collection('reservas').doc(reservaId).delete();
  }
}
