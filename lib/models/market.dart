class Market {
  final String? id; // ID Firestore
  final String name;
  final String description;
  final String? hours; // Optionnel
  final double latitude;
  final double longitude;
  final String? image; // URL de l'image Firebase
  final String? cityName; // 🆕 Nouveau champ : nom de la ville

  Market({
    this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.hours,
    this.image,
    this.cityName,
  });

  // 🔁 Créer une copie modifiée de l'objet
  Market copyWith({
    String? id,
    String? name,
    String? description,
    String? hours,
    double? latitude,
    double? longitude,
    String? image,
    String? cityName,
  }) {
    return Market(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      hours: hours ?? this.hours,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      image: image ?? this.image,
      cityName: cityName ?? this.cityName,
    );
  }

  // 🔄 Convertir en Map pour Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'hours': hours,
      'latitude': latitude,
      'longitude': longitude,
      'image': image,
      'cityName': cityName,
    };
  }

  // 🔄 Créer un objet à partir d’un Map (depuis Firestore)
  factory Market.fromMap(Map<String, dynamic> map, {String? id}) {
    return Market(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      hours: map['hours'],
      latitude: (map['latitude'] is int)
          ? (map['latitude'] as int).toDouble()
          : (map['latitude'] ?? 0.0),
      longitude: (map['longitude'] is int)
          ? (map['longitude'] as int).toDouble()
          : (map['longitude'] ?? 0.0),
      image: map['image'],
      cityName: map['cityName'], // 🆕 récupération du nom de la ville
    );
  }
}
