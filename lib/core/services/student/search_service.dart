import 'package:supabase_flutter/supabase_flutter.dart';

/// # Search Service for Knowble Flutter App
/// 
/// This service provides comprehensive course search functionality with Supabase integration.
/// 
/// ## Required Database Tables:
/// 
/// ### courses
/// - id (uuid, primary key)
/// - instructor_id (uuid, foreign key to users.id)
/// - title (text)
/// - description (text)
/// - price (numeric)
/// - is_paid (boolean)
/// - duration_days (integer)
/// - created_at (timestamp)
/// 
/// ### users
/// - id (uuid, primary key)
/// - name (text)
/// - role (text)
/// 
/// ### course_reviews
/// - id (uuid, primary key)
/// - course_id (uuid, foreign key to courses.id)
/// - student_id (uuid, foreign key to users.id)
/// - rating (numeric, 1-5)
/// 
/// ### tags
/// - id (uuid, primary key)
/// - name (text)
/// 
/// ### course_tags
/// - course_id (uuid, foreign key to courses.id)
/// - tag_id (uuid, foreign key to tags.id)
/// 
/// ### recent_searches (optional)
/// - id (uuid, primary key)
/// - user_id (uuid, foreign key to users.id)
/// - query (text)
/// - created_at (timestamp)
/// 
/// ## RPC Functions (optional, for better performance):
/// 
/// ### get_popular_search_terms
/// ```sql
/// CREATE OR REPLACE FUNCTION get_popular_search_terms(result_limit integer DEFAULT 10)
/// RETURNS TABLE(query text, search_count bigint) AS $$
/// BEGIN
///   RETURN QUERY
///   SELECT rs.query, COUNT(*) as search_count
///   FROM recent_searches rs
///   WHERE rs.created_at > NOW() - INTERVAL '30 days'
///   GROUP BY rs.query
///   ORDER BY search_count DESC, rs.query
///   LIMIT result_limit;
/// END;
/// $$ LANGUAGE plpgsql;
/// ```

/// Course model for search results
/// 
/// Example usage:
/// ```dart
/// final searchService = SearchService();
/// final courses = await searchService.searchCourses(
///   query: 'flutter',
///   category: 'Programming',
///   freeOnly: true,
///   minRating: 4.0,
///   limit: 10,
/// );
/// ```
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
  /// 
  /// [query] - Free text search across title, description, and tags
  /// [category] - Filter by category (matched against tags)
  /// [minPrice] - Minimum price filter
  /// [maxPrice] - Maximum price filter
  /// [freeOnly] - Show only free courses
  /// [minRating] - Minimum average rating
  /// [durationMin] - Minimum duration in days
  /// [durationMax] - Maximum duration in days
  /// [limit] - Number of results to return (default: 20)
  /// [offset] - Offset for pagination (default: 0)
  /// [sortBy] - Sort method: "relevance", "newest", "popular", "rating" (default: "relevance")
  Future<List<Course>> searchCourses({
    String? query,
    String? category,
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
      print('SearchService: Starting course search with query: $query, category: $category');
      
      // Build the base query with simplified joins
      var queryBuilder = _supabase
          .from('courses')
          .select('''
            *,
            users!instructor_id(name),
            course_reviews(rating)
          ''');

      // Apply text search filter
      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'title.ilike.%$query%,description.ilike.%$query%'
        );
      }

      // Apply price filters
      if (freeOnly == true) {
        queryBuilder = queryBuilder.eq('is_paid', false);
      } else {
        if (minPrice != null) {
          queryBuilder = queryBuilder.gte('price', minPrice);
        }
        if (maxPrice != null) {
          queryBuilder = queryBuilder.lte('price', maxPrice);
        }
      }

      // Apply duration filters
      if (durationMin != null) {
        queryBuilder = queryBuilder.gte('duration_days', durationMin);
      }
      if (durationMax != null) {
        queryBuilder = queryBuilder.lte('duration_days', durationMax);
      }

      // Apply sorting and pagination
      String orderColumn = 'created_at';
      bool ascending = false;
      
      switch (sortBy.toLowerCase()) {
        case "newest":
          orderColumn = 'created_at';
          ascending = false;
          break;
        case "popular":
          orderColumn = 'created_at';
          ascending = false;
          break;
        case "rating":
          orderColumn = 'created_at';
          ascending = false;
          break;
        case "relevance":
        default:
          orderColumn = 'created_at';
          ascending = false;
          break;
      }

      print('SearchService: Executing Supabase query...');
      final response = await queryBuilder
          .order(orderColumn, ascending: ascending)
          .range(offset, offset + limit - 1);
      
      print('SearchService: Raw response length: ${response.length}');

      // Get course IDs for tag filtering
      List<String> courseIds = response.map((course) => course['id'].toString()).toList();
      
      // Fetch tags for all courses
      Map<String, List<String>> courseTags = {};
      if (courseIds.isNotEmpty) {
        final tagsResponse = await _supabase
            .from('course_tags')
            .select('course_id, tags(name)')
            .inFilter('course_id', courseIds);
        
        for (var tagData in tagsResponse) {
          final courseId = tagData['course_id']?.toString();
          final tagName = tagData['tags']?['name'];
          if (courseId != null && tagName != null) {
            courseTags[courseId] ??= [];
            courseTags[courseId]!.add(tagName);
          }
        }
      }

      // Process the results
      List<Course> courses = [];
      
      for (var courseData in response) {
        try {
          // Get course ID
          final courseId = courseData['id']?.toString() ?? '';
          
          // Get tags for this course
          List<String> tags = courseTags[courseId] ?? [];
          
          // Apply category filter if specified
          if (category != null && category.isNotEmpty) {
            bool hasCategory = tags.any((tag) => 
              tag.toLowerCase() == category.toLowerCase());
            if (!hasCategory) {
              continue; // Skip this course if it doesn't match the category
            }
          }

          // Extract instructor name
          String instructorName = 'Unknown Instructor';
          if (courseData['users'] != null && courseData['users']['name'] != null) {
            instructorName = courseData['users']['name'];
          }

          // Calculate average rating
          double avgRating = 0.0;
          int reviewCount = 0;
          if (courseData['course_reviews'] != null) {
            final reviews = courseData['course_reviews'] as List;
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

          // Apply rating filter after computation
          if (minRating != null && avgRating < minRating) {
            continue;
          }

          // Get students count (simplified - could be from enrollments table)
          int studentsCount = reviewCount; // Using review count as proxy

          // Create course object
          final course = Course(
            id: courseData['id'] ?? '',
            title: courseData['title'] ?? '',
            description: courseData['description'] ?? '',
            instructorName: instructorName,
            price: (courseData['price'] ?? 0.0).toDouble(),
            isPaid: courseData['is_paid'] ?? false,
            durationDays: courseData['duration_days'] ?? 0,
            avgRating: avgRating,
            studentsCount: studentsCount,
            tags: tags,
            createdAt: DateTime.tryParse(courseData['created_at'] ?? '') ?? DateTime.now(),
          );

          courses.add(course);
        } catch (e) {
          print('SearchService: Error processing course data: $e');
          continue;
        }
      }

      // Apply post-processing sorting for rating-based sort
      if (sortBy.toLowerCase() == "rating") {
        courses.sort((a, b) => b.avgRating.compareTo(a.avgRating));
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

  /// Get course categories with course counts
  /// 
  /// Returns a list of maps with 'name' and 'count' keys
  Future<List<Map<String, dynamic>>> getCategoriesWithCounts() async {
    try {
      print('SearchService: Fetching categories with course counts');
      
      final response = await _supabase
          .from('tags')
          .select('''
            name,
            course_tags(count)
          ''');

      List<Map<String, dynamic>> categories = [];
      for (var tag in response) {
        if (tag['name'] != null) {
          final courseCount = (tag['course_tags'] as List?)?.length ?? 0;
          categories.add({
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