import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart' as local_auth;
import '../widgets/role_based_widget.dart';
import 'add_event_screen.dart';
import '../widgets/event_card.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Event> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider.initializeEvents();
      eventProvider.loadCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final results = await eventProvider.searchEvents(query);
    
    setState(() {
      _searchResults = results;
    });
  }

  void _showDeleteDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer l\'événement "${event.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final eventProvider = Provider.of<EventProvider>(context, listen: false);
              final success = await eventProvider.deleteEvent(event.id);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Événement supprimé avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(eventProvider.error ?? 'Erreur lors de la suppression'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _editEvent(Event event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEventScreen(event: event),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: eventProvider.categories.length,
            itemBuilder: (context, index) {
              final category = eventProvider.categories[index];
              final isSelected = category == eventProvider.selectedCategory;
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    eventProvider.setSelectedCategory(category);
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.green.withOpacity(0.3),
                  checkmarkColor: Colors.green,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.green[800] : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEventsList(List<Event> events) {
    if (events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun événement trouvé',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Consumer<local_auth.AuthProvider>(
      builder: (context, authProvider, child) {
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final currentUser = FirebaseAuth.instance.currentUser;
            
            // Logique pour déterminer si l'utilisateur peut éditer/supprimer
            bool canEdit = false;
            bool canDelete = false;
            
            if (authProvider.isAdmin) {
              // Les admins peuvent tout gérer
              canEdit = true;
              canDelete = true;
            } else if (authProvider.isUser && currentUser?.uid == event.organizerId) {
              // Les users peuvent seulement gérer leurs propres événements
              canEdit = true;
              canDelete = true;
            }
            // Sinon, aucune action de modification n'est permise

            return EventCard(
              event: event,
              onEdit: canEdit ? () => _editEvent(event) : null,
              onDelete: canDelete ? () => _showDeleteDialog(event) : null,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Événements'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Tous les événements'),
            Tab(text: 'À venir'),
          ],
        ),
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${eventProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      eventProvider.clearError();
                      eventProvider.refresh();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Barre de recherche
              Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Rechercher des événements...',
                    prefixIcon: const Icon(Icons.search, color: Colors.green),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                    fillColor: Colors.grey[50],
                    filled: true,
                  ),
                ),
              ),

              // Filtres par catégorie (seulement si on ne recherche pas)
              if (!_isSearching) _buildCategoryFilter(),

              // Liste des événements
              Expanded(
                child: _isSearching
                    ? _buildEventsList(_searchResults)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          // Tous les événements
                          RefreshIndicator(
                            onRefresh: eventProvider.refresh,
                            child: _buildEventsList(eventProvider.filteredEvents),
                          ),
                          // Événements à venir
                          RefreshIndicator(
                            onRefresh: eventProvider.refresh,
                            child: _buildEventsList(eventProvider.upcomingEvents),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
      // FloatingActionButton seulement pour les admins
      floatingActionButton: AdminOnly(
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddEventScreen(),
              ),
            );
          },
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Nouvel événement'),
        ),
      ),
    );
  }
}