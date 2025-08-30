import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for fetching admin dashboard data from backend
class AdminDashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get dashboard metrics with real-time data
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    try {
      // Get total users count
      final totalUsersResponse = await _supabase.from('users').select('id');

      final totalUsersCount = (totalUsersResponse as List).length;

      // Get total verified instructors
      final verifiedInstructorsResponse = await _supabase
          .from('instructor_info')
          .select('id')
          .eq('verification_status', 'approved');

      final verifiedInstructors = (verifiedInstructorsResponse as List).length;

      // Get total verified courses
      final totalCoursesResponse = await _supabase
          .from('courses')
          .select('id')
          .eq('is_verified', true);

      final totalCourses = (totalCoursesResponse as List).length;

      // Calculate growth percentages (comparing with last month)
      final lastMonthUsers = await _getLastMonthUsers();
      final usersGrowth = _calculateGrowthPercentage(
        totalUsersCount,
        lastMonthUsers,
      );

      final lastMonthInstructors = await _getLastMonthVerifiedInstructors();
      final instructorsGrowth = _calculateGrowthPercentage(
        verifiedInstructors,
        lastMonthInstructors,
      );

      final lastMonthCourses = await _getLastMonthCourses();
      final coursesGrowth = _calculateGrowthPercentage(
        totalCourses,
        lastMonthCourses,
      );

      return {
        'totalUsers': {
          'value': totalUsersCount,
          'growth': usersGrowth,
          'isPositive': usersGrowth >= 0,
        },
        'verifiedInstructors': {
          'value': verifiedInstructors,
          'growth': instructorsGrowth,
          'isPositive': instructorsGrowth >= 0,
        },
        'totalCourses': {
          'value': totalCourses,
          'growth': coursesGrowth,
          'isPositive': coursesGrowth >= 0,
        },
      };
    } catch (e) {
      print('Error fetching dashboard metrics: $e');
      return {
        'totalUsers': {'value': 0, 'growth': 0.0, 'isPositive': true},
        'verifiedInstructors': {'value': 0, 'growth': 0.0, 'isPositive': true},
        'totalCourses': {'value': 0, 'growth': 0.0, 'isPositive': true},
      };
    }
  }

  /// Get enrollment chart data for the last 30 days
  Future<List<Map<String, dynamic>>> getEnrollmentChartData() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final enrollments = await _supabase
          .from('enrollments')
          .select('enrolled_at')
          .gte('enrolled_at', thirtyDaysAgo.toIso8601String())
          .order('enrolled_at');

      // Group enrollments by date
      Map<String, int> dailyEnrollments = {};

      // Initialize all dates with 0
      for (int i = 29; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        dailyEnrollments[dateKey] = 0;
      }

      // Count actual enrollments
      for (var enrollment in enrollments as List) {
        final date = DateTime.parse(enrollment['enrolled_at']);
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        if (dailyEnrollments.containsKey(dateKey)) {
          dailyEnrollments[dateKey] = dailyEnrollments[dateKey]! + 1;
        }
      }

      return dailyEnrollments.entries
          .map((e) => {'date': e.key, 'enrollments': e.value})
          .toList();
    } catch (e) {
      print('Error fetching enrollment chart data: $e');
      return [];
    }
  }

  /// Get recent activity feed for admin dashboard
  Future<List<Map<String, dynamic>>> getActivityFeed({int limit = 20}) async {
    try {
      List<Map<String, dynamic>> activities = [];

      // Get recent instructor applications
      final instructorApps = await _supabase
          .from('instructor_info')
          .select('''
            id,
            verification_status,
            submitted_at,
            users!instructor_info_user_id_fkey(name, profile_pic)
          ''')
          .order('submitted_at', ascending: false)
          .limit(10);

      for (var app in instructorApps as List) {
        final user = app['users'] as Map<String, dynamic>?;
        activities.add({
          'id': 'instructor_${app['id']}',
          'type': 'instructor_application',
          'title': app['verification_status'] == 'approved'
              ? 'Instructor Verification Complete'
              : app['verification_status'] == 'rejected'
              ? 'Application Rejected'
              : 'New Instructor Application',
          'description': app['verification_status'] == 'approved'
              ? '${user?['name'] ?? 'Unknown'} has been approved'
              : app['verification_status'] == 'rejected'
              ? 'Application from ${user?['name'] ?? 'Unknown'} was rejected'
              : '${user?['name'] ?? 'Unknown'} submitted verification documents',
          'timestamp': DateTime.parse(
            app['submitted_at'] ?? DateTime.now().toIso8601String(),
          ),
          'status': app['verification_status'] ?? 'pending',
          'avatar': user?['profile_pic'] ?? '',
        });
      }

      // Get recent course reports
      final courseReports = await _supabase
          .from('course_reports')
          .select('''
            id,
            course_id,
            status,
            created_at,
            courses!course_reports_course_id_fkey(title),
            users!course_reports_reported_by_fkey(name, profile_pic)
          ''')
          .order('created_at', ascending: false)
          .limit(10);

      for (var report in courseReports as List) {
        final course = report['courses'] as Map<String, dynamic>?;
        final user = report['users'] as Map<String, dynamic>?;
        activities.add({
          'id': 'report_${report['id']}',
          'type': 'course_report',
          'title': report['status'] == 'resolved'
              ? 'Course Review Completed'
              : 'Course Content Reported',
          'description': report['status'] == 'resolved'
              ? '${course?['title'] ?? 'Unknown Course'} content has been approved'
              : '${course?['title'] ?? 'Unknown Course'} flagged for review',
          'timestamp': DateTime.parse(
            report['created_at'] ?? DateTime.now().toIso8601String(),
          ),
          'status': report['status'] ?? 'pending',
          'avatar': user?['profile_pic'] ?? '',
        });
      }

      // Sort all activities by timestamp
      activities.sort(
        (a, b) =>
            (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime),
      );

      return activities.take(limit).toList();
    } catch (e) {
      print('Error fetching activity feed: $e');
      return [];
    }
  }

  /// Get platform statistics for charts and analytics
  Future<Map<String, dynamic>> getPlatformStats() async {
    try {
      // Total users by role
      final usersStats = await _supabase
          .from('users')
          .select('role')
          .order('role');

      final roleCount = <String, int>{};
      for (var user in usersStats as List) {
        final role = user['role'] as String? ?? 'student';
        roleCount[role] = (roleCount[role] ?? 0) + 1;
      }

      // Course enrollment trends (last 6 months)
      final enrollmentTrends = await _getEnrollmentTrends();

      // Top performing courses
      final topCourses = await _getTopCourses();

      // Revenue analytics (if you have payment tracking)
      final revenueStats = await _getRevenueStats();

      return {
        'usersByRole': roleCount,
        'enrollmentTrends': enrollmentTrends,
        'topCourses': topCourses,
        'revenue': revenueStats,
      };
    } catch (e) {
      print('Error fetching platform stats: $e');
      return {};
    }
  }

  // Helper methods for growth calculations and historical data

  Future<int> _getLastMonthUsers() async {
    try {
      final currentMonth = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        1,
      );

      final response = await _supabase
          .from('users')
          .select('id')
          .lt('created_at', currentMonth.toIso8601String());

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getLastMonthVerifiedInstructors() async {
    try {
      final currentMonth = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        1,
      );

      final response = await _supabase
          .from('instructor_info')
          .select('id')
          .eq('verification_status', 'approved')
          .lt('verified_at', currentMonth.toIso8601String());

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getLastMonthCourses() async {
    try {
      final currentMonth = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        1,
      );

      final response = await _supabase
          .from('courses')
          .select('id')
          .eq('is_verified', true)
          .lt('created_at', currentMonth.toIso8601String());

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  double _calculateGrowthPercentage(int current, int previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100;
  }

  Future<List<Map<String, dynamic>>> _getEnrollmentTrends() async {
    try {
      final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));

      final enrollments = await _supabase
          .from('enrollments')
          .select('enrolled_at')
          .gte('enrolled_at', sixMonthsAgo.toIso8601String())
          .order('enrolled_at');

      // Group by month
      Map<String, int> monthlyEnrollments = {};
      for (var enrollment in enrollments as List) {
        final date = DateTime.parse(enrollment['enrolled_at']);
        final monthKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}';
        monthlyEnrollments[monthKey] = (monthlyEnrollments[monthKey] ?? 0) + 1;
      }

      return monthlyEnrollments.entries
          .map((e) => {'month': e.key, 'enrollments': e.value})
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getTopCourses() async {
    try {
      final courses = await _supabase
          .from('courses')
          .select('''
            id,
            title,
            enrollments!course_id(id)
          ''')
          .limit(5);

      List<Map<String, dynamic>> topCourses = [];
      for (var course in courses as List) {
        final enrollmentCount = (course['enrollments'] as List).length;
        topCourses.add({
          'id': course['id'],
          'title': course['title'],
          'enrollments': enrollmentCount,
        });
      }

      topCourses.sort(
        (a, b) => (b['enrollments'] as int).compareTo(a['enrollments'] as int),
      );
      return topCourses;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> _getRevenueStats() async {
    try {
      // This would depend on your payment/transaction table structure
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final paidCourses = await _supabase
          .from('enrollments')
          .select('''
            enrolled_at,
            courses!course_id(price, is_paid)
          ''')
          .gte('enrolled_at', thirtyDaysAgo.toIso8601String());

      double totalRevenue = 0.0;
      int paidEnrollments = 0;

      for (var enrollment in paidCourses as List) {
        final course = enrollment['courses'] as Map<String, dynamic>?;
        if (course?['is_paid'] == true) {
          totalRevenue += (course?['price'] ?? 0.0) as double;
          paidEnrollments++;
        }
      }

      return {
        'totalRevenue': totalRevenue,
        'paidEnrollments': paidEnrollments,
        'averageOrderValue': paidEnrollments > 0
            ? totalRevenue / paidEnrollments
            : 0.0,
      };
    } catch (e) {
      return {
        'totalRevenue': 0.0,
        'paidEnrollments': 0,
        'averageOrderValue': 0.0,
      };
    }
  }
}
