import '../models/user.dart';
import '../utils/api_constants.dart';
import 'api_service.dart';

class AuthService {
  // Register user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await ApiService.post(
      ApiConstants.register,
      {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
      },
    );

    if (response['success']) {
      await ApiService.saveToken(response['token']);
      return {
        'user': User.fromJson(response['user']),
        'token': response['token'],
      };
    } else {
      throw Exception(response['message'] ?? 'Registration failed');
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print('🔑 AuthService: Début du login');
    print('📧 Email: $email');
    print('🌐 URL: ${ApiConstants.login}');
    
    final response = await ApiService.post(
      ApiConstants.login,
      {
        'email': email,
        'password': password,
      },
    );

    print('📦 AuthService: Réponse reçue - $response');

    if (response['success']) {
      print('✅ AuthService: Login réussi, sauvegarde du token...');
      await ApiService.saveToken(response['token']);
      return {
        'user': User.fromJson(response['user']),
        'token': response['token'],
      };
    } else {
      print('❌ AuthService: Login échoué - ${response['message']}');
      throw Exception(response['message'] ?? 'Login failed');
    }
  }

  // Get current user
  static Future<User> getCurrentUser() async {
    final response = await ApiService.get(
      ApiConstants.getMe,
      requiresAuth: true,
    );

    if (response['success']) {
      return User.fromJson(response['data']);
    } else {
      throw Exception(response['message'] ?? 'Failed to get user');
    }
  }

  // Logout
  static Future<void> logout() async {
    await ApiService.deleteToken();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null;
  }

  // Save token from OAuth (bypasses API call)
  static Future<void> saveTokenFromOAuth(String token) async {
    await ApiService.saveToken(token);
  }
}
