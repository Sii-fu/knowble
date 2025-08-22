import 'package:supabase_flutter/supabase_flutter.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String instructorName;
  final double price;
  final bool isPaid;
  final int durationDays;
  final double avgRating;
  final int studentsCount;
  final List<String> tags;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorName,
    required this.price,
    required this.isPaid,
    required this.durationDays,
    required this.avgRating,
    required this.studentsCount,
    required this.tags,
    required this.createdAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructorName: json['instructor_name'] ?? 'Unknown Instructor',
      price: (json['price'] ?? 0.0).toDouble(),
      isPaid: json['is_paid'] ?? false,
      durationDays: json['duration_days'] ?? 0,
      avgRating: (json['avg_rating'] ?? 0.0).toDouble(),
      studentsCount: json['students_count'] ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor_name': instructorName,
      'price': price,
      'is_paid': isPaid,
      'duration_days': durationDays,
      'avg_rating': avgRating,
      'students_count': studentsCount,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Service for handling course search operations
class SearchService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Search courses with comprehensive filtering and sorting
  Future<List<Course>> searchCourses({
    String? query,
    String? tagId, // ✅ use tagId instead of category string
    double? minPrice,
    double? maxPrice,
    bool? freeOnly,
    double? minRating,
    int? durationMin,
    int? durationMax,
    int limit = 20,
    int offset = 0,
    String sortBy = "relevance",
  }) async {
    try {
      print('SearchService: Calling DB function search_courses with params: query=$query, tagId=$tagId, freeOnly=$freeOnly, minPrice=$minPrice, maxPrice=$maxPrice, durationMin=$durationMin, durationMax=$durationMax, sortBy=$sortBy, offset=$offset, limit=$limit');

      final rpcResponse = await _supabase.rpc('search_courses', params: {
        'p_query': query,
        'p_tag_id': tagId,
        'p_free_only': freeOnly,
        'p_min_price': minPrice,
        'p_max_price': maxPrice,
        'p_duration_min': durationMin,
        'p_duration_max': durationMax,
        'p_sort_by': sortBy,
        'p_offset': offset,
        'p_limit': limit,
      });

      if (rpcResponse == null) {
        print('SearchService: RPC returned null');
        return [];
      }

      // rpcResponse may be a List of course records (maps)
      List<dynamic> rows = [];
      if (rpcResponse is List) {
        rows = rpcResponse;
      } else if (rpcResponse is Map && rpcResponse.containsKey('data')) {
        rows = rpcResponse['data'] as List<dynamic>;
      }

      if (rows.isEmpty) return [];

      // For each returned course row, fetch full course details using getCourseById
      final courseFutures = rows.map((r) {
        final courseId = r['id']?.toString();
        if (courseId == null || courseId.isEmpty) return Future<Course?>.value(null);
        return getCourseById(courseId);
      }).toList();

      final fetched = await Future.wait(courseFutures);
      final courses = fetched.whereType<Course>().toList();

      // Apply client-side rating sort if requested (DB already handles many sorts)
      if (sortBy.toLowerCase() == 'rating') {
        courses.sort((a, b) => b.avgRating.compareTo(a.avgRating));
      }

      print('SearchService: search_courses returned ${courses.length} courses');
      return courses;
    } catch (e) {
      print('SearchService: Error in searchCourses RPC path: $e');
      // Fallback: return empty list (or optionally implement previous manual query fallback)
      return [];
    }
  }

  /// Get recent search queries for a user
  /// 
  /// [userId] - ID of the user to fetch recent searches for
  /// [limit] - Maximum number of recent searches to return (default: 10)
  Future<List<String>> getRecentSearches(String userId, {int limit = 10}) async {
    try {
      print('SearchService: Fetching recent searches for user: $userId');
      
      final response = await _supabase
          .from('recent_searches')
          .select('query')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      List<String> searches = []; 
      for (var search in response) {
        if (search['query'] != null && search['query'].toString().isNotEmpty) {
          searches.add(search['query'].toString());
        }
      }

      print('SearchService: Found ${searches.length} recent searches');
      return searches;

    } catch (e) {
      print('SearchService: Error fetching recent searches: $e');
      return [];
    }
  }

  /// Save a search query to recent searches
  /// 
  /// [userId] - ID of the user performing the search
  /// [query] - The search query to save
  Future<void> saveSearchQuery(String userId, String query) async {
    try {
      if (query.trim().isEmpty) return;

      print('SearchService: Saving search query: $query for user: $userId');

      // Check if this exact query already exists for this user
      final existing = await _supabase
          .from('recent_searches')
          .select('id')
          .eq('user_id', userId)
          .eq('query', query.trim())
          .maybeSingle();

      if (existing != null) {
        // Update the timestamp of existing search
        await _supabase
            .from('recent_searches')
            .update({'created_at': DateTime.now().toIso8601String()})
            .eq('id', existing['id']);
      } else {
        // Insert new search query
        await _supabase.from('recent_searches').insert({
          'user_id': userId,
          'query': query.trim(),
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Keep only the latest 20 searches per user
      final allSearches = await _supabase
          .from('recent_searches')
          .select('id')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (allSearches.length > 20) {
        final toDelete = allSearches.skip(20).map((s) => s['id']).toList();
        for (String id in toDelete) {
          await _supabase
              .from('recent_searches')
              .delete()
              .eq('id', id);
        }
      }

      print('SearchService: Successfully saved search query');

    } catch (e) {
      print('SearchService: Error saving search query: $e');
    }
  }

  /// Clear all recent searches for a user
  /// 
  /// [userId] - ID of the user to clear searches for
  Future<void> clearRecentSearches(String userId) async {
    try {
      print('SearchService: Clearing recent searches for user: $userId');
      
      await _supabase
          .from('recent_searches')
          .delete()
          .eq('user_id', userId);

      print('SearchService: Successfully cleared recent searches');

    } catch (e) {
      print('SearchService: Error clearing recent searches: $e');
    }
  }

  /// Get popular search terms across all users
  /// 
  /// [limit] - Maximum number of popular terms to return (default: 10)
  Future<List<String>> getPopularSearchTerms({int limit = 10}) async {
    try {
      print('SearchService: Fetching popular search terms');
      
      final response = await _supabase
          .rpc('get_popular_search_terms', params: {'result_limit': limit});

      List<String> terms = [];
      for (var term in response) {
        if (term['query'] != null && term['query'].toString().isNotEmpty) {
          terms.add(term['query'].toString());
        }
      }

      print('SearchService: Found ${terms.length} popular search terms');
      return terms;

    } catch (e) {
      print('SearchService: Error fetching popular search terms: $e');
      // Fallback to basic query if RPC function doesn't exist
      try {
        final response = await _supabase
            .from('recent_searches')
            .select('query')
            .order('created_at', ascending: false)
            .limit(limit);

        return response
            .map((e) => e['query'].toString())
            .where((query) => query.isNotEmpty)
            .toSet() // Remove duplicates
            .take(limit)
            .toList();
      } catch (e2) {
        print('SearchService: Fallback query also failed: $e2');
        return [];
      }
    }
  }

  /// Get course categories with course counts
  /// 
  /// Returns a list of maps with 'id', 'name' and 'count' keys
  Future<List<Map<String, dynamic>>> getCategoriesWithCounts() async {
    try {
      print('SearchService: Fetching categories with course counts');
      
      final response = await _supabase
          .from('tags')
          .select('''
            id,
            name,
            course_tags(count)
          ''');

      List<Map<String, dynamic>> categories = [];
      for (var tag in response) {
        if (tag['name'] != null) {
          final courseCount = (tag['course_tags'] as List?)?.length ?? 0;
          categories.add({
            'id': tag['id'],
            'name': tag['name'],
            'count': courseCount,
          });
        }
      }

      // Sort by course count descending
      categories.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      print('SearchService: Found ${categories.length} categories');
      return categories;

    } catch (e) {
      print('SearchService: Error fetching categories: $e');
      return [];
    }
  }

  /// Get a single course by ID with full details
  /// 
  /// [courseId] - The ID of the course to fetch
  Future<Course?> getCourseById(String courseId) async {
    try {
      print('SearchService: Fetching course by ID: $courseId');
      
      final response = await _supabase
          .from('courses')
          .select('''
            id,
            title,
            description,
            price,
            is_paid,
            duration_days,
            created_at,
            users!instructor_id(name),
            course_reviews(rating),
            course_tags(tags(name))
          ''')
          .eq('id', courseId)
          .maybeSingle();

      if (response == null) {
        print('SearchService: Course not found');
        return null;
      }

      // Process single course using same logic as searchCourses
      String instructorName = 'Unknown Instructor';
      if (response['users'] != null && response['users']['name'] != null) {
        instructorName = response['users']['name'];
      }

      double avgRating = 0.0;
      int reviewCount = 0;
      if (response['course_reviews'] != null) {
        final reviews = response['course_reviews'] as List;
        if (reviews.isNotEmpty) {
          double totalRating = 0.0;
          for (var review in reviews) {
            if (review['rating'] != null) {
              totalRating += (review['rating'] as num).toDouble();
              reviewCount++;
            }
          }
          if (reviewCount > 0) {
            avgRating = totalRating / reviewCount;
          }
        }
      }

      List<String> tags = [];
      if (response['course_tags'] != null) {
        final courseTags = response['course_tags'] as List;
        for (var courseTag in courseTags) {
          if (courseTag['tags'] != null && courseTag['tags']['name'] != null) {
            tags.add(courseTag['tags']['name']);
          }
        }
      }

      final course = Course(
        id: response['id'] ?? '',
        title: response['title'] ?? '',
        description: response['description'] ?? '',
        instructorName: instructorName,
        price: (response['price'] ?? 0.0).toDouble(),
        isPaid: response['is_paid'] ?? false,
        durationDays: response['duration_days'] ?? 0,
        avgRating: avgRating,
        studentsCount: reviewCount,
        tags: tags,
        createdAt: DateTime.tryParse(response['created_at'] ?? '') ?? DateTime.now(),
      );

      print('SearchService: Successfully fetched course: ${course.title}');
      return course;

    } catch (e) {
      print('SearchService: Error fetching course by ID: $e');
      return null;
    }
  }
}