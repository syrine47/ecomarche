class Market {
  final String? id; // ID Firestore
  final String name;
  final String description;
  final String? hours; // optionnel
  final double latitude;
  final double longitude;
  final String? image; // URL de l'image dans Firebase Storage

  Market({
    this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.hours,
    this.image,
  });

  // 🔁 copyWith : pour faire une copie modifiable
  Market copyWith({
    String? id,
    String? name,
    String? description,
    String? hours,
    double? latitude,
    double? longitude,
    String? image,
  }) {
    return Market(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      hours: hours ?? this.hours,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      image: image ?? this.image,
    );
  }

  // 🔄 toMap : pour sauvegarder dans Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'hours': hours,
      'latitude': latitude,
      'longitude': longitude,
      'image': image,
    };
  }

  // 🔄 fromMap : pour lire depuis Firestore
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
    );
  }
}

         