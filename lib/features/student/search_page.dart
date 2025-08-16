import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'search_layout.dart';
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
  String _selectedCategory = '';
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};

  // Mock data
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

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    if (_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
      setState(() {
        _currentState = SearchPageState.recentSearches;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isNotEmpty) {
        _currentState = SearchPageState.searchResults;
      } else if (_searchFocusNode.hasFocus) {
        _currentState = SearchPageState.recentSearches;
      } else {
        _currentState = SearchPageState.categories;
      }
    });
  }

  void _onCategorySelected(String categoryName) {
    setState(() {
      _selectedCategory = categoryName;
      _currentState = SearchPageState.categoryResults;
    });
  }

  void _onRecentSearchSelected(String searchTerm) {
    _searchController.text = searchTerm;
    _searchFocusNode.unfocus();
    setState(() {
      _searchQuery = searchTerm;
      _currentState = SearchPageState.searchResults;
    });
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
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchQuery = '';
      _currentState = SearchPageState.categories;
    });
  }

  List<Map<String, dynamic>> _getFilteredResults() {
    List<Map<String, dynamic>> results = List.from(_mockResults);
    
    if (_activeFilters['level'] != null && _activeFilters['level'].isNotEmpty) {
      results = results.where((course) => 
        course['level'] == _activeFilters['level']).toList();
    }
    
    if (_activeFilters['priceRange'] != null) {
      final range = _activeFilters['priceRange'] as RangeValues;
      results = results.where((course) {
        final price = double.parse(course['price'].replaceAll('\$', ''));
        return price >= range.start && price <= range.end;
      }).toList();
    }
    
    if (_activeFilters['rating'] != null) {
      final minRating = _activeFilters['rating'] as double;
      results = results.where((course) => 
        course['rating'] >= minRating).toList();
    }
    
    return results;
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
              child: AnimatedSwitcher(
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
                  onCategorySelected: _onCategorySelected,
                  onRecentSearchSelected: _onRecentSearchSelected,
                  selectedCategory: _selectedCategory,
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
