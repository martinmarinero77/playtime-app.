import 'package:cloud_firestore/cloud_firestore.dart';

class ComplexModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final List<String> sports;

  ComplexModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.sports,
  });

  factory ComplexModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<String> sportsFromDb = [];
    if (data['deportes'] is List) {
      sportsFromDb = List<String>.from(data['deportes'].map((item) => item.toString()));
    }

    return ComplexModel(
      id: doc.id,
      name: data['nombre'] ?? '',
      phone: data['telefono'] ?? '',
      address: data['domicilio'] ?? '',
      city: data['localidad'] ?? '',
      state: data['provincia'] ?? '',
      sports: sportsFromDb,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': name,
      'telefono': phone,
      'domicilio': address,
      'localidad': city,
      'provincia': state,
      'deportes': sports,
    };
  }
}