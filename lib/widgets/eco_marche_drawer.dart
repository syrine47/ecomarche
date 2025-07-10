import 'package:flutter/material.dart';

class EcoMarcheDrawer extends StatelessWidget {
  const EcoMarcheDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Text(
              'Menu EcoMarché',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Carte des marchés'),
            onTap: () {
              Navigator.pushNamed(context, '/market-map');
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Marchés locaux'),
            onTap: () {
              Navigator.pushNamed(context, '/market-form'); // 👈 nouvelle route
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_basket),
            title: const Text('Produits bio'),
            onTap: () {
              Navigator.pushNamed(context, '/product-list');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favoris'),
            onTap: () {
              // Navigator.pushNamed(context, '/favorites');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              // Navigator.pushNamed(context, '/notifications');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              // Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () {
              // Déconnexion Firebase ici
            },
          ),
        ],
      ),
    );
  }
}
