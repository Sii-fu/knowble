import 'package:supabase_flutter/supabase_flutter.dart';

class CourseFetchService {
  final supabase = Supabase.instance.client;

  // Fetch all modules (chapters), sections (lessons), and contents for a course by courseId
  Future<List<Map<String, dynamic>>> fetchCourseModulesWithSectionsAndContents(String courseId) async {
    // Fetch modules (chapters)
    final modules = await supabase
        .from('modules')
        .select('id, title, "order"')
        .eq('course_id', courseId)
        .order('order');
 
    List<Map<String, dynamic>> moduleList = [];
    for (final module in modules) {
      // Fetch sections (lessons)
      final sections = await supabase
          .from('sections')
          .select('id, title, description, "order"')
          .eq('module_id', module['id'])
          .order('order');

      List<Map<String, dynamic>> sectionList = [];
      for (final section in sections) {
        // Fetch contents (PDFs, etc)
        final contents = await supabase
            .from('contents')
            .select('id, type, title, url, "order"')
            .eq('section_id', section['id'])
            .order('order');

        sectionList.add({
          'id': section['id'],
          'title': section['title'],
          'description': section['description'],
          'order': section['order'],
          'contents': contents,
        });
      }
      moduleList.add({
        'id': module['id'],
        'title': module['title'],
        'order': module['order'],
        'sections': sectionList,
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

    // Fetch modules (chapters)
    final modules = await supabase
        .from('modules')
        .select('id, title, "order"')
        .eq('course_id', courseId)
        .order('order');

    List<Map<String, dynamic>> chapters = [];
    for (final module in modules) {
      // Fetch sections (lessons)
      final sections = await supabase
          .from('sections')
          .select('id, title, description, "order"')
          .eq('module_id', module['id'])
          .order('order');

      List<Map<String, dynamic>> lessons = [];
      for (final section in sections) {
        // Fetch contents (PDFs, etc)
        final contents = await supabase
            .from('contents')
            .select('id, type, title, url, "order"')
            .eq('section_id', section['id'])
            .order('order');

        lessons.add({
          'id': section['id'],
          'title': section['title'],
          'description': section['description'],
          'order': section['order'],
          'contents': contents,
        });
      }
      chapters.add({
        'id': module['id'],
        'title': module['title'],
        'order': module['order'],
        'lessons': lessons,
      });
    }
    return {
      'id': course['id'],
      'title': course['title'],
      'description': course['description'],
      'duration_days': course['duration_days'],
      'banner': course['banner'],
      'chapters': chapters,
    };
  }
}

