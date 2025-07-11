import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';

class TaskDetailView extends StatefulWidget {
  const TaskDetailView({super.key});

  @override
  State<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  // Mock task data
  final Map<String, dynamic> taskData = {
    "id": 1,
    "title": "Advanced Calculus Study Session",
    "description":
        "Review integration techniques, practice solving complex integrals, and prepare for upcoming midterm exam. Focus on integration by parts, trigonometric substitution, and partial fractions.",
    "startTime": "09:00 AM",
    "endTime": "11:30 AM",
    "priority": "High",
    "course_id": "course-1", // Added course_id
    "date": "July 11, 2025",
    "createdAt": "July 10, 2025 at 3:45 PM",
    "modifiedAt": "July 11, 2025 at 8:20 AM",
    "subject": "Mathematics",
    "location": "Library Study Room 3A",
  };

  // TODO: Replace with actual backend data
  final List<Map<String, dynamic>> _enrolledCourses = [
    {'id': 'course-1', 'name': 'Mathematics 101', 'code': 'MATH101'},
    {'id': 'course-2', 'name': 'Physics Fundamentals', 'code': 'PHYS200'},
    {'id': 'course-3', 'name': 'Computer Science Basics', 'code': 'CS101'},
    {'id': 'course-4', 'name': 'Chemistry Laboratory', 'code': 'CHEM150'},
    {'id': 'course-5', 'name': 'English Literature', 'code': 'ENG201'},
    {'id': 'course-6', 'name': 'Biology Essentials', 'code': 'BIO100'},
  ];

  Map<String, dynamic>? _getCourseInfo(String? courseId) {
    if (courseId == null) return null;
    try {
      return _enrolledCourses.firstWhere((course) => course['id'] == courseId);
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

  Color _getSubjectColor(String subject) {
    final int hash = subject.hashCode;
    final List<Color> colors = [
      Colors.blue,
      Colors.purple,
      Colors.indigo,
      Colors.teal,
      Colors.cyan,
      Colors.pink,
      Colors.amber,
      Colors.deepOrange,
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
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
        ),
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
        IconButton(
          onPressed: () => _navigateToEditTask(context),
          icon: Icon(Icons.edit, color: AppTheme.primaryTeal, size: 6.w),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildTimeRangeCard() {
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
            taskData["date"],
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
                  taskData["startTime"],
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
                  taskData["endTime"],
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
            "Duration: 2 hours 30 minutes",
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
            taskData["title"],
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              fontFamily: 'Jost',
            ),
          ),

          SizedBox(height: 3.h),

          // Tags row
          Row(
            children: [
              // Subject tag
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getSubjectColor(taskData["subject"]).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  taskData["subject"],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: _getSubjectColor(taskData["subject"]),
                    fontFamily: 'Jost',
                  ),
                ),
              ),

              SizedBox(width: 3.w),

              // Priority tag
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getPriorityColor(
                    taskData["priority"],
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
                        color: _getPriorityColor(taskData["priority"]),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      taskData["priority"],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: _getPriorityColor(taskData["priority"]),
                        fontFamily: 'Jost',
                      ),
                    ),
                  ],
                ),
              ),
              // Course Information (if available)
              if (_getCourseInfo(taskData["course_id"]) != null)
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getCourseInfo(taskData["course_id"])!['name'],
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryTeal,
                              fontFamily: 'Jost',
                            ),
                          ),
                          Text(
                            _getCourseInfo(taskData["course_id"])!['code'],
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppTheme.primaryTeal,
                              fontFamily: 'Jost',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: 3.h),

          // Description
          if (taskData["description"].isNotEmpty) ...[
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
              taskData["description"],
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textSecondary,
                fontFamily: 'Jost',
                height: 1.5,
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // Location
          if (taskData["location"].isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.location_on, color: AppTheme.primaryTeal, size: 5.w),
                SizedBox(width: 2.w),
                Text(
                  "Location",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Jost',
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              taskData["location"],
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textSecondary,
                fontFamily: 'Jost',
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // Metadata
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Created: ${taskData["createdAt"]}",
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppTheme.textSecondary,
                  fontFamily: 'Jost',
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                "Last modified: ${taskData["modifiedAt"]}",
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
    Navigator.pushNamed(context, '/task-edit-modal', arguments: taskData);
  }

  void _deleteTask(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Task',
              style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Jost'),
            ),
            content: Text(
              'Are you sure you want to delete this task? This action cannot be undone.',
              style: TextStyle(fontFamily: 'Jost'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontFamily: 'Jost',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to calendar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Task deleted successfully'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white, fontFamily: 'Jost'),
                ),
              ),
            ],
          ),
    );
  }
}
