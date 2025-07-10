import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketMapScreen extends StatefulWidget {
  @override
  State<MarketMapScreen> createState() => _MarketMapScreenState();
}

class _MarketMapScreenState extends State<MarketMapScreen> {
  final LatLng _tunisiaCenter = LatLng(33.8869, 9.5375);

  List<LatLng> _markets = [
    LatLng(36.8065, 10.1815), // Tunis
    LatLng(36.8441, 10.2729), // La Marsa
    LatLng(35.8256, 10.6084), // Sousse
  ];

  LatLng? _currentLatLng;
  bool _loadingLocation = true;

  final Distance _distance = Distance();

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
        _loadingLocation = false;
      });
    } catch (e) {
      print("Erreur de géolocalisation: $e");
      setState(() {
        _loadingLocation = false;
      });
    }
  }

  // Vérifie si un nouveau point est à au moins 50m d'un point existant
  bool _isFarFromExistingMarket(LatLng point, double thresholdMeters) {
    for (var market in _markets) {
      final meterDist = _distance(point, market);
      if (meterDist < thresholdMeters) return false;
    }
    return true;
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible d’ouvrir l’URL")),
      );
    }
  }

  void _showMarketInfo(LatLng location) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Marché Bio"),
        content: Text("Coordonnées:\nLat: ${location.latitude}\nLng: ${location.longitude}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fermer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Carte des Marchés Bio")),
      floatingActionButton: FloatingActionButton(
        tooltip: "Ouvrir dans Google Maps",
        child: Icon(Icons.map),
        onPressed: () {
          if (_currentLatLng != null) {
            final url =
                "https://www.google.com/maps/search/?api=1&query=${_currentLatLng!.latitude},${_currentLatLng!.longitude}";
            _launchURL(url);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Position utilisateur non disponible")),
            );
          }
        },
      ),
      body: _loadingLocation
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                center: _tunisiaCenter,
                zoom: 7.0,
                onTap: (tapPosition, latlng) {
                  if (_isFarFromExistingMarket(latlng, 50)) {
                    setState(() {
                      _markets.add(latlng);
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              "Un marché existe déjà proche de cet emplacement.")),
                    );
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    if (_currentLatLng != null)
                      Marker(
                        point: _currentLatLng!,
                        width: 60,
                        height: 60,
                        child: Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                    ..._markets.map(
                      (market) => Marker(
                        point: market,
                        width: 60,
                        height: 60,
                        child: GestureDetector(
                          onTap: () => _showMarketInfo(market),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
