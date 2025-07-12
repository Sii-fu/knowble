import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import './widgets/course_list_item_card.dart';
import '../../widgets/custom_icon_widget.dart';

class AdminCoursesManagement extends StatefulWidget {
  const AdminCoursesManagement({super.key});

  @override
  State<AdminCoursesManagement> createState() => _AdminCoursesManagementState();
}

class _AdminCoursesManagementState extends State<AdminCoursesManagement> {
  int _currentIndex = 2; // Courses tab active
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSelectionMode = false;
  List<int> _selectedCourses = [];

  final List<Map<String, dynamic>> _mockCourses = [
    {
      "id": 1,
      "title": "Advanced Mathematics for Engineers",
      "instructor": "Dr. Sarah Johnson",
      "thumbnail":
          "https://images.unsplash.com/photo-1509228468518-180dd4864904?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      "enrollmentCount": 1284,
      "status": "pending",
      "category": "Mathematics",
      "createdAt": DateTime.now().subtract(const Duration(days: 2)),
      "reportCount": 0,
      "duration": "12 hours",
      "rating": 4.8,
    },
    {
      "id": 2,
      "title": "Computer Science Fundamentals",
      "instructor": "Prof. Michael Rodriguez",
      "thumbnail":
          "https://images.unsplash.com/photo-1517077304055-6e89abbf09b0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      "enrollmentCount": 956,
      "status": "approved",
      "category": "Computer Science",
      "createdAt": DateTime.now().subtract(const Duration(days: 5)),
      "reportCount": 0,
      "duration": "15 hours",
      "rating": 4.7,
    },
  ];

  List<Map<String, dynamic>> get _filteredCourses {
    if (_searchQuery.isEmpty) {
      return _mockCourses;
    }
    return _mockCourses.where((course) {
      final title = (course['title'] as String).toLowerCase();
      final instructor = (course['instructor'] as String).toLowerCase();
      final category = (course['category'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();

      return title.contains(query) ||
          instructor.contains(query) ||
          category.contains(query);
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedCourses.clear();
      }
    });
  }

  void _toggleCourseSelection(int courseId) {
    setState(() {
      if (_selectedCourses.contains(courseId)) {
        _selectedCourses.remove(courseId);
      } else {
        _selectedCourses.add(courseId);
      }
    });
  }

  void _performBulkAction(String action) {
    if (_selectedCourses.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action applied to ${_selectedCourses.length} courses'),
        backgroundColor: AppTheme.successGreen,
      ),
    );

    setState(() {
      _selectedCourses.clear();
      _isSelectionMode = false;
    });
  }

  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/admin/instructors');
        break;
      case 2:
        // Current screen
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/admin/users');
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 2.0,
        shadowColor: AppTheme.shadowLight,
        title: Text(
          'Courses Management',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          if (_isSelectionMode) ...[
            TextButton(
              onPressed: () => _performBulkAction('Approve'),
              child: Text(
                'Approve',
                style: TextStyle(color: AppTheme.successGreen),
              ),
            ),
            TextButton(
              onPressed: () => _performBulkAction('Flag'),
              child: Text('Flag', style: TextStyle(color: AppTheme.errorRed)),
            ),
          ] else ...[
            IconButton(
              onPressed: _toggleSelectionMode,
              icon: CustomIconWidget(
                iconName: 'checklist',
                color: AppTheme.primaryTeal,
                size: 24,
              ),
            ),
          ],
          SizedBox(width: 2.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Section
            Container(
              color: AppTheme.surfaceWhite,
              padding: EdgeInsets.all(4.w),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search courses, instructors, categories...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          )
                          : null,
                ),
              ),
            ),
            // Courses List
            Expanded(
              child:
                  _filteredCourses.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                        onRefresh: () async {
                          await Future.delayed(Duration(seconds: 1));
                        },
                        color: AppTheme.primaryTeal,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          itemCount: _filteredCourses.length,
                          itemBuilder: (context, index) {
                            final course = _filteredCourses[index];
                            final courseId = course['id'] as int;
                            final isSelected = _selectedCourses.contains(
                              courseId,
                            );

                            return CourseListItemCard(
                              course: course,
                              isSelectionMode: _isSelectionMode,
                              isSelected: isSelected,
                              onTap: () {
                                if (_isSelectionMode) {
                                  _toggleCourseSelection(courseId);
                                } else {
                                  // Handle course tap
                                }
                              },
                              onApprove: () => _approveCourse(course),
                              onFlag: () => _flagCourse(course),
                              onDelete: () => _deleteCourse(course),
                              onPreview: () => _showCoursePreview(course),
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surfaceWhite,
        selectedItemColor: AppTheme.primaryTeal,
        unselectedItemColor: AppTheme.textSecondary,
        elevation: 8.0,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              color:
                  _currentIndex == 0
                      ? AppTheme.primaryTeal
                      : AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'school',
              color:
                  _currentIndex == 1
                      ? AppTheme.primaryTeal
                      : AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Instructors',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'book',
              color:
                  _currentIndex == 2
                      ? AppTheme.primaryTeal
                      : AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'people',
              color:
                  _currentIndex == 3
                      ? AppTheme.primaryTeal
                      : AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Users',
          ),
        ],
      ),
    );
  }

  void _approveCourse(Map<String, dynamic> course) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Course "${course['title']}" approved'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _flagCourse(Map<String, dynamic> course) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Course "${course['title']}" flagged for review'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _deleteCourse(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Course'),
            content: Text(
              'Are you sure you want to delete "${course['title']}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Course "${course['title']}" deleted'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorRed,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showCoursePreview(Map<String, dynamic> course) {
    // Implementation for course preview
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'school_outlined',
              color: AppTheme.textSecondary,
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              'No Courses Found',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search criteria'
                  : 'No courses available for moderation',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
