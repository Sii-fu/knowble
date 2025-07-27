import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'filter_page.dart';

enum SearchBodyState {
  showCategories, // Initial view
  showHistory,    // When search bar is tapped
  showResults     // After a search or category selection
}

class UnifiedSearchPage extends StatefulWidget {
  const UnifiedSearchPage({super.key});

  @override
  State<UnifiedSearchPage> createState() => _UnifiedSearchPageState();
}

class _UnifiedSearchPageState extends State<UnifiedSearchPage> {
  SearchBodyState _currentState = SearchBodyState.showCategories;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  final List<String> _searchHistory = [
    'Graphic Design',
    'Web Development',
    'Photography',
    'Digital Marketing',
    'UI/UX Design',
  ];

  List<CourseItem> _currentResults = [];
  Map<String, dynamic>? _appliedFilters;

  // Sample categories data
  final List<CategoryItem> _categories = const [
    CategoryItem('3D Design', Icons.view_in_ar),
    CategoryItem('Web Development', Icons.web),
    CategoryItem('Finance & Accounting', Icons.account_balance),
    CategoryItem('Mobile Development', Icons.smartphone),
    CategoryItem('Graphic Design', Icons.design_services),
    CategoryItem('Data Science', Icons.analytics),
    CategoryItem('Marketing', Icons.campaign),
    CategoryItem('Photography', Icons.camera_alt),
    CategoryItem('Music', Icons.music_note),
    CategoryItem('Business', Icons.business),
    CategoryItem('Art & Design', Icons.palette),
    CategoryItem('Programming', Icons.code),
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_searchFocusNode.hasFocus) {
      if (_currentState == SearchBodyState.showCategories) {
        setState(() {
          _currentState = SearchBodyState.showHistory;
        });
      }
    } else {
      // Only go back to categories if we're in history view and search is empty
      if (_currentState == SearchBodyState.showHistory && _searchController.text.isEmpty) {
        setState(() {
          _currentState = SearchBodyState.showCategories;
        });
      }
    }
  }

  String _getHeaderTitle() {
    switch (_currentState) {
      case SearchBodyState.showCategories:
        return 'All Categories';
      case SearchBodyState.showHistory:
        return 'All Categories';
      case SearchBodyState.showResults:
        return 'Search Results';
    }
  }

  void _onCategoryTapped(String categoryName) {
    _searchController.text = categoryName;
    _loadCoursesForQuery(categoryName);
    setState(() {
      _currentState = SearchBodyState.showResults;
    });
    _searchFocusNode.unfocus();
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      _addToSearchHistory(query.trim());
      _loadCoursesForQuery(query.trim());
      setState(() {
        _currentState = SearchBodyState.showResults;
      });
      _searchFocusNode.unfocus();
    }
  }

  void _onHistoryItemTapped(String searchTerm) {
    _searchController.text = searchTerm;
    _loadCoursesForQuery(searchTerm);
    setState(() {
      _currentState = SearchBodyState.showResults;
    });
    _searchFocusNode.unfocus();
  }

  void _addToSearchHistory(String query) {
    if (!_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      });
    }
  }

  void _removeFromHistory(int index) {
    setState(() {
      _searchHistory.removeAt(index);
    });
  }

  void _loadCoursesForQuery(String query) {
    // Sample course data - in a real app, this would come from your backend
    _currentResults = [
      CourseItem(
        id: '1',
        title: 'Graphic Design Advanced',
        category: 'Graphic Design',
        rating: 4.8,
        studentCount: 2341,
        imageUrl: 'assets/images/gd1.jpg',
      ),
      CourseItem(
        id: '2',
        title: 'Web Development Bootcamp',
        category: 'Web Development',
        rating: 4.9,
        studentCount: 5678,
        imageUrl: 'assets/images/web.png',
      ),
      CourseItem(
        id: '3',
        title: 'UI/UX Design Fundamentals',
        category: 'Design',
        rating: 4.7,
        studentCount: 1234,
        imageUrl: 'assets/images/gd2.jpg',
      ),
      CourseItem(
        id: '4',
        title: 'Mobile App Development',
        category: 'Mobile Development',
        rating: 4.6,
        studentCount: 987,
        imageUrl: 'assets/images/web.png',
      ),
      CourseItem(
        id: '5',
        title: 'Digital Marketing Mastery',
        category: 'Marketing',
        rating: 4.5,
        studentCount: 3456,
        imageUrl: 'assets/images/dm.jpg',
      ),
    ];
  }

  void _resetToInitialState() {
    setState(() {
      _currentState = SearchBodyState.showCategories;
      _searchController.clear();
      _currentResults.clear();
    });
    _searchFocusNode.unfocus();
  }

  void _onSearchBarTapped() {
    setState(() {
      _currentState = SearchBodyState.showHistory;
    });
    if (!_searchFocusNode.hasFocus) {
      _searchFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.borderSubtle,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
                      onPressed: () {
                        if (_currentState == SearchBodyState.showResults) {
                          _resetToInitialState();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    Expanded(
                      child: Text(
                        _getHeaderTitle(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Search Bar
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.borderSubtle,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onTap: _onSearchBarTapped,
                        onSubmitted: _onSearchSubmitted,
                        decoration: InputDecoration(
                          hintText: 'Search for...',
                          hintStyle: TextStyle(color: AppTheme.textSecondary),
                          prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                    ),
                    if (_currentState == SearchBodyState.showResults)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: Icon(
                            Icons.tune,
                            color: AppTheme.primaryTeal,
                          ),
                          onPressed: () async {
                            final filters = await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FilterPage(
                                  currentFilters: _appliedFilters,
                                ),
                              ),
                            );
                            if (filters != null) {
                              setState(() {
                                _appliedFilters = filters;
                                // Apply filters to course list
                                _loadCoursesForQuery(_searchController.text);
                              });
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),

              // Dynamic Content Body
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentState) {
      case SearchBodyState.showCategories:
        return _buildCategoriesView();
      case SearchBodyState.showHistory:
        return _buildHistoryView();
      case SearchBodyState.showResults:
        return _buildResultsView();
    }
  }

  Widget _buildCategoriesView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _CategoryCard(
            category: category,
            onTap: () => _onCategoryTapped(category.name),
          );
        },
      ),
    );
  }

  Widget _buildHistoryView() {
    final theme = AppTheme.lightTheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Search',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _searchHistory.length,
              separatorBuilder: (_, __) => Divider(
                color: AppTheme.borderSubtle,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final searchTerm = _searchHistory[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.history,
                    color: AppTheme.textSecondary,
                  ),
                  title: Text(
                    searchTerm,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () => _removeFromHistory(index),
                  ),
                  onTap: () => _onHistoryItemTapped(searchTerm),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    final theme = AppTheme.lightTheme;
    return Column(
      children: [
        // Results summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Result for '${_searchController.text}'",
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Course list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _currentResults.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final course = _currentResults[index];
              return _CourseCard(course: course);
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryItem category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderSubtle,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.accentLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                category.icon,
                color: AppTheme.primaryTeal,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                category.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseItem course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return GestureDetector(
      onTap: () {
        // Navigate to course detail page
        // Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailPage(courseId: course.id)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderSubtle,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Course thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  course.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: AppTheme.accentLight,
                    child: Icon(
                      Icons.image,
                      color: AppTheme.primaryTeal,
                      size: 32,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Course details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    Text(
                      course.category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Course title
                    Text(
                      course.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Rating and student count
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: AppTheme.warningAmber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course.rating.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.people,
                          color: AppTheme.textSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course.studentCount} students',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryItem {
  final String name;
  final IconData icon;

  const CategoryItem(this.name, this.icon);
}

class CourseItem {
  final String id;
  final String title;
  final String category;
  final double rating;
  final int studentCount;
  final String imageUrl;

  CourseItem({
    required this.id,
    required this.title,
    required this.category,
    required this.rating,
    required this.studentCount,
    required this.imageUrl,
  });
}
