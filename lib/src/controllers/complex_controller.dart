import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playtime/src/models/complex_model.dart';
import 'package:playtime/src/models/field_model.dart';

class ComplexController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ComplexModel>> getComplexes() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('complejos').get();
      List<ComplexModel> complexes = querySnapshot.docs.map((doc) {
        return ComplexModel.fromFirestore(doc);
      }).toList();
      return complexes;
    } catch (e) {
      print('Error getting complexes: $e');
      return [];
    }
  }

  Future<List<FieldModel>> getFieldsForComplex(String complexId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('complejos')
          .doc(complexId)
          .collection('canchas')
          .get();

      List<FieldModel> fields = querySnapshot.docs.map((doc) {
        return FieldModel.fromFirestore(doc);
      }).toList();
      
      return fields;
    } catch (e) {
      print('Error getting fields for complex $complexId: $e');
      return [];
    }
  }
}
