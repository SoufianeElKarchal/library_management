import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================
  // Inscription
  // ==========================
  Future<String?> register({
    required String nom,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'nom': nom,
        'email': email,
        'role': role,
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ==========================
  // Connexion
  // ==========================
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ==========================
  // Déconnexion
  // ==========================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ==========================
  // Utilisateur connecté
  // ==========================
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
