import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/eco_marche_drawer.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController originController = TextEditingController();

  String? selectedCategory;
  final List<String> categories = [
    'Fruits',
    'Légumes',
    'Produits laitiers',
    'Épicerie',
    'Autre'
  ];

  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submitForm() async {
    final String name = nameController.text.trim();
    final String description = descriptionController.text.trim();
    final String priceText = priceController.text.trim();
    final String origin = originController.text.trim();
    final String? category = selectedCategory;

    if (name.isEmpty || description.isEmpty || priceText.isEmpty || category == null || origin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Veuillez remplir tous les champs'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.image, color: Colors.white),
              SizedBox(width: 8),
              Text('Veuillez sélectionner une image'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final double? price = double.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Le prix doit être un nombre valide'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final newProduct = Product(
      name: name,
      description: description,
      price: price,
      category: category,
      origin: origin,
    );

    final File? imageToUpload = _imageFile;

    try {
      await Provider.of<ProductProvider>(context, listen: false)
          .addProduct(newProduct, imageToUpload);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Produit ajouté avec succès'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Réinitialisation
      nameController.clear();
      descriptionController.clear();
      priceController.clear();
      originController.clear();
      setState(() {
        selectedCategory = null;
        _imageFile = null;
        _isLoading = false;
      });

      Navigator.pushReplacementNamed(context, '/product-list');
    } catch (error) {
      print("❌ Erreur lors de l'ajout du produit : $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Erreur lors de l\'ajout : $error'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Ajouter un produit",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const EcoMarcheDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec icône
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade600],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_shopping_cart,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Nouveau produit bio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Ajoutez vos produits biologiques',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Formulaire
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Image
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Photo du produit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 12),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 180,
                            width: 180,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _imageFile == null ? Colors.grey.shade300 : Colors.green.shade400,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: _imageFile == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Ajouter une photo',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Stack(
                                      children: [
                                        Image.file(
                                          _imageFile!,
                                          height: 176,
                                          width: 176,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade600,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.check,
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
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Nom du produit
                  _buildTextField(
                    controller: nameController,
                    label: 'Nom du produit',
                    hint: 'Ex: Tomates cerises bio',
                    icon: Icons.eco,
                    color: Colors.green.shade600,
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Description
                  _buildTextField(
                    controller: descriptionController,
                    label: 'Description',
                    hint: 'Décrivez votre produit...',
                    icon: Icons.description,
                    color: Colors.blue.shade600,
                    maxLines: 3,
                  ),
                  
                  SizedBox(height: 20),
                  
                // Prix sur une ligne
_buildTextField(
  controller: priceController,
  label: 'Prix (DT)',
  hint: '0.00',
  icon: Icons.euro,
  color: Colors.orange.shade600,
  keyboardType: TextInputType.number,
),

SizedBox(height: 20),

// Catégorie sur une autre ligne
_buildDropdownField(),

                  
                  SizedBox(height: 20),
                  
                  // Origine
                  _buildTextField(
                    controller: originController,
                    label: 'Origine',
                    hint: 'Ex: Béja, Nabeul...',
                    icon: Icons.location_on,
                    color: Colors.red.shade600,
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Bouton Ajouter
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Ajout en cours...',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Ajouter le produit',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Sélectionner',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.category, color: Colors.purple.shade600, size: 20),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.purple.shade600, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            value: selectedCategory,
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
          ),
        ),
      ],
    );
  }
}