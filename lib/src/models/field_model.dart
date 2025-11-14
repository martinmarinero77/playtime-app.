import 'package:cloud_firestore/cloud_firestore.dart';

class FieldModel {
  final String id;
  final String complexId;
  final String sport;
  final String type;
  final int capacity;
  final double price;
  final int number;

  FieldModel({
    required this.id,
    required this.complexId,
    required this.sport,
    required this.type,
    required this.capacity,
    required this.price,
    required this.number,
  });

  factory FieldModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FieldModel(
      id: doc.id,
      complexId: data['complexId'] ?? '',
      sport: data['deporte'] ?? '',
      type: data['tipo'] ?? '',
      capacity: data['capacidad'] ?? 0,
      price: (data['precio'] ?? 0.0).toDouble(),
      number: data['numero'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'complexId': complexId,
      'deporte': sport,
      'tipo': type,
      'capacidad': capacity,
      'precio': price,
      'numero': number,
    };
  }
}