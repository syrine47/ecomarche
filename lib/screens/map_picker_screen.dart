import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _selectedPosition;
  String? _cityName;

 Future<void> _getCityName(double latitude, double longitude) async {
  try {
    final placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      final p = placemarks.first;
      String? name = p.locality ??
          p.subAdministrativeArea ??
          p.administrativeArea ??
          p.subLocality ??
          p.thoroughfare ??
          p.name;

      setState(() {
        _cityName = (name != null && name.isNotEmpty) ? name : "Ville inconnue";
      });
      print("Ville trouvée : $_cityName");
    } else {
      setState(() {
        _cityName = "Ville inconnue";
      });
      print("Aucun placemark trouvé");
    }
  } catch (e) {
    print("Erreur de géocodage inversé : $e");
    setState(() {
      _cityName = "Erreur géocodage";
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un emplacement'),
        backgroundColor: Colors.green.shade700,
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(36.8, 10.2), // Tunisie
          zoom: 7.0,
          onTap: (tapPosition, point) {
            setState(() {
              _selectedPosition = point;
              _cityName = null;
            });
            _getCityName(point.latitude, point.longitude);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.ecomarche',
          ),
          if (_selectedPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedPosition!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: (_selectedPosition != null && _cityName != null)
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pop(context, {
                  'latlng': _selectedPosition,
                  'city': _cityName,
                });
              },
              icon: const Icon(Icons.check),
              label: Text("Valider $_cityName"),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }
}
