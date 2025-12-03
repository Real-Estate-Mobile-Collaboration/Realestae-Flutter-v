import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Base URL - Automatically detects platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api'; // For Web
    } else {
      // **IMPORTANT**: Change this to your computer's local IP address
      // To find your IP:
      // - Windows: Open CMD and type "ipconfig" (look for IPv4 Address)
      // - Mac/Linux: Open Terminal and type "ifconfig" (look for inet)
      
      const String computerIp = '10.57.251.123'; // <-- Your computer's IP
      
      // For real devices (phone/tablet connected to same WiFi)
      return 'http://$computerIp:5000/api';
      
      // Uncomment this ONLY if using Android Emulator:
      // return 'http://10.0.2.2:5000/api';
    }
  }

  // Socket.IO URL
  static String get socketUrl {
    if (kIsWeb) {
      return 'http://localhost:5000'; // For Web
    } else {
      const String computerIp = '10.57.251.123'; // <-- Your computer's IP
      
      // For real devices
      return 'http://$computerIp:5000';
      
      // Uncomment this ONLY if using Android Emulator:
      // return 'http://10.0.2.2:5000';
    }
  }

  // Upload URL helper
  static String uploadsUrl(String filename) {
    if (kIsWeb) {
      return 'http://localhost:5000/uploads/$filename';
    } else {
      const String computerIp = '10.57.251.123';
      return 'http://$computerIp:5000/uploads/$filename'; // Your computer's IP address
      // return 'http://10.0.2.2:5000/uploads/$filename'; // For Android emulator
    }
  }

  // Auth endpoints
  static String get register => '$baseUrl/auth/register';
  static String get login => '$baseUrl/auth/login';
  static String get getMe => '$baseUrl/auth/me';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String resetPassword(String token) => '$baseUrl/auth/reset-password/$token';

  // User endpoints
  static String get userProfile => '$baseUrl/users';
  static String get updateProfile => '$baseUrl/users/profile';
  static String get changePassword => '$baseUrl/users/change-password';
  static String get updateSettings => '$baseUrl/users/settings';
  static String get myProperties => '$baseUrl/users/my-properties';
  static String get deleteAccount => '$baseUrl/users/account';

  // Property endpoints
  static String get properties => '$baseUrl/properties';
  static String propertyById(String id) => '$properties/$id';
  static String nearbyProperties(double lat, double lng) =>
      '$properties/nearby/$lat/$lng';

  // Message endpoints
  static String get messages => '$baseUrl/messages';
  static String get conversations => '$messages/conversations';
  static String messagesWithUser(String userId) => '$messages/$userId';
  static String markAsRead(String id) => '$messages/$id/read';
  static String deleteMessage(String messageId) => '$messages/$messageId';
  static String deleteConversation(String userId) => '$messages/conversation/$userId';

  // Favorite endpoints
  static String get favorites => '$baseUrl/favorites';
  static String addFavorite(String propertyId) => '$favorites/$propertyId';
  static String removeFavorite(String propertyId) => '$favorites/$propertyId';
  static String checkFavorite(String propertyId) =>
      '$favorites/check/$propertyId';

  // Review endpoints
  static String get reviews => '$baseUrl/reviews';
  static String propertyReviews(String propertyId) => '$reviews/$propertyId';
  static String addReview(String propertyId) => '$reviews/$propertyId';
  static String updateReview(String reviewId) => '$reviews/$reviewId';
  static String deleteReview(String reviewId) => '$reviews/$reviewId';
  static String get myReviews => '$reviews/user/me';

  // Email endpoints
  static String get sendVerificationCode => '$baseUrl/email/send-verification';
  static String get verifyEmail => '$baseUrl/email/verify-email';
  static String get resendVerificationCode => '$baseUrl/email/resend-verification';
  static String get requestPasswordReset => '$baseUrl/email/request-reset';
  static String get resetPasswordWithCode => '$baseUrl/email/reset-password';

  // Saved Search endpoints
  static String get savedSearches => '$baseUrl/saved-searches';
  static String savedSearchById(String id) => '$savedSearches/$id';
  static String get matchingProperties => '$savedSearches/matches';

  // Booking endpoints
  static String get bookings => '$baseUrl/bookings';
  static String get myBookings => '$bookings/my-bookings';
  static String get ownerBookings => '$bookings/owner-bookings';
  static String bookingById(String id) => '$bookings/$id';
  static String bookingStatus(String id) => '$bookings/$id/status';
  static String cancelBooking(String id) => '$bookings/$id/cancel';
  static String availableSlots(String propertyId, String date) =>
      '$bookings/available-slots/$propertyId/$date';

  // Analytics endpoints
  static String get listingAnalytics => '$baseUrl/analytics/listings';
  static String propertyAnalytics(String id) => '$baseUrl/analytics/property/$id';

  // Payment endpoints
  static String get createPaymentIntent => '$baseUrl/payments/create-intent';
}
