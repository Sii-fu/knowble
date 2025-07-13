import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class CourseService {
  final supabase = Supabase.instance.client;
  final uuid = const Uuid();

  Future<String?> getInstructorId() async {
    final user = supabase.auth.currentUser;
    return user?.id;
  }

  Future<String?> createCourse({
    required String title,
    required String description,
    required double price,
    required int durationDays,
  }) async {
    final instructorId = await getInstructorId();
    if (instructorId == null) return null;
    final courseId = uuid.v4();
    final response = await supabase.from('courses').insert({
      'id': courseId,
      'instructor_id': instructorId,
      'title': title,
      'description': description,
      'price': price,
      'is_paid': price > 0,
      'duration_days': durationDays,
      'created_at': DateTime.now().toIso8601String(),
    }).select('id').single();
    if (response['id'] == null) return null;
    return courseId;
  }

  Future<String?> createModule({
    required String courseId,
    required String title,
    required int order,
  }) async {
    final moduleId = uuid.v4();
    final response = await supabase.from('modules').insert({
      'id': moduleId,
      'course_id': courseId,
      'title': title,
      'order': order,
    }).select('id').single();
    if (response['id'] == null) return null;
    return moduleId;
  }

  Future<String?> createSection({
    required String moduleId,
    required String title,
    required int order,
    String? description,
  }) async {
    final sectionId = uuid.v4();
    final response = await supabase.from('sections').insert({
      'id': sectionId,
      'module_id': moduleId,
      'title': title,
      'description': description ?? '',
      'order': order,
    }).select('id').single();
    if (response['id'] == null) return null;
    return sectionId;
  }
}
