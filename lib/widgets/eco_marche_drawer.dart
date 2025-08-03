import 'package:ecomarche/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EcoMarcheDrawer extends StatelessWidget {
  const EcoMarcheDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.green),
                child: Text(
                  'Menu EcoMarché',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              
              // 📍 Carte des marchés - VISIBLE POUR TOUS
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Carte des marchés'),
                onTap: () {
                  Navigator.pushNamed(context, '/market-map');
                },
              ),
              
              // 🏪 Marchés locaux - ADMIN SEULEMENT
              if (authProvider.isAdmin)
                ListTile(
                  leading: const Icon(Icons.store),
                  title: const Text('Marchés locaux'),
                  onTap: () {
                    Navigator.pushNamed(context, '/market-form');
                  },
                ),
              
              // 🏬 Marchés disponibles - VISIBLE POUR TOUS
              ListTile(
                leading: const Icon(Icons.store),
                title: const Text('Marchés disponibles'),
                onTap: () {
                  Navigator.pushNamed(context, '/market-list');
                },
              ),

              // 🛒 Produits bio - VISIBLE POUR TOUS
              ListTile(
                leading: const Icon(Icons.shopping_basket),
                title: const Text('Produits bio'),
                onTap: () {
                  Navigator.pushNamed(context, '/product-list');
                },
              ),

               //test
               ListTile(
                leading: const Icon(Icons.person),
                title: const Text('events'),
                onTap: () {
                  Navigator.pushNamed(context, '/eventlist');
                },
              ),
              
              // ❤️ Favoris - VISIBLE POUR TOUS
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Favoris'),
                onTap: () {
                  Navigator.pushNamed(context, '/fav');
                },
              ),
              
              // 🔔 Notifications - VISIBLE POUR TOUS
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                onTap: () {
                  // Navigator.pushNamed(context, '/notifications');
                },
              ),

              const Divider(),
              
             
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profil'),
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),

             
              
              // 🚪 Déconnexion - VISIBLE POUR TOUS
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Déconnexion'),
                onTap: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.logout(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}