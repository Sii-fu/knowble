import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/course.dart';

class ReminderCourseService {
  final _client = Supabase.instance.client;

  /// Fetches courses that the student is enrolled in with full course details
  /// This method joins the enrollments and courses tables to get enrolled courses
  Future<List<Course>> fetchEnrolledCoursesForReminder(String studentId) async {
    try {
      final response = await _client
          .from('enrollments')
          .select('''
            course_id,
            courses:course_id (
              id,
              instructor_id,
              title,
              description,
              price,
              is_paid,
              duration_days,
              created_at,
              banner
            )
          ''')
          .eq('student_id', studentId);

      final data = response as List<dynamic>? ?? [];
      return data
          .where((item) => item['courses'] != null)
          .map(
            (item) => Course.fromMap(item['courses'] as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error fetching enrolled courses for reminder: $e');
      return [];
    }
  }

  /// Get current authenticated user ID
  String? getCurrentUserId() {
    return Supabase.instance.client.auth.currentUser?.id;
  }

  /// Convenience method to fetch enrolled courses for the current user
  Future<List<Course>> fetchCurrentUserEnrolledCourses() async {
    final userId = getCurrentUserId();
    if (userId == null) {
      print('No authenticated user found');
      return [];
    }
    return await fetchEnrolledCoursesForReminder(userId);
  }
}
