class UserModel {
  final String uid;
  final String nom;
  final String prenom;
  final String email;
  final String dateNaissance;
  final String role; // 👈 NOUVEAU : rôle ajouté

  UserModel({
    required this.uid,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.dateNaissance,
    this.role = 'user', // 👈 Par défaut : 'user'
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'dateNaissance': dateNaissance,
      'role': role, // 👈 Inclure le rôle dans la map
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      email: map['email'] ?? '',
      dateNaissance: map['dateNaissance'] ?? '',
      role: map['role'] ?? 'user', // 👈 Par défaut 'user' si pas trouvé
    );
  }

  // 👈 NOUVEAU : Méthodes utiles pour vérifier le rôle
  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';
}