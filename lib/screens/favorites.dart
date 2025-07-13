import 'package:ecomarche/models/product.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Veuillez vous connecter pour voir vos favoris."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Favoris"),
        backgroundColor: Colors.green.shade600,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, favSnapshot) {
          if (favSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!favSnapshot.hasData || favSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Vous n'avez aucun produit en favori."),
            );
          }

          final favDocs = favSnapshot.data!.docs;

          return ListView.builder(
            itemCount: favDocs.length,
            itemBuilder: (context, index) {
              final favData = favDocs[index].data() as Map<String, dynamic>;
              final productId = favData['productId'] as String;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('products')
                    .doc(productId)
                    .get(),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('Chargement...'));
                  }
                  if (!productSnapshot.hasData || !productSnapshot.data!.exists) {
                    return const ListTile(title: Text('Produit non trouvé'));
                  }

                  final productData =
                      productSnapshot.data!.data() as Map<String, dynamic>;

                  final product = Product(
                    id: productId,
                    name: productData['name'] ?? 'Sans nom',
                    description: productData['description'] ?? '',
                    price: productData['price'] ?? 0,
                    category: productData['category'] ?? '',
                    origin: productData['origin'] ?? '',
                    image: productData['image'],
                  );

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: product.image != null
                          ? Image.network(
                              product.image!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported),
                      title: Text(product.name),
                      subtitle: Text('${product.category} - ${product.price} TND'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Retirer des favoris',
                        onPressed: () async {
                          // Supprimer le favori dans Firestore
                          await FirebaseFirestore.instance
                              .collection('favorites')
                              .doc(favDocs[index].id)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} a été retiré des favoris'),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
