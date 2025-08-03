import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  List<Event> _events = [];
  List<Event> _upcomingEvents = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'Tous';

  // Getters
  List<Event> get events => _events;
  List<Event> get upcomingEvents => _upcomingEvents;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  // Filtrer les événements par catégorie
  List<Event> get filteredEvents {
    if (_selectedCategory == 'Tous') {
      return _events;
    }
    return _events.where((event) => event.category == _selectedCategory).toList();
  }

  // Setters
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Initialiser les événements
  void initializeEvents() {
    EventService.getAllEventsStream().listen(
      (events) {
        _events = events;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );

    EventService.getUpcomingEventsStream().listen(
      (events) {
        _upcomingEvents = events;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Charger les catégories
  Future<void> loadCategories() async {
    try {
      _categories = await EventService.getAvailableCategories();
      _categories.insert(0, 'Tous'); // Ajouter l'option "Tous"
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Créer un événement
  Future<bool> createEvent(Event event) async {
    try {
      setLoading(true);
      setError(null);
      
      final eventId = await EventService.createEvent(event);
      
      // Recharger les catégories si une nouvelle catégorie est ajoutée
      if (!_categories.contains(event.category)) {
        await loadCategories();
      }
      
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  // Mettre à jour un événement
  Future<bool> updateEvent(String eventId, Event event) async {
    try {
      setLoading(true);
      setError(null);
      
      await EventService.updateEvent(eventId, event);
      
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  // Supprimer un événement
  Future<bool> deleteEvent(String eventId) async {
    try {
      setLoading(true);
      setError(null);
      
      await EventService.deleteEvent(eventId);
      
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  // Rechercher des événements
  Future<List<Event>> searchEvents(String query) async {
    try {
      setLoading(true);
      setError(null);
      
      final results = await EventService.searchEvents(query);
      
      setLoading(false);
      return results;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return [];
    }
  }

  // Récupérer un événement par ID
  Future<Event?> getEventById(String eventId) async {
    try {
      return await EventService.getEventById(eventId);
    } catch (e) {
      setError(e.toString());
      return null;
    }
  }

  // Nettoyer les erreurs
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Rafraîchir les données
  Future<void> refresh() async {
    await loadCategories();
    // Les streams se mettront à jour automatiquement
  }
}