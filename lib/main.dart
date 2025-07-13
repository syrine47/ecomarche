import 'package:ecomarche/screens/favorites.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

// 🟢 Providers
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/market_provider.dart';

// 🟢 Screens
import 'screens/login_screen.dart';
import 'screens/sign_up_page.dart';
import 'screens/profile_screen.dart';
import 'screens/product_list.dart';
import 'screens/product_form_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/home.dart';
import 'screens/market_map_screen.dart';
import 'screens/market_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase
  await Firebase.initializeApp();

  // ✅ Supabase
  await Supabase.initialize(
    url: 'https://xyzpsegsttcxpxgxbduk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5enBzZWdzdHRjeHB4Z3hiZHVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4NjgyNTYsImV4cCI6MjA2NjQ0NDI1Nn0.RFy3KH6R_NovFrrqzFUx2FjOgKTefYEQ5NPebLOvDn0',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        // Auth
        '/': (context) => const LoginScreen(),
        '/signup': (context) => SignUpPage(),
        '/profile': (context) => const ProfileScreen(),

        // Products
        '/product-list': (context) => const ProductListScreen(),
                '/fav': (context) => FavoritesScreen(),


        '/product-form': (context) => const ProductFormScreen(),
        '/edit-product': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return EditProductScreen(
            productId: args['productId'],
            productData: args['productData'],
          );
        },

        // Markets
        '/home': (context) => const HomeScreen(),
        '/market-map': (context) => MarketMapScreen(),
        '/market-form': (context) => const MarketFormScreen(),
      },
    );
  }
}
