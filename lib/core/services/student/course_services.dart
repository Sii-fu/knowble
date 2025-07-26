import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/course.dart';
import '../../../data/models/module.dart';
import '../../../data/models/section.dart';
import '../../../data/models/content.dart';
import '../../../data/models/enrollment.dart';

class CourseServices {
  Future<List<Course>> fetchRecentLearningCourses(String studentId) async {
    final enrollments = await fetchUserEnrollments(studentId);
    final enrolledCourseIds = enrollments.map((e) => e.courseId).toSet();
    final allCourses = await fetchAllCourses();
    return allCourses.where((c) => enrolledCourseIds.contains(c.id)).toList();
  }
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

  Future<List<Course>> fetchRecommendedCourses(String studentId) async {
    final allCourses = await fetchAllCourses();
    final enrollments = await fetchUserEnrollments(studentId);
    final enrolledCourseIds = enrollments.map((e) => e.courseId).toSet();
    return allCourses
        .where((course) => !enrolledCourseIds.contains(course.id))
        .toList();
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
}