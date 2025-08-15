import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/reminder.dart';
import 'notification_service.dart';

/// ReminderService handles all reminder-related operations with Supabase
/// Similar to AuthManager pattern but for reminder CRUD operations
class ReminderService {
  // Get Supabase client instance (same pattern as AuthManager)
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user's role from the users table
  static Future<String?> _getCurrentUserRole() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      return response?['role'] as String?;
    } catch (e) {
      print('❌ Error getting user role: $e');
      return null;
    }
  }

  /// Create a new reminder in the database
  /// Returns null if successful, error message if failed (same pattern as AuthManager)
  static Future<String?> createReminder({
    required String title, // Task title from form
    required String description, // Task description from form
    required DateTime startTime, // Combined date + start time from form
    required DateTime endTime, // Combined date + end time from form
    String? courseId, // Selected course ID (optional) - can be null for now
    String priority = 'Medium', // Priority level from dropdown
  }) async {
    try {
      // Check if user is authenticated (same pattern as all auth operations)
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 'User not authenticated'; // Return error message if no user
      }

      // Get user's role for created_by field
      final userRole = await _getCurrentUserRole();

      // Convert times to Bangladesh Standard Time (GMT+6) before storing
      final bstStartTime = convertToBangladeshTime(startTime);
      final bstEndTime = convertToBangladeshTime(endTime);

      print('🔍 Original start time: ${startTime.toString()}');
      print('🔍 BST start time: ${bstStartTime.toString()}');

      // Prepare reminder data for database insertion
      final reminderData = {
        'user_id': user.id, // Current authenticated user's ID
        'course_id': courseId, // Optional course reference (can be null)
        'title': title.trim(), // Remove extra whitespace from title
        'description': description
            .trim(), // Remove extra whitespace from description
        'time': bstStartTime
            .toIso8601String(), // Convert BST DateTime to ISO string for database
        'end_time': bstEndTime
            .toIso8601String(), // Convert BST DateTime to ISO string for database
        'created_by': userRole, // Set user role (student, instructor, or admin)
        'priority': priority, // Store priority in dedicated priority column
      };

      // Insert reminder into Supabase reminders table
      final response = await _supabase
          .from('reminders')
          .insert(reminderData)
          .select()
          .single();

      // Get the created reminder ID for notification scheduling
      final String createdReminderId = response['id'];

      print('🔍 Reminder created with ID: $createdReminderId');
      print(
        '🔍 About to schedule notification for time: ${startTime.toString()}',
      );

      // Schedule notification for the reminder (use original local time for notification scheduling)
      final notificationId =
          await NotificationService.scheduleReminderNotification(
            reminderId: createdReminderId,
            title: title.trim(),
            description: description.trim().isNotEmpty
                ? description.trim()
                : 'Reminder for your task',
            scheduledTime:
                startTime, // Use original local time for notification scheduling
            priority: priority,
          );

      print('🔍 Notification service returned ID: $notificationId');

      // Log success for debugging purposes
      print('✅ Reminder created successfully: $title');
      print('   📅 Date: ${startTime.toString().split(' ')[0]}');
      print(
        '   ⏰ Time: ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}',
      );
      print('   🎯 Priority: $priority');
      print('   👤 Created by: $userRole');
      if (notificationId != null) {
        print('   📱 Notification scheduled with ID: $notificationId');
      }

      return null; // Return null to indicate success (AuthManager pattern)
    } on PostgrestException catch (e) {
      // Handle Supabase database-specific errors
      print('❌ Database Error creating reminder: ${e.message}');
      return 'Database error: ${e.message}';
    } catch (e) {
      // Handle any other unexpected errors
      print('❌ Unknown Error creating reminder: $e');
      return 'Failed to create reminder. Please try again.';
    }
  }

  /// Get all reminders for a specific date
  /// Returns list of Reminder objects for that date
  static Future<List<Reminder>> getRemindersForDate(DateTime date) async {
    try {
      // Check if user is authenticated
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Calculate start and end of the selected date for filtering
      final startOfDay = DateTime(
        date.year,
        date.month,
        date.day,
      ); // e.g., 2024-03-15 00:00:00
      final endOfDay = DateTime(
        date.year,
        date.month,
        date.day,
        23,
        59,
        59,
      ); // e.g., 2024-03-15 23:59:59

      // Query reminders from database for the specific date and user
      final response = await _supabase
          .from('reminders') // From reminders table
          .select('*') // Select all columns
          .eq('user_id', user.id) // Filter by current user only
          .gte(
            'time',
            startOfDay.toIso8601String(),
          ) // Start time >= beginning of day
          .lte('time', endOfDay.toIso8601String()) // Start time <= end of day
          .order(
            'time',
            ascending: true,
          ); // Order by start time (earliest first)

      // Convert database response to Reminder objects using fromMap method
      final reminders = response
          .map<Reminder>((data) => Reminder.fromMap(data))
          .toList();

      // Log success with details for debugging
      print(
        '✅ Fetched ${reminders.length} reminders for ${date.toString().split(' ')[0]}',
      );
      if (reminders.isNotEmpty) {
        print('   📋 Tasks: ${reminders.map((r) => r.title).join(', ')}');
      }

      return reminders;
    } on PostgrestException catch (e) {
      // Handle database errors gracefully
      print('❌ Database Error fetching reminders: ${e.message}');
      return []; // Return empty list on error so UI doesn't crash
    } catch (e) {
      // Handle other errors
      print('❌ Error fetching reminders: $e');
      return []; // Return empty list on error
    }
  }

  /// Get all reminders for a specific month
  /// Returns list of Reminder objects for the entire month
  static Future<List<Reminder>> getRemindersForMonth(DateTime month) async {
    try {
      // Check if user is authenticated
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Calculate start and end of the month for filtering
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      // Query reminders from database for the specific month and user
      final response = await _supabase
          .from('reminders') // From reminders table
          .select('*') // Select all columns
          .eq('user_id', user.id) // Filter by current user only
          .gte(
            'time',
            startOfMonth.toIso8601String(),
          ) // Start time >= beginning of month
          .lte(
            'time',
            endOfMonth.toIso8601String(),
          ) // Start time <= end of month
          .order(
            'time',
            ascending: true,
          ); // Order by start time (earliest first)

      // Convert database response to Reminder objects using fromMap method
      final reminders = response
          .map<Reminder>((data) => Reminder.fromMap(data))
          .toList();

      // Log success with details for debugging
      print(
        '✅ Fetched ${reminders.length} reminders for ${month.year}-${month.month.toString().padLeft(2, '0')}',
      );

      return reminders;
    } on PostgrestException catch (e) {
      // Handle database errors gracefully
      print('❌ Database Error fetching month reminders: ${e.message}');
      return []; // Return empty list on error so UI doesn't crash
    } catch (e) {
      // Handle other errors
      print('❌ Error fetching month reminders: $e');
      return []; // Return empty list on error
    }
  }

  /// Update an existing reminder
  /// Returns null if successful, error message if failed
  static Future<String?> updateReminder({
    required String reminderId, // ID of reminder to update
    required String title, // New title
    required String description, // New description
    required DateTime startTime, // New start time
    required DateTime endTime, // New end time
    String? courseId, // New course association (can be null)
    String priority = 'Medium', // New priority
  }) async {
    try {
      // Check if user is authenticated
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 'User not authenticated';
      }

      // Convert times to Bangladesh Standard Time (GMT+6) before storing
      final bstStartTime = convertToBangladeshTime(startTime);
      final bstEndTime = convertToBangladeshTime(endTime);

      print('🔍 Update - Original start time: ${startTime.toString()}');
      print('🔍 Update - BST start time: ${bstStartTime.toString()}');

      // Prepare updated data
      final updateData = {
        'title': title.trim(), // Updated title
        'description': description.trim(), // Updated description
        'time': bstStartTime.toIso8601String(), // Updated start time in BST
        'end_time': bstEndTime.toIso8601String(), // Updated end time in BST
        'course_id': courseId, // Updated course reference (can be null)
        'priority': priority, // Updated priority
      };

      // Update reminder in database with security check
      await _supabase
          .from('reminders')
          .update(updateData)
          .eq('id', reminderId) // Match by reminder ID
          .eq('user_id', user.id); // Security: ensure user owns this reminder

      // Cancel any existing notifications for this reminder
      // Note: In a production app, you'd store notification IDs with reminders
      // For now, we'll schedule a new notification

      // Schedule new notification for updated reminder
      final notificationId =
          await NotificationService.scheduleReminderNotification(
            reminderId: reminderId,
            title: title.trim(),
            description: description.trim().isNotEmpty
                ? description.trim()
                : 'Reminder for your task',
            scheduledTime:
                startTime, // Use original local time for notification scheduling
            priority: priority,
          );

      // Log success
      print('✅ Reminder updated successfully: $title');
      if (notificationId != null) {
        print('   📱 New notification scheduled with ID: $notificationId');
      }
      return null; // Success
    } on PostgrestException catch (e) {
      // Handle database errors
      print('❌ Database Error updating reminder: ${e.message}');
      return 'Database error: ${e.message}';
    } catch (e) {
      // Handle other errors
      print('❌ Error updating reminder: $e');
      return 'Failed to update reminder. Please try again.';
    }
  }

  /// Delete a reminder
  /// Returns null if successful, error message if failed
  static Future<String?> deleteReminder(String reminderId) async {
    try {
      // Check if user is authenticated
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 'User not authenticated';
      }

      // Delete reminder from database with security check
      await _supabase
          .from('reminders')
          .delete()
          .eq('id', reminderId) // Match by reminder ID
          .eq('user_id', user.id); // Security: ensure user owns this reminder

      // Note: In a production app, you'd store notification IDs with reminders
      // to properly cancel them. For now, this is a basic implementation.
      // You could query the notifications table and cancel related notifications

      // Log success
      print('✅ Reminder deleted successfully');
      return null; // Success
    } on PostgrestException catch (e) {
      // Handle database errors
      print('❌ Database Error deleting reminder: ${e.message}');
      return 'Database error: ${e.message}';
    } catch (e) {
      // Handle other errors
      print('❌ Error deleting reminder: $e');
      return 'Failed to delete reminder. Please try again.';
    }
  }

  /// Convert a DateTime to Bangladesh Standard Time (GMT+6)
  static DateTime convertToBangladeshTime(DateTime dateTime) {
    // Bangladesh Standard Time is GMT+6
    // Add 6 hours to convert to Bangladesh time
    DateTime bangladeshTime = dateTime.add(Duration(hours: 6));

    print('🔍 Input time: ${dateTime.toString()}');
    print('🔍 Bangladesh time (GMT+6): ${bangladeshTime.toString()}');

    return bangladeshTime;
  }

  /// Convert a Bangladesh time back to local time for notifications
  /// Update existing reminders' timestamps to Bangladesh Standard Time
  static Future<String?> convertExistingRemindersToBasT() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 'User not authenticated';
      }

      print(
        '🔧 Starting conversion of existing reminders to Bangladesh Standard Time...',
      );

      // Get all reminders for the current user
      final response = await _supabase
          .from('reminders')
          .select('*')
          .eq('user_id', user.id);

      if (response.isEmpty) {
        print('✅ No reminders found to convert');
        return null;
      }

      int convertedCount = 0;

      for (final reminderData in response) {
        try {
          final String reminderId = reminderData['id'];
          final DateTime originalTime = DateTime.parse(reminderData['time']);
          final DateTime? originalEndTime = reminderData['end_time'] != null
              ? DateTime.parse(reminderData['end_time'])
              : null;

          // Convert times to Bangladesh Standard Time
          final bstTime = convertToBangladeshTime(originalTime);
          final bstEndTime = originalEndTime != null
              ? convertToBangladeshTime(originalEndTime)
              : null;

          // Update the reminder with Bangladesh time
          final updateData = {
            'time': bstTime.toIso8601String(),
            if (bstEndTime != null) 'end_time': bstEndTime.toIso8601String(),
          };

          await _supabase
              .from('reminders')
              .update(updateData)
              .eq('id', reminderId);

          convertedCount++;

          print('✅ Converted reminder: ${reminderData['title']}');
          print('   Original: ${originalTime.toString()}');
          print('   BST: ${bstTime.toString()}');
        } catch (e) {
          print('❌ Error converting reminder ${reminderData['id']}: $e');
        }
      }

      print(
        '✅ Conversion completed. $convertedCount reminders converted to Bangladesh Standard Time.',
      );
      return null;
    } on PostgrestException catch (e) {
      print('❌ Database Error converting reminders: ${e.message}');
      return 'Database error: ${e.message}';
    } catch (e) {
      print('❌ Error converting reminders: $e');
      return 'Failed to convert reminders. Please try again.';
    }
  }
}
