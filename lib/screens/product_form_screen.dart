import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/eco_marche_drawer.dart'; // 🔹 appel du drawer externe

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

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submitForm() {
  final String name = nameController.text.trim();
  final String description = descriptionController.text.trim();
  final String priceText = priceController.text.trim();
  final String origin = originController.text.trim();
  final String? category = selectedCategory;

  if (name.isEmpty || description.isEmpty || priceText.isEmpty || category == null || origin.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❌ Veuillez remplir tous les champs')),
    );
    return;
  }

  if (_imageFile == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❌ Veuillez sélectionner une image')),
    );
    return;
  }

  final double? price = double.tryParse(priceText);
  if (price == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❌ Le prix doit être un nombre valide')),
    );
    return;
  }

  final newProduct = Product(
    name: name,
    description: description,
    price: price,
    category: category,
    origin: origin,
  );

  final File? imageToUpload = _imageFile;

  Provider.of<ProductProvider>(context, listen: false)
      .addProduct(newProduct, imageToUpload)
      .then((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Produit ajouté avec succès')),
    );

    // Réinitialisation
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    originController.clear();
    setState(() {
      selectedCategory = null;
      _imageFile = null;
    });

    Navigator.pushReplacementNamed(context, '/product-list');
  }).catchError((error) {
    print("❌ Erreur lors de l'ajout du produit : $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ Erreur lors de l\'ajout : $error')),
    );
  });
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Ajouter un produit"),
      centerTitle: true,
      backgroundColor: Colors.green.shade700,
    ),
     drawer: const EcoMarcheDrawer(),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Nom du produit',
              prefixIcon: const Icon(Icons.shopping_bag),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Prix
          TextField(
            controller: priceController,
            decoration: InputDecoration(
              labelText: 'Prix (TND)',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Catégorie
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Catégorie',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
          const SizedBox(height: 16),

          // Origine
          TextField(
            controller: originController,
            decoration: InputDecoration(
              labelText: 'Origine (ex: Béja, Nabeul...)',
              prefixIcon: const Icon(Icons.place),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),

          // Image Picker
          Center(
            child: GestureDetector(
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
          ),
          const SizedBox(height: 24),

          // Bouton Ajouter
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.green.shade700,
              ),
              icon: const Icon(Icons.check_circle),
              label: const Text(
                "Ajouter le produit",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
