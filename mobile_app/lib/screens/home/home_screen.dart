import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/property_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/property.dart';
import '../property/property_details_screen.dart';
import '../search/property_search_screen.dart';
import '../map/map_screen.dart';
import '../../widgets/property_filter_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PropertyFilters? _currentFilters;
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropertyProvider>(context, listen: false).fetchProperties();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final provider = Provider.of<PropertyProvider>(context, listen: false);
    if (query.isEmpty) {
      provider.fetchProperties();
      return;
    }

    // Search for city/town and zoom to it on the map
    final cityCoords = _getCityCoordinates(query);
    if (cityCoords != null) {
      _mapController.move(cityCoords, 12.0);
    }

    // Also search properties
    provider.fetchProperties(search: query);
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
    return _getCityCoordinates(property.location.city) ?? const LatLng(33.5731, -7.5898);
  }

  Future<void> _showFilterDialog() async {
    final filters = await showDialog<PropertyFilters>(
      context: context,
      builder: (context) => PropertyFilterDialog(currentFilters: _currentFilters),
    );

    if (filters != null && mounted) {
      setState(() {
        _currentFilters = filters;
      });
      final provider = Provider.of<PropertyProvider>(context, listen: false);
      provider.fetchProperties(
        propertyType: filters.type,
        status: filters.status,
        minPrice: filters.minPrice,
        maxPrice: filters.maxPrice,
        city: filters.city,
        bedrooms: filters.bedrooms,
        bathrooms: filters.bathrooms,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 160,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF6366F1),
                elevation: 0,
                flexibleSpace: Container(
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
                  child: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name != null ? 'Hello, ${user!.name.split(' ')[0]}' : 'Hello, User',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Find Your Dream Home',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search properties...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : IconButton(
                                icon: const Icon(Icons.tune),
                                onPressed: _showFilterDialog,
                              ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      onChanged: _onSearchChanged,
                      onSubmitted: (value) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PropertySearchScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Map View Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Map View',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'View Full Map',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 250,
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
                            final properties = propertyProvider.properties;
                            
                            if (properties.isEmpty) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    FlutterMap(
                                      mapController: _mapController,
                                      options: const MapOptions(
                                        initialCenter: LatLng(33.5731, -7.5898),
                                        initialZoom: 6.0,
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          userAgentPackageName: 'com.example.real_estate_app',
                                        ),
                                      ],
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'No properties to display',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: _getPropertyCoordinates(properties.first),
                                  initialZoom: 8.0,
                                  minZoom: 5.0,
                                  maxZoom: 18.0,
                                  onTap: (_, __) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const MapScreen(),
                                      ),
                                    );
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.real_estate_app',
                                  ),
                                  MarkerLayer(
                                    markers: properties.take(20).map((property) {
                                      final coords = _getPropertyCoordinates(property);
                                      return Marker(
                                        point: coords,
                                        width: 40,
                                        height: 40,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PropertyDetailsScreen(property: property),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red,
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
                                            child: const Icon(
                                              Icons.home,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Properties Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Featured Properties',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PropertySearchScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'See All',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Properties Grid
              Consumer<PropertyProvider>(
                builder: (context, propertyProvider, child) {
                  if (propertyProvider.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  }

                  if (propertyProvider.error != null) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.white70,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              propertyProvider.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => propertyProvider.fetchProperties(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Theme.of(context).primaryColor,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final properties = propertyProvider.properties;

                  if (properties.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: 48,
                              color: Colors.white70,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No properties found',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(20.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final property = properties[index];
                          return _buildPropertyCard(property);
                        },
                        childCount: properties.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildPropertyCard(property) {
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image with Status Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.home, size: 48, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                // Status Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: property.status == 'For Sale' ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      property.status == 'For Sale' ? 'SALE' : 'RENT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Rating Badge (if has reviews)
                if (property.reviewCount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            property.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Property Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${property.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${property.location.city}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.bed, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 2),
                        Text(
                          '${property.bedrooms}',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.bathtub, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 2),
                        Text(
                          '${property.bathrooms}',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
