import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playtime/src/models/jugador_modelo.dart';

class JugadorController {
  final CollectionReference _jugadoresCollection = FirebaseFirestore.instance.collection('jugadores');

  /// Obtiene el perfil de un jugador por su ID.
  Future<Jugador?> getJugador(String jugadorId) async {
    if (jugadorId.isEmpty) return null;
    
    final doc = await _jugadoresCollection.doc(jugadorId).get();
    if (doc.exists) {
      return Jugador.fromFirestore(doc);
    }
    return null;
  }

  /// Busca un jugador por su email.
  Future<Jugador?> findJugadorByEmail(String email) async {
    if (email.isEmpty) return null;

    final querySnapshot = await _jugadoresCollection
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return Jugador.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }

  /// Crea un documento de perfil para un nuevo jugador.
  Future<void> createJugadorProfile(Jugador jugador) async {
    return _jugadoresCollection.doc(jugador.id).set(jugador.toMap());
  }

  /// Obtiene múltiples perfiles de jugador en una sola consulta.
  Future<Map<String, Jugador>> getMultipleJugadores(List<String> jugadorIds) async {
    if (jugadorIds.isEmpty) {
      return {};
    }

    final Map<String, Jugador> perfiles = {};
    // Firestore permite hasta 30 IDs en una consulta 'whereIn'
    final chunks = _splitList(jugadorIds, 30);

    for (final chunk in chunks) {
      final querySnapshot = await _jugadoresCollection
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      
      for (final doc in querySnapshot.docs) {
        perfiles[doc.id] = Jugador.fromFirestore(doc);
      }
    }
    
    return perfiles;
  }

  // Helper para dividir la lista en trozos de un tamaño máximo
  List<List<T>> _splitList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }
}
