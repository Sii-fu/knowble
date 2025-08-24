import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class EditCourseService {
  final SupabaseClient supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  /// Update only provided fields on courses table.
  Future<bool> updateCourseBasic({
    required String courseId,
    String? title,
    String? description,
    double? price,
    int? durationDays,
    String? bannerUrl,
  }) async {
    final updateMap = <String, dynamic>{};
    if (title != null) updateMap['title'] = title;
    if (description != null) updateMap['description'] = description;
    if (price != null) {
      updateMap['price'] = price;
      updateMap['is_paid'] = price > 0;
    }
    if (durationDays != null) updateMap['duration_days'] = durationDays;
    if (bannerUrl != null) updateMap['banner'] = bannerUrl;

    if (updateMap.isEmpty) return true;
    final res = await supabase.from('courses').update(updateMap).eq('id', courseId).select().maybeSingle();
    return res != null;
  }

  /// Update a module (chapter) partially.
  Future<bool> updateModule({
    required String moduleId,
    String? title,
    int? order,
  }) async {
    final updateMap = <String, dynamic>{};
    if (title != null) updateMap['title'] = title;
    if (order != null) updateMap['order'] = order;
    if (updateMap.isEmpty) return true;
    final res = await supabase.from('modules').update(updateMap).eq('id', moduleId).select().maybeSingle();
    return res != null;
  }

  /// Update a section (lesson) partially.
  Future<bool> updateSection({
    required String sectionId,
    String? title,
    String? description,
    int? order,
  }) async {
    final updateMap = <String, dynamic>{};
    if (title != null) updateMap['title'] = title;
    if (description != null) updateMap['description'] = description;
    if (order != null) updateMap['order'] = order;
    if (updateMap.isEmpty) return true;
    final res = await supabase.from('sections').update(updateMap).eq('id', sectionId).select().maybeSingle();
    return res != null;
  }

  /// Update content partially.
  Future<bool> updateContent({
    required String contentId,
    String? title,
    String? url,
    int? order,
    String? type,
    String? storagePath,
  }) async {
    final updateMap = <String, dynamic>{};
    if (title != null) updateMap['title'] = title;
    if (url != null) updateMap['url'] = url;
    if (order != null) updateMap['order'] = order;
    if (type != null) updateMap['type'] = type;
    if (storagePath != null) updateMap['storage_path'] = storagePath;
    if (updateMap.isEmpty) return true;
    final res = await supabase.from('contents').update(updateMap).eq('id', contentId).select().maybeSingle();
    return res != null;
  }

  /// Fetch detailed course information (course + modules -> sections -> contents)
  Future<Map<String, dynamic>?> fetchCourseDetail(String courseId) async {
    final course = await supabase
        .from('courses')
        .select('id, title, description, price, is_paid, duration_days, banner')
        .eq('id', courseId)
        .maybeSingle();
    if (course == null) return null;

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
    final modulesData = List.from(modules as List? ?? []);
    modulesData.sort((a, b) => ((a['order'] ?? 0) as int).compareTo(((b['order'] ?? 0) as int)));

    for (final m in modulesData) {
      final rawSecs = List.from(m['sections'] as List? ?? []);
      rawSecs.sort((a, b) => ((a['order'] ?? 0) as int).compareTo(((b['order'] ?? 0) as int)));
      final lessons = <Map<String, dynamic>>[];
      for (final s in rawSecs) {
        final contents = <Map<String, dynamic>>[];
        final rawContents = List.from(s['contents'] as List? ?? []);
        rawContents.sort((a, b) => ((a['order'] ?? 0) as int).compareTo(((b['order'] ?? 0) as int)));
        for (final c in rawContents) {
          // Defensive handling: some DB schemas store a storage path under different keys.
          final Map contentMap = (c as Map).cast<String, dynamic>();
          String url = (contentMap['url'] ?? '') as String;
          final storagePath = contentMap.containsKey('storage_path')
              ? contentMap['storage_path']
              : contentMap.containsKey('storagePath')
                  ? contentMap['storagePath']
                  : contentMap.containsKey('path')
                      ? contentMap['path']
                      : null;

          if ((contentMap['type'] ?? '') == 'pdf' && storagePath != null && storagePath.toString().isNotEmpty) {
            try {
              url = supabase.storage.from('content-pdf').getPublicUrl(storagePath.toString());
            } catch (_) {}
          }

          contents.add({
            'id': contentMap['id'],
            'type': contentMap['type'],
            'title': contentMap['title'],
            'url': url,
            'order': contentMap['order'],
            'storage_path': storagePath,
          });
        }

        lessons.add({
          'id': s['id'],
          'title': s['title'],
          'description': s['description'],
          'order': s['order'],
          'contents': contents,
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
      'price': course['price'],
      'is_paid': course['is_paid'],
      'duration_days': course['duration_days'],
      'banner': course['banner'],
      'chapters': chaptersList,
    };
  }

  /// Create a new module (chapter) under a course. Returns created module id or null.
  Future<String?> createModule({
    required String courseId,
    required String title,
    required int order,
  }) async {
    final id = _uuid.v4();
    final res = await supabase.from('modules').insert({
      'id': id,
      'course_id': courseId,
      'title': title,
      'order': order,
    }).select('id').maybeSingle();
    return res != null ? res['id'] as String : null;
  }

  /// Create a new section (lesson) under a module. Returns id or null.
  Future<String?> createSection({
    required String moduleId,
    required String title,
    String? description,
    required int order,
  }) async {
    final id = _uuid.v4();
    final res = await supabase.from('sections').insert({
      'id': id,
      'module_id': moduleId,
      'title': title,
      'description': description,
      'order': order,
    }).select('id').maybeSingle();
    return res != null ? res['id'] as String : null;
  }

  /// Create content under a section. Returns id or null.
  Future<String?> createContent({
    required String sectionId,
    required String type,
    required String url,
    required int order,
    String? title,
    String? storagePath,
  }) async {
    final id = _uuid.v4();
    final res = await supabase.from('contents').insert({
      'id': id,
      'section_id': sectionId,
      'type': type,
      'url': url,
      'title': title ?? '',
      'order': order,
      if (storagePath != null) 'storage_path': storagePath,
    }).select('id').maybeSingle();
    return res != null ? res['id'] as String : null;
  }
}
