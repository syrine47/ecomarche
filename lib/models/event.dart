import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final String category; // Type d'événement (marché bio, dégustation, etc.)
  final String imageUrl; // Image de l'événement
  final String organizerId;
  final String organizerName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final List<String> tags;
  final double? latitude;
  final double? longitude;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.category,
    this.imageUrl = '',
    required this.organizerId,
    required this.organizerName,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.tags = const [],
    this.latitude,
    this.longitude,
  });

  // Constructeur depuis Map (Firestore)
  factory Event.fromMap(Map<String, dynamic> map, String documentId) {
    return Event(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      time: map['time'] ?? '',
      location: map['location'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      organizerId: map['organizerId'] ?? '',
      organizerName: map['organizerName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
      tags: List<String>.from(map['tags'] ?? []),
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  // Conversion vers Map (pour Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'time': time,
      'location': location,
      'category': category,
      'imageUrl': imageUrl,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'tags': tags,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Méthode copyWith pour faciliter les modifications
  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? location,
    String? category,
    String? imageUrl,
    String? organizerId,
    String? organizerName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? tags,
    double? latitude,
    double? longitude,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      tags: tags ?? this.tags,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() {
    return 'Event(id: $id, title: $title, date: $date, location: $location)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}