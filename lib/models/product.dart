class Product {
  final String? id; // ID Firestore optionnel
  final String name;
  final String description;
  final double price;
  final String category;
  final String origin;
  final String? image;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.origin,
    this.image,
  });

  // 🔧 AJOUT : méthode copyWith
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? origin,
    String? image,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      origin: origin ?? this.origin,
      image: image ?? this.image,
    );
  }

  // Convertir Product en Map (pour Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'origin': origin,
      'image': image,
    };
  }

  // Construire un Product à partir d'une Map
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0.0),
      category: map['category'] ?? '',
      origin: map['origin'] ?? '',
      image: map['image'],
    );
  }
}
