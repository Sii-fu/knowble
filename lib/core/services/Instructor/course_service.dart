
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class CourseService {

  /// Batch create a course with multiple chapters (modules), lessons (sections), and PDFs (contents)
  /// [courseData] contains: title, description, price, durationDays, tag
  /// [chapters] is a list of maps: { 'title': chapterName, 'lessons': [ { 'title': ..., 'description': ..., 'pdf': { 'fileName': ..., 'filePath' or 'bytes': ... } } ] }
  Future<String?> createFullCourse({
    required Map<String, dynamic> courseData,
    required List<Map<String, dynamic>> chapters,
  }) async {
    final instructorId = await getInstructorId();
    if (instructorId == null) return null;
    final courseId = uuid.v4();
    // Insert course
    final response = await supabase.from('courses').insert({
      'id': courseId,
      'instructor_id': instructorId,
      'title': courseData['title'],
      'description': courseData['description'],
      'price': courseData['price'],
      'is_paid': (courseData['price'] ?? 0) > 0,
      'duration_days': courseData['durationDays'],
      'created_at': DateTime.now().toIso8601String(),
    }).select('id').single();
    if (response['id'] == null) return null;

    // Insert tag if provided
    if (courseData['tag'] != null && (courseData['tag'] as String).trim().isNotEmpty) {
      final tag = courseData['tag'].trim();
      final tagQuery = await supabase.from('tags').select('id').eq('name', tag).maybeSingle();
      String tagId;
      if (tagQuery != null && tagQuery['id'] != null) {
        tagId = tagQuery['id'] as String;
      } else {
        tagId = uuid.v4();
        await supabase.from('tags').insert({ 'id': tagId, 'name': tag });
      }
      await supabase.from('course_tags').insert({
        'course_id': courseId,
        'tag_id': tagId,
        'primary': true,
        'note': null,
      });
    }

    // Insert chapters (modules)
    for (int c = 0; c < chapters.length; c++) {
      final chapter = chapters[c];
      final moduleId = uuid.v4();
      await supabase.from('modules').insert({
        'id': moduleId,
        'course_id': courseId,
        'title': chapter['title'],
        'order': c + 1,
      });

      // Insert lessons (sections)
      final lessons = chapter['lessons'] as List<Map<String, dynamic>>;
      for (int l = 0; l < lessons.length; l++) {
        final lesson = lessons[l];
        final sectionId = uuid.v4();
        await supabase.from('sections').insert({
          'id': sectionId,
          'module_id': moduleId,
          'title': lesson['title'],
          'description': lesson['description'],
          'order': l + 1,
        });

        // Insert PDF content if provided
        if (lesson['pdf'] != null) {
          final pdf = lesson['pdf'] as Map<String, dynamic>;
          String? publicUrl;
          if (kIsWeb && pdf['bytes'] != null) {
            publicUrl = await uploadPdfToStorage(bytes: pdf['bytes'], fileName: pdf['fileName']);
          } else if (!kIsWeb && pdf['filePath'] != null) {
            publicUrl = await uploadPdfToStorage(filePath: pdf['filePath'], fileName: pdf['fileName']);
          }
          if (publicUrl != null) {
            await supabase.from('contents').insert({
              'id': uuid.v4(),
              'section_id': sectionId,
              'type': 'pdf',
              'title': pdf['fileName'],
              'url': publicUrl,
              'order': 1,
            });
          }
        }
      }
    }
    return courseId;
  }
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
    String? tag, // New: tag name to insert and link
  }) async {
    final instructorId = await getInstructorId();
    if (instructorId == null) return null;
    final courseId = uuid.v4();
    // Insert course
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

    // Insert tag if provided
    if (tag != null && tag.trim().isNotEmpty) {
      // Try to find existing tag
      final tagQuery = await supabase.from('tags').select('id').eq('name', tag.trim()).maybeSingle();
      String tagId;
      if (tagQuery != null && tagQuery['id'] != null) {
        tagId = tagQuery['id'] as String;
      } else {
        // Insert new tag
        tagId = uuid.v4();
        await supabase.from('tags').insert({
          'id': tagId,
          'name': tag.trim(),
        });
      }
      // Insert into course_tags
      await supabase.from('course_tags').insert({
        'course_id': courseId,
        'tag_id': tagId,
        'primary': true,
        'note': null,
      });
    }
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
