import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/modern_app_bar.dart';
import '../../providers/property_provider.dart';
import '../../models/property.dart';
import '../property/property_details_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Property? _selectedProperty;
  final TextEditingController _searchController = TextEditingController();
  List<Property> _filteredProperties = [];
  
  // Default center: Morocco (Casablanca)
  final LatLng _currentCenter = const LatLng(33.5731, -7.5898);
  final double _currentZoom = 10.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Charger TOUTES les propriétés sans limite pour la carte
      Provider.of<PropertyProvider>(context, listen: false).fetchAllProperties();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      // Si la recherche est vide, afficher toutes les propriétés
      if (query.isEmpty) {
        _filteredProperties = [];
        _selectedProperty = null;
        return;
      }

      // Search for city/town and zoom to it
      final cityCoords = _getCityCoordinates(query);
      if (cityCoords != null) {
        _mapController.move(cityCoords, 12.0);
      }

      // Filtrer les propriétés par ville, adresse ou titre
      final allProperties = Provider.of<PropertyProvider>(context, listen: false).properties;
      _filteredProperties = allProperties.where((property) {
        final searchLower = query.toLowerCase();
        return property.location.city.toLowerCase().contains(searchLower) ||
               property.location.address.toLowerCase().contains(searchLower) ||
               property.title.toLowerCase().contains(searchLower);
      }).toList();

      // Si on trouve des propriétés, centrer sur la première
      if (_filteredProperties.isNotEmpty) {
        final firstProperty = _filteredProperties.first;
        final coords = _getPropertyCoordinates(firstProperty);
        _mapController.move(coords, 15.0);
        _selectedProperty = firstProperty;
      }
    });
  }

  void _onPropertyTap(Property property) {
    setState(() {
      _selectedProperty = property;
    });
    
    // Animate to property location
    final coords = _getPropertyCoordinates(property);
    _mapController.move(coords, 15.0);
  }

  LatLng? _getCityCoordinates(String cityName) {
    final city = cityName.toLowerCase().trim();
    
    // World countries, capitals and major cities
    final cityCoordinates = {
      // Morocco
      'morocco': const LatLng(31.7917, -7.0926),
      'casablanca': const LatLng(33.5731, -7.5898),
      'rabat': const LatLng(34.0209, -6.8416),
      'marrakech': const LatLng(31.6295, -7.9811),
      'fes': const LatLng(34.0181, -5.0078),
      'tangier': const LatLng(35.7595, -5.8340),
      'agadir': const LatLng(30.4278, -9.5981),
      'meknes': const LatLng(33.8935, -5.5473),
      
      // Africa
      'algeria': const LatLng(28.0339, 1.6596),
      'algiers': const LatLng(36.7538, 3.0588),
      'tunisia': const LatLng(33.8869, 9.5375),
      'tunis': const LatLng(36.8065, 10.1815),
      'la marsa': const LatLng(36.8780, 10.3247),
      'sousse': const LatLng(35.8256, 10.6369),
      'hammamet': const LatLng(36.4000, 10.6167),
      'sfax': const LatLng(34.7406, 10.7603),
      'monastir': const LatLng(35.7775, 10.8261),
      'nabeul': const LatLng(36.4513, 10.7356),
      'tozeur': const LatLng(33.9197, 8.1338),
      'gafsa': const LatLng(34.4250, 8.7842),
      'egypt': const LatLng(26.8206, 30.8025),
      'cairo': const LatLng(30.0444, 31.2357),
      'south africa': const LatLng(-30.5595, 22.9375),
      'johannesburg': const LatLng(-26.2041, 28.0473),
      'cape town': const LatLng(-33.9249, 18.4241),
      'nigeria': const LatLng(9.0820, 8.6753),
      'lagos': const LatLng(6.5244, 3.3792),
      'kenya': const LatLng(-0.0236, 37.9062),
      'nairobi': const LatLng(-1.2864, 36.8172),
      
      // Europe
      'france': const LatLng(46.2276, 2.2137),
      'paris': const LatLng(48.8566, 2.3522),
      'lyon': const LatLng(45.7640, 4.8357),
      'marseille': const LatLng(43.2965, 5.3698),
      'spain': const LatLng(40.4637, -3.7492),
      'madrid': const LatLng(40.4168, -3.7038),
      'barcelona': const LatLng(41.3851, 2.1734),
      'italy': const LatLng(41.8719, 12.5674),
      'rome': const LatLng(41.9028, 12.4964),
      'milan': const LatLng(45.4642, 9.1900),
      'venice': const LatLng(45.4408, 12.3155),
      'germany': const LatLng(51.1657, 10.4515),
      'berlin': const LatLng(52.5200, 13.4050),
      'munich': const LatLng(48.1351, 11.5820),
      'united kingdom': const LatLng(55.3781, -3.4360),
      'uk': const LatLng(55.3781, -3.4360),
      'london': const LatLng(51.5074, -0.1278),
      'manchester': const LatLng(53.4808, -2.2426),
      'netherlands': const LatLng(52.1326, 5.2913),
      'amsterdam': const LatLng(52.3676, 4.9041),
      'belgium': const LatLng(50.5039, 4.4699),
      'brussels': const LatLng(50.8503, 4.3517),
      'switzerland': const LatLng(46.8182, 8.2275),
      'zurich': const LatLng(47.3769, 8.5417),
      'geneva': const LatLng(46.2044, 6.1432),
      'austria': const LatLng(47.5162, 14.5501),
      'vienna': const LatLng(48.2082, 16.3738),
      'portugal': const LatLng(39.3999, -8.2245),
      'lisbon': const LatLng(38.7223, -9.1393),
      'porto': const LatLng(41.1579, -8.6291),
      'greece': const LatLng(39.0742, 21.8243),
      'athens': const LatLng(37.9838, 23.7275),
      'russia': const LatLng(61.5240, 105.3188),
      'moscow': const LatLng(55.7558, 37.6173),
      'turkey': const LatLng(38.9637, 35.2433),
      'istanbul': const LatLng(41.0082, 28.9784),
      'ankara': const LatLng(39.9334, 32.8597),
      
      // Americas
      'usa': const LatLng(37.0902, -95.7129),
      'united states': const LatLng(37.0902, -95.7129),
      'new york': const LatLng(40.7128, -74.0060),
      'los angeles': const LatLng(34.0522, -118.2437),
      'chicago': const LatLng(41.8781, -87.6298),
      'houston': const LatLng(29.7604, -95.3698),
      'miami': const LatLng(25.7617, -80.1918),
      'san francisco': const LatLng(37.7749, -122.4194),
      'washington': const LatLng(38.9072, -77.0369),
      'boston': const LatLng(42.3601, -71.0589),
      'canada': const LatLng(56.1304, -106.3468),
      'toronto': const LatLng(43.6532, -79.3832),
      'montreal': const LatLng(45.5017, -73.5673),
      'vancouver': const LatLng(49.2827, -123.1207),
      'mexico': const LatLng(23.6345, -102.5528),
      'mexico city': const LatLng(19.4326, -99.1332),
      'brazil': const LatLng(-14.2350, -51.9253),
      'sao paulo': const LatLng(-23.5505, -46.6333),
      'rio de janeiro': const LatLng(-22.9068, -43.1729),
      'argentina': const LatLng(-38.4161, -63.6167),
      'buenos aires': const LatLng(-34.6037, -58.3816),
      
      // Asia
      'china': const LatLng(35.8617, 104.1954),
      'beijing': const LatLng(39.9042, 116.4074),
      'shanghai': const LatLng(31.2304, 121.4737),
      'hong kong': const LatLng(22.3193, 114.1694),
      'japan': const LatLng(36.2048, 138.2529),
      'tokyo': const LatLng(35.6762, 139.6503),
      'osaka': const LatLng(34.6937, 135.5023),
      'kyoto': const LatLng(35.0116, 135.7681),
      'india': const LatLng(20.5937, 78.9629),
      'delhi': const LatLng(28.7041, 77.1025),
      'mumbai': const LatLng(19.0760, 72.8777),
      'bangalore': const LatLng(12.9716, 77.5946),
      'singapore': const LatLng(1.3521, 103.8198),
      'thailand': const LatLng(15.8700, 100.9925),
      'bangkok': const LatLng(13.7563, 100.5018),
      'vietnam': const LatLng(14.0583, 108.2772),
      'hanoi': const LatLng(21.0285, 105.8542),
      'ho chi minh': const LatLng(10.8231, 106.6297),
      'malaysia': const LatLng(4.2105, 101.9758),
      'kuala lumpur': const LatLng(3.1390, 101.6869),
      'south korea': const LatLng(35.9078, 127.7669),
      'seoul': const LatLng(37.5665, 126.9780),
      'indonesia': const LatLng(-0.7893, 113.9213),
      'jakarta': const LatLng(-6.2088, 106.8456),
      'bali': const LatLng(-8.3405, 115.0920),
      'philippines': const LatLng(12.8797, 121.7740),
      'manila': const LatLng(14.5995, 120.9842),
      'pakistan': const LatLng(30.3753, 69.3451),
      'karachi': const LatLng(24.8607, 67.0011),
      
      // Middle East
      'uae': const LatLng(23.4241, 53.8478),
      'dubai': const LatLng(25.2048, 55.2708),
      'abu dhabi': const LatLng(24.4539, 54.3773),
      'saudi arabia': const LatLng(23.8859, 45.0792),
      'riyadh': const LatLng(24.7136, 46.6753),
      'qatar': const LatLng(25.3548, 51.1839),
      'doha': const LatLng(25.2854, 51.5310),
      'kuwait': const LatLng(29.3117, 47.4818),
      'israel': const LatLng(31.0461, 34.8516),
      'tel aviv': const LatLng(32.0853, 34.7818),
      'jerusalem': const LatLng(31.7683, 35.2137),
      'lebanon': const LatLng(33.8547, 35.8623),
      'beirut': const LatLng(33.8886, 35.4955),
      
      // Oceania
      'australia': const LatLng(-25.2744, 133.7751),
      'sydney': const LatLng(-33.8688, 151.2093),
      'melbourne': const LatLng(-37.8136, 144.9631),
      'brisbane': const LatLng(-27.4698, 153.0251),
      'new zealand': const LatLng(-40.9006, 174.8860),
      'auckland': const LatLng(-36.8485, 174.7633),
      'wellington': const LatLng(-41.2865, 174.7762),
    };
    
    // Try exact match first
    if (cityCoordinates.containsKey(city)) {
      return cityCoordinates[city];
    }
    
    // Try partial match
    for (var entry in cityCoordinates.entries) {
      if (entry.key.contains(city) || city.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return null;
  }

  LatLng _getPropertyCoordinates(Property property) {
    // Utiliser les coordonnées réelles de la propriété
    final lat = property.location.coordinates.latitude;
    final lng = property.location.coordinates.longitude;
    
    // Vérifier que les coordonnées sont valides
    if (lat != 0 && lng != 0) {
      return LatLng(lat, lng);
    }
    
    // Fallback: essayer de trouver la ville dans la liste
    return _getCityCoordinates(property.location.city) ?? _currentCenter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: const ModernAppBar(title: 'Map View'),
      body: Column(
          children: [
            // Search Bar
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search location...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.my_location),
                          onPressed: () {
                            // Reset to Morocco center
                            _mapController.move(_currentCenter, 10.0);
                            setState(() {
                              _selectedProperty = null;
                            });
                          },
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
            ),

            // Interactive Map with Properties
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Consumer<PropertyProvider>(
                  builder: (context, propertyProvider, child) {
                    if (propertyProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final allProperties = propertyProvider.properties;
                    
                    // Utiliser les propriétés filtrées si la recherche est active, sinon toutes
                    final properties = _searchController.text.isEmpty
                        ? allProperties
                        : _filteredProperties;

                    if (allProperties.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No Properties on Map',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Properties with location data will appear here',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Message si aucun résultat de recherche
                    if (properties.isEmpty && _searchController.text.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No Results Found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try searching for "${_searchController.text}"',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear Search'),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Interactive Map
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: _currentCenter,
                                  initialZoom: _currentZoom,
                                  minZoom: 5.0,
                                  maxZoom: 18.0,
                                ),
                                children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.real_estate_app',
                                  maxZoom: 19,
                                ),
                                MarkerLayer(
                                  markers: allProperties.map((property) {
                                    final coords = _getPropertyCoordinates(property);
                                    final isSelected = _selectedProperty?.id == property.id;
                                    
                                    return Marker(
                                      point: coords,
                                      width: isSelected ? 50 : 40,
                                      height: isSelected ? 50 : 40,
                                      child: GestureDetector(
                                        onTap: () => _onPropertyTap(property),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isSelected 
                                                ? Theme.of(context).primaryColor 
                                                : Colors.red,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.home,
                                            color: Colors.white,
                                            size: isSelected ? 24 : 20,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                        // Properties List
                        Expanded(
                          flex: 2,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: properties.length,
                            itemBuilder: (context, index) {
                              final property = properties[index];
                              final isSelected = _selectedProperty?.id == property.id;
                              return _buildMapPropertyCard(property, isSelected);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
    );
  }

  Widget _buildMapPropertyCard(Property property, bool isSelected) {
    final imageUrl = property.images.isNotEmpty
        ? property.images[0]
        : 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailsScreen(property: property),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  child: Image.network(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.home, size: 40, color: Colors.grey),
                      );
                    },
                  ),
                ),
                // Status Badge
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: property.status == 'For Sale' ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      property.status == 'For Sale' ? 'SALE' : 'RENT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${property.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.propertyType,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${property.location.city}, ${property.location.country}',
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bed, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${property.bedrooms}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 12),
                        Icon(Icons.bathtub, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${property.bathrooms}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        if (property.reviewCount > 0)
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                property.averageRating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
