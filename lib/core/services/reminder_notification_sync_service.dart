import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper service to sync reminders with notifications
class ReminderNotificationSyncService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Create notification entry in notification table when reminder is created
  /// This ensures notifications appear in the notification page even if push notifications fail
  static Future<void> createNotificationForReminder({
    required String reminderId,
    required String title,
    required String description,
    required DateTime scheduledTime,
    required String priority,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated, cannot create notification');
        return;
      }

      print('📝 Creating notification entry for reminder: $reminderId');

      // Convert to GMT+6 (Bangladesh time) for database storage
      final bangladeshTime = scheduledTime.add(const Duration(hours: 6));
      print(
        '🌍 Time conversion: ${scheduledTime.toString()} → ${bangladeshTime.toString()} (GMT+6)',
      );

      final notificationData = {
        'user_id': user.id,
        'title': title,
        'description': description.isNotEmpty
            ? description
            : 'Reminder for your task',
        'priority': priority.toLowerCase(),
        'alert_time': bangladeshTime.toIso8601String(),
        'navigate': reminderId, // Store reminder ID for navigation
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'is_read': false,
      };

      final response = await _supabase
          .from('notification')
          .insert(notificationData)
          .select()
          .single();

      print('Notification entry created: ${response['id']}');
      print('    Title: $title');
      print('    Linked to reminder: $reminderId');
    } catch (e) {
      print(' Error creating notification entry: $e');
      // Re-throw the error so calling code knows about the failure
      rethrow;
    }
  }

  /// Update notification when reminder is updated
  static Future<void> updateNotificationForReminder({
    required String reminderId,
    required String title,
    required String description,
    required DateTime scheduledTime,
    required String priority,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print(' User not authenticated, cannot update notification');
        return;
      }

      print(' Updating notification for reminder: $reminderId');

      final updateData = {
        'title': title,
        'description': description.isNotEmpty
            ? description
            : 'Reminder for your task',
        'priority': priority.toLowerCase(),
        'alert_time': scheduledTime.toIso8601String(),
      };

      final response = await _supabase
          .from('notification')
          .update(updateData)
          .eq('navigate', reminderId)
          .eq('user_id', user.id)
          .select();

      if (response.isNotEmpty) {
        print(' Notification updated for reminder: $reminderId');
      } else {
        print(' No notification found to update for reminder: $reminderId');
        // Create new notification if none exists
        await createNotificationForReminder(
          reminderId: reminderId,
          title: title,
          description: description,
          scheduledTime: scheduledTime,
          priority: priority,
        );
      }
    } catch (e) {
      print('❌ Error updating notification: $e');
    }
  }

  /// Delete notification when reminder is deleted
  static Future<void> deleteNotificationForReminder(String reminderId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print(' User not authenticated, cannot delete notification');
        return;
      }

      print(' Deleting notification for reminder: $reminderId');

      await _supabase
          .from('notification')
          .delete()
          .eq('navigate', reminderId)
          .eq('user_id', user.id);

      print(' Notification deleted for reminder: $reminderId');
    } catch (e) {
      print(' Error deleting notification: $e');
    }
  }

  /// Sync all existing reminders to create notification entries
  /// Useful for migrating existing reminders to the notification system
  static Future<void> syncAllRemindersToNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print(' User not authenticated');
        return;
      }

      print(' Starting sync of all reminders to notifications...');

      // Get all reminders for the user
      final reminders = await _supabase
          .from('reminders')
          .select('*')
          .eq('user_id', user.id)
          .order('time', ascending: true);

      if (reminders.isEmpty) {
        print(' No reminders found to sync');
        return;
      }

      int syncedCount = 0;
      int skippedCount = 0;

      for (final reminder in reminders) {
        try {
          final reminderId = reminder['id'];

          // Check if notification already exists for this reminder
          final existingNotification = await _supabase
              .from('notification')
              .select('id')
              .eq('navigate', reminderId)
              .eq('user_id', user.id)
              .maybeSingle();

          if (existingNotification != null) {
            print(
              '⏭ Notification already exists for reminder: ${reminder['title']}',
            );
            skippedCount++;
            continue;
          }

          // Create notification for this reminder
          await createNotificationForReminder(
            reminderId: reminderId,
            title: reminder['title'] ?? 'Untitled Reminder',
            description: reminder['description'] ?? '',
            scheduledTime: DateTime.parse(reminder['time']),
            priority: reminder['priority'] ?? 'medium',
          );

          syncedCount++;
        } catch (e) {
          print(' Error syncing reminder ${reminder['id']}: $e');
        }
      }

      print(' Sync completed!');
      print('    Total reminders: ${reminders.length}');
      print('    Synced: $syncedCount');
      print('   ⏭ Skipped (already exist): $skippedCount');
    } catch (e) {
      print(' Error syncing reminders to notifications: $e');
    }
  }
}
