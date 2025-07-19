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
            .snapshots(),
        builder: (context, favSnapshot) {
          // Debug logging
          print('🔍 Connection state: ${favSnapshot.connectionState}');
          print('🔍 Has data: ${favSnapshot.hasData}');
          print('🔍 User ID: ${user.uid}');
          
          if (favSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (favSnapshot.hasError) {
            print('❌ Error: ${favSnapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text('Erreur: ${favSnapshot.error}'),
                ],
              ),
            );
          }
          
          if (!favSnapshot.hasData) {
            print('❌ No data received');
            return const Center(child: Text("Aucune donnée reçue"));
          }
          
          final favDocs = favSnapshot.data!.docs;
          print('🔍 Documents count: ${favDocs.length}');
          
          // Log each document for debugging
          for (var doc in favDocs) {
            print('🔍 Doc ID: ${doc.id}');
            print('🔍 Doc data: ${doc.data()}');
          }
          
          if (favDocs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Vous n'avez aucun produit en favori."),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: favDocs.length,
            itemBuilder: (context, index) {
              final favData = favDocs[index].data() as Map<String, dynamic>;
              print('🔍 Building item $index with data: $favData');

              final product = Product(
                id: favData['productId'] ?? '',
                name: favData['productName'] ?? 'Sans nom',
                description: '', // Non disponible ici
                price: (favData['productPrice'] ?? 0).toDouble(),
                category: '', // Pas stocké dans Firestore
                origin: '',
                image: favData['productImageUrl'],
              );

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: product.image != null && product.image!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.image!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image_not_supported);
                            },
                          ),
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(product.name),
                  subtitle: Text('${product.price} TND'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Retirer des favoris',
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('favorites')
                            .doc(favDocs[index].id)
                            .delete();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} a été retiré des favoris'),
                          ),
                        );
                      } catch (e) {
                        print('❌ Error deleting favorite: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur lors de la suppression'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}