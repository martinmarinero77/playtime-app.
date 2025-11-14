import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playtime/src/models/equipo_modelo.dart';
import 'package:playtime/src/models/jugador_modelo.dart';
import 'package:playtime/src/controllers/jugador_controller.dart';

class EquipoController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _equiposCollection = FirebaseFirestore.instance.collection('equipos');
  final CollectionReference _reservasCollection = FirebaseFirestore.instance.collection('reservas');
  final JugadorController _jugadorController = JugadorController();

  /// Obtiene un equipo por su ID.
  Future<Equipo?> getEquipo(String equipoId) async {
    if (equipoId.isEmpty) return null;
    
    final doc = await _equiposCollection.doc(equipoId).get();
    if (doc.exists) {
      return Equipo.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Crea un equipo para una reserva, añade al creador como primer miembro y actualiza la reserva.
  Future<String> createEquipoForReserva(String reservaId, String creadorId) async {
    // 1. Crear el primer miembro del equipo (el creador)
    final primerJugador = JugadorEnEquipo(jugadorId: creadorId, camiseta: TipoCamiseta.indefinido);

    // 2. Crear el objeto Equipo
    final nuevoEquipo = Equipo(
      id: '', // Firestore asignará el ID
      reservaId: reservaId,
      jugadores: [primerJugador],
    );

    // 3. Añadir el equipo a la colección 'equipos'
    final docRef = await _equiposCollection.add(nuevoEquipo.toMap());

    // 4. Actualizar el equipo y la reserva con los IDs correspondientes
    await docRef.update({'id': docRef.id});
    await _reservasCollection.doc(reservaId).update({'equipoId': docRef.id});

    return docRef.id;
  }

  /// Añade un jugador a un equipo y a la lista de miembros de la reserva.
  Future<void> addJugadorToEquipo(String equipoId, String jugadorId) async {
    if (equipoId.isEmpty || jugadorId.isEmpty) return;

    final nuevoJugador = JugadorEnEquipo(jugadorId: jugadorId, camiseta: TipoCamiseta.indefinido);
    
    // Adicionalmente, actualizamos la lista 'miembros' en la reserva para las queries
    final Jugador? jugador = await _jugadorController.getJugador(jugadorId);
    if (jugador == null) {
      throw Exception("No se encontró el perfil del jugador a añadir.");
    }

    final equipoDoc = await _equiposCollection.doc(equipoId).get();
    if (equipoDoc.exists) {
      final reservaId = (equipoDoc.data() as Map<String, dynamic>)['reservaId'];
      
      await _firestore.runTransaction((transaction) async {
        // Actualizar el equipo
        transaction.update(_equiposCollection.doc(equipoId), {
          'jugadores': FieldValue.arrayUnion([nuevoJugador.toMap()])
        });
        // Actualizar la reserva
        transaction.update(_reservasCollection.doc(reservaId), {
          'miembros': FieldValue.arrayUnion([jugador.email])
        });
      });
    }
  }

  /// Cambia la camiseta de un jugador dentro de un equipo.
  Future<void> setJugadorCamiseta(String equipoId, String jugadorId, TipoCamiseta nuevaCamiseta) async {
    if (equipoId.isEmpty || jugadorId.isEmpty) return;

    final equipoRef = _equiposCollection.doc(equipoId);
    final equipoDoc = await equipoRef.get();

    if (equipoDoc.exists) {
      final equipo = Equipo.fromMap(equipoDoc.data() as Map<String, dynamic>);
      
      // Encontrar y actualizar el jugador en la lista
      final updatedJugadores = equipo.jugadores.map((j) {
        if (j.jugadorId == jugadorId) {
          return JugadorEnEquipo(jugadorId: j.jugadorId, camiseta: nuevaCamiseta);
        }
        return j;
      }).toList();

      // Reescribir la lista completa en Firestore
      await equipoRef.update({
        'jugadores': updatedJugadores.map((j) => j.toMap()).toList(),
      });
    }
  }

  /// Elimina un jugador de un equipo.
  Future<void> removeJugadorFromEquipo(String equipoId, String jugadorId) async {
    // Esta función es compleja porque requiere eliminar un mapa de un array.
    // La forma más segura es leer, modificar y reescribir, similar a setJugadorCamiseta.
    if (equipoId.isEmpty || jugadorId.isEmpty) return;

    final equipoRef = _equiposCollection.doc(equipoId);
    final equipoDoc = await equipoRef.get();

    if (equipoDoc.exists) {
      final equipo = Equipo.fromMap(equipoDoc.data() as Map<String, dynamic>);
      
      // Filtrar la lista para eliminar al jugador
      final updatedJugadores = equipo.jugadores.where((j) => j.jugadorId != jugadorId).toList();

      // Adicionalmente, eliminarlo de la lista 'miembros' en la reserva
      final Jugador? jugador = await _jugadorController.getJugador(jugadorId);
      if (jugador != null) {
         await _reservasCollection.doc(equipo.reservaId).update({
          'miembros': FieldValue.arrayRemove([jugador.email])
        });
      }

      // Reescribir la lista en el equipo
      await equipoRef.update({
        'jugadores': updatedJugadores.map((j) => j.toMap()).toList(),
      });
    }
  }
}
