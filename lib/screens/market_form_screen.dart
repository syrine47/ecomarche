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

class _MarketFormScreenState extends State<MarketFormScreen> with TickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController hoursController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double? latitude;
  double? longitude;
  String? cityName;
  File? _imageFile;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

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
    if (!_formKey.currentState!.validate()) return;

    final marketProvider = Provider.of<MarketProvider>(context, listen: false);

    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final hours = hoursController.text.trim();

    if (latitude == null || longitude == null) {
      _showSnackBar("📍 Veuillez sélectionner une position sur la carte", isError: true);
      return;
    }

    if (_imageFile == null) {
      _showSnackBar("📷 Veuillez sélectionner une image", isError: true);
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
      _showSnackBar("✅ Marché ajouté avec succès", isError: false);
      Navigator.pushReplacementNamed(context, '/market-list');
    }).catchError((error) {
      _showSnackBar("❌ Erreur : $error", isError: true);
    });
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    hoursController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<MarketProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Nouveau marché bio",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: const EcoMarcheDrawer(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec icône
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade100, Colors.green.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Partagez votre marché bio",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Ajoutez un nouveau marché local et bio pour votre communauté",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Nom du marché
                _buildSectionTitle("Informations générales"),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: nameController,
                  label: "Nom du marché",
                  icon: Icons.storefront,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Le nom du marché est obligatoire";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Description
                _buildTextField(
                  controller: descriptionController,
                  label: "Description",
                  icon: Icons.description,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "La description est obligatoire";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Horaires
                _buildTextField(
                  controller: hoursController,
                  label: "Horaires d'ouverture",
                  icon: Icons.schedule,
                  hintText: "Ex: Lundi à samedi de 8h à 14h",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Les horaires sont obligatoires";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Localisation
                _buildSectionTitle("Localisation"),
                const SizedBox(height: 16),
                _buildLocationSelector(),

                const SizedBox(height: 32),

                // Image
                _buildSectionTitle("Photo du marché"),
                const SizedBox(height: 16),
                _buildImageSelector(),

                const SizedBox(height: 40),

                // Bouton de soumission
                _buildSubmitButton(isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.green.shade600,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green.shade600, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          labelStyle: TextStyle(color: Colors.grey.shade700),
        ),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _openMapPicker,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: latitude != null && longitude != null
                        ? Colors.green.shade100
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: latitude != null && longitude != null
                        ? Colors.green.shade600
                        : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latitude != null && longitude != null
                            ? cityName ?? "Ville inconnue"
                            : "Sélectionner une position",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      if (latitude != null && longitude != null)
                        Text(
                          "Lat: ${latitude!.toStringAsFixed(4)}, Lng: ${longitude!.toStringAsFixed(4)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: _imageFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.green.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Ajouter une photo",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Touchez pour sélectionner une image",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          height: 168,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : _submitForm,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 16),
                ] else ...[
                  const Icon(
                    Icons.add_location,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  isLoading ? "Ajout en cours..." : "Ajouter le marché",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}