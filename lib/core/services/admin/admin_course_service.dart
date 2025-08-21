import 'package:supabase_flutter/supabase_flutter.dart';

class AdminCourseService {
  final _client = Supabase.instance.client;

  // Fetch all courses with instructor information for admin management
  Future<List<Map<String, dynamic>>> fetchAllCoursesForAdmin() async {
    try {
      final response = await _client
          .from('courses')
          .select('''
            *,
            instructor:users!instructor_id(id, name, email)
          ''')
          .order('created_at', ascending: false);

      final data = response as List<dynamic>? ?? [];

      List<Map<String, dynamic>> courses = [];
      for (var courseData in data) {
        final course = courseData as Map<String, dynamic>;

        // Get enrollment count
        final enrollmentCount = await _getEnrollmentCount(course['id']);

        // Get instructor information
        final instructor = course['instructor'] as Map<String, dynamic>?;
        final instructorName = instructor?['name'] ?? 'Unknown Instructor';

        // Calculate course duration in hours from modules/sections
        final duration = await _calculateCourseDuration(course['id']);

        // Determine status based on is_verified column
        String status;
        final isVerified = course['is_verified'];
        if (isVerified == null) {
          status = 'pending';
        } else if (isVerified == true) {
          status = 'approved';
        } else {
          status = 'rejected';
        }

        courses.add({
          'id': course['id'],
          'title': course['title'],
          'description': course['description'],
          'instructor': instructorName,
          'instructorId': course['instructor_id'],
          'thumbnail': course['banner'] ?? '',
          'enrollmentCount': enrollmentCount,
          'status': status,
          'category': 'General', // Default category
          'createdAt': DateTime.parse(course['created_at']),
          'reportCount': 0, // Simplified - can be added later if needed
          'duration': duration,
          'rating': 0.0, // Simplified - can be added later if needed
          'price': course['price'] ?? 0.0,
          'isPaid': course['is_paid'] ?? false,
          'durationDays': course['duration_days'] ?? 0,
        });
      }

      return courses;
    } catch (e) {
      print('Error fetching courses for admin: $e');
      return [];
    }
  }

  // Get enrollment count for a specific course
  Future<int> _getEnrollmentCount(String courseId) async {
    try {
      final response = await _client
          .from('enrollments')
          .select('id')
          .eq('course_id', courseId);

      return (response as List).length;
    } catch (e) {
      print('Error fetching enrollment count: $e');
      return 0;
    }
  }

  // Calculate course duration from modules and sections
  Future<String> _calculateCourseDuration(String courseId) async {
    try {
      final modules = await _client
          .from('modules')
          .select('id')
          .eq('course_id', courseId);

      int totalMinutes = 0;
      for (var module in modules) {
        final sections = await _client
            .from('sections')
            .select('id, estimated_duration')
            .eq('module_id', module['id']);

        for (var section in sections) {
          totalMinutes +=
              (section['estimated_duration'] as int? ??
              30); // Default 30 minutes per section
        }
      }

      final hours = (totalMinutes / 60).round();
      return hours > 0 ? '$hours hours' : '${totalMinutes} minutes';
    } catch (e) {
      print('Error calculating course duration: $e');
      return '0 hours';
    }
  }

  // Fetch course details for preview/review
  Future<Map<String, dynamic>?> fetchCourseDetails(String courseId) async {
    try {
      final courseResponse = await _client
          .from('courses')
          .select('''
            *,
            instructor:users!instructor_id(id, name, email, profile_pic)
          ''')
          .eq('id', courseId)
          .single();

      final course = courseResponse;
      final instructor = course['instructor'] as Map<String, dynamic>?;

      // Get modules with sections and contents
      final modules = await _fetchModulesWithDetails(courseId);

      // Get enrollment statistics
      final enrollmentStats = await _getEnrollmentStatistics(courseId);

      return {
        'id': course['id'],
        'title': course['title'],
        'description': course['description'],
        'banner': course['banner'],
        'price': course['price'],
        'isPaid': course['is_paid'],
        'durationDays': course['duration_days'],
        'createdAt': DateTime.parse(course['created_at']),
        'status': course['status'] ?? 'pending',
        'category': course['category'] ?? 'General',
        'rating': course['rating'] ?? 0.0,
        'instructor': {
          'id': instructor?['id'],
          'name': instructor?['name'] ?? 'Unknown',
          'email': instructor?['email'] ?? '',
          'profilePic': instructor?['profile_pic'],
        },
        'modules': modules,
        'enrollmentStats': enrollmentStats,
      };
    } catch (e) {
      print('Error fetching course details: $e');
      return null;
    }
  }

  // Fetch modules with sections and contents
  Future<List<Map<String, dynamic>>> _fetchModulesWithDetails(
    String courseId,
  ) async {
    try {
      final modulesResponse = await _client
          .from('modules')
          .select('*')
          .eq('course_id', courseId)
          .order('order');

      final modules = modulesResponse as List<dynamic>;
      List<Map<String, dynamic>> modulesList = [];

      for (var moduleData in modules) {
        final module = moduleData as Map<String, dynamic>;

        // Get sections for this module
        final sectionsResponse = await _client
            .from('sections')
            .select('*')
            .eq('module_id', module['id'])
            .order('order');

        final sections = sectionsResponse as List<dynamic>;
        List<Map<String, dynamic>> sectionsList = [];

        for (var sectionData in sections) {
          final section = sectionData as Map<String, dynamic>;

          // Get contents for this section
          final contentsResponse = await _client
              .from('contents')
              .select('*')
              .eq('section_id', section['id'])
              .order('order');

          final contents = contentsResponse as List<dynamic>;

          sectionsList.add({
            'id': section['id'],
            'title': section['title'],
            'order': section['order'],
            'estimatedDuration': section['estimated_duration'] ?? 30,
            'contents': contents
                .map(
                  (content) => {
                    'id': content['id'],
                    'title': content['title'],
                    'type': content['type'],
                    'url': content['url'],
                    'order': content['order'],
                  },
                )
                .toList(),
          });
        }

        modulesList.add({
          'id': module['id'],
          'title': module['title'],
          'order': module['order'],
          'sections': sectionsList,
        });
      }

      return modulesList;
    } catch (e) {
      print('Error fetching modules with details: $e');
      return [];
    }
  }

  // Get enrollment statistics for a course
  Future<Map<String, dynamic>> _getEnrollmentStatistics(String courseId) async {
    try {
      final enrollments = await _client
          .from('enrollments')
          .select('*')
          .eq('course_id', courseId);

      final enrollmentData = enrollments as List<dynamic>;

      // Calculate statistics
      final totalEnrollments = enrollmentData.length;
      final completionRates = enrollmentData
          .map((e) => e['progress'] as double? ?? 0.0)
          .toList();
      final averageProgress = completionRates.isNotEmpty
          ? completionRates.reduce((a, b) => a + b) / completionRates.length
          : 0.0;

      // Get recent enrollments (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentEnrollments = enrollmentData.where((e) {
        final enrolledAt = DateTime.parse(e['enrolled_at']);
        return enrolledAt.isAfter(thirtyDaysAgo);
      }).length;

      return {
        'totalEnrollments': totalEnrollments,
        'averageProgress': averageProgress,
        'recentEnrollments': recentEnrollments,
        'completionRate': completionRates.where((rate) => rate >= 100.0).length,
      };
    } catch (e) {
      print('Error fetching enrollment statistics: $e');
      return {
        'totalEnrollments': 0,
        'averageProgress': 0.0,
        'recentEnrollments': 0,
        'completionRate': 0,
      };
    }
  }

  // Update course status using is_verified column (approve, reject)
  Future<bool> updateCourseStatus(
    String courseId,
    String status, {
    String? reason,
  }) async {
    try {
      // Convert status to is_verified boolean value
      bool? isVerified;
      switch (status.toLowerCase()) {
        case 'approved':
          isVerified = true;
          break;
        case 'rejected':
          isVerified = false;
          break;
        case 'pending':
          isVerified = null;
          break;
        default:
          throw Exception('Invalid status: $status');
      }

      await _client
          .from('courses')
          .update({
            'is_verified': isVerified,
          })
          .eq('id', courseId);

      return true;
    } catch (e) {
      print('Error updating course status: $e');
      return false;
    }
  }

  // Log admin actions for audit trail
  Future<void> _logAdminAction(
    String courseId,
    String action,
    String? reason,
  ) async {
    try {
      final adminId = _client.auth.currentUser?.id;
      if (adminId != null) {
        await _client.from('admin_actions').insert({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'admin_id': adminId,
          'course_id': courseId,
          'action': action,
          'reason': reason,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error logging admin action: $e');
    }
  }

  // Delete course and all related data
  Future<bool> deleteCourse(String courseId) async {
    try {
      // Delete in reverse order of dependencies

      // 1. Delete contents
      final sections = await _client
          .from('sections')
          .select('id')
          .eq('module_id', courseId);

      for (var section in sections) {
        await _client.from('contents').delete().eq('section_id', section['id']);
      }

      // 2. Delete sections
      final modules = await _client
          .from('modules')
          .select('id')
          .eq('course_id', courseId);

      for (var module in modules) {
        await _client.from('sections').delete().eq('module_id', module['id']);
      }

      // 3. Delete modules
      await _client.from('modules').delete().eq('course_id', courseId);

      // 4. Delete enrollments
      await _client.from('enrollments').delete().eq('course_id', courseId);

      // 5. Delete course reports
      await _client.from('course_reports').delete().eq('course_id', courseId);

      // 6. Finally delete the course
      await _client.from('courses').delete().eq('id', courseId);

      // Log the deletion
      await _logAdminAction(courseId, 'delete', 'Course deleted by admin');

      return true;
    } catch (e) {
      print('Error deleting course: $e');
      return false;
    }
  }

  // Get courses by status for filtering
  Future<List<Map<String, dynamic>>> fetchCoursesByStatus(String status) async {
    try {
      final allCourses = await fetchAllCoursesForAdmin();
      return allCourses.where((course) => course['status'] == status).toList();
    } catch (e) {
      print('Error fetching courses by status: $e');
      return [];
    }
  }

  // Search courses by title, instructor, or category
  Future<List<Map<String, dynamic>>> searchCourses(String query) async {
    try {
      final allCourses = await fetchAllCoursesForAdmin();
      final lowercaseQuery = query.toLowerCase();

      return allCourses.where((course) {
        final title = (course['title'] as String).toLowerCase();
        final instructor = (course['instructor'] as String).toLowerCase();
        final category = (course['category'] as String).toLowerCase();

        return title.contains(lowercaseQuery) ||
            instructor.contains(lowercaseQuery) ||
            category.contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      print('Error searching courses: $e');
      return [];
    }
  }

  // Get admin dashboard statistics
  Future<Map<String, dynamic>> getAdminDashboardStats() async {
    try {
      final allCourses = await fetchAllCoursesForAdmin();

      final pendingCourses = allCourses
          .where((c) => c['status'] == 'pending')
          .length;
      final approvedCourses = allCourses
          .where((c) => c['status'] == 'approved')
          .length;
      final rejectedCourses = allCourses
          .where((c) => c['status'] == 'rejected')
          .length;
      final flaggedCourses = allCourses
          .where((c) => c['status'] == 'flagged')
          .length;

      final totalEnrollments = allCourses.fold<int>(
        0,
        (sum, course) => sum + (course['enrollmentCount'] as int),
      );
      final totalReports = allCourses.fold<int>(
        0,
        (sum, course) => sum + (course['reportCount'] as int),
      );

      return {
        'totalCourses': allCourses.length,
        'pendingCourses': pendingCourses,
        'approvedCourses': approvedCourses,
        'rejectedCourses': rejectedCourses,
        'flaggedCourses': flaggedCourses,
        'totalEnrollments': totalEnrollments,
        'totalReports': totalReports,
      };
    } catch (e) {
      print('Error fetching admin dashboard stats: $e');
      return {
        'totalCourses': 0,
        'pendingCourses': 0,
        'approvedCourses': 0,
        'rejectedCourses': 0,
        'flaggedCourses': 0,
        'totalEnrollments': 0,
        'totalReports': 0,
      };
    }
  }

  // Bulk update course statuses
  Future<bool> bulkUpdateCourseStatus(
    List<String> courseIds,
    String status, {
    String? reason,
  }) async {
    try {
      for (String courseId in courseIds) {
        await updateCourseStatus(courseId, status, reason: reason);
      }
      return true;
    } catch (e) {
      print('Error bulk updating course status: $e');
      return false;
    }
  }
}
