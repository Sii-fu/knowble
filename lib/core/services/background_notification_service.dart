import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'local_notification_service.dart';

/// Background service to handle notifications when app is closed
class BackgroundNotificationService {
  static const String _taskName = 'notificationCheckTask';
  static const String _isolateName = 'notificationIsolate';
  
  /// Initialize the background notification service
  static Future<void> initialize() async {
    try {
      print('🔄 Initializing background notification service...');
      
      // Initialize WorkManager
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );
      
      // Register periodic task to check notifications every 5 minutes
      await Workmanager().registerPeriodicTask(
        _taskName,
        _taskName,
        frequency: const Duration(minutes: 5),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
      
      print('✅ Background notification service initialized');
    } catch (e) {
      print('❌ Error initializing background notification service: $e');
    }
  }
  
  /// Cancel all background tasks
  static Future<void> cancelAllTasks() async {
    try {
      await Workmanager().cancelAll();
      print('🛑 All background notification tasks cancelled');
    } catch (e) {
      print('❌ Error cancelling background tasks: $e');
    }
  }
  
  /// Check for notifications that should be triggered now
  static Future<void> checkAndTriggerNotifications() async {
    try {
      print('🔍 Checking for notifications to trigger...');
      
      // Initialize Supabase client in background
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        print('❌ No authenticated user in background check');
        return;
      }
      
      final now = DateTime.now();
      final currentTimeString = now.toIso8601String();
      
      // Query notifications that should be triggered now
      final response = await supabase
          .from('notification')
          .select('*')
          .eq('user_id', user.id)
          .eq('is_read', false)
          .lte('alert_time', currentTimeString)
          .order('alert_time', ascending: true);
      
      if (response.isNotEmpty) {
        print('📱 Found ${response.length} notifications to trigger');
        
        for (final notification in response) {
          await _triggerNotification(notification);
          
          // Mark as read to prevent duplicate triggers
          await supabase
              .from('notification')
              .update({'is_read': true})
              .eq('id', notification['id']);
        }
      } else {
        print('✅ No notifications to trigger at this time');
      }
    } catch (e) {
      print('❌ Error in background notification check: $e');
    }
  }
  
  /// Trigger a notification
  static Future<void> _triggerNotification(Map<String, dynamic> notification) async {
    try {
      final title = notification['title'] ?? 'Reminder';
      final description = notification['description'] ?? 'You have a reminder';
      final id = notification['id']?.toString() ?? '';
      
      print('🔔 Triggering notification: $title');
      
      // Initialize local notification service
      await LocalNotificationService.initialize();
      
      // Show the notification
      await LocalNotificationService.showNotification(
        title: title,
        body: description,
        payload: 'notification_$id',
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      );
      
      print('✅ Notification triggered: $title');
    } catch (e) {
      print('❌ Error triggering notification: $e');
    }
  }
}

/// Callback dispatcher for background tasks
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('🔄 Background task started: $task');
      
      switch (task) {
        case 'notificationCheckTask':
          await BackgroundNotificationService.checkAndTriggerNotifications();
          break;
        default:
          print('❌ Unknown background task: $task');
      }
      
      return Future.value(true);
    } catch (e) {
      print('❌ Background task error: $e');
      return Future.value(false);
    }
  });
}
