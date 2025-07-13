import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Inscription
  Future<void> registerUser(UserModel userModel, String password) async {
    try {
      // 🔐 Créer l'utilisateur dans Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: userModel.email,
            password: password,
          );

      final uid = userCredential.user!.uid;

      // 👤 Enregistrer les infos dans Firestore avec uid comme ID
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'nom': userModel.nom,
        'prenom': userModel.prenom,
        'email': userModel.email,
        'dateNaissance': userModel.dateNaissance,
      });
    } catch (e) {
      print("❌ Erreur d'inscription: $e");
      rethrow;
    }
  }

  /// Connexion
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("❌ Erreur de connexion: $e");
      rethrow;
    }
  }

  /// Récupérer les données utilisateur
  Future<UserModel?> getUserData(String uid) async {
    try {
      final snapshot = await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data()!);
      }
    } catch (e) {
      print("❌ Erreur récupération données utilisateur: $e");
    }
    return null;
  }

  /// Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
