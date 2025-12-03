import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Service gratuit pour géocoder des adresses avec Nominatim (OpenStreetMap)
/// Pas de clé API requise, pas de carte bancaire nécessaire
class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  
  /// Convertit une adresse en coordonnées GPS
  /// Exemple: "1600 Amphitheatre Parkway, Mountain View, CA"
  static Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final url = Uri.parse('$_baseUrl/search?q=$encodedAddress&format=json&limit=1');
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'RealEstateApp/1.0', // Nominatim requires a User-Agent
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        if (data.isNotEmpty) {
          final result = data.first;
          final lat = double.parse(result['lat']);
          final lon = double.parse(result['lon']);
          
          return LatLng(lat, lon);
        }
      }
      
      return null;
    } catch (e) {
      print('Error geocoding address: $e');
      return null;
    }
  }

  /// Convertit des coordonnées GPS en adresse
  /// Reverse geocoding
  static Future<String?> getAddressFromCoordinates(LatLng coordinates) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/reverse?lat=${coordinates.latitude}&lon=${coordinates.longitude}&format=json'
      );
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'RealEstateApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'];
      }
      
      return null;
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }

  /// Recherche de lieux avec suggestions
  /// Utile pour l'autocomplétion d'adresses
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse('$_baseUrl/search?q=$encodedQuery&format=json&limit=5');
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'RealEstateApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        return data.map((place) => {
          'name': place['display_name'] as String,
          'lat': double.parse(place['lat']),
          'lon': double.parse(place['lon']),
        }).toList();
      }
      
      return [];
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }
}
