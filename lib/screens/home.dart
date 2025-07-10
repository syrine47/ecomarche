import 'package:flutter/material.dart';
import '../widgets/eco_marche_drawer.dart'; // 🔹 appel du drawer externe

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _toggleDrawer() {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      Navigator.of(context).pop();
    } else {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('EcoMarché'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _toggleDrawer,
        ),
      ),
      drawer: const EcoMarcheDrawer(), // 🔹 appel du Drawer ici
      body: const Center(
        child: Text(
          'Bienvenue dans EcoMarché !',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
