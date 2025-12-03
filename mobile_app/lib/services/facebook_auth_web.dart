import 'dart:js' as js;
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

class FacebookAuthWeb {
  /// Sign in with Facebook using JavaScript interop
  static Future<Map<String, dynamic>?> signIn() async {
    if (!kIsWeb) {
      throw Exception('This method is only for web platform');
    }

    try {
      print('🔵 Starting Facebook Sign-In (Web)...');

      // Check if running on HTTPS
      final currentUrl = js.context['location']['protocol'].toString();
      if (currentUrl.contains('http:')) {
        print('⚠️ Facebook OAuth requires HTTPS');
        print('💡 Localhost HTTP is blocked by Facebook for security');
        print('📝 Options:');
        print('   1. Deploy to HTTPS domain (production)');
        print('   2. Use ngrok to create HTTPS tunnel');
        print('   3. Use Google Sign-In instead (works on localhost)');
        
        return {
          'success': false,
          'message': 'Facebook OAuth requires HTTPS. Please use Google Sign-In or deploy to a secure domain.',
        };
      }

      // Check if FB is available
      if (!js.context.hasProperty('FB')) {
        print('❌ Facebook SDK not loaded');
        return null;
      }

      print('✅ Facebook SDK is available');

      // Create a completer to handle the async callback
      final result = await _fbLogin();
      
      if (result == null || result['status'] != 'connected') {
        print('❌ Facebook login failed or cancelled');
        return null;
      }

      print('✅ Facebook login successful');

      // Get access token
      final accessToken = result['authResponse']['accessToken'];
      final userId = result['authResponse']['userID'];

      // Get user data using Graph API
      final userData = await _getFacebookUserData(accessToken);
      
      if (userData == null) {
        print('❌ Failed to get Facebook user data');
        return null;
      }

      print('📦 Facebook user data: $userData');

      final String? email = userData['email'];
      final String? name = userData['name'];
      final String? photoUrl = userData['picture']?['data']?['url'];

      // Send to backend
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/facebook/mobile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'accessToken': accessToken,
          'userId': userId,
          'email': email,
          'name': name,
          'photoUrl': photoUrl,
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

          print('✅ Facebook Sign-In successful!');
          
          return {
            'success': true,
            'token': data['token'],
            'user': data['user'],
          };
        }
      }

      print('❌ Backend returned error: ${response.body}');
      return null;

    } catch (error) {
      print('❌ Facebook Sign-In error: $error');
      return null;
    }
  }

  /// Call FB.login using JavaScript interop
  static Future<Map<String, dynamic>?> _fbLogin() async {
    try {
      // Call FB.login with a callback
      final jsResult = await _callFBLogin();
      return jsResult;
    } catch (e) {
      print('❌ FB.login error: $e');
      return null;
    }
  }

  /// JavaScript interop to call FB.login
  static Future<Map<String, dynamic>?> _callFBLogin() {
    final completer = Completer<Map<String, dynamic>?>();
    
    // Define the callback function
    js.context['_fbLoginCallback'] = js.allowInterop((response) {
      try {
        final Map<String, dynamic> result = {
          'status': response['status'],
          'authResponse': response['authResponse'] != null ? {
            'accessToken': response['authResponse']['accessToken'],
            'userID': response['authResponse']['userID'],
          } : null,
        };
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });

    // Call FB.login
    js.context.callMethod('eval', ['''
      FB.login(function(response) {
        window._fbLoginCallback(response);
      }, {scope: 'email,public_profile'});
    ''']);

    return completer.future;
  }

  /// Get user data from Facebook Graph API
  static Future<Map<String, dynamic>?> _getFacebookUserData(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://graph.facebook.com/me?fields=id,name,email,picture.width(200)&access_token=$accessToken'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      return null;
    } catch (e) {
      print('❌ Error fetching Facebook user data: $e');
      return null;
    }
  }

  /// Sign out from Facebook
  static Future<void> signOut() async {
    if (!kIsWeb) return;

    try {
      if (js.context.hasProperty('FB')) {
        js.context.callMethod('eval', ['FB.logout();']);
        print('✅ Signed out from Facebook');
      }
    } catch (error) {
      print('❌ Facebook Sign-Out error: $error');
    }
  }
}
