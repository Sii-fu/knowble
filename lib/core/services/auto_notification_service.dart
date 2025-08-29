import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_notification_service.dart';

/// Service to automatically send device notifications for new unread notifications
class AutoNotificationService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static bool _isListening = false;

  /// Initialize automatic notifications for new unread notifications
  static Future<void> initialize() async {
    if (_isListening) return;

    try {
      print('🔔 Setting up automatic device notifications...');

      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated for auto notifications');
        return;
      }

      // Listen for new notifications in real-time
      _supabase.from('notification').stream(primaryKey: ['id']).listen((data) {
        // Filter for current user's unread notifications
        final userNotifications = data
            .where(
              (notification) =>
                  notification['user_id'] == user.id &&
                  notification['is_read'] == false,
            )
            .toList();

        if (userNotifications.isNotEmpty) {
          _handleNewNotifications(userNotifications);
        }
      });

      _isListening = true;
      print('✅ Auto notification service initialized');
    } catch (e) {
      print('❌ Error initializing auto notification service: $e');
    }
  }

  /// Handle new notifications by sending device notifications
  static Future<void> _handleNewNotifications(
    List<Map<String, dynamic>> notifications,
  ) async {
    for (final notification in notifications) {
      await _sendDeviceNotificationForData(notification);
    }
  }

  /// Send device notification for a notification data
  static Future<void> _sendDeviceNotificationForData(
    Map<String, dynamic> notificationData,
  ) async {
    try {
      final title = notificationData['title'] ?? 'New Notification';
      final description =
          notificationData['description'] ?? 'You have a new notification';
      final id = notificationData['id']?.toString() ?? '';

      print('📱 Sending device notification: $title');

      await LocalNotificationService.showNotification(
        title: title,
        body: description,
        payload: 'notification_$id',
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      );

      print('✅ Device notification sent for: $title');
    } catch (e) {
      print('❌ Error sending device notification: $e');
    }
  }

  /// Manually send device notification for new unread notification
  static Future<void> sendDeviceNotificationForNewNotification({
    required String title,
    required String description,
    String? notificationId,
  }) async {
    try {
      print('📱 Sending manual device notification: $title');

      await LocalNotificationService.showNotification(
        title: title,
        body: description,
        payload:
            'notification_${notificationId ?? DateTime.now().millisecondsSinceEpoch}',
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      );

      print('✅ Manual device notification sent: $title');
    } catch (e) {
      print('❌ Error sending manual device notification: $e');
    }
  }

  /// Stop listening for auto notifications
  static void dispose() {
    _isListening = false;
    print('🔔 Auto notification service disposed');
  }
}
