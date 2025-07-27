import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;

  UserModel? get user => _user;

  // 👈 NOUVEAU : Getters pour vérifier le rôle facilement
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isUser => _user?.isUser ?? true;
  String get userRole => _user?.role ?? 'user';

  /// Inscription d'un utilisateur
  Future<void> registerUser({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String dateNaissance,
  }) async {
    final userModel = UserModel(
      uid: '', // UID sera défini dans Firestore automatiquement par l'ID du document
      nom: nom,
      prenom: prenom,
      email: email,
      dateNaissance: dateNaissance,
      role: 'user', // 👈 Rôle par défaut lors de l'inscription
    );

    await _authService.registerUser(userModel, password);
    notifyListeners();
  }

  /// Connexion avec redirection selon le rôle
  Future<void> login(String email, String password, BuildContext context) async {
    final user = await _authService.signIn(email, password);

    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      _user = userData;
      notifyListeners();

      // 👈 NOUVEAU : Redirection selon le rôle
      if (_user != null) {
        if (_user!.isAdmin) {
          // Redirection vers interface admin
          Navigator.pushReplacementNamed(context, '/product-form');
        } else {
          // Redirection vers interface utilisateur normal
          Navigator.pushReplacementNamed(context, '/product-list');
        }
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    await _authService.signOut(); // déconnexion Firebase
    _user = null;
    notifyListeners();

    // Redirection vers la LandingPage
    Navigator.pushReplacementNamed(context, '/landing');
  }
}