import 'package:cloud_firestore/cloud_firestore.dart';

/// Clase que representa el perfil de un Jugador.
/// Contiene información permanente y pública del usuario.
class Jugador {
  final String id; // Mismo ID que el User de Authentication
  final String nombre;
  final String apellido;
  final String apodo;
  final String email;

  Jugador({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.apodo,
    required this.email,
  });

  // Crea un objeto Jugador desde un documento de Firestore
  factory Jugador.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Jugador(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      apodo: data['apodo'] ?? '',
      email: data['email'] ?? '',
    );
  }

  // Convierte un objeto Jugador a un Map para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'apodo': apodo,
      'email': email,
    };
  }
}
