import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final CollectionReference _productsCollection = FirebaseFirestore.instance
      .collection('products'); // nom de ta collection Firestore
  final CollectionReference _favoritesCollection = FirebaseFirestore.instance
      .collection('favorites');

  // Ajouter un produit
  Future<void> addProduct(Product product) async {
    await _productsCollection.add(product.toMap());
  }

  // Récupérer tous les produits en stream (pour afficher la liste en temps réel)
  Stream<List<Product>> getProducts() {
    return _productsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Mettre à jour un produit par id
  Future<void> updateProduct(Product product) async {
    if (product.id == null) throw Exception("Product id is null");
    await _productsCollection.doc(product.id).update(product.toMap());
  }

  // Supprimer un produit par id
  Future<void> deleteProduct(String productId) async {
    await _productsCollection.doc(productId).delete();
  }

  Stream<List<Product>> getFavoritesByUser(String userId) {
    return _favoritesCollection.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Ici on suppose que le doc favori contient un champ 'productData' avec toutes les infos
        final productMap = data['productData'] as Map<String, dynamic>;

        // L'id du produit est dans productMap['id']
        return Product.fromMap(productMap, productMap['id']);
      }).toList();
    });
  }
}
