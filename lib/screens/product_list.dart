import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_product_screen.dart';
import '../widgets/eco_marche_drawer.dart';





class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  // Fonction pour supprimer un produit
  Future<void> _deleteProduct(String productId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produit supprimé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fonction pour confirmer la suppression
  Future<void> _confirmDelete(String productId, String productName, BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer "$productName" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(productId, context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des produits"),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      
      // 🔴 Bouton flottant pour ajouter un produit
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Redirection vers l'écran d'ajout de produit
          Navigator.pushNamed(context, '/product-form');
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: Colors.green.shade600,
      ),
       drawer: const EcoMarcheDrawer(),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Aucun produit trouvé",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Commencez par ajouter vos premiers produits bio !",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productDoc = products[index];
              final product = productDoc.data() as Map<String, dynamic>;
              final productId = productDoc.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Row(
                  children: [
                    // 🖼️ Image du produit (à gauche)
                    product['image'] != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12)),
                            child: Image.network(
                              product['image'],
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 120,
                                  width: 120,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12)),
                                  ),
                                  child: const Icon(Icons.broken_image, size: 40, color: Colors.white),
                                );
                              },
                            ),
                          )
                        : Container(
                            height: 120,
                            width: 120,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12)),
                            ),
                            child: const Icon(Icons.image_not_supported, size: 40, color: Colors.white),
                          ),

                    // 📋 Infos du produit (au centre)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] ?? 'Nom non défini',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product['description'] ?? 'Aucune description',
                              style: const TextStyle(color: Colors.grey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.attach_money, size: 16, color: Colors.green.shade600),
                                Text(
                                  "${product['price'] ?? '0'} DT",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.category, size: 16, color: Colors.blue.shade600),
                                const SizedBox(width: 4),
                                Text(product['category'] ?? 'Non catégorisé'),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.orange.shade600),
                                const SizedBox(width: 4),
                                Text(product['origin'] ?? 'Origine inconnue'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 🔧 Boutons d'action (à droite)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bouton Modifier
                          IconButton(
                            onPressed: () {
                              // Redirection vers l'écran de modification avec les données du produit
                           Navigator.pushNamed(
  context, 
  '/edit-product', // ✅ redirige vers l'écran de modification
  arguments: {
    'productId': productId,
    'productData': product,
  },
);

                            },
                            icon: const Icon(Icons.edit),
                            color: Colors.blue.shade600,
                            tooltip: 'Modifier',
                          ),
                          
                          // Bouton Supprimer
                          IconButton(
                            onPressed: () {
                              _confirmDelete(productId, product['name'] ?? 'ce produit', context);
                            },
                            icon: const Icon(Icons.delete),
                            color: Colors.red.shade600,
                            tooltip: 'Supprimer',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}