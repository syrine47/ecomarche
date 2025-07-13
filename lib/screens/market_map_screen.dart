import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import '../models/market.dart';
import '../providers/market_provider.dart';

class MarketMapScreen extends StatefulWidget {
  const MarketMapScreen({super.key});

  @override
  State<MarketMapScreen> createState() => _MarketMapScreenState();
}

class _MarketMapScreenState extends State<MarketMapScreen> {
  final LatLng _tunisiaCenter = LatLng(33.8869, 9.5375);
  LatLng? _currentLatLng;
  bool _loadingLocation = true;
  bool _loadingMarkets = true;

  @override
  void initState() {
    super.initState();
    _loadLocationAndMarkets();
  }

  Future<void> _loadLocationAndMarkets() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentLatLng = LatLng(position.latitude, position.longitude);
          _loadingLocation = false;
        });
      }
    } catch (e) {
      print("Erreur position utilisateur : $e");
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }

    await Provider.of<MarketProvider>(context, listen: false).fetchMarkets();
    if (mounted) {
      setState(() => _loadingMarkets = false);
    }
  }

 void _launchInGoogleMaps(LatLng latLng) async {
  final googleMapsUrl = Uri.parse(
    "geo:${latLng.latitude},${latLng.longitude}?q=${latLng.latitude},${latLng.longitude}(Marché Bio)",
  );

  // ✅ Essayer d'ouvrir via l'application native Google Maps
  if (await canLaunchUrl(googleMapsUrl)) {
    await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
  } else {
    // 🟡 Fallback : ouvrir la version web
    final fallbackUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${latLng.latitude},${latLng.longitude}",
    );

    if (await canLaunchUrl(fallbackUrl)) {
      await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d’ouvrir la localisation.")),
      );
    }
  }
}


  void _showMarketInfoDialog(Market market) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(market.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (market.cityName != null) Text("Ville : ${market.cityName}"),
            Text("Lat : ${market.latitude.toStringAsFixed(6)}"),
            Text("Lng : ${market.longitude.toStringAsFixed(6)}"),
            if (market.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text("Description : ${market.description}"),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _launchInGoogleMaps(LatLng(market.latitude, market.longitude)),
            child: const Text("Ouvrir dans Google Maps"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);
    final markets = marketProvider.markets;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carte des Marchés Bio"),
        backgroundColor: Colors.green.shade700,
      ),
      body: (_loadingLocation || _loadingMarkets)
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                center: _tunisiaCenter,
                zoom: 7.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.ecomarche',
                ),
                MarkerLayer(
                  markers: [
                    if (_currentLatLng != null)
                      Marker(
                        point: _currentLatLng!,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.person_pin_circle,
                          size: 40,
                          color: Colors.blue,
                        ),
                      ),
                    ...markets.map((market) {
                      return Marker(
                        point: LatLng(market.latitude, market.longitude),
                        width: 60,
                        height: 60,
                        child: GestureDetector(
                          onTap: () => _showMarketInfoDialog(market),
                          child: const Icon(
                            Icons.location_on,
                            size: 40,
                            color: Colors.green,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
    );
  }
}
