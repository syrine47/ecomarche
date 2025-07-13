import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/market.dart';
import '../services/supabase_service.dart';

class MarketProvider with ChangeNotifier {
  final List<Market> _markets = [];

  List<Market> get markets => [..._markets];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 🔄 Charger les marchés depuis Firestore
  Future<void> fetchMarkets() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('markets').get();

      _markets.clear();

      for (var doc in snapshot.docs) {
        final market = Market.fromMap(doc.data(), id: doc.id);
        _markets.add(market);
      }

      notifyListeners();
    } catch (e) {
      throw Exception("Erreur lors du chargement des marchés : $e");
    }
  } 

  /// ➕ Ajouter un nouveau marché avec image
  Future<void> addMarket(Market market, File imageFile) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Upload image via SupabaseService (direct dans bucket racine)
      final imageUrl = await SupabaseService.uploadImage(imageFile);

      if (imageUrl == null) {
        throw Exception("Échec de l'upload de l'image");
      }

      // 2. Préparer le marché avec l'URL de l'image
      final marketWithImage = market.copyWith(image: imageUrl);

      // 3. Enregistrer dans Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('markets')
          .add(marketWithImage.toMap());

      // 4. Ajouter localement dans la liste et notifier
      _markets.add(marketWithImage.copyWith(id: docRef.id));
      notifyListeners();
    } catch (e) {
      throw Exception("Erreur lors de l'ajout du marché : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🗑️ Supprimer un marché (et l’image si besoin)
  Future<void> deleteMarket(String marketId, String? imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('markets').doc(marketId).delete();

      if (imageUrl != null) {
        // Supprimer l'image depuis Supabase storage
        // Ici, il faut extraire le nom du fichier à partir de l'URL publique
        final fileName = imageUrl.split('/').last.split('?').first;
        await SupabaseService.deleteImage(fileName);
      }

      _markets.removeWhere((market) => market.id == marketId);
      notifyListeners();
    } catch (e) {
      throw Exception("Erreur lors de la suppression du marché : $e");
    }
  }

  /// ✏️ Modifier un marché (si besoin plus tard)
  Future<void> updateMarket(String id, Market updatedMarket) async {
    try {
      await FirebaseFirestore.instance
          .collection('markets')
          .doc(id)
          .update(updatedMarket.toMap());

      final index = _markets.indexWhere((m) => m.id == id);
      if (index != -1) {
        _markets[index] = updatedMarket.copyWith(id: id);
        notifyListeners();
      }
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour : $e");
    }
  }
}
