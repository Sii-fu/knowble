import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherDashboardService {
  final supabase = Supabase.instance.client;
  
  static final List<Map<String, dynamic>> _sessionActivities = [];
  static DateTime? _sessionStart;
  
  /// Initialize session tracking
  static void initializeSession() {
    _sessionStart = DateTime.now();
    _sessionActivities.clear();
  }
  
  /// Clear session data (call on logout)
  static void clearSession() {
    _sessionActivities.clear();
    _sessionStart = null;
  }
  
  /// Log an activity for the current session
  static void logActivity({
    required String type,
    required String message,
    String? refId,
  }) {
    final activity = {
      'type': type,
      'message': message,
      'created_at': DateTime.now().toIso8601String(),
      'ref_id': refId,
      'session_id': _sessionStart?.millisecondsSinceEpoch.toString(),
    };
    
    _sessionActivities.insert(0, activity); // Insert at beginning for newest first
    
    // Keep only last 20 activities to prevent memory issues
    if (_sessionActivities.length > 20) {
      _sessionActivities.removeRange(20, _sessionActivities.length);
    }
  }

  /// Fetches dashboard overview for the current instructor.
  /// Returns a map with keys: totalCourses (int), totalStudents (int), totalDays (int), recentCourses (List<Map>)
  Future<Map<String, dynamic>> fetchInstructorOverview({int recentLimit = 4}) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return {
      'totalCourses': 0,
      'totalStudents': 0,
      'totalDays': 0,
      'recentCourses': <Map<String, dynamic>>[],
    };
    }

    // Try to fetch instructor name from users table (if available)
    String teacherName = user.email ?? 'Instructor';
    try {
      final profile = await supabase.from('users').select('full_name').eq('id', user.id).maybeSingle();
      if (profile != null && profile['full_name'] != null && profile['full_name'].toString().trim().isNotEmpty) {
        teacherName = profile['full_name'];
      }
    } catch (_) {}

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
    final courseIds = courses.map((c) => c['id']).where((e) => e != null).map((e) => e.toString()).toList();
    if (courseIds.isNotEmpty) {
    final inList = '(${courseIds.map((id) => '"$id"').join(',')})';
    final enrollResp = await supabase
      .from('enrollments')
      .select('id, course_id')
      .filter('course_id', 'in', inList);
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
      'teacherName': teacherName,
    };
  }

  /// Fetch recent activity for the current instructor scoped to the current session.
  /// Now returns session-based activities instead of synthesized ones
  Future<List<Map<String, dynamic>>> fetchRecentActivity({DateTime? sessionStart, int limit = 6}) async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return [];

    // Return session activities, limited by the requested amount
    final activities = List<Map<String, dynamic>>.from(_sessionActivities);
    if (activities.length > limit) {
      return activities.take(limit).toList();
    }
    return activities;
  }

  /// Fetches revenue aggregated by month for a given year for the current instructor.
  /// Returns a map: { 'monthly': List<double> (length 12, index 0 = Jan), 'total': double }
  Future<Map<String, dynamic>> fetchAnnualRevenue({int? year}) async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return {'monthly': List.filled(12, 0.0), 'total': 0.0};
    final int targetYear = year ?? DateTime.now().year;

  // Fetch courses for instructor to get prices (only paid courses)
  final coursesResp = await supabase
    .from('courses')
    .select('id, price, is_paid')
    .eq('instructor_id', currentUser.id);

    final courses = List.from(coursesResp as List? ?? []);
    final priceByCourse = <String, double>{};
    for (final c in courses) {
      final id = c['id'] as String?;
      final p = c['price'];
      final isPaid = c['is_paid'];
      double price = 0.0;
      if (p is num) price = p.toDouble();
      else if (p is String) price = double.tryParse(p) ?? 0.0;
      // Only include paid courses with a positive price
      final paidFlag = (isPaid is bool) ? isPaid : (isPaid?.toString().toLowerCase() == 'true');
      if (id != null && paidFlag == true && price > 0) {
        priceByCourse[id] = price;
      }
    }

    if (priceByCourse.isEmpty) return {'monthly': List.filled(12, 0.0), 'total': 0.0};

    // Fetch enrollments for these courses
  final courseIds = priceByCourse.keys.map((e) => e.toString()).toList();
  final inList = '(${courseIds.map((id) => '"$id"').join(',')})';
  final enrollResp = await supabase
    .from('enrollments')
    .select('id, course_id, enrolled_at')
    .filter('course_id', 'in', inList);

    var enrolls = List.from(enrollResp as List? ?? []);

    // Debugging info
    print('fetchAnnualRevenue: courses=${courses.length}, paidCourses=${priceByCourse.length}, enrollmentsFetched=${enrolls.length}');
    print('priceByCourse sample: ${priceByCourse.entries.take(5).toList()}');

    // Fallback: if the single 'in' query didn't return results (some PostgREST
    // setups reject the 'in' filter formatting), fetch enrollments per course id
    // and merge them. This is slightly more chatty but reliable for correctness.
    if (enrolls.isEmpty) {
      final List<Map<String, dynamic>> merged = [];
      for (final cid in priceByCourse.keys) {
        try {
          final r = await supabase
              .from('enrollments')
              .select('id, course_id, enrolled_at')
              .eq('course_id', cid);
          final lr = List.from(r as List? ?? []);
          merged.addAll(lr.cast<Map<String, dynamic>>());
        } catch (e) {
          // ignore per-course failures
          print('fetchAnnualRevenue: per-course enroll fetch failed for $cid: $e');
        }
      }
      enrolls = merged;
      print('fetchAnnualRevenue: after fallback enrollmentsFetched=${enrolls.length}');
    }

    final monthly = List<double>.filled(12, 0.0);
    double total = 0.0;

    for (final e in enrolls) {
      final cid = e['course_id'] as String?;
      final enrolledAtRaw = e['enrolled_at'];
      if (cid == null) continue;
      final price = priceByCourse[cid] ?? 0.0;
      if (price == 0.0) continue;

      DateTime? dt;
      if (enrolledAtRaw is DateTime) dt = enrolledAtRaw;
      else if (enrolledAtRaw is String) dt = DateTime.tryParse(enrolledAtRaw);
      if (dt == null) continue;

      if (dt.year != targetYear) continue;
      final monthIndex = dt.month - 1;
      monthly[monthIndex] = monthly[monthIndex] + price;
      total += price;
    }

    // Also return some debug info to help validate mapping
    final enrollmentCourseIds = enrolls.map((e) => e['course_id']?.toString()).where((e) => e != null).toList();
    return {
      'monthly': monthly,
      'total': total,
      'debug': {
        'courseIds': courseIds,
        'priceByCourseKeys': priceByCourse.keys.toList(),
        'enrollmentCourseIds': enrollmentCourseIds,
      }
    };
  }
}
