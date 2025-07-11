import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/reminder.dart';

/// ReminderService handles all reminder-related operations with Supabase
/// Similar to AuthManager pattern but for reminder CRUD operations
class ReminderService {
  // Get Supabase client instance (same pattern as AuthManager)
  static final SupabaseClient _supabase = Supabase.instance.client;

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

      // Prepare reminder data for database insertion
      final reminderData = {
        'user_id': user.id, // Current authenticated user's ID
        'course_id': courseId, // Optional course reference (can be null)
        'title': title.trim(), // Remove extra whitespace from title
        'description':
            description.trim(), // Remove extra whitespace from description
        'time':
            startTime
                .toIso8601String(), // Convert start DateTime to ISO string for database
        'end_time':
            endTime
                .toIso8601String(), // Convert end DateTime to ISO string for database
        'created_by':
            null, // Set to null since we have separate priority column
        'priority': priority, // Store priority in dedicated priority column
      };

      // Insert reminder into Supabase reminders table
      await _supabase.from('reminders').insert(reminderData);

      // Log success for debugging purposes
      print('✅ Reminder created successfully: $title');
      print('   📅 Date: ${startTime.toString().split(' ')[0]}');
      print(
        '   ⏰ Time: ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}',
      );
      print('   🎯 Priority: $priority');

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
      final reminders =
          response.map<Reminder>((data) => Reminder.fromMap(data)).toList();

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

      // Prepare updated data
      final updateData = {
        'title': title.trim(), // Updated title
        'description': description.trim(), // Updated description
        'time': startTime.toIso8601String(), // Updated start time
        'end_time': endTime.toIso8601String(), // Updated end time
        'course_id': courseId, // Updated course reference (can be null)
        'priority': priority, // Updated priority
      };

      // Update reminder in database with security check
      await _supabase
          .from('reminders')
          .update(updateData)
          .eq('id', reminderId) // Match by reminder ID
          .eq('user_id', user.id); // Security: ensure user owns this reminder

      // Log success
      print('✅ Reminder updated successfully: $title');
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
}
