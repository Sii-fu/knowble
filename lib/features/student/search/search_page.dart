import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../core/services/student/search_service.dart';
import 'search_layout.dart';
import '../Course_Details.dart';
import 'filter_page.dart';
import 'search_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  SearchPageState _currentState = SearchPageState.categories;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedCategoryId = '';
  String _selectedCategoryName = '';
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};

  // Backend service
  final SearchService _searchService = SearchService();
  
  // Data from backend
  List<String> _recentSearches = [];
  List<Map<String, dynamic>> _categories = [];
  List<Course> _searchResults = [];
  bool _isLoading = false;
  final String _currentUserId = 'test-user-123'; // TODO: Get this from your auth service/provider

  // TODO: Add this method to get current user ID from your authentication system
  // String? _getCurrentUserId() {
  //   // Return current user ID from your auth service
  //   // Example: return Supabase.instance.client.auth.currentUser?.id;
  //   return null;
  // }

  // Mock data (commented out - now using backend)
  /*
  final List<String> _recentSearches = [
    'Flutter development',
    'Data structures',
    'Machine learning',
    'Web design',
    'Mobile app development',
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Programming', 'icon': Icons.code, 'count': 45},
    {'name': 'Design', 'icon': Icons.palette, 'count': 32},
    {'name': 'Mathematics', 'icon': Icons.calculate, 'count': 28},
    {'name': 'Science', 'icon': Icons.science, 'count': 38},
    {'name': 'Business', 'icon': Icons.business, 'count': 22},
    {'name': 'Language', 'icon': Icons.language, 'count': 15},
    {'name': 'Arts', 'icon': Icons.brush, 'count': 19},
    {'name': 'Health', 'icon': Icons.health_and_safety, 'count': 12},
  ];

  final List<Map<String, dynamic>> _mockResults = [
    {
      'title': 'Complete Flutter Development Course',
      'instructor': 'Dr. Sarah Johnson',
      'rating': 4.8,
      'students': 2340,
      'price': '\$89.99',
      'duration': '24 hours',
      'level': 'Beginner',
      'image': 'https://via.placeholder.com/150x100',
    },
    {
      'title': 'Advanced React Native Masterclass',
      'instructor': 'Mike Chen',
      'rating': 4.9,
      'students': 1890,
      'price': '\$129.99',
      'duration': '18 hours',
      'level': 'Advanced',
      'image': 'https://via.placeholder.com/150x100',
    },
    {
      'title': 'UI/UX Design Fundamentals',
      'instructor': 'Emma Williams',
      'rating': 4.7,
      'students': 3120,
      'price': '\$69.99',
      'duration': '15 hours',
      'level': 'Intermediate',
      'image': 'https://via.placeholder.com/150x100',
    },
    {
      'title': 'Data Science with Python',
      'instructor': 'Prof. Alex Kumar',
      'rating': 4.9,
      'students': 2780,
      'price': '\$149.99',
      'duration': '32 hours',
      'level': 'Intermediate',
      'image': 'https://via.placeholder.com/150x100',
    },
  ];
  */

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Load initial data from backend
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load categories
      final categories = await _searchService.getCategoriesWithCounts();
      final categoriesWithIcons = categories.map((cat) {
        return {
          'id': cat['id'], // Include tag ID
          'name': cat['name'],
          'count': cat['count'],
          'icon': _getCategoryIcon(cat['name']), // Helper method to get icons
        };
      }).toList();

      // Load recent searches if user is logged in
      List<String> recentSearches = [];
      recentSearches = await _searchService.getRecentSearches(_currentUserId);
    
      setState(() {
        _categories = categoriesWithIcons;
        _recentSearches = recentSearches;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading initial data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Helper method to assign icons to categories
  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'programming':
      case 'development':
      case 'coding':
        return Icons.code;
      case 'design':
      case 'graphics':
        return Icons.palette;
      case 'mathematics':
      case 'math':
        return Icons.calculate;
      case 'science':
      case 'physics':
      case 'chemistry':
        return Icons.science;
      case 'business':
      case 'marketing':
        return Icons.business;
      case 'language':
      case 'languages':
        return Icons.language;
      case 'arts':
      case 'art':
        return Icons.brush;
      case 'health':
      case 'fitness':
        return Icons.health_and_safety;
      default:
        return Icons.school;
    }
  }

  void _onSearchFocusChanged() {
    if (_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
      setState(() {
        _currentState = SearchPageState.recentSearches;
      });
    }
  }

  void _onSearchChanged(String query) async {
    setState(() {
      _searchQuery = query;
      if (query.isNotEmpty) {
        _currentState = SearchPageState.searchResults;
        _isLoading = true;
      } else if (_searchFocusNode.hasFocus) {
        _currentState = SearchPageState.recentSearches;
      } else {
        _currentState = SearchPageState.categories;
      }
    });

    // Perform search if query is not empty
    if (query.isNotEmpty) {
      await _performSearch();
      
      // Save search query if user is logged in
      await _searchService.saveSearchQuery(_currentUserId, query);
        }
  }

  void _onCategorySelected(String categoryId, String categoryName) async {
    print('SearchPage: Category selected: $categoryName (ID: $categoryId)');
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedCategoryName = categoryName;
      _currentState = SearchPageState.categoryResults;
      _isLoading = true;
    });

    await _performSearch(tagId: categoryId);
  }

  void _onRecentSearchSelected(String searchTerm) async {
    _searchController.text = searchTerm;
    _searchFocusNode.unfocus();
    setState(() {
      _searchQuery = searchTerm;
      _currentState = SearchPageState.searchResults;
      _isLoading = true;
    });

    await _performSearch();
  }

  /// Perform search using the backend service
  Future<void> _performSearch({String? tagId}) async {
    try {
      print('SearchPage: Performing search with query: "$_searchQuery", tagId: "$tagId"');
      
      final courses = await _searchService.searchCourses(
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
        tagId: (tagId != null && tagId.isNotEmpty)
            ? tagId
            : (_selectedCategoryId.isNotEmpty ? _selectedCategoryId : null),
        freeOnly: _activeFilters['freeOnly'] == true ? true : null,
        minPrice: (_activeFilters['priceRange'] is RangeValues &&
                (_activeFilters['priceRange'] as RangeValues).start > 0)
            ? (_activeFilters['priceRange'] as RangeValues).start
            : null,
        maxPrice: (_activeFilters['priceRange'] is RangeValues &&
                (_activeFilters['priceRange'] as RangeValues).end > 0)
            ? (_activeFilters['priceRange'] as RangeValues).end
            : null,
        minRating: (_activeFilters['rating'] is double &&
                (_activeFilters['rating'] as double) > 0)
            ? _activeFilters['rating'] as double
            : null,
        durationMin: (_activeFilters['duration'] is String &&
                (_activeFilters['duration'] as String).isNotEmpty)
            ? _getDurationMin(_activeFilters['duration'] as String)
            : null,
        durationMax: (_activeFilters['duration'] is String &&
                (_activeFilters['duration'] as String).isNotEmpty)
            ? _getDurationMax(_activeFilters['duration'] as String)
            : null,
        sortBy: (_activeFilters['sortBy'] as String?)?.toLowerCase().trim() ?? 'relevance',
        offset: _activeFilters['offset'] ?? 0,
        limit: _activeFilters['limit'] ?? 100,
      );



      print('SearchPage: Search completed, found ${courses.length} courses');
      setState(() {
        _searchResults = courses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error performing search: $e');
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  /// Helper method to convert duration filter to minimum days
  int? _getDurationMin(String? duration) {
    if (duration == null) return null;
    switch (duration) {
      case '< 5 hours':
        return null; // No minimum
      case '5-10 hours':
        return 1;
      case '10-20 hours':
        return 2;
      case '20+ hours':
        return 4;
      default:
        return null;
    }
  }

  /// Helper method to convert duration filter to maximum days
  int? _getDurationMax(String? duration) {
    if (duration == null) return null;
    switch (duration) {
      case '< 5 hours':
        return 1;
      case '5-10 hours':
        return 1;
      case '10-20 hours':
        return 3;
      case '20+ hours':
        return null; // No maximum
      default:
        return null;
    }
  }

  void _onFilterPressed() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterPage(activeFilters: _activeFilters),
    );

    if (result != null) {
      setState(() {
        _activeFilters = result;
        if (_activeFilters.isNotEmpty) {
          _currentState = SearchPageState.searchResults;
        }
      });
      
      // Re-perform search with new filters
      await _performSearch();
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchQuery = '';
      _selectedCategoryId = '';
      _selectedCategoryName = '';
      _currentState = SearchPageState.categories;
      _searchResults = [];
    });
  }

  /// Convert Course objects to Map format for UI compatibility
  List<Map<String, dynamic>> _getFilteredResults() {
    const defaultBanner = 'https://picsum.photos/1000/600';
    return _searchResults.map((course) => {
      'id': course.id,
      'title': course.title,
      'instructor': course.instructorName,
      'rating': course.avgRating,
      'students': course.studentsCount,
      'price': course.isPaid ? '\$${course.price.toStringAsFixed(2)}' : 'Free',
      'duration': '${course.durationDays} days',
      'level': _getLevelFromTags(course.tags),
      'banner': (course.banner.isNotEmpty) ? course.banner : defaultBanner,
    }).toList();
  }

  /// Helper method to extract level from tags
  String _getLevelFromTags(List<String> tags) {
    final levelTags = ['Beginner', 'Intermediate', 'Advanced'];
    for (String tag in tags) {
      if (levelTags.contains(tag)) {
        return tag;
      }
    }
    return 'Beginner'; // Default level
  }

  /// Clear recent searches
  Future<void> _clearRecentSearches() async {
    await _searchService.clearRecentSearches(_currentUserId);
    setState(() {
      _recentSearches = [];
    });
    }

  /// Navigate to course details page
  void _onCourseSelected(String courseId) {
    // Prefer direct route to CourseDetailPage to ensure courseId is passed as constructor arg
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourseDetailPage(courseId: courseId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Section - Always at top
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _searchFocusNode.hasFocus 
                            ? AppTheme.primaryTeal 
                            : AppTheme.borderSubtle,
                          width: _searchFocusNode.hasFocus ? 2 : 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search courses, categories...',
                          hintStyle: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: _searchFocusNode.hasFocus 
                              ? AppTheme.primaryTeal 
                              : AppTheme.textSecondary,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: _onClearSearch,
                              )
                            : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: _activeFilters.isNotEmpty 
                        ? AppTheme.primaryTeal 
                        : AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.borderSubtle,
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.tune,
                        color: _activeFilters.isNotEmpty 
                          ? AppTheme.surfaceWhite 
                          : AppTheme.textSecondary,
                      ),
                      onPressed: _onFilterPressed,
                    ),
                  ),
                ],
              ),
            ),

            // Dynamic Content Body
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: SearchLayout(
                      key: ValueKey(_currentState),
                      state: _currentState,
                      categories: _categories,
                      recentSearches: _recentSearches,
                      searchResults: _getFilteredResults(),
                      onCategorySelected: (categoryName) {
                        // Find the category by name and get its ID
                        final category = _categories.firstWhere(
                          (cat) => cat['name'] == categoryName,
                          orElse: () => {'id': '', 'name': ''},
                        );
                        if (category['id'] != null && category['id'].isNotEmpty) {
                          _onCategorySelected(category['id'], categoryName);
                        }
                      },
                      onRecentSearchSelected: _onRecentSearchSelected,
                      onClearRecentSearches: _clearRecentSearches,
                      onCourseSelected: _onCourseSelected,
                      selectedCategory: _selectedCategoryName,
                      searchQuery: _searchQuery,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
