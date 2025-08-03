import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'events';

  // Créer un événement
  static Future<String> createEvent(Event event) async {
    try {
      final docRef = await _firestore.collection(_collection).add(event.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'événement: $e');
    }
  }

  // Récupérer tous les événements (stream) - SIMPLIFIÉ
  static Stream<List<Event>> getAllEventsStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs.map((doc) {
        return Event.fromMap(doc.data(), doc.id);
      }).toList();
      
      // Trier côté client pour éviter l'index
      events.sort((a, b) => a.date.compareTo(b.date));
      return events;
    }).handleError((error) {
      print('Erreur dans getAllEventsStream: $error');
      return <Event>[];
    });
  }

  // Récupérer les événements à venir - CORRIGÉ SANS INDEX
  static Stream<List<Event>> getUpcomingEventsStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final events = snapshot.docs.map((doc) {
        return Event.fromMap(doc.data(), doc.id);
      }).toList();
      
      // Filtrer et trier côté client
      final upcomingEvents = events
          .where((event) => event.date.isAfter(now))
          .toList();
      
      upcomingEvents.sort((a, b) => a.date.compareTo(b.date));
      
      return upcomingEvents.take(10).toList();
    }).handleError((error) {
      print('Erreur dans getUpcomingEventsStream: $error');
      return <Event>[];
    });
  }

  // Récupérer les événements par catégorie - SIMPLIFIÉ
  static Stream<List<Event>> getEventsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs.map((doc) {
        return Event.fromMap(doc.data(), doc.id);
      }).toList();
      
      // Filtrer par catégorie et trier côté client
      final filteredEvents = events
          .where((event) => event.category == category)
          .toList();
      
      filteredEvents.sort((a, b) => a.date.compareTo(b.date));
      return filteredEvents;
    }).handleError((error) {
      print('Erreur dans getEventsByCategory: $error');
      return <Event>[];
    });
  }

  // Récupérer un événement par ID
  static Future<Event?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(eventId).get();
      if (doc.exists) {
        return Event.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'événement: $e');
    }
  }

  // Mettre à jour un événement
  static Future<void> updateEvent(String eventId, Event event) async {
    try {
      await _firestore.collection(_collection).doc(eventId).update(
        event.copyWith(updatedAt: DateTime.now()).toMap(),
      );
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'événement: $e');
    }
  }

  // Supprimer un événement (soft delete)
  static Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'événement: $e');
    }
  }

  // Supprimer définitivement un événement
  static Future<void> permanentDeleteEvent(String eventId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression définitive: $e');
    }
  }

  // Rechercher des événements - AVEC GESTION D'ERREUR
  static Future<List<Event>> searchEvents(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final events = snapshot.docs.map((doc) {
        return Event.fromMap(doc.data(), doc.id);
      }).toList();

      // Filtrer localement par titre, description et tags
      final results = events.where((event) {
        return event.title.toLowerCase().contains(query.toLowerCase()) ||
            event.description.toLowerCase().contains(query.toLowerCase()) ||
            event.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
      }).toList();

      // Trier par date
      results.sort((a, b) => a.date.compareTo(b.date));
      return results;
    } catch (e) {
      print('Erreur lors de la recherche: $e');
      return [];
    }
  }

  // Récupérer les événements par organisateur - SIMPLIFIÉ
  static Stream<List<Event>> getEventsByOrganizer(String organizerId) {
    return _firestore
        .collection(_collection)
        .where('organizerId', isEqualTo: organizerId)
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs.map((doc) {
        return Event.fromMap(doc.data(), doc.id);
      }).toList();
      
      // Trier côté client
      events.sort((a, b) => b.date.compareTo(a.date));
      return events;
    }).handleError((error) {
      print('Erreur dans getEventsByOrganizer: $error');
      return <Event>[];
    });
  }

  // Récupérer les catégories disponibles - AVEC GESTION D'ERREUR
  static Future<List<String>> getAvailableCategories() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final categories = <String>{};
      for (final doc in snapshot.docs) {
        final category = doc.data()['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }
      return categories.toList()..sort();
    } catch (e) {
      print('Erreur lors de la récupération des catégories: $e');
      return [];
    }
  }
}