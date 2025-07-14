
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class CourseService {
  final supabase = Supabase.instance.client;
  final uuid = const Uuid();

  Future<List<Map<String, dynamic>>> fetchInstructorCourses() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];
    final response = await supabase
        .from('courses')
        .select('id, title, duration_days')
        .eq('instructor_id', user.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<String?> uploadPdfToStorage({String? filePath, Uint8List? bytes, required String fileName}) async {
    dynamic response;
    if (kIsWeb) {
      if (bytes == null) return null;
      response = await supabase.storage.from('content-pdf').uploadBinary(fileName, bytes, fileOptions: const FileOptions(upsert: true));
    } else {
      if (filePath == null) return null;
      final file = io.File(filePath);
      response = await supabase.storage.from('content-pdf').upload(fileName, file, fileOptions: const FileOptions(upsert: true));
    }
    if (response == null || (response is String && response.isEmpty)) {
      return null;
    }
    // Get public URL
    final publicUrl = supabase.storage.from('content-pdf').getPublicUrl(fileName);
    return publicUrl;
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


  Future<String?> getInstructorId() async {
    final user = supabase.auth.currentUser;
    return user?.id;
  }

  Future<String?> createContent({
    required String sectionId,
    required String type, // 'pdf', 'video', 'link'
    required String url,
    required int order,
  }) async {
    final contentId = uuid.v4();
    final response = await supabase.from('contents').insert({
      'id': contentId,
      'section_id': sectionId,
      'type': type,
      'url': url,
      'order': order,
      'created_at': DateTime.now().toIso8601String(),
    }).select('id').single();
    if (response['id'] == null) return null;
    return contentId;
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
  }) async {
    final sectionId = uuid.v4();
    final response = await supabase.from('sections').insert({
      'id': sectionId,
      'module_id': moduleId,
      'title': title,
      'order': order,
    }).select('id').single();
    if (response['id'] == null) return null;
    return sectionId;
  }
}
