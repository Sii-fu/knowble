import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:Knowble/config/theme.dart';
import './widgets/course_list_item_card.dart';
import './widgets/course_preview_modal.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../core/services/admin/admin_course_service.dart';

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
  final List<String> _selectedCourses = [];
  final AdminCourseService _adminCourseService = AdminCourseService();

  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    print('🔍 AdminCoursesManagement: Starting to load courses...');
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔍 AdminCoursesManagement: Calling fetchAllCoursesForAdmin...');
      final courses = await _adminCourseService.fetchAllCoursesForAdmin();
      print('🔍 AdminCoursesManagement: Received ${courses.length} courses');
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ AdminCoursesManagement: Error loading courses: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading courses: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredCourses {
    if (_searchQuery.isEmpty) {
      return _courses;
    }
    return _courses.where((course) {
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

  void _toggleCourseSelection(String courseId) {
    setState(() {
      if (_selectedCourses.contains(courseId)) {
        _selectedCourses.remove(courseId);
      } else {
        _selectedCourses.add(courseId);
      }
    });
  }

  void _performBulkAction(String action) async {
    if (_selectedCourses.isEmpty) return;

    try {
      String status;
      switch (action.toLowerCase()) {
        case 'approve':
          status = 'approved';
          break;
        case 'reject':
          status = 'rejected';
          break;
        default:
          return;
      }

      final success = await _adminCourseService.bulkUpdateCourseStatus(
        _selectedCourses,
        status,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$action applied to ${_selectedCourses.length} courses',
            ),
            backgroundColor: action == 'approve'
                ? AppTheme.successGreen
                : AppTheme.errorRed,
          ),
        );

        setState(() {
          _selectedCourses.clear();
          _isSelectionMode = false;
        });

        // Reload courses to reflect changes
        _loadCourses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to $action courses'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
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
              onPressed: () => _performBulkAction('Reject'),
              child: Text('Reject', style: TextStyle(color: AppTheme.errorRed)),
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
                  suffixIcon: _searchQuery.isNotEmpty
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCourses.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadCourses,
                      color: AppTheme.primaryTeal,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        itemCount: _filteredCourses.length,
                        itemBuilder: (context, index) {
                          final course = _filteredCourses[index];
                          final courseId = course['id'] as String;
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
                            onDetails: () => _showCoursePreview(course),
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
              color: _currentIndex == 0
                  ? AppTheme.primaryTeal
                  : AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'school',
              color: _currentIndex == 1
                  ? AppTheme.primaryTeal
                  : AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Instructors',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'book',
              color: _currentIndex == 2
                  ? AppTheme.primaryTeal
                  : AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'people',
              color: _currentIndex == 3
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

  void _showCoursePreview(Map<String, dynamic> course) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Fetch detailed course information
      final detailedCourse = await _adminCourseService.fetchCourseDetails(
        course['id'] as String,
      );

      // Close loading dialog
      Navigator.pop(context);

      if (detailedCourse != null) {
        showDialog(
          context: context,
          builder: (context) => CoursePreviewModal(
            course: detailedCourse,
            onDecision: (decision, reason) {
              _handleCourseDecision(detailedCourse, decision, reason);
            },
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load course details'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading course details: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _handleCourseDecision(
    Map<String, dynamic> course,
    String decision,
    String? reason,
  ) async {
    try {
      String status;
      switch (decision) {
        case 'approve':
          status = 'approved';
          break;
        case 'reject':
          status = 'rejected';
          break;
        default:
          return;
      }

      final success = await _adminCourseService.updateCourseStatus(
        course['id'] as String,
        status,
        reason: reason,
      );

      if (success) {
        String message;
        Color backgroundColor;

        switch (decision) {
          case 'approve':
            message = 'Course "${course['title']}" has been approved';
            backgroundColor = AppTheme.successGreen;
            break;
          case 'reject':
            message = 'Course "${course['title']}" has been rejected';
            backgroundColor = AppTheme.errorRed;
            break;
          default:
            return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                if (reason != null && reason.isNotEmpty) ...[
                  SizedBox(height: 0.5.h),
                  Text('Reason: $reason', style: TextStyle(fontSize: 12)),
                ],
              ],
            ),
            backgroundColor: backgroundColor,
            duration: Duration(seconds: 4),
          ),
        );

        // Reload courses to reflect changes
        _loadCourses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update course status'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
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
