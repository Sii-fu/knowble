import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/course.dart';
import '../../../data/models/module.dart';
import '../../../data/models/section.dart';
import '../../../data/models/content.dart';
import '../../../data/models/enrollment.dart';

class CourseServices {
  final _client = Supabase.instance.client;

  Future<List<Course>> fetchAllCourses() async {
    final response = await _client
        .from('courses')
        .select()
        .order('created_at', ascending: false);
    final data = response as List<dynamic>? ?? [];
    return data
        .map((course) => Course.fromMap(course as Map<String, dynamic>))
        .toList();
  }

  Future<List<Enrollment>> fetchUserEnrollments(String studentId) async {
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
    if (response == null) return null;
    return Course.fromMap(response as Map<String, dynamic>);
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
}