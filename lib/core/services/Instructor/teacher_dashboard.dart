import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherDashboardService {
  final supabase = Supabase.instance.client;

  /// Fetches dashboard overview for the current instructor.
  /// Returns a map with keys: totalCourses (int), totalStudents (int), totalDays (int), recentCourses (List<Map>)
  Future<Map<String, dynamic>> fetchInstructorOverview({int recentLimit = 4}) async {
    final user = supabase.auth.currentUser;
    if (user == null) return {
      'totalCourses': 0,
      'totalStudents': 0,
      'totalDays': 0,
      'recentCourses': <Map<String, dynamic>>[],
    };

    // Fetch courses for this instructor with required fields
    final coursesResp = await supabase
        .from('courses')
        .select('id, title, duration_days, created_at')
        .eq('instructor_id', user.id)
        .order('created_at', ascending: false);

    final courses = List.from(coursesResp as List? ?? []);
    final totalCourses = courses.length;

    // Sum duration_days defensively
    int totalDays = 0;
    for (final c in courses) {
      final v = c['duration_days'];
      if (v is int) {
        totalDays += v;
      } else if (v is String) {
        totalDays += int.tryParse(v) ?? 0;
      }
    }

    // Build recent courses (limit)
    final recent = courses.take(recentLimit).map((c) => {
      'id': c['id'],
      'title': c['title'],
      'duration_days': c['duration_days'],
      'created_at': c['created_at'],
    }).toList();

    // If there are courses, fetch enrollments for those course ids to compute student counts
    int totalStudents = 0;
    final studentsPerCourse = <String, int>{};
    final courseIds = courses.map((c) => c['id']).where((e) => e != null).toList();
    if (courseIds.isNotEmpty) {
    final enrollResp = await supabase
      .from('enrollments')
      .select('id, course_id')
      .filter('course_id', 'in', courseIds);
      final enrolls = List.from(enrollResp as List? ?? []);
      for (final e in enrolls) {
        final cid = e['course_id'] as String?;
        if (cid == null) continue;
        studentsPerCourse[cid] = (studentsPerCourse[cid] ?? 0) + 1;
        totalStudents += 1;
      }
    }

    // Attach student counts to recent courses
    final recentWithCounts = recent.map((c) {
      final cid = c['id'] as String?;
      return {
        ...c,
        'students': cid != null ? (studentsPerCourse[cid] ?? 0) : 0,
      };
    }).toList();

    return {
      'totalCourses': totalCourses,
      'totalStudents': totalStudents,
      'totalDays': totalDays,
      'recentCourses': recentWithCounts,
    };
  }
}
