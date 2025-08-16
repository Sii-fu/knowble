import 'package:flutter/material.dart';

import 'create_course_screen.dart';
import 'course_detail_screen.dart';
import '../../config/theme_instructor.dart';
import '../../core/services/Instructor/course_fetch.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final CourseFetchService _fetchService = CourseFetchService();
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  List<String> _availableFilters = ['All'];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    final courses = await _fetchService.fetchInstructorCoursesFull(); 

    // Extract unique categories for filters
    Set<String> categories = {'All'};
    for (final course in courses) {
      final courseTags = course['course_tags'] as List<dynamic>?;
      if (courseTags != null && courseTags.isNotEmpty) {
        final firstTag = courseTags[0] as Map<String, dynamic>?;
        if (firstTag != null) {
          final tags = firstTag['tags'] as Map<String, dynamic>?;
          if (tags != null) {
            final category = tags['name'] as String?;
            if (category != null && category.isNotEmpty) {
              categories.add(category);
            }
          }
        }
      }
    }

    setState(() {
      _courses = courses;
      _availableFilters = categories.toList();
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredCourses {
    if (_selectedFilter == 'All') return _courses;
    
    return _courses.where((course) {
      final courseTags = course['course_tags'] as List<dynamic>?;
      if (courseTags != null && courseTags.isNotEmpty) {
        final firstTag = courseTags[0] as Map<String, dynamic>?;
        if (firstTag != null) {
          final tags = firstTag['tags'] as Map<String, dynamic>?;
          if (tags != null) {
            final category = tags['name'] as String?;
            return category == _selectedFilter;
          }
        }
      }
      return false;
    }).toList();
  }

  int get _totalStudents {
    return _filteredCourses.fold<int>(0, (total, course) {
      final enrollments = course['enrollments'] as List<dynamic>?;
      return total + (enrollments?.length ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppThemeInstructor.lightTheme,
      child: Scaffold(
        backgroundColor: AppThemeInstructor.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppThemeInstructor.surfaceWhite,
          elevation: 0,
          
          title: Text(
            'My Courses',
            style: AppThemeInstructor.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppThemeInstructor.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppThemeInstructor.accentLight,
                shape: BoxShape.circle,
              ),
              
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Filter Chips
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _availableFilters.length,
                  itemBuilder: (context, index) {
                    final filter = _availableFilters[index];
                    final isSelected = _selectedFilter == filter;
                    
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppThemeInstructor.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        backgroundColor: AppThemeInstructor.surfaceWhite,
                        selectedColor: AppThemeInstructor.primaryBlue,
                        checkmarkColor: Colors.white,
                        side: BorderSide(
                          color: isSelected ? AppThemeInstructor.primaryBlue : AppThemeInstructor.borderSubtle,
                        ),
                        elevation: isSelected ? 2 : 0,
                        shadowColor: AppThemeInstructor.primaryBlue.withOpacity(0.3),
                      ),
                    );
                  },
                ),
              ),
              // Stats Row
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppThemeInstructor.primaryBlue.withOpacity(0.1),
                      AppThemeInstructor.successGreen.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppThemeInstructor.borderSubtle),
                ),
                child: Row(
                  children: [
                    _buildStatItem('${_filteredCourses.length}', 'Courses', Icons.book_outlined),
                    const SizedBox(width: 24),
                    _buildStatItem('$_totalStudents', 'Students', Icons.people_outline),
                    const SizedBox(width: 24),
                    _buildStatItem('4.8', 'Rating', Icons.star_outline),
                  ],
                ),
              ),
              // Course List
              Expanded(
                child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCourses.isEmpty
                    ? const Center(child: Text('No courses found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        itemCount: _filteredCourses.length,
                        itemBuilder: (context, index) {
                          final course = _filteredCourses[index];
                          return ModernCourseCard(
                            course: course,
                            onTap: () {
                              // Extract name from nested structure
                              String name = '';
                              final courseTags = course['course_tags'] as List<dynamic>?;
                              if (courseTags != null && courseTags.isNotEmpty) {
                                final firstTag = courseTags[0] as Map<String, dynamic>?;
                                if (firstTag != null) {
                                  final tags = firstTag['tags'] as Map<String, dynamic>?;
                                  if (tags != null) {
                                    name = tags['name'] as String? ?? '';
                                  }
                                }
                              }
                              
                              // Extract enrollment count
                              int studentCount = 0;
                              final enrollments = course['enrollments'] as List<dynamic>?;
                              if (enrollments != null) {
                                studentCount = enrollments.length;
                              }
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseDetailScreen(
                                    id: course['id'],
                                    title: course['title'] ?? '',
                                    subject: name,
                                    students: studentCount,
                                    duration: course['duration_days'] ?? 0,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateCourseScreen(),
              ),
            ).then((_) => _loadCourses());
          },
          backgroundColor: AppThemeInstructor.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          label: const Text(
            'Create Course',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppThemeInstructor.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppThemeInstructor.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: AppThemeInstructor.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: AppThemeInstructor.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ModernCourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onTap;

  const ModernCourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color mainColor = AppThemeInstructor.primaryBlue;
    final Color accentColor = AppThemeInstructor.successGreen;
    
    // Extract name from nested structure
    String name = 'General';
    final courseTags = course['course_tags'] as List<dynamic>?;
    if (courseTags != null && courseTags.isNotEmpty) {
      final firstTag = courseTags[0] as Map<String, dynamic>?;
      if (firstTag != null) {
        final tags = firstTag['tags'] as Map<String, dynamic>?;
        if (tags != null) {
          name = tags['name'] as String? ?? 'General';
        }
      }
    }
    
    // Extract enrollment count
    int studentCount = 0;
    final enrollments = course['enrollments'] as List<dynamic>?;
    if (enrollments != null) {
      studentCount = enrollments.length;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppThemeInstructor.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeInstructor.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppThemeInstructor.shadowLight.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Course Icon with gradient background
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [mainColor, mainColor.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.menu_book,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Course Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              name,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course['title'] ?? '',
                            style: TextStyle(
                              color: AppThemeInstructor.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Duration Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${course['duration_days'] ?? '-'} days',
                        style: TextStyle(
                          color: mainColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats Row
                Row(
                  children: [
                    _buildStatChip(Icons.people_outline, '$studentCount'),
                    const SizedBox(width: 12),
                    _buildStatChip(Icons.star_rounded, '4.8'),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppThemeInstructor.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppThemeInstructor.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppThemeInstructor.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: AppThemeInstructor.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

