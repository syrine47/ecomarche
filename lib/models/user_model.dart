class UserModel {
  final String uid;
  final String nom;
  final String prenom;
  final String email;
  final String dateNaissance;

  UserModel({
    required this.uid,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.dateNaissance,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'dateNaissance': dateNaissance,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      email: map['email'] ?? '',
      dateNaissance: map['dateNaissance'] ?? '',
    );
  }
}