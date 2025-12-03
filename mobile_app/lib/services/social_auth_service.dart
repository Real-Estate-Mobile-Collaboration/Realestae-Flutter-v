import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

class SocialAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '752571424787-j3fbqj6s4e4jshbjd0bmsk2gkes3o8g0.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  // ===== GOOGLE SIGN-IN =====
  
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('🔵 Starting Google Sign-In...');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ User cancelled Google Sign-In');
        return null;
      }

      print('✅ Google user signed in: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('🔑 Got Google ID Token');

      // Send to backend
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/google/mobile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'idToken': googleAuth.idToken,
          'email': googleUser.email,
          'name': googleUser.displayName,
          'photoUrl': googleUser.photoUrl,
        }),
      );

      print('📡 Backend response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          // Save token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          await prefs.setString('user', json.encode(data['user']));

          print('✅ Google Sign-In successful!');
          
          return {
            'success': true,
            'token': data['token'],
            'user': data['user'],
          };
        }
      }

      print('❌ Backend returned error: ${response.body}');
      return {
        'success': false,
        'message': 'Authentication failed',
      };
    } catch (error) {
      print('❌ Google Sign-In error: $error');
      return {
        'success': false,
        'message': error.toString(),
      };
    }
  }

  Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
      print('✅ Signed out from Google');
    } catch (error) {
      print('❌ Google Sign-Out error: $error');
    }
  }

  // ===== COMMON =====
  
  Future<void> signOutFromAll() async {
    try {
      await signOutFromGoogle();
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      
      print('✅ Signed out from all providers');
    } catch (error) {
      print('❌ Sign out error: $error');
    }
  }

  // Check if user is currently signed in
  Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    
    if (userString != null) {
      return json.decode(userString);
    }
    
    return null;
  }
}
