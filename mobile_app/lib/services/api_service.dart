import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/analytics.dart';
import '../utils/api_constants.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();

  // Get auth token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Save auth token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Delete auth token
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Get headers
  static Future<Map<String, String>> getHeaders({bool requiresAuth = false}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET request
  static Future<dynamic> get(String endpoint, {bool requiresAuth = false}) async {
    try {
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST request
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT request
  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http.put(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE request
  static Future<dynamic> delete(String endpoint, {bool requiresAuth = false}) async {
    try {
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http.delete(
        Uri.parse(endpoint),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Multipart request for file uploads
  static Future<dynamic> uploadFiles(
    String endpoint,
    Map<String, String> fields,
    List<String> filePaths,
    String fileFieldName,
  ) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest('POST', Uri.parse(endpoint));

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      request.fields.addAll(fields);

      // Add files
      for (var filePath in filePaths) {
        request.files.add(await http.MultipartFile.fromPath(fileFieldName, filePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  // Handle API response
  static dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'An error occurred');
    }
  }

  // Analytics
  Future<ListingAnalytics> getListingAnalytics() async {
    final response = await get(ApiConstants.listingAnalytics, requiresAuth: true);
    return ListingAnalytics.fromJson(response);
  }

  Future<PropertyAnalytics> getPropertyAnalytics(String propertyId) async {
    final response = await get(ApiConstants.propertyAnalytics(propertyId), requiresAuth: true);
    return PropertyAnalytics.fromJson(response);
  }

  // Payment
  Future<String> createPaymentIntent({required int amount, required String currency}) async {
    final response = await post(
      ApiConstants.createPaymentIntent,
      {'amount': amount, 'currency': currency},
      requiresAuth: true,
    );
    return response['clientSecret'];
  }
}
