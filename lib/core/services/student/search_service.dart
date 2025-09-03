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

  /// Search courses with comprehensive filtering and sorting using course_search_view
  Future<List<Course>> searchCourses({
    String? query,
    String? tagId,
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
      print('SearchService: Building query using course_search_view with filters');
      
      // Start with base query from the view
      var baseQuery = _supabase.from('course_search_view').select('*');

      // Apply text search filter if query provided
      if (query != null && query.trim().isNotEmpty) {
        print('SearchService: Applying text search for: $query');
        baseQuery = baseQuery.or('title.ilike.%$query%,description.ilike.%$query%');
      }

      // Apply tag filter if provided (using array contains)
      if (tagId != null && tagId.isNotEmpty) {
        print('SearchService: Applying tag filter for tagId: $tagId');
        // First get the tag name from the tagId
        final tagResponse = await _supabase
            .from('tags')
            .select('name')
            .eq('id', tagId)
            .maybeSingle();
        
        if (tagResponse != null && tagResponse['name'] != null) {
          final tagName = tagResponse['name'];
          print('SearchService: Filtering by tag name: $tagName');
          baseQuery = baseQuery.contains('tags', [tagName]);
        }
      }

      // Apply price filters
      if (freeOnly == true) {
        print('SearchService: Filtering for free courses only');
        baseQuery = baseQuery.eq('is_paid', false);
      } else {
        if (minPrice != null) {
          print('SearchService: Applying min price filter: $minPrice');
          baseQuery = baseQuery.gte('price', minPrice);
        }
        if (maxPrice != null) {
          print('SearchService: Applying max price filter: $maxPrice');
          baseQuery = baseQuery.lte('price', maxPrice);
        }
      }

      // Apply duration filters
      if (durationMin != null) {
        print('SearchService: Applying min duration filter: $durationMin days');
        baseQuery = baseQuery.gte('duration_days', durationMin);
      }
      if (durationMax != null) {
        print('SearchService: Applying max duration filter: $durationMax days');
        baseQuery = baseQuery.lte('duration_days', durationMax);
      }

      // Apply rating filter
      if (minRating != null) {
        print('SearchService: Applying min rating filter: $minRating');
        baseQuery = baseQuery.gte('avg_rating', minRating);
      }

      // Apply sorting and execute query
      List<dynamic> response;
      switch (sortBy.toLowerCase()) {
        case 'newest':
          response = await baseQuery.order('created_at', ascending: false).range(offset, offset + limit - 1);
          break;
        case 'oldest':
          response = await baseQuery.order('created_at', ascending: true).range(offset, offset + limit - 1);
          break;
        case 'price_low':
          response = await baseQuery.order('price', ascending: true).range(offset, offset + limit - 1);
          break;
        case 'price_high':
          response = await baseQuery.order('price', ascending: false).range(offset, offset + limit - 1);
          break;
        case 'duration':
          response = await baseQuery.order('duration_days', ascending: true).range(offset, offset + limit - 1);
          break;
        case 'title':
          response = await baseQuery.order('title', ascending: true).range(offset, offset + limit - 1);
          break;
        case 'rating':
          response = await baseQuery.order('avg_rating', ascending: false).range(offset, offset + limit - 1);
          break;
        default: // relevance or any other
          response = await baseQuery.order('created_at', ascending: false).range(offset, offset + limit - 1);
      }

      print('SearchService: Executing query with limit=$limit, offset=$offset');

      if (response.isEmpty) {
        print('SearchService: No courses found');
        return [];
      }

      print('SearchService: Processing ${response.length} course records from view');
      
      // Convert each record to Course object using fromJson
      List<Course> courses = [];
      for (var courseData in response) {
        try {
          final course = Course.fromJson(courseData);
          courses.add(course);
        } catch (e) {
          print('SearchService: Error processing course record: $e');
          continue;
        }
      }

      print('SearchService: Successfully processed ${courses.length} courses');
      return courses;
    } catch (e) {
      print('SearchService: Error in searchCourses: $e');
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

  /// Get course categories with course counts using more efficient aggregation
  /// 
  /// Returns a list of maps with 'id', 'name' and 'count' keys
  Future<List<Map<String, dynamic>>> getCategoriesWithCounts() async {
    try {
      print('SearchService: Fetching categories with course counts');
      
      // Use a more efficient query that counts directly in SQL
      final response = await _supabase
          .from('tags')
          .select('''
            id,
            name,
            course_tags!inner(count)
          ''');

      List<Map<String, dynamic>> categories = [];
      for (var tag in response) {
        if (tag['name'] != null) {
          final courseCount = (tag['course_tags'] as List?)?.length ?? 0;
          if (courseCount > 0) { // Only include tags that have courses
            categories.add({
              'id': tag['id'],
              'name': tag['name'],
              'count': courseCount,
            });
          }
        }
      }

      // Sort by course count descending
      categories.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      print('SearchService: Found ${categories.length} categories with courses');
      return categories;

    } catch (e) {
      print('SearchService: Error fetching categories: $e');
      // Fallback to simpler query if the above fails
      try {
        final response = await _supabase
            .from('tags')
            .select('id, name');

        List<Map<String, dynamic>> categories = [];
        for (var tag in response) {
          if (tag['name'] != null) {
            // Get count separately for each tag
            final countResponse = await _supabase
                .from('course_tags')
                .select('id')
                .eq('tag_id', tag['id']);
            
            final count = countResponse.length;
            if (count > 0) {
              categories.add({
                'id': tag['id'],
                'name': tag['name'],
                'count': count,
              });
            }
          }
        }

        categories.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
        print('SearchService: Fallback query found ${categories.length} categories');
        return categories;
      } catch (e2) {
        print('SearchService: Fallback query also failed: $e2');
        return [];
      }
    }
  }

  /// Get a single course by ID with full details using course_search_view
  /// 
  /// [courseId] - The ID of the course to fetch
  Future<Course?> getCourseById(String courseId) async {
    try {
      print('SearchService: Fetching course by ID: $courseId');
      
      final response = await _supabase
          .from('course_search_view')
          .select('*')
          .eq('id', courseId)
          .maybeSingle();

      if (response == null) {
        print('SearchService: Course not found');
        return null;
      }

      final course = Course.fromJson(response);
      print('SearchService: Successfully fetched course: ${course.title}');
      return course;

    } catch (e) {
      print('SearchService: Error fetching course by ID: $e');
      return null;
    }
  }
}