import '../models/property.dart';
import '../utils/api_constants.dart';
import 'api_service.dart';

class PropertyService {
  // Get all properties with filters
  static Future<Map<String, dynamic>> getProperties({
    String? propertyType,
    String? status,
    double? minPrice,
    double? maxPrice,
    String? city,
    int? bedrooms,
    int? bathrooms,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    String url = ApiConstants.properties;
    List<String> queryParams = [];

    if (propertyType != null) queryParams.add('propertyType=$propertyType');
    if (status != null) queryParams.add('status=$status');
    if (minPrice != null) queryParams.add('minPrice=$minPrice');
    if (maxPrice != null) queryParams.add('maxPrice=$maxPrice');
    if (city != null) queryParams.add('city=$city');
    if (bedrooms != null) queryParams.add('bedrooms=$bedrooms');
    if (bathrooms != null) queryParams.add('bathrooms=$bathrooms');
    if (search != null) queryParams.add('search=$search');
    queryParams.add('page=$page');
    queryParams.add('limit=$limit');

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final response = await ApiService.get(url);

    if (response['success']) {
      List<Property> properties = (response['data'] as List)
          .map((json) => Property.fromJson(json))
          .toList();

      return {
        'properties': properties,
        'total': response['total'],
        'page': response['page'],
        'pages': response['pages'],
      };
    } else {
      throw Exception(response['message'] ?? 'Failed to load properties');
    }
  }

  // Get single property
  static Future<Property> getProperty(String id) async {
    final response = await ApiService.get(
      ApiConstants.propertyById(id),
    );

    if (response['success']) {
      return Property.fromJson(response['data']);
    } else {
      throw Exception(response['message'] ?? 'Failed to load property');
    }
  }

  // Create property
  static Future<Property> createProperty({
    required String title,
    required String description,
    required double price,
    required String propertyType,
    required String status,
    required double area,
    required int bedrooms,
    required int bathrooms,
    required Map<String, dynamic> location,
    List<String>? images,
    List<String>? amenities,
  }) async {
    print('🏗️ Creating property with images: ${images?.length ?? 0}');
    
    final response = await ApiService.post(
      ApiConstants.properties,
      {
        'title': title,
        'description': description,
        'price': price,
        'propertyType': propertyType,
        'status': status,
        'area': area,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'location': location,
        'amenities': amenities ?? [],
        'images': images ?? [],
      },
      requiresAuth: true,
    );

    if (response['success']) {
      return Property.fromJson(response['data']);
    } else {
      throw Exception(response['message'] ?? 'Failed to create property');
    }
  }

  // Update property
  static Future<Property> updateProperty(String id, Map<String, dynamic> data) async {
    final response = await ApiService.put(
      ApiConstants.propertyById(id),
      data,
      requiresAuth: true,
    );

    if (response['success']) {
      return Property.fromJson(response['data']);
    } else {
      throw Exception(response['message'] ?? 'Failed to update property');
    }
  }

  // Delete property
  static Future<void> deleteProperty(String id) async {
    final response = await ApiService.delete(
      ApiConstants.propertyById(id),
      requiresAuth: true,
    );

    if (!response['success']) {
      throw Exception(response['message'] ?? 'Failed to delete property');
    }
  }

  // Get nearby properties
  static Future<List<Property>> getNearbyProperties({
    required double latitude,
    required double longitude,
    double distance = 10,
  }) async {
    final response = await ApiService.get(
      '${ApiConstants.nearbyProperties(latitude, longitude)}?distance=$distance',
    );

    if (response['success']) {
      return (response['data'] as List)
          .map((json) => Property.fromJson(json))
          .toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load nearby properties');
    }
  }

  // Get my properties
  static Future<List<Property>> getMyProperties() async {
    final response = await ApiService.get(
      ApiConstants.myProperties,
      requiresAuth: true,
    );

    if (response['success']) {
      return (response['data'] as List)
          .map((json) => Property.fromJson(json))
          .toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load my properties');
    }
  }
}
