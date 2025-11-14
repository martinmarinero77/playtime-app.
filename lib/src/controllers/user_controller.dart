
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playtime/src/models/user_model.dart';
import 'package:playtime/src/models/jugador_modelo.dart';
import 'package:playtime/src/controllers/jugador_controller.dart';

class UserController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final JugadorController _jugadorController = JugadorController();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase auth errors
      print('Firebase Auth Error: ${e.message}');
      return null;
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(
      String email, String password, String nombre, String apellido, String telefono) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create a new user document in Firestore
      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'telefono': telefono,
        'localidad': '', // Set localidad to empty as requested
      });

      // Also create the public player profile
      final nuevoJugador = Jugador(
        id: userCredential.user!.uid,
        nombre: nombre,
        apellido: apellido,
        apodo: '', // Apodo se puede añadir/editar después en el perfil
        email: email,
      );
      await _jugadorController.createJugadorProfile(nuevoJugador);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase auth errors
      print('Firebase Auth Error: ${e.message}');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return null;
  }
}
