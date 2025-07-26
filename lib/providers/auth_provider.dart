import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;

  UserModel? get user => _user;

  /// Inscription d’un utilisateur
  Future<void> registerUser({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String dateNaissance,
  }) async {
    final userModel = UserModel(
      uid:
          '', // UID sera défini dans Firestore automatiquement par l’ID du document
      nom: nom,
      prenom: prenom,
      email: email,
      dateNaissance: dateNaissance,
    );

    await _authService.registerUser(userModel, password);
    notifyListeners();
  }

  /// Connexion
  Future<void> login(String email, String password) async {
    final user = await _authService.signIn(email, password);

    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      _user = userData;
      notifyListeners();
    }
  }

  /// Déconnexion
  // Future<void> logout() async {
  //   await _authService.signOut(); // déconnexion Firebase
  //   _user = null; // vider les données locales
  //   notifyListeners(); // notifier les listeners
  // }

  Future<void> logout(BuildContext context) async {
  await _authService.signOut(); // déconnexion Firebase
  _user = null;
  notifyListeners();

  // Redirection vers la LandingPage
  Navigator.pushReplacementNamed(context, '/landing');
}

}