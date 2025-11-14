/// Enum para representar el tipo de camiseta.
enum TipoCamiseta {
  clara,
  oscura,
  indefinido, // Para jugadores que aún no han elegido
}

// --- Clase de Vínculo ---
/// Representa un jugador dentro de un equipo para una reserva específica,
/// vinculando su ID con la camiseta que ha elegido.
class JugadorEnEquipo {
  final String jugadorId; // Coincide con el ID del Jugador y del User
  final TipoCamiseta camiseta;

  JugadorEnEquipo({required this.jugadorId, required this.camiseta});

  // Métodos para serialización (guardar/leer en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'jugadorId': jugadorId,
      'camiseta': camiseta.toString().split('.').last,
    };
  }

  factory JugadorEnEquipo.fromMap(Map<String, dynamic> map) {
    return JugadorEnEquipo(
      jugadorId: map['jugadorId'] ?? '',
      camiseta: TipoCamiseta.values.firstWhere(
        (e) => e.toString().split('.').last == map['camiseta'],
        orElse: () => TipoCamiseta.indefinido,
      ),
    );
  }
}


// --- Clase Principal ---
/// Modelo que representa al Equipo de una reserva.
class Equipo {
  final String id;
  final String reservaId;
  final List<JugadorEnEquipo> jugadores;

  Equipo({
    required this.id,
    required this.reservaId,
    required this.jugadores,
  });

  // Métodos para serialización (guardar/leer en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reservaId': reservaId,
      'jugadores': jugadores.map((j) => j.toMap()).toList(),
    };
  }

  factory Equipo.fromMap(Map<String, dynamic> map) {
    return Equipo(
      id: map['id'] ?? '',
      reservaId: map['reservaId'] ?? '',
      jugadores: (map['jugadores'] as List<dynamic>?)
          ?.map((j) => JugadorEnEquipo.fromMap(j as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

