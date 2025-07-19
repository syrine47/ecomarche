import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/product.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Product> _products = [];
  List<Product> get products => _products;

Future<void> addProduct(Product product, File? imageFile) async {
  try {
    _isLoading = true;
    notifyListeners();

    print("🔄 Début ajout produit...");

    String? imageUrl;

    // 1. Upload de l'image avec SupabaseService si elle existe
    if (imageFile != null) {
      print("📷 Image détectée, en cours d'upload vers Supabase...");
      imageUrl = await SupabaseService.uploadImage(imageFile);

      if (imageUrl != null) {
        print("✅ Image uploadée avec succès : $imageUrl");
      } else {
        print("❌ Échec de l'upload de l'image");
      }
    }

    // 2. Créer le produit avec l'URL de l'image
    final productWithImage = product.copyWith(image: imageUrl);

    // 3. Sauvegarder dans Firestore
    DocumentReference productRef = await _firestore.collection('products').add(productWithImage.toMap());

    print("✅ Produit ajouté avec succès !");

    // 4. NOTIFICATION: Notification locale pour l'utilisateur qui a ajouté
    await NotificationService.showLocalNotification(
      id: 1,
      title: 'Produit ajouté',
      body: 'Votre produit "${product.name}" a été ajouté avec succès',
      payload: 'product_added_${productRef.id}', // ✅ Payload personnalisé avec l'ID du produit
    );

    // 5. Cloud Function (déclenchée automatiquement)
    print("🔔 Cloud Function déclenchée pour notifier les autres utilisateurs");

    // 6. Recharger la liste des produits
    await fetchProducts();

  } catch (e) {
    print("❌ Erreur lors de l'ajout : $e");

    // Notification d'erreur
    await NotificationService.showLocalNotification(
      id: 2,
      title: 'Erreur',
      body: 'Impossible d\'ajouter le produit "${product.name}". Veuillez réessayer.',
      payload: 'error_add_product', // ✅ Payload pour identifier les erreurs
    );

    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      _products = snapshot.docs
          .map(
            (doc) =>
                Product.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
      print(
        "✅ Produits chargés avec succès : ${_products.length} produits trouvés",
      );
      notifyListeners();
    } catch (e) {
      print("❌ Erreur lors du chargement des produits : $e");
    }
  }

  Future<void> updateProduct(
    String productId,
    Product updatedProduct,
    File? newImageFile,
  ) async {
    try {
      print("🔄 Début mise à jour du produit...");
      String? imageUrl = updatedProduct.image;

      // Si une nouvelle image a été sélectionnée, on la remplace
      if (newImageFile != null) {
        final ref = _storage
            .ref()
            .child('product_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(newImageFile);
        imageUrl = await ref.getDownloadURL();
        print("✅ Nouvelle image uploadée : $imageUrl");
      }

      final productData = updatedProduct.copyWith(image: imageUrl).toMap();
      print("📝 Nouvelles données produit : $productData");

      await _firestore
          .collection('products')
          .doc(productId)
          .update(productData);
      print("✅ Produit mis à jour dans Firestore !");

      await fetchProducts(); // 🔄 Rafraîchir la liste locale
      notifyListeners();
    } catch (e) {
      print("❌ Erreur lors de la mise à jour : $e");
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      print("🔄 Suppression du produit en cours...");
      await _firestore.collection('products').doc(productId).delete();
      print("✅ Produit supprimé de Firestore !");

      // Rafraîchir la liste des produits localement
      _products.removeWhere((product) => product.id == productId);
      notifyListeners();
    } catch (e) {
      print("❌ Erreur lors de la suppression : $e");
      rethrow;
    }
  }
}
