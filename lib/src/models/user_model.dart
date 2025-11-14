import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String localidad;

  UserModel({
    required this.uid,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.localidad,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      email: data['email'] ?? '',
      telefono: data['telefono'] ?? '',
      localidad: data['localidad'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'localidad': localidad,
    };
  }
}