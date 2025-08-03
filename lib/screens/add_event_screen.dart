import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';

class AddEventScreen extends StatefulWidget {
  final Event? event; // Pour l'édition

  const AddEventScreen({Key? key, this.event}) : super(key: key);

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _tagsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = 'Marché bio';
  
  final List<String> _eventCategories = [
    'Marché bio',
    'Dégustation',
    'Atelier cuisine',
    'Conférence',
    'Festival',
    'Vente directe',
    'Autre'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final event = widget.event!;
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _locationController.text = event.location;
    _imageUrlController.text = event.imageUrl;
    _tagsController.text = event.tags.join(', ');
    _selectedDate = event.date;
    _selectedTime = TimeOfDay.fromDateTime(event.date);
    _selectedCategory = event.category;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté')),
      );
      return;
    }

    final eventDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final event = Event(
      id: widget.event?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: eventDate,
      time: _selectedTime.format(context),
      location: _locationController.text.trim(),
      category: _selectedCategory,
      imageUrl: _imageUrlController.text.trim(),
      organizerId: user.uid,
      organizerName: user.displayName ?? user.email ?? 'Utilisateur',
      createdAt: widget.event?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      tags: tags,
    );

    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    bool success;

    if (widget.event != null) {
      success = await eventProvider.updateEvent(widget.event!.id, event);
    } else {
      success = await eventProvider.createEvent(event);
    }

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.event != null 
            ? 'Événement modifié avec succès' 
            : 'Événement créé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(eventProvider.error ?? 'Une erreur est survenue'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event != null ? 'Modifier l\'événement' : 'Nouvel événement'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Titre
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Titre de l\'événement *',
                          prefixIcon: Icon(Icons.event, color: Colors.green),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => 
                          value?.isEmpty == true ? 'Le titre est requis' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          prefixIcon: Icon(Icons.description, color: Colors.green),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => 
                          value?.isEmpty == true ? 'La description est requise' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date et Heure
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 2,
                          child: InkWell(
                            onTap: _selectDate,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Colors.green),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Date', style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                      Text(
                                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          elevation: 2,
                          child: InkWell(
                            onTap: _selectTime,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, color: Colors.green),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Heure', style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                      Text(
                                        _selectedTime.format(context),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Localisation
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Localisation *',
                          prefixIcon: Icon(Icons.location_on, color: Colors.green),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => 
                          value?.isEmpty == true ? 'La localisation est requise' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Catégorie
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Catégorie',
                          prefixIcon: Icon(Icons.category, color: Colors.green),
                          border: OutlineInputBorder(),
                        ),
                        items: _eventCategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                  ),
                //   const SizedBox(height: 16),

                //   // URL de l'image
                //   Card(
                //     elevation: 2,
                //     child: Padding(
                //       padding: const EdgeInsets.all(16),
                //       child: TextFormField(
                //         controller: _imageUrlController,
                //         decoration: const InputDecoration(
                //           labelText: 'URL de l\'image (optionnel)',
                //           prefixIcon: Icon(Icons.image, color: Colors.green),
                //           border: OutlineInputBorder(),
                //         ),
                //       ),
                //     ),
                //   ),
                  const SizedBox(height: 16),

                  // Tags
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags (séparés par des virgules)',
                          prefixIcon: Icon(Icons.tag, color: Colors.green),
                          border: OutlineInputBorder(),
                          hintText: 'bio, local, marché...',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bouton de sauvegarde
                  ElevatedButton(
                    onPressed: eventProvider.isLoading ? null : _saveEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: eventProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.event != null ? 'Modifier l\'événement' : 'Créer l\'événement',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}