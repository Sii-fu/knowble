import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize the local notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Android initialization settings
      const AndroidInitializationSettings androidInitSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosInitSettings =
          DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
          );

      // Combined initialization settings
      const InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iosInitSettings,
      );

      // Initialize
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions for Android 13+
      await _requestPermissions();

      _isInitialized = true;
      print('✅ Local Notification Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Local Notification Service: $e');
    }
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Check if notification permissions are granted
  static Future<bool> checkPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final isGranted =
            await androidImplementation.areNotificationsEnabled() ?? false;
        print('📱 Notification permissions granted: $isGranted');
        return isGranted;
      }

      // For iOS, assume granted if initialization was successful
      return _isInitialized;
    } catch (e) {
      print('❌ Error checking notification permissions: $e');
      return false;
    }
  }

  /// Request notification permissions explicitly
  static Future<bool> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final granted = await androidImplementation
            .requestNotificationsPermission();
        print('📱 Notification permission request result: $granted');
        return granted ?? false;
      }

      return true; // iOS permissions are requested during initialization
    } catch (e) {
      print('❌ Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // You can navigate to specific screens based on payload
  }

  /// Show a local notification (REAL device notification)
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'knowble_channel', // Channel ID
            'Knowble Notifications', // Channel name
            channelDescription: 'Notifications from Knowble app',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );

      print('✅ Device notification shown: $title');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  /// Show big text notification
  static Future<void> showBigTextNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    try {
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'knowble_channel',
            'Knowble Notifications',
            channelDescription: 'Notifications from Knowble app',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(
              body,
              contentTitle: title,
              summaryText: 'Knowble',
            ),
            enableVibration: true,
            playSound: true,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );

      print('✅ Big text device notification shown: $title');
    } catch (e) {
      print('❌ Error showing big text notification: $e');
    }
  }

  /// Test notification - shows immediately on device
  static Future<void> showTestNotification() async {
    await showNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Knowble app!',
      payload: 'test_notification',
      id: 999,
    );
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Schedule a notification for a specific time
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    int? id,
  }) async {
    try {
      // Don't schedule if the time is in the past
      if (scheduledTime.isBefore(DateTime.now())) {
        print('⚠️ Cannot schedule notification for past time: $scheduledTime');
        return;
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'knowble_scheduled_channel',
            'Knowble Scheduled Notifications',
            channelDescription: 'Scheduled notifications from Knowble app',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        platformDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('📅 Scheduled notification for: $scheduledTime');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }
}
