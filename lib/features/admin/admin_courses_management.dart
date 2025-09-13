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
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  final AdminCourseService _adminCourseService = AdminCourseService();

  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreCourses = true;
  static const int _batchSize = 5;
  int _currentOffset = 0;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreCourses();
    }
  }

  Future<void> _loadCourses({bool isRefresh = false}) async {
    print('🔍 AdminCoursesManagement: Starting to load courses...');

    if (isRefresh) {
      _currentOffset = 0;
      _hasMoreCourses = true;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print(
        '🔍 AdminCoursesManagement: Loading courses batch (offset=$_currentOffset, batchSize=$_batchSize, search="$_searchQuery")...',
      );

      final result = await _adminCourseService.fetchCoursesForAdminPaginated(
        offset: _currentOffset,
        batchSize: _batchSize,
        searchQuery: _searchQuery,
      );

      final batchCourses = result['courses'] as List<Map<String, dynamic>>;
      final hasMore = result['hasMore'] as bool;
      final nextOffset = result['nextOffset'] as int;

      print(
        '🔍 AdminCoursesManagement: Received ${batchCourses.length} courses in batch, hasMore=$hasMore',
      );

      setState(() {
        if (isRefresh) {
          _courses = batchCourses;
        } else {
          _courses.addAll(batchCourses);
        }
        _isLoading = false;
        _currentOffset = nextOffset;
        _hasMoreCourses = hasMore;
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

  Future<void> _loadMoreCourses() async {
    if (_isLoadingMore || !_hasMoreCourses) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      print(
        '🔍 AdminCoursesManagement: Loading more courses (offset=$_currentOffset, batchSize=$_batchSize)...',
      );

      final result = await _adminCourseService.fetchCoursesForAdminPaginated(
        offset: _currentOffset,
        batchSize: _batchSize,
        searchQuery: _searchQuery,
      );

      final moreCourses = result['courses'] as List<Map<String, dynamic>>;
      final hasMore = result['hasMore'] as bool;
      final nextOffset = result['nextOffset'] as int;

      print(
        '🔍 AdminCoursesManagement: Loaded ${moreCourses.length} more courses, hasMore=$hasMore',
      );

      setState(() {
        _courses.addAll(moreCourses);
        _isLoadingMore = false;
        _currentOffset = nextOffset;
        _hasMoreCourses = hasMore;
      });
    } catch (e) {
      print('❌ Error loading more courses: $e');
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _currentOffset = 0;
      _hasMoreCourses = true;
    });

    // Reset and reload with search query
    _loadCourses(isRefresh: true);
  }


  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;

    // Don't update _currentIndex when navigating away since page will be replaced
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
      case 4:
        Navigator.pushReplacementNamed(context, '/admin/user-verification');
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 6.w,
        toolbarHeight: 8.h,
        title: Text(
          'Courses Management',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          SizedBox(width: 4.w),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Column(
            children: [
              // Search Section
              Container(
                height: 6.h, // Reduced height
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryTeal, // Thin teal border
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search courses, instructors, categories...',
                    hintStyle: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: CustomIconWidget(
                        iconName: 'search',
                        color:
                            AppTheme.primaryTeal, // Teal color for search icon
                        size: 28, // Bigger search icon
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
                              size: 24,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              // Courses List
              Expanded(
                child: _isLoading && _courses.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _courses.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => _loadCourses(isRefresh: true),
                        color: AppTheme.primaryTeal,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.only(bottom: 2.h),
                          itemCount: _courses.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show loading indicator for more items
                            if (index == _courses.length) {
                              return Container(
                                padding: EdgeInsets.all(4.w),
                                child: Center(
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(
                                        color: AppTheme.primaryTeal,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Loading more courses...',
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final course = _courses[index];

                            return Container(
                              margin: EdgeInsets.only(bottom: 3.h),
                              child: CourseListItemCard(
                                course: course,
                                onTap: () {
                                  // Handle course tap
                                },
                                onDetails: () => _showCoursePreview(course),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
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
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'verified_user',
              color: _currentIndex == 4
                  ? AppTheme.primaryTeal
                  : AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Verification',
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
        _loadCourses(isRefresh: true);
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
