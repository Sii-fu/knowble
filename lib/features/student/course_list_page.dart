import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'filter_page.dart';

class CourseListPage extends StatefulWidget {
  final String searchQuery;

  const CourseListPage({
    super.key,
    required this.searchQuery,
  });

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  late TextEditingController _searchController;
  List<CourseItem> _courses = [];
  Map<String, dynamic>? _appliedFilters;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _loadCourses();
  }

  void _loadCourses() {
    // Sample course data - in a real app, this would come from your backend
    _courses = [
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

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Online Courses',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: AppTheme.surfaceWhite,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0.5,
          shadowColor: AppTheme.shadowLight,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: AppTheme.backgroundLight,
        body: Column(
          children: [
            // Search bar with filter button
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
                      decoration: InputDecoration(
                        hintText: 'Search courses...',
                        hintStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      style: TextStyle(color: AppTheme.textPrimary),
                      onSubmitted: (value) {
                        setState(() {
                          // Update search results based on new query
                          _loadCourses();
                        });
                      },
                    ),
                  ),
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
                            _loadCourses();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Results summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Result for '${widget.searchQuery}'",
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
                itemCount: _courses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  return _CourseCard(course: course);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
