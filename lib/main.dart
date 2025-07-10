import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👈 Ajout
import 'package:provider/provider.dart';
import 'providers/market_provider.dart';

import 'providers/product_provider.dart';
import 'screens/product_form_screen.dart';
import 'screens/product_list.dart';
import 'screens/edit_product_screen.dart';
import 'screens/home.dart';
import 'screens/market_map_screen.dart';
import 'screens/market_form_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase
  await Firebase.initializeApp();
  
  // Supabase
  await Supabase.initialize(
    url: 'https://xyzpsegsttcxpxgxbduk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5enBzZWdzdHRjeHB4Z3hiZHVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4NjgyNTYsImV4cCI6MjA2NjQ0NDI1Nn0.RFy3KH6R_NovFrrqzFUx2FjOgKTefYEQ5NPebLOvDn0',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoMarché',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
    routes: {
  '/': (context) => const HomeScreen(),
  '/product-list': (context) => const ProductListScreen(),
  '/product-form': (context) => const ProductFormScreen(),
  '/market-map': (context) => MarketMapScreen(),
  '/market-form': (context) => const MarketFormScreen(), // 👈 nouvelle route
  '/edit-product': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return EditProductScreen(
      productId: args['productId'],
      productData: args['productData'],
    );
  },
},

      initialRoute: '/',
    );
  }
}