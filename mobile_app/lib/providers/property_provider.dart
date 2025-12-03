import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_service.dart';

class PropertyProvider with ChangeNotifier {
  List<Property> _properties = [];
  List<Property> _myProperties = [];
  Property? _selectedProperty;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  List<Property> get properties => _properties;
  List<Property> get myProperties => _myProperties;
  Property? get selectedProperty => _selectedProperty;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _hasMore;

  // Fetch ALL properties without pagination (pour la carte)
  Future<void> fetchAllProperties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await PropertyService.getProperties(
        page: 1,
        limit: 1000, // Grande limite pour obtenir toutes les propriétés
      );

      _properties = result['properties'];
      print('🗺️ Loaded ${result['properties'].length} properties for map (Total: ${result['total']})');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch properties with filters
  Future<void> fetchProperties({
    String? propertyType,
    String? status,
    double? minPrice,
    double? maxPrice,
    String? city,
    int? bedrooms,
    int? bathrooms,
    String? search,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      _isLoading = true;
      _currentPage = 1;
      _properties = [];
    }

    _error = null;
    notifyListeners();

    try {
      final result = await PropertyService.getProperties(
        propertyType: propertyType,
        status: status,
        minPrice: minPrice,
        maxPrice: maxPrice,
        city: city,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        search: search,
        page: _currentPage,
        limit: 50,
      );

      if (loadMore) {
        _properties.addAll(result['properties']);
      } else {
        _properties = result['properties'];
      }

      print('🏡 Loaded ${result['properties'].length} properties (Total: ${result['total']})');

      _totalPages = result['pages'];
      _hasMore = _currentPage < _totalPages;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more properties
  Future<void> loadMoreProperties({
    String? propertyType,
    String? status,
    double? minPrice,
    double? maxPrice,
    String? city,
    int? bedrooms,
    int? bathrooms,
    String? search,
  }) async {
    if (_hasMore && !_isLoading) {
      _currentPage++;
      await fetchProperties(
        propertyType: propertyType,
        status: status,
        minPrice: minPrice,
        maxPrice: maxPrice,
        city: city,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        search: search,
        loadMore: true,
      );
    }
  }

  // Get single property
  Future<void> fetchProperty(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProperty = await PropertyService.getProperty(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get my properties
  Future<void> fetchMyProperties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myProperties = await PropertyService.getMyProperties();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create property
  Future<bool> createProperty(Map<String, dynamic> propertyData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🏠 Creating property with data: $propertyData');
      final property = await PropertyService.createProperty(
        title: propertyData['title'],
        description: propertyData['description'],
        price: propertyData['price'],
        propertyType: propertyData['propertyType'],
        status: propertyData['status'],
        area: propertyData['area'],
        bedrooms: propertyData['bedrooms'],
        bathrooms: propertyData['bathrooms'],
        location: propertyData['location'],
        images: propertyData['images'],
        amenities: propertyData['amenities'],
      );

      print('✅ Property created successfully: ${property.id}');
      _properties.insert(0, property);
      _myProperties.insert(0, property);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error creating property: $e');
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update property
  Future<bool> updateProperty(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final property = await PropertyService.updateProperty(id, data);

      // Update in my properties list
      final index = _myProperties.indexWhere((p) => p.id == id);
      if (index != -1) {
        _myProperties[index] = property;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete property
  Future<bool> deleteProperty(String id) async {
    try {
      await PropertyService.deleteProperty(id);
      _myProperties.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear selected property
  void clearSelectedProperty() {
    _selectedProperty = null;
    notifyListeners();
  }
}
