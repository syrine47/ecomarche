import 'package:ecomarche/models/product.dart';
import 'package:ecomarche/providers/auth_provider.dart' as AppAuth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
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
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Produit supprimé avec succès'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Erreur lors de la suppression: $e'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade600),
              SizedBox(width: 12),
              Text('Confirmer la suppression'),
            ],
          ),
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Êtes-vous sûr de vouloir supprimer "$productName" ?\n\nCette action est irréversible.',
              style: TextStyle(fontSize: 16),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(productId, context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  //fonction pour mettre favoris
  Future<void> addToFavorites(Product product, String userId, BuildContext context) async {
    try {
      final favoritesRef = FirebaseFirestore.instance.collection('favorites');

      // Check if already favorited to avoid duplicates
      final existing = await favoritesRef
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: product.id)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 8),
                Text('${product.name} est déjà dans vos favoris.'),
              ],
            ),
            backgroundColor: Colors.blue.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      await favoritesRef.add({
        'userId': userId,
        'productId': product.id,
        'productName': product.name,
        'productPrice': product.price,
        'productImageUrl': product.image,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.favorite, color: Colors.white),
              SizedBox(width: 8),
              Text('${product.name} a été ajouté aux favoris.'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      print('❌ Erreur ajout aux favoris: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Erreur lors de l\'ajout aux favoris.'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuth.AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text(
              "Produits Bio",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
            ),
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  // Fonctionnalité de recherche à implémenter
                },
              ),
              SizedBox(width: 8),
            ],
          ),
          
          // 👈 BOUTON FLOTTANT - ADMIN SEULEMENT
          floatingActionButton: (authProvider.user?.role == 'admin') 
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.pushNamed(context, '/product-form');
                  },
                  icon: const Icon(Icons.add, size: 24),
                  label: const Text('Ajouter un produit', style: TextStyle(fontWeight: FontWeight.w600)),
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                )
              : null, // 👈 Pas de bouton si user normal
          
          drawer: const EcoMarcheDrawer(),
          
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Chargement des produits...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.eco,
                          size: 60,
                          color: Colors.green.shade400,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        "Aucun produit trouvé",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Commencez par ajouter vos premiers produits bio !",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),
                      // 👈 BOUTON D'AJOUT - ADMIN SEULEMENT
                      if (authProvider.user?.role == 'admin')
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/product-form');
                          },
                          icon: Icon(Icons.add),
                          label: Text('Ajouter un produit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                    ],
                  ),
                );
              }

              final products = snapshot.data!.docs;

              return Column(
                children: [
                  // En-tête avec statistiques
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade600, Colors.green.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade200,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${products.length}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Produits disponibles',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Liste des produits
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final productDoc = products[index];
                        final product = productDoc.data() as Map<String, dynamic>;
                        final productId = productDoc.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Row(
                              children: [
                                // Image du produit
                                Container(
                                  width: 120,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                  ),
                                  child: product['image'] != null
                                      ? Image.network(
                                          product['image'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey.shade200,
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Colors.grey.shade400,
                                              ),
                                            );
                                          },
                                        )
                                      : Icon(
                                          Icons.eco,
                                          size: 40,
                                          color: Colors.green.shade400,
                                        ),
                                ),

                                // Informations du produit
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name'] ?? 'Nom non défini',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          product['description'] ?? 'Aucune description',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 12),
                                        
                                        // Prix
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.green.shade200),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.euro,
                                                size: 16,
                                                color: Colors.green.shade700,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                "${product['price'] ?? '0'} DT",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade700,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        SizedBox(height: 8),
                                        
                                        // Catégorie et origine
                                        Wrap(
                                          spacing: 8,
                                          children: [
                                            _buildInfoChip(
                                              icon: Icons.category,
                                              label: product['category'] ?? 'Non catégorisé',
                                              color: Colors.blue.shade600,
                                            ),
                                            _buildInfoChip(
                                              icon: Icons.location_on,
                                              label: product['origin'] ?? 'Origine inconnue',
                                              color: Colors.orange.shade600,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // 👈 BOUTONS D'ACTION - CONDITIONNELS SELON LE RÔLE
                                Container(
                                  width: 60,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    border: Border(
                                      left: BorderSide(color: Colors.grey.shade200),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // 👈 BOUTON MODIFIER - ADMIN SEULEMENT
                                      if (authProvider.user?.role == 'admin')
                                        _buildActionButton(
                                          icon: Icons.edit,
                                          color: Colors.blue.shade600,
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/edit-product',
                                              arguments: {
                                                'productId': productId,
                                                'productData': product,
                                              },
                                            );
                                          },
                                        ),
                                      
                                      // 👈 BOUTON SUPPRIMER - ADMIN SEULEMENT
                                      if (authProvider.user?.role == 'admin')
                                        _buildActionButton(
                                          icon: Icons.delete,
                                          color: Colors.red.shade600,
                                          onPressed: () {
                                            _confirmDelete(productId, product['name'] ?? 'ce produit', context);
                                          },
                                        ),

                                      // 👤 BOUTON FAVORIS - VISIBLE POUR TOUS
                                      _buildActionButton(
                                        icon: Icons.favorite_border,
                                        color: Colors.pink.shade600,
                                        onPressed: () async {
                                          final user = FirebaseAuth.instance.currentUser;
                                          if (user != null) {
                                            await addToFavorites(
                                              Product(
                                                id: productId,
                                                name: product['name'],
                                                description: product['description'],
                                                price: product['price'],
                                                category: product['category'],
                                                origin: product['origin'],
                                                image: product['image'],
                                              ),
                                              user.uid,
                                              context,
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    Icon(Icons.person, color: Colors.white),
                                                    SizedBox(width: 8),
                                                    Text("Veuillez vous connecter pour ajouter aux favoris."),
                                                  ],
                                                ),
                                                backgroundColor: Colors.orange.shade600,
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 20),
        padding: EdgeInsets.zero,
      ),
    );
  }
}