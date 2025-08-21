


import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class CourseService {
  /// Upload course banner image to Supabase Storage (bucket: course-banner)
  Future<String?> uploadBannerToStorage({String? filePath, Uint8List? bytes, required String fileName}) async {
    // Sanitize filename: replace spaces and special chars with underscores
    String safeFileName = fileName.replaceAll(RegExp(r'[\s\[\]\(\)]+'), '_');
    safeFileName = safeFileName.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '');
    dynamic response;
    if (kIsWeb) {
      if (bytes == null) return null;
      response = await supabase.storage.from('course-banner').uploadBinary(safeFileName, bytes, fileOptions: const FileOptions(upsert: true));
    } else {
      if (filePath == null) return null;
      final file = io.File(filePath);
      response = await supabase.storage.from('course-banner').upload(safeFileName, file, fileOptions: const FileOptions(upsert: true));
    }
    if (response == null || (response is String && response.isEmpty)) {
      return null;
    }
    // Get public URL
    final publicUrl = supabase.storage.from('course-banner').getPublicUrl(safeFileName);
    return publicUrl;
  }

  /// Batch create a course with multiple chapters (modules), lessons (sections), and PDFs (contents)
  /// [courseData] contains: title, description, price, durationDays, tag
  /// [chapters] is a list of maps: { 'title': chapterName, 'lessons': [ { 'title': ..., 'description': ..., 'pdf': { 'fileName': ..., 'filePath' or 'bytes': ... } } ] }
  Future<Map<String, dynamic>?> createFullCourse({
    required Map<String, dynamic> courseData,
    required List<Map<String, dynamic>> chapters,
  }) async {
    final instructorId = await getInstructorId();
    if (instructorId == null) return null;
    final courseId = uuid.v4();
    // Upload banner image if provided
    String? bannerUrl;
    if (courseData['banner'] != null) {
      final banner = courseData['banner'] as Map<String, dynamic>;
      if (kIsWeb && banner['bytes'] != null) {
        bannerUrl = await uploadBannerToStorage(bytes: banner['bytes'], fileName: banner['name']);
      } else if (!kIsWeb && banner['path'] != null) {
        bannerUrl = await uploadBannerToStorage(filePath: banner['path'], fileName: banner['name']);
      }
    }
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
      if (bannerUrl != null) 'banner': bannerUrl,
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

    // Track section ids per chapter so the caller can map them back to in-memory models
    final List<List<String>> sectionIdsByChapter = [];
    // Insert chapters (modules)
    for (int c = 0; c < chapters.length; c++) {
      final chapter = chapters[c];
  final moduleId = uuid.v4();
  await supabase.from('modules').insert({
        'id': moduleId,
        'course_id': courseId,
        'title': chapter['title'],
        'order': c + 1,
  }).select('id').single();
      // Remove null check: always continue to insert sections

      // Insert lessons (sections)
      final lessons = chapter['lessons'] as List<Map<String, dynamic>>;
      final List<String> sectionIdsForThisChapter = [];
      for (int l = 0; l < lessons.length; l++) {
        final lesson = lessons[l];
  final sectionId = uuid.v4();
  await supabase.from('sections').insert({
          'id': sectionId,
          'module_id': moduleId,
          'title': lesson['title'],
          'description': lesson['description'],
          'order': l + 1,
  }).select('id').single();
        sectionIdsForThisChapter.add(sectionId);
        // Remove null check: always continue to insert PDF content

        // Insert PDF content if provided
        if (lesson['pdf'] != null) {
          final pdf = lesson['pdf'] as Map<String, dynamic>;
          // Always generate a unique filename for each section
          String uniqueFileName = pdf['fileName'];
          // Use the actual filename only, no unique suffix
          String actualFileName = pdf['fileName'];
          // Sanitize filename
          uniqueFileName = uniqueFileName.replaceAll(RegExp(r'[\s\[\]\(\)]+'), '_');
          uniqueFileName = uniqueFileName.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '');
          // Append sectionId to ensure uniqueness
          uniqueFileName = uniqueFileName.replaceAll('.pdf', '_$sectionId.pdf');
          actualFileName = actualFileName.replaceAll(RegExp(r'[\s\[\]\(\)]+'), '_');
          actualFileName = actualFileName.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '');
          String? publicUrl;
          if (kIsWeb && pdf['bytes'] != null) {
            publicUrl = await uploadPdfToStorage(bytes: pdf['bytes'], fileName: uniqueFileName);
            publicUrl = await uploadPdfToStorage(bytes: pdf['bytes'], fileName: actualFileName);
          } else if (!kIsWeb && pdf['filePath'] != null) {
            publicUrl = await uploadPdfToStorage(filePath: pdf['filePath'], fileName: uniqueFileName);
            publicUrl = await uploadPdfToStorage(filePath: pdf['filePath'], fileName: actualFileName);
          }
          // Always insert, even if publicUrl is the same as another section
          if (publicUrl != null) {
            await supabase.from('contents').insert({
              'id': uuid.v4(),
              'section_id': sectionId,
              'type': 'pdf',
              'title': pdf['fileName'],
              'url': publicUrl,
              'order': 1,
            }).select('id').single();
          }
        }
      }
      sectionIdsByChapter.add(sectionIdsForThisChapter);
    }
    return {
      'course_id': courseId,
      'section_ids': sectionIdsByChapter,
    };
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
    // Sanitize filename: replace spaces and special chars with underscores
    String safeFileName = fileName.replaceAll(RegExp(r'[\s\[\]\(\)]+'), '_');
    safeFileName = safeFileName.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '');

    // Check if file already exists in Supabase Storage
    final existing = await supabase.storage.from('content-pdf').list(path: '').then((files) => files.where((f) => f.name == safeFileName).toList());
    if (existing.isNotEmpty) {
      // File already exists, just return its public URL
      return supabase.storage.from('content-pdf').getPublicUrl(safeFileName);
    }

    dynamic response;
    if (kIsWeb) {
      if (bytes == null) return null;
      response = await supabase.storage.from('content-pdf').uploadBinary(safeFileName, bytes, fileOptions: const FileOptions(upsert: true));
    } else {
      if (filePath == null) return null;
      final file = io.File(filePath);
      response = await supabase.storage.from('content-pdf').upload(safeFileName, file, fileOptions: const FileOptions(upsert: true));
    }
    if (response == null || (response is String && response.isEmpty)) {
      return null;
    }
    // Get public URL
    final publicUrl = supabase.storage.from('content-pdf').getPublicUrl(safeFileName);
    return publicUrl;
  }


  Future<String?> createCourse({
    required String title,
    required String description,
    required double price,
    required int durationDays,
    String? tag, // New: tag name to insert and link
    Map<String, dynamic>? banner, // optional banner map: { 'name', 'bytes'|'path' }
  }) async {
    final instructorId = await getInstructorId();
    if (instructorId == null) return null;
    final courseId = uuid.v4();
    // Upload banner if provided
    String? bannerUrl;
    if (banner != null) {
      if (kIsWeb && banner['bytes'] != null) {
        bannerUrl = await uploadBannerToStorage(bytes: banner['bytes'], fileName: banner['name']);
      } else if (!kIsWeb && banner['path'] != null) {
        bannerUrl = await uploadBannerToStorage(filePath: banner['path'], fileName: banner['name']);
      }
    }
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
      if (bannerUrl != null) 'banner': bannerUrl,
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
  
  /// Fetch tag names that start with the provided prefix (case-insensitive)
  Future<List<String>> fetchTagsByPrefix(String prefix, {int limit = 10}) async {
    final q = prefix.trim();
    if (q.isEmpty) return [];
    final resp = await supabase
        .from('tags')
        .select('name')
        .ilike('name', '$q%')
        .order('name')
        .limit(limit);
    final list = List.from(resp as List? ?? []);
    final names = list.map((e) => (e as Map)['name'] as String).toSet().toList();
    return names;
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
