import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/api_constants.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize - check if user is logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        _user = await AuthService.getCurrentUser();
        _isAuthenticated = true;
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      _user = result['user'];
      _isAuthenticated = true;
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

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    print('📱 AuthProvider: Début du login');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🌐 AuthProvider: Appel du AuthService.login...');
      final result = await AuthService.login(
        email: email,
        password: password,
      );

      print('✅ AuthProvider: Login réussi');
      _user = result['user'];
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ AuthProvider: Erreur - $e');
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Update user profile
  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  // Set user data (for OAuth)
  void setUser(Map<String, dynamic> userData) {
    _user = User.fromJson(userData);
    _isAuthenticated = true;
    notifyListeners();
  }

  // Set token (for OAuth)
  Future<void> setToken(String token) async {
    await AuthService.saveTokenFromOAuth(token);
  }

  // Login with social auth (Google, Facebook, etc.)
  Future<bool> loginWithSocial(Map<String, dynamic> result) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Save token
      final token = result['token'];
      if (token != null) {
        await setToken(token);
      }

      // Set user data
      final userData = result['user'];
      if (userData != null) {
        setUser(userData);
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

  // Upload profile photo
  Future<void> uploadProfilePhoto(List<int> bytes, String filename) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final uri = Uri.parse('${ApiConstants.baseUrl}/users/upload-photo');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: filename,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // Attendre un peu pour que le fichier soit bien sauvegardé
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Rafraîchir les données utilisateur depuis le serveur
        _user = await AuthService.getCurrentUser();
        
        // Forcer la mise à jour de l'UI
        notifyListeners();
      } else {
        throw Exception('Upload failed: $responseData');
      }
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }
}

