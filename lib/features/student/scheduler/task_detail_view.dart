import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import '../../../core/services/reminder_service.dart';
import '../../../core/services/reminder_course_service.dart';
import '../../../data/models/reminder.dart';
import '../../../data/models/course.dart';

class TaskDetailView extends StatefulWidget {
  const TaskDetailView({super.key});

  @override
  State<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  Reminder? _reminder; // Actual reminder data from Supabase
  bool _isLoading = true; // Loading state
  String? _errorMessage; // Error message if loading fails

  // Backend course data
  final ReminderCourseService _reminderCourseService = ReminderCourseService();
  List<Course> _enrolledCourses = [];
  bool _isLoadingCourses = false;

  @override
  void initState() {
    super.initState();
    // Load reminder data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReminderData();
    });
  }

  void _loadReminderData() async {
    // Get reminder data passed from calendar dashboard
    final reminder = ModalRoute.of(context)?.settings.arguments as Reminder?;

    if (reminder != null) {
      setState(() {
        _reminder = reminder;
        _isLoading = false;
      });
      // Load courses for the course information display
      await _fetchEnrolledCourses();
    } else {
      setState(() {
        _errorMessage = 'No task data provided';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchEnrolledCourses() async {
    if (!mounted) return;
    setState(() {
      _isLoadingCourses = true;
    });

    try {
      final courses = await _reminderCourseService
          .fetchCurrentUserEnrolledCourses();
      if (!mounted) return;
      setState(() {
        _enrolledCourses = courses;
        _isLoadingCourses = false;
      });
    } catch (e) {
      print('Error fetching enrolled courses: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingCourses = false;
      });
    }
  }

  Course? _getCourseInfo(String? courseId) {
    if (courseId == null) return null;
    try {
      return _enrolledCourses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _calculateDuration() {
    if (_reminder?.endTime == null) return 'No end time';

    final duration = _reminder!.endTime!.difference(_reminder!.time);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return 'Duration: $hours hours $minutes minutes';
    } else if (hours > 0) {
      return 'Duration: $hours hours';
    } else {
      return 'Duration: $minutes minutes';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshTaskData,
          color: AppTheme.primaryTeal,
          child: _isLoading
              ? _buildLoadingState()
              : _errorMessage != null
              ? _buildErrorState()
              : _buildTaskContent(),
        ),
      ),
    );
  }

  Future<void> _refreshTaskData() async {
    if (_reminder != null) {
      await _fetchEnrolledCourses();
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading task details...',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontFamily: 'Jost',
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 15.w, color: Colors.red),
              SizedBox(height: 2.h),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Jost',
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: AppTheme.surfaceWhite,
                ),
                child: Text('Go Back', style: TextStyle(fontFamily: 'Jost')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRangeCard(),
          SizedBox(height: 3.h),
          _buildTaskInfoCard(),
          SizedBox(height: 3.h),
          _buildActionButtons(context),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundLight,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 6.w),
      ),
      title: Text(
        'Task Details',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
          fontFamily: 'Jost',
        ),
      ),
      centerTitle: true,
      actions: [
        if (!_isLoading && _reminder != null) ...[
          IconButton(
            onPressed: _isLoadingCourses ? null : _refreshTaskData,
            icon: _isLoadingCourses
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryTeal,
                      ),
                    ),
                  )
                : Icon(Icons.refresh, color: AppTheme.primaryTeal, size: 6.w),
          ),
          IconButton(
            onPressed: () => _navigateToEditTask(context),
            icon: Icon(Icons.edit, color: AppTheme.primaryTeal, size: 6.w),
          ),
        ],
        SizedBox(width: 1.w),
      ],
    );
  }

  Widget _buildTimeRangeCard() {
    if (_reminder == null) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date
          Text(
            _reminder!.formattedDate,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryTeal,
              fontFamily: 'Jost',
            ),
          ),
          SizedBox(height: 2.h),

          // Time Range
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _reminder!.formattedStartTime,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTeal,
                    fontFamily: 'Jost',
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Container(width: 8.w, height: 2, color: AppTheme.primaryTeal),
              SizedBox(width: 3.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _reminder!.formattedEndTime,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTeal,
                    fontFamily: 'Jost',
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Duration calculation
          Text(
            _calculateDuration(),
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textSecondary,
              fontFamily: 'Jost',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskInfoCard() {
    if (_reminder == null) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            _reminder!.title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              fontFamily: 'Jost',
            ),
          ),

          SizedBox(height: 3.h),

          // Tags row
          Wrap(
            spacing: 3.w,
            runSpacing: 1.h,
            children: [
              // Priority tag
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getPriorityColor(
                    _reminder!.priority,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(_reminder!.priority),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _reminder!.priority,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: _getPriorityColor(_reminder!.priority),
                        fontFamily: 'Jost',
                      ),
                    ),
                  ],
                ),
              ),

              // Course Information (if available)
              if (_getCourseInfo(_reminder!.courseId) != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryTeal.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school,
                        size: 4.w,
                        color: AppTheme.primaryTeal,
                      ),
                      SizedBox(width: 1.w),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getCourseInfo(_reminder!.courseId)!.title,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.primaryTeal,
                                fontFamily: 'Jost',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_getCourseInfo(
                              _reminder!.courseId,
                            )!.description.isNotEmpty)
                              Text(
                                _getCourseInfo(
                                          _reminder!.courseId,
                                        )!.description.length >
                                        20
                                    ? '${_getCourseInfo(_reminder!.courseId)!.description.substring(0, 20)}...'
                                    : _getCourseInfo(
                                        _reminder!.courseId,
                                      )!.description,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppTheme.primaryTeal.withOpacity(0.8),
                                  fontFamily: 'Jost',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              // Show course ID if course data not found but ID exists
              else if (_reminder!.courseId != null && !_isLoadingCourses)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.textSecondary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 4.w,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Course not found',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppTheme.textSecondary,
                          fontFamily: 'Jost',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

              // Show loading indicator if courses are still loading
              if (_isLoadingCourses && _reminder!.courseId != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderSubtle, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryTeal,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Loading course info...',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppTheme.textSecondary,
                          fontFamily: 'Jost',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: 3.h),

          // Description
          if (_reminder!.description != null &&
              _reminder!.description!.isNotEmpty) ...[
            Text(
              "Description",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontFamily: 'Jost',
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _reminder!.description!,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textSecondary,
                fontFamily: 'Jost',
                height: 1.5,
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // Metadata
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Task ID: ${_reminder!.id}",
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppTheme.textSecondary,
                  fontFamily: 'Jost',
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                "User ID: ${_reminder!.userId}",
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppTheme.textSecondary,
                  fontFamily: 'Jost',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _navigateToEditTask(context),
            icon: Icon(Icons.edit, size: 5.w),
            label: Text(
              'Edit Task',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Jost',
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: AppTheme.surfaceWhite,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _deleteTask(context),
            icon: Icon(Icons.delete, size: 5.w, color: Colors.red),
            label: Text(
              'Delete',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red,
                fontFamily: 'Jost',
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red),
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

void _navigateToEditTask(BuildContext context) {
  Navigator.pushNamed(
    context,
    '/task-edit-modal',
    arguments: _reminder, 
  );
}
  void _deleteTask(BuildContext context) async {
    if (_reminder == null) return;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Task',
          style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Jost'),
        ),
        content: Text(
          'Are you sure you want to delete "${_reminder!.title}"? This action cannot be undone.',
          style: TextStyle(fontFamily: 'Jost'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontFamily: 'Jost',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white, fontFamily: 'Jost'),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        final error = await ReminderService.deleteReminder(_reminder!.id);

        if (error == null) {
          Navigator.of(context).pop(); // Go back to calendar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task "${_reminder!.title}" deleted successfully'),
              backgroundColor: AppTheme.primaryTeal,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete task. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
