import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng _selectedLocation = const LatLng(33.5731, -7.5898); // Default: Casablanca
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  void _confirmLocation() {
    Navigator.pop(context, {
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
      'address': null,
      'city': _getCityFromCoordinates(_selectedLocation),
    });
  }

  String? _getCityFromCoordinates(LatLng coords) {
    // Simple reverse lookup based on proximity to known cities
    final cityCoordinates = {
      'Casablanca': const LatLng(33.5731, -7.5898),
      'Rabat': const LatLng(34.0209, -6.8416),
      'Marrakech': const LatLng(31.6295, -7.9811),
      'Fes': const LatLng(34.0181, -5.0078),
      'Tangier': const LatLng(35.7595, -5.8340),
      'Agadir': const LatLng(30.4278, -9.5981),
      'Meknes': const LatLng(33.8935, -5.5473),
      'Oujda': const LatLng(34.6814, -1.9086),
      'Kenitra': const LatLng(34.2610, -6.5802),
      'Tetouan': const LatLng(35.5889, -5.3626),
    };

    String? nearestCity;
    double nearestDistance = double.infinity;

    for (var entry in cityCoordinates.entries) {
      final distance = _calculateDistance(coords, entry.value);
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestCity = entry.key;
      }
    }

    // Only return city if within 50km
    if (nearestDistance < 50000) {
      return nearestCity;
    }
    return null;
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, point1, point2);
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) return;

    final coords = _getCityCoordinates(query);
    if (coords != null) {
      _mapController.move(coords, 12.0);
      setState(() {
        _selectedLocation = coords;
      });
    }
  }

  LatLng? _getCityCoordinates(String cityName) {
    final city = cityName.toLowerCase().trim();
    
    final cityCoordinates = {
      // Morocco
      'casablanca': const LatLng(33.5731, -7.5898),
      'rabat': const LatLng(34.0209, -6.8416),
      'marrakech': const LatLng(31.6295, -7.9811),
      'fes': const LatLng(34.0181, -5.0078),
      'tangier': const LatLng(35.7595, -5.8340),
      'agadir': const LatLng(30.4278, -9.5981),
      'meknes': const LatLng(33.8935, -5.5473),
      'oujda': const LatLng(34.6814, -1.9086),
      'kenitra': const LatLng(34.2610, -6.5802),
      'tetouan': const LatLng(35.5889, -5.3626),
      'safi': const LatLng(32.2994, -9.2372),
      'el jadida': const LatLng(33.2316, -8.5007),
      'nador': const LatLng(35.1681, -2.9333),
      'mohammedia': const LatLng(33.7063, -7.3824),
    };

    if (cityCoordinates.containsKey(city)) {
      return cityCoordinates[city];
    }

    for (var entry in cityCoordinates.entries) {
      if (entry.key.contains(city) || city.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirmLocation,
            tooltip: 'Confirm Location',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 12.0,
              minZoom: 5.0,
              maxZoom: 18.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.real_estate_app',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 60,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search city...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ),

          // Location Info Card
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, 
                        size: 20, 
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, '
                          'Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  if (_getCityFromCoordinates(_selectedLocation) != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_city,
                          size: 20,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getCityFromCoordinates(_selectedLocation)!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirmLocation,
                      icon: const Icon(Icons.check),
                      label: const Text('Confirm Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Instructions
          Positioned(
            top: 80,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tap anywhere on the map to select location',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
