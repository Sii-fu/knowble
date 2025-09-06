
import 'package:supabase_flutter/supabase_flutter.dart';
// ...existing code...
// Helper to get public URL for a file in Supabase Storage
String getPublicPdfUrl(String storagePath) {
  final supabase = Supabase.instance.client;
  // Use the correct bucket name 'content-pdf'
  return supabase.storage.from('content-pdf').getPublicUrl(storagePath);
}

class CourseFetchService {
  final supabase = Supabase.instance.client;

  // Fetch all modules (chapters), sections (lessons), and contents for a course by courseId
  Future<List<Map<String, dynamic>>> fetchCourseModulesWithSectionsAndContents(String courseId) async {
    // Use a nested select to fetch modules with their sections and contents in one round-trip
    final modules = await supabase
        .from('modules')
        .select('''
          id,
          title,
          "order",
          sections (
            id,
            title,
            description,
            "order",
            contents (id, type, title, url, "order")
          )
        ''')
        .eq('course_id', courseId)
        .order('order');

  // Defensive: convert to a Dart List and sort modules by their "order" field
  final moduleList = <Map<String, dynamic>>[];
  final modulesData = List.from(modules as List? ?? []);
  modulesData.sort((a, b) => ((a['order'] ?? 0) as int).compareTo(((b['order'] ?? 0) as int)));

    for (final m in modulesData) {
      final secs = <Map<String, dynamic>>[];
      // Defensive: sort sections by their "order" before processing
      final rawSecs = List.from(m['sections'] as List? ?? []);
      rawSecs.sort((a, b) => ((a['order'] ?? 0) as int).compareTo(((b['order'] ?? 0) as int)));
      for (final s in rawSecs) {
        secs.add({
          'id': s['id'],
          'title': s['title'],
          'description': s['description'],
          'order': s['order'],
          'contents': (s['contents'] as List? ?? []).map((c) => {
                'id': c['id'],
                'type': c['type'],
                'title': c['title'],
                'url': c['type'] == 'pdf' && c['storage_path'] != null
                  ? getPublicPdfUrl(c['storage_path'])
                  : c['url'],
                'order': c['order'],
              }).toList(),
        });
      }
      moduleList.add({
        'id': m['id'],
        'title': m['title'],
        'order': m['order'],
        'sections': secs,
      });
    }
    return moduleList;
  }

  /// Fetches all courses for the current instructor, including modules, sections, and contents (PDFs)
  Future<List<Map<String, dynamic>>> fetchInstructorCoursesFull() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];
    // Fetch all courses for the authenticated instructor (with duration_days)
    final coursesResp = await supabase
      .from('courses')
      .select('''
        id,
        title,
        description,
        duration_days,  
        course_tags (
          tags (
            name
          )
        ),
        enrollments (
          id
        )
      ''')
      .eq('instructor_id', user.id)
      .order('created_at', ascending: false);

    // Defensive cast: ensure we return an empty list if the response is null
    return List<Map<String, dynamic>>.from(coursesResp as List? ?? []);
  }

  /// Fetches full details for a single course (modules, sections, contents)
  Future<Map<String, dynamic>?> fetchCourseDetail(String courseId) async {
    // Fetch course info including banner
    final course = await supabase
        .from('courses')
        .select('id, title, description, duration_days, banner')
        .eq('id', courseId)
        .maybeSingle();
    if (course == null) return null;
    // Use nested select to fetch modules -> sections -> contents in a single request
    final modules = await supabase
        .from('modules')
        .select('''
          id,
          title,
          "order",
          sections (
            id,
            title,
            description,
            "order",
            contents (id, type, title, url, "order")
          )
        ''')
        .eq('course_id', courseId)
        .order('order');

  final chaptersList = <Map<String, dynamic>>[];

    // Defensive: convert to a Dart List and sort modules by their "order" field
    final modulesData2 = List.from(modules as List? ?? []);
    modulesData2.sort((a, b) => ((a['order'] ?? 0) as int).compareTo(((b['order'] ?? 0) as int)));

    for (final m in modulesData2) {
      final rawSecs = List.from(m['sections'] as List? ?? []);
      // Defensive: sort sections by their "order" before processing
      rawSecs.sort((a, b) => ((a['order'] ?? 0) as int).compareTo(((b['order'] ?? 0) as int)));
      final lessons = <Map<String, dynamic>>[];
      for (final s in rawSecs) {
        lessons.add({
          'id': s['id'],
          'title': s['title'],
          'description': s['description'],
          'order': s['order'],
          'contents': (s['contents'] as List? ?? []).map((c) => {
                'id': c['id'],
                'type': c['type'],
                'title': c['title'],
                'url': c['type'] == 'pdf' && c['storage_path'] != null
                    ? getPublicPdfUrl(c['storage_path'])
                    : c['url'],
                'order': c['order'],
              }).toList(),
        });
      }
      chaptersList.add({
        'id': m['id'],
        'title': m['title'],
        'order': m['order'],
        'lessons': lessons,
      });
    }

    return {
      'id': course['id'],
      'title': course['title'],
      'description': course['description'],
      'duration_days': course['duration_days'],
      'banner': course['banner'],
      'chapters': chaptersList,
    };
  }
}

