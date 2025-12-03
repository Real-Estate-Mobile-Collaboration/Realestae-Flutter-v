import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
import '../../models/property.dart';
import '../../widgets/property_card.dart';
import '../property/property_details_screen.dart';

class PropertySearchScreen extends StatefulWidget {
  const PropertySearchScreen({super.key});

  @override
  State<PropertySearchScreen> createState() => _PropertySearchScreenState();
}

class _PropertySearchScreenState extends State<PropertySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedType;
  String? _selectedStatus;
  double? _minPrice;
  double? _maxPrice;
  String? _city;
  int? _bedrooms;
  int? _bathrooms;
  bool _isSearching = false;
  List<Property> _searchResults = [];

  final List<String> _propertyTypes = ['Apartment', 'House', 'Villa', 'Land', 'Office', 'Studio'];
  final List<String> _statuses = ['For Sale', 'For Rent'];
  final List<String> _popularCities = [
    // Morocco
    'Casablanca', 'Marrakech', 'Rabat', 'Fès', 'Tanger', 'Agadir',
    // Tunisia
    'Tunis', 'La Marsa', 'Sousse', 'Hammamet', 'Sfax', 'Monastir', 'Nabeul', 'Tozeur', 'Gafsa'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {});
    // Debounce la recherche pour éviter trop d'appels API
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && query == _searchController.text) {
        _performSearch();
      }
    });
  }

  Future<void> _performSearch() async {
    setState(() {
      _isSearching = true;
    });

    try {
      final provider = Provider.of<PropertyProvider>(context, listen: false);
      await provider.fetchProperties(
        search: _searchController.text.trim(),
        propertyType: _selectedType,
        status: _selectedStatus,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        city: _city,
        bedrooms: _bedrooms,
        bathrooms: _bathrooms,
      );

      setState(() {
        _searchResults = provider.properties;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedType = null;
      _selectedStatus = null;
      _minPrice = null;
      _maxPrice = null;
      _city = null;
      _bedrooms = null;
      _bathrooms = null;
    });
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
          child: Column(
            children: [
              // Modern AppBar with Gradient
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
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Search Properties',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.map_outlined, color: Colors.white),
                      tooltip: 'Map View',
                      onPressed: () {
                        Navigator.pushNamed(context, '/map');
                      },
                    ),
                    if (_selectedType != null || _selectedStatus != null || _city != null)
                      IconButton(
                        icon: const Icon(Icons.clear_all_rounded, color: Colors.white),
                        tooltip: 'Clear Filters',
                        onPressed: _clearFilters,
                      ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                      // Search Bar
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(4),
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
                        child: Column(
                          children: [
                            TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Search by title, location, or keyword...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          _onSearchChanged('');
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onSubmitted: (_) => _performSearch(),
                            ),
                          ],
                        ),
                      ),

                      // Filters Section
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            // Property Type Filter
                            _buildFilterChip(
                              label: _selectedType ?? 'Type',
                              icon: Icons.home,
                              onTap: () => _showTypeSelector(),
                              isActive: _selectedType != null,
                            ),
                            const SizedBox(width: 8),

                            // Status Filter
                            _buildFilterChip(
                              label: _selectedStatus ?? 'Status',
                              icon: Icons.sell,
                              onTap: () => _showStatusSelector(),
                              isActive: _selectedStatus != null,
                            ),
                            const SizedBox(width: 8),

                            // City Filter
                            _buildFilterChip(
                              label: _city ?? 'City',
                              icon: Icons.location_city,
                              onTap: () => _showCitySelector(),
                              isActive: _city != null,
                            ),
                            const SizedBox(width: 8),

                            // Price Filter
                            _buildFilterChip(
                              label: _minPrice != null || _maxPrice != null
                                  ? '\$${_minPrice?.toInt() ?? 0} - \$${_maxPrice?.toInt() ?? '∞'}'
                                  : 'Price',
                              icon: Icons.attach_money,
                              onTap: () => _showPriceRangeDialog(),
                              isActive: _minPrice != null || _maxPrice != null,
                            ),
                            const SizedBox(width: 8),

                            // Bedrooms Filter
                            _buildFilterChip(
                              label: _bedrooms != null ? '$_bedrooms Beds' : 'Beds',
                              icon: Icons.bed,
                              onTap: () => _showBedroomsSelector(),
                              isActive: _bedrooms != null,
                            ),
                            const SizedBox(width: 8),

                            // Bathrooms Filter
                            _buildFilterChip(
                              label: _bathrooms != null ? '$_bathrooms Baths' : 'Baths',
                              icon: Icons.bathroom,
                              onTap: () => _showBathroomsSelector(),
                              isActive: _bathrooms != null,
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      // Search Results
                      Expanded(
                        child: _isSearching
                            ? const Center(child: CircularProgressIndicator())
                            : _searchResults.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.search_off,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _searchController.text.isEmpty && _selectedType == null
                                              ? 'Start searching for properties'
                                              : 'No properties found',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Try different filters or keywords',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _searchResults.length,
                                    itemBuilder: (context, index) {
                                      final property = _searchResults[index];
                                      return PropertyCard(
                                        property: property,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PropertyDetailsScreen(property: property),
                                            ),
                                          );
                                        },
                                        showActions: false,
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isActive,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
      backgroundColor: Colors.grey[200],
    );
  }

  Future<void> _showTypeSelector() async {
    final type = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Property Type'),
        children: _propertyTypes
            .map((type) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, type),
                  child: Text(type),
                ))
            .toList(),
      ),
    );

    if (type != null) {
      setState(() {
        _selectedType = type;
      });
      _performSearch();
    }
  }

  Future<void> _showStatusSelector() async {
    final status = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Status'),
        children: _statuses
            .map((status) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, status),
                  child: Text(status),
                ))
            .toList(),
      ),
    );

    if (status != null) {
      setState(() {
        _selectedStatus = status;
      });
      _performSearch();
    }
  }

  Future<void> _showCitySelector() async {
    final city = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select City'),
        children: _popularCities
            .map((city) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, city),
                  child: Text(city),
                ))
            .toList(),
      ),
    );

    if (city != null) {
      setState(() {
        _city = city;
      });
      _performSearch();
    }
  }

  Future<void> _showPriceRangeDialog() async {
    final TextEditingController minController = TextEditingController(
      text: _minPrice?.toInt().toString() ?? '',
    );
    final TextEditingController maxController = TextEditingController(
      text: _maxPrice?.toInt().toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Price Range'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Min Price',
                prefixText: '\$',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max Price',
                prefixText: '\$',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _minPrice = double.tryParse(minController.text);
                _maxPrice = double.tryParse(maxController.text);
              });
              Navigator.pop(context);
              _performSearch();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    minController.dispose();
    maxController.dispose();
  }

  Future<void> _showBedroomsSelector() async {
    final bedrooms = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Bedrooms'),
        children: List.generate(
          6,
          (index) => SimpleDialogOption(
            onPressed: () => Navigator.pop(context, index + 1),
            child: Text('${index + 1}+ Bedroom${index + 1 > 1 ? 's' : ''}'),
          ),
        ),
      ),
    );

    if (bedrooms != null) {
      setState(() {
        _bedrooms = bedrooms;
      });
      _performSearch();
    }
  }

  Future<void> _showBathroomsSelector() async {
    final bathrooms = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Bathrooms'),
        children: List.generate(
          5,
          (index) => SimpleDialogOption(
            onPressed: () => Navigator.pop(context, index + 1),
            child: Text('${index + 1}+ Bathroom${index + 1 > 1 ? 's' : ''}'),
          ),
        ),
      ),
    );

    if (bathrooms != null) {
      setState(() {
        _bathrooms = bathrooms;
      });
      _performSearch();
    }
  }
}
