import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  // Initialize the notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    print('✅ Push Notifications initialized');
  }

  // Request notification permissions
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ requires permission
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        return status.isGranted;
      }
      return true;
    } else if (Platform.isIOS) {
      final result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return false;
  }

  // Show new message notification
  static Future<void> showMessageNotification({
    required String senderName,
    required String message,
    required String conversationId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'messages_channel',
      'Messages',
      channelDescription: 'Notifications for new messages',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      conversationId.hashCode, // Unique ID per conversation
      '💬 $senderName',
      message,
      details,
      payload: 'message:$conversationId',
    );
  }

  // Show booking update notification
  static Future<void> showBookingNotification({
    required String title,
    required String body,
    required String bookingId,
    String? propertyTitle,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'bookings_channel',
      'Bookings',
      channelDescription: 'Notifications for booking updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      bookingId.hashCode,
      '📅 $title',
      propertyTitle != null ? '$body\n$propertyTitle' : body,
      details,
      payload: 'booking:$bookingId',
    );
  }

  // Show price alert notification
  static Future<void> showPriceAlertNotification({
    required String propertyTitle,
    required double oldPrice,
    required double newPrice,
    required String propertyId,
  }) async {
    final priceDrop = oldPrice - newPrice;
    final percentDrop = ((priceDrop / oldPrice) * 100).toStringAsFixed(1);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'price_alerts_channel',
      'Price Alerts',
      channelDescription: 'Notifications for price changes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF00FF00),
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      propertyId.hashCode,
      '💰 Price Drop Alert!',
      '$propertyTitle\nWas: \$$oldPrice → Now: \$$newPrice\nSave $percentDrop%!',
      details,
      payload: 'property:$propertyId',
    );
  }

  // Show property view notification (for property owners)
  static Future<void> showPropertyViewNotification({
    required String propertyTitle,
    required int viewCount,
    required String propertyId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'property_views_channel',
      'Property Views',
      channelDescription: 'Notifications for property views',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      propertyId.hashCode,
      '👀 New Views on Your Property',
      '$propertyTitle has received $viewCount new views!',
      details,
      payload: 'property:$propertyId',
    );
  }

  // Show review notification
  static Future<void> showReviewNotification({
    required String propertyTitle,
    required int rating,
    required String reviewText,
    required String propertyId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'reviews_channel',
      'Reviews',
      channelDescription: 'Notifications for new reviews',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final stars = '⭐' * rating;

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch,
      '⭐ New Review on $propertyTitle',
      '$stars\n$reviewText',
      details,
      payload: 'property:$propertyId',
    );
  }

  // Schedule a reminder notification
  static Future<void> scheduleReminder({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'reminders_channel',
      'Reminders',
      channelDescription: 'Scheduled reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      scheduledDate.millisecondsSinceEpoch,
      title,
      body,
      _convertToTZDateTime(scheduledDate),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Get pending notifications
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  // Callback when notification is received while app is in foreground
  static void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    print('📬 Received notification: $title - $body');
  }

  // Callback when notification is tapped
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    print('🔔 Notification tapped with payload: $payload');

    // Handle navigation based on payload
    if (payload != null) {
      if (payload.startsWith('message:')) {
        // Navigate to conversation
        final conversationId = payload.replaceFirst('message:', '');
        print('Navigate to conversation: $conversationId');
      } else if (payload.startsWith('booking:')) {
        // Navigate to booking details
        final bookingId = payload.replaceFirst('booking:', '');
        print('Navigate to booking: $bookingId');
      } else if (payload.startsWith('property:')) {
        // Navigate to property details
        final propertyId = payload.replaceFirst('property:', '');
        print('Navigate to property: $propertyId');
      }
    }
  }

  // Helper to convert DateTime to TZDateTime
  static dynamic _convertToTZDateTime(DateTime dateTime) {
    // This is a simplified version. In production, use timezone package
    return dateTime;
  }

  // Show a simple test notification
  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0,
      '🎉 Test Notification',
      'Push notifications are working perfectly!',
      details,
    );
  }
}
