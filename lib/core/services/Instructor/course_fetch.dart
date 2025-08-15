import 'package:supabase_flutter/supabase_flutter.dart';

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

  final moduleList = <Map<String, dynamic>>[];

    for (final m in modules as List) {
      final secs = <Map<String, dynamic>>[];
      final rawSecs = m['sections'] as List? ?? [];
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
                'url': c['url'],
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
    // Fetch all courses for this instructor (with duration_days)
    final courses = await supabase
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
      .eq('instructor_id', 'c2e56f95-6eb7-40fe-90c4-f0a36e428a39')
      .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(courses);
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

    for (final m in modules as List) {
      final rawSecs = m['sections'] as List? ?? [];
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
                'url': c['url'],
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

