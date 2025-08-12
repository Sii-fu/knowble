
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'create_course_screen.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  
  final List<String> _filters = ['All', 'Biology', 'Mathematics', 'Physics', 'Chemistry'];
  
  final List<CourseData> _courses = [
    CourseData(
      subject: 'Biology',
      title: 'Bacterial Biology Overview',
      subtitle: 'for College',
      students: '2.4k Students',
      duration: '3h 30m',
      icon: Icons.biotech,
      color: AppTheme.successGreen,
      rating: 4.8,
      level: 'Intermediate',
    ),
    CourseData(
      subject: 'Biology',
      title: 'Metabolic Biochemistry for High School',
      subtitle: 'Advanced concepts',
      students: '1k Students',
      duration: '2h 30m',
      icon: Icons.science,
      color: Colors.teal,
      rating: 4.6,
      level: 'Advanced',
    ),
    CourseData(
      subject: 'Biology',
      title: 'Mendelian Genetics & Mechanisms of Heredity',
      subtitle: 'Genetics fundamentals',
      students: '3k Students',
      duration: '2h 45m',
      icon: Icons.psychology,
      color: Colors.purple,
      rating: 4.9,
      level: 'Beginner',
    ),
    CourseData(
      subject: 'Mathematics',
      title: 'High School Algebra I: Help and Review',
      subtitle: 'Complete algebra course',
      students: '2.6k Students',
      duration: '4h 30m',
      icon: Icons.calculate,
      color: AppTheme.primaryTeal,
      rating: 4.7,
      level: 'Beginner',
    ),
  ];

  List<CourseData> get _filteredCourses {
    if (_selectedFilter == 'All') return _courses;
    return _courses.where((course) => course.subject == _selectedFilter).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppTheme.surfaceWhite,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'My Courses',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppTheme.accentLight,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.filter_list, color: AppTheme.primaryTeal),
                onPressed: () {
                  // Handle filter action
                },
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              
              
              // Filter Chips
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        backgroundColor: AppTheme.surfaceWhite,
                        selectedColor: AppTheme.primaryTeal,
                        checkmarkColor: Colors.white,
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryTeal : AppTheme.borderSubtle,
                        ),
                        elevation: isSelected ? 2 : 0,
                        shadowColor: AppTheme.primaryTeal.withOpacity(0.3),
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
                      AppTheme.primaryTeal.withOpacity(0.1),
                      AppTheme.successGreen.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  children: [
                    _buildStatItem('${_filteredCourses.length}', 'Courses', Icons.book_outlined),
                    const SizedBox(width: 24),
                    _buildStatItem('8.2k', 'Students', Icons.people_outline),
                    const SizedBox(width: 24),
                    _buildStatItem('4.8', 'Rating', Icons.star_outline),
                  ],
                ),
              ),
              
              // Course List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: _filteredCourses.length,
                  itemBuilder: (context, index) {
                    return ModernCourseCard(
                      course: _filteredCourses[index],
                      onTap: () => _showCourseDetail(context, _filteredCourses[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Modern Floating Action Button
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateCourseScreen(),
              ),
            );
          },
          backgroundColor: AppTheme.primaryTeal,
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
              color: AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryTeal,
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
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
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

  void _showCourseDetail(BuildContext context, CourseData course) {
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (context) => CourseDetailScreen(
    //     title: course.title,
    //     subject: course.subject,
    //     students: course.students,
    //     duration: course.duration,
    //   ),
    // );
  }
}

class CourseData {
  final String subject;
  final String title;
  final String subtitle;
  final String students;
  final String duration;
  final IconData icon;
  final Color color;
  final double rating;
  final String level;

  CourseData({
    required this.subject,
    required this.title,
    required this.subtitle,
    required this.students,
    required this.duration,
    required this.icon,
    required this.color,
    required this.rating,
    required this.level,
  });
}

class ModernCourseCard extends StatelessWidget {
  final CourseData course;
  final VoidCallback onTap;

  const ModernCourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withOpacity(0.1),
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
                          colors: [
                            course.color,
                            course.color.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        course.icon,
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
                              color: course.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course.subject,
                              style: TextStyle(
                                color: course.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course.title,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
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
                    // Level Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getLevelColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        course.level,
                        style: TextStyle(
                          color: _getLevelColor(),
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
                    _buildStatChip(Icons.people_outline, course.students),
                    const SizedBox(width: 12),
                    _buildStatChip(Icons.access_time_rounded, course.duration),
                    const SizedBox(width: 12),
                    _buildStatChip(Icons.star_rounded, '${course.rating}'),
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
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor() {
    switch (course.level) {
      case 'Beginner':
        return AppTheme.successGreen;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return AppTheme.textSecondary;
    }
  }
}