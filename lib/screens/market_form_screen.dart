import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

import '../models/market.dart';
import '../providers/market_provider.dart';
import '../widgets/eco_marche_drawer.dart';

class MarketFormScreen extends StatefulWidget {
  const MarketFormScreen({super.key});

  @override
  State<MarketFormScreen> createState() => _MarketFormScreenState();
}

class _MarketFormScreenState extends State<MarketFormScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController hoursController = TextEditingController();

  double? latitude;
  double? longitude;
  String? cityName; // variable pour stocker le nom de la ville
  File? _imageFile;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  // Ouvre la page Map Picker et récupère la position et le nom de la ville
  Future<void> _openMapPicker() async {
    final result = await Navigator.pushNamed(context, '/map-picker') as Map<String, dynamic>?;

    if (result != null && result['latlng'] != null) {
      final LatLng latlng = result['latlng'];
      setState(() {
        latitude = latlng.latitude;
        longitude = latlng.longitude;
        cityName = (result['city'] as String?) ?? "Ville inconnue";
      });
      print("MarketFormScreen: cityName récupérée = $cityName");
    }
  }
void _submitForm() {
  final marketProvider = Provider.of<MarketProvider>(context, listen: false);

  final name = nameController.text.trim();
  final description = descriptionController.text.trim();
  final hours = hoursController.text.trim();

  if (name.isEmpty || description.isEmpty || latitude == null || longitude == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ Remplissez tous les champs obligatoires")),
    );
    return;
  }

  if (_imageFile == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ Veuillez sélectionner une image")),
    );
    return;
  }

  final newMarket = Market(
    name: name,
    description: description,
    hours: hours,
    latitude: latitude!,
    longitude: longitude!,
    cityName: cityName,
  );

  marketProvider.addMarket(newMarket, _imageFile!).then((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Marché ajouté avec succès")),
    );

    Navigator.pushReplacementNamed(context, '/market-list'); // ✅ Redirection
  }).catchError((error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Erreur : $error")),
    );
  });
}


  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<MarketProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un marché"),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
      ),
      drawer: const EcoMarcheDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nom du marché',
                prefixIcon: const Icon(Icons.store),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: hoursController,
              decoration: InputDecoration(
                labelText: 'Horaires (ex : Lundi à samedi de 8h à 14h)',
                prefixIcon: const Icon(Icons.access_time),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            // Affichage ville + coordonnées
            Row(
              children: [
                Expanded(
                  child: Text(
                    latitude != null && longitude != null
                        ? '📍 ${cityName ?? "Ville inconnue"}\nLat: $latitude, Lng: $longitude'
                        : '📍 Position non définie',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: _openMapPicker,
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: _imageFile == null
                  ? Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _imageFile!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _submitForm,
                icon: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.add_location),
                label: Text(isLoading ? "Ajout en cours..." : "Ajouter le marché"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
