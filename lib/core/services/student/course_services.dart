import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/course.dart';
import '../../../data/models/module.dart';
import '../../../data/models/section.dart';
import '../../../data/models/content.dart';
import '../../../data/models/enrollment.dart';

class CourseServices {
  final _client = Supabase.instance.client;

  Future<List<Course>> fetchAllCourses() async {
    try {
      final response = await _client
          .from('courses')
          .select()
          .order('created_at', ascending: false);
      final data = response as List<dynamic>? ?? [];
      return data
          .map((course) => Course.fromMap(course as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  Future<List<Enrollment>> fetchUserEnrollments(String studentId) async {
    try {
      final response = await _client
          .from('enrollments')
          .select()
          .eq('student_id', studentId);
      final data = response as List<dynamic>? ?? [];
      return data
          .map((e) => Enrollment(
                id: e['id'],
                studentId: e['student_id'],
                courseId: e['course_id'],
                enrolledAt: DateTime.parse(e['enrolled_at']),
                progress: (e['progress'] as num?)?.toDouble() ?? 0.0,
              ))
          .toList();
    } catch (e) {
      print('Error fetching enrollments: $e');
      return [];
    }
  }

  Future<List<String>> fetchCompletedCourseIds(String studentId) async {
    try {
      final response = await _client
          .from('certificates')
          .select('course_id')
          .eq('student_id', studentId);
      final data = response as List<dynamic>? ?? [];
      return data.map((e) => e['course_id'] as String).toList();
    } catch (e) {
      print('Error fetching completed course IDs: $e');
      return [];
    }
  }

  Future<List<Course>> fetchCompletedCourses(String studentId) async {
    final completedIds = await fetchCompletedCourseIds(studentId);
    final allCourses = await fetchAllCourses();
    return allCourses.where((c) => completedIds.contains(c.id)).toList();
  }

  Future<List<Course>> fetchOngoingCourses(String studentId) async {
    final enrollments = await fetchUserEnrollments(studentId);
    final enrolledCourseIds = enrollments.map((e) => e.courseId).toSet();
    final completedCourseIds = await fetchCompletedCourseIds(studentId);
    final ongoingIds = enrolledCourseIds.difference(completedCourseIds.toSet());
    final allCourses = await fetchAllCourses();
    return allCourses.where((c) => ongoingIds.contains(c.id)).toList();
  }

  Future<List<Course>> fetchAllStudentCourses(String studentId) async {
    final enrolled = await fetchUserEnrollments(studentId);
    final completed = await fetchCompletedCourseIds(studentId);
    final ids = enrolled.map((e) => e.courseId).toSet().union(completed.toSet());
    final allCourses = await fetchAllCourses();
    return allCourses.where((c) => ids.contains(c.id)).toList();
  }

  Future<Course?> fetchCourseById(String courseId) async {
    final response = await _client
        .from('courses')
        .select()
        .eq('id', courseId)
        .single();
    return Course.fromMap(response);
  }

  Future<List<Module>> fetchModules(String courseId) async {
    final response = await _client
        .from('modules')
        .select()
        .eq('course_id', courseId);
    final data = response as List<dynamic>? ?? [];
    return data.map((m) => Module.fromMap(m as Map<String, dynamic>)).toList();
  }

  Future<List<Section>> fetchSections(String moduleId) async {
    final response = await _client
        .from('sections')
        .select()
        .eq('module_id', moduleId);
    final data = response as List<dynamic>? ?? [];
    return data.map((s) => Section.fromMap(s as Map<String, dynamic>)).toList();
  }

  Future<List<Content>> fetchContents(String sectionId) async {
    final response = await _client
        .from('contents')
        .select()
        .eq('section_id', sectionId);
    final data = response as List<dynamic>? ?? [];
    return data.map((c) => Content.fromMap(c as Map<String, dynamic>)).toList();
  }

  Future<void> enrollCourse(String userId, String courseId) async {
    final uuid = Uuid();
    await _client.from('enrollments').insert({
      'id': uuid.v4(),
      'student_id': userId,
      'course_id': courseId,
      'enrolled_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Course>> fetchRecentLearningCourses(String studentId) async {
    final enrollments = await fetchUserEnrollments(studentId);
    final enrolledCourseIds = enrollments.map((e) => e.courseId).toSet();
    final allCourses = await fetchAllCourses();
    return allCourses.where((c) => enrolledCourseIds.contains(c.id)).toList();
  }

  /// New: Recommendation Algorithm
  Future<List<Course>> fetchRecommendedCourses(String studentId) async {
    try {
      // Step 1: Get user's chosen tags
      final studentTagsResponse = await _client
          .from('student_tags')
          .select('tag_id')
          .eq('student_id', studentId);
      final studentTagIds = (studentTagsResponse as List<dynamic>)
          .map((e) => e['tag_id'] as String)
          .toSet();

      if (studentTagIds.isEmpty) {
        // No chosen tags, fallback to non-enrolled courses
        return _fallbackRecommendations(studentId);
      }

      // Step 2: Get courses matching those tags
      final matchingCoursesResponse = await _client
          .from('course_tags')
          .select('course_id, tag_id')
          .inFilter('tag_id', studentTagIds.toList());

      // Count matching tags per course
      final Map<String, int> courseMatchCount = {};
      for (var row in matchingCoursesResponse as List<dynamic>) {
        final courseId = row['course_id'] as String;
        courseMatchCount[courseId] = (courseMatchCount[courseId] ?? 0) + 1;
      }

      if (courseMatchCount.isEmpty) {
        return _fallbackRecommendations(studentId);
      }

      // Step 3: Exclude already enrolled courses
      final enrollments = await fetchUserEnrollments(studentId);
      final enrolledCourseIds = enrollments.map((e) => e.courseId).toSet();

      final sortedCourseIds = courseMatchCount.entries
          .where((e) => !enrolledCourseIds.contains(e.key))
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value)); // Desc by match count

      // Step 4: Fetch course details
      final courseIds = sortedCourseIds.map((e) => e.key).toList();
      if (courseIds.isEmpty) return [];

      final coursesResponse = await _client
          .from('courses')
          .select()
          .inFilter('id', courseIds);

      final allCourses = (coursesResponse as List<dynamic>)
          .map((course) => Course.fromMap(course as Map<String, dynamic>))
          .toList();

      // Order by match count
      allCourses.sort((a, b) =>
          (courseMatchCount[b.id] ?? 0).compareTo(courseMatchCount[a.id] ?? 0));

      return allCourses;
    } catch (e) {
      print('Error fetching recommended courses: $e');
      return _fallbackRecommendations(studentId);
    }
  }

  /// Fallback: Return all courses not enrolled by the user
  Future<List<Course>> _fallbackRecommendations(String studentId) async {
    final allCourses = await fetchAllCourses();
    final enrollments = await fetchUserEnrollments(studentId);
    final enrolledCourseIds = enrollments.map((e) => e.courseId).toSet();
    return allCourses
        .where((course) => !enrolledCourseIds.contains(course.id))
        .toList();
  }
}
