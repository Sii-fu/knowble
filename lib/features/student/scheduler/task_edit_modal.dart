import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import '../../../core/services/reminder_service.dart';
import '../../../core/services/reminder_course_service.dart';
import '../../../data/models/course.dart';
import '../../../data/models/reminder.dart';

class TaskEditModal extends StatefulWidget {
  final Reminder? reminder;

  const TaskEditModal({super.key, this.reminder});

  @override
  State<TaskEditModal> createState() => _TaskEditModalState();
}

class _TaskEditModalState extends State<TaskEditModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ReminderCourseService _reminderCourseService = ReminderCourseService();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _priority = 'Medium';
  String? _selectedCourseId;
  bool _hasChanges = false;
  bool _isLoading = false;
  bool _isLoadingCourses = true;
  Reminder? _currentReminder;
  final List<String> _priorityOptions = ['Low', 'Medium', 'High'];
  List<Course> _enrolledCourses = [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get reminder from route arguments if available
    final routeReminder =
        ModalRoute.of(context)?.settings.arguments as Reminder?;

    if (routeReminder != null && _currentReminder == null) {
      _currentReminder = routeReminder;
      _initializeFields();
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize with widget.reminder if provided
    _currentReminder = widget.reminder;
    _initializeFields();
    _fetchEnrolledCourses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchEnrolledCourses() async {
    try {
      final courses = await _reminderCourseService
          .fetchCurrentUserEnrolledCourses();
      setState(() {
        _enrolledCourses = courses;
        _isLoadingCourses = false;

        // If the selected course is not in the enrolled courses list, reset it
        if (_selectedCourseId != null &&
            !courses.any((course) => course.id == _selectedCourseId)) {
          print(
            'Selected course $_selectedCourseId not found in enrolled courses, resetting',
          );
          _selectedCourseId = null;
          _hasChanges = true;
        }
      });
    } catch (e) {
      print('Error fetching enrolled courses: $e');
      setState(() {
        _isLoadingCourses = false;
        // Reset selected course on error
        if (_selectedCourseId != null) {
          print('Resetting selected course due to fetch error');
          _selectedCourseId = null;
          _hasChanges = true;
        }
      });
    }
  }

  void _initializeFields() {
    if (_currentReminder != null) {
      print('Initializing fields with reminder: ${_currentReminder!.title}');
      print('Reminder course ID: ${_currentReminder!.courseId}');

      _titleController.text = _currentReminder!.title;
      _descriptionController.text = _currentReminder!.description ?? '';
      _priority = _currentReminder!.priority;
      _selectedCourseId = _currentReminder!.courseId;

      // Parse DateTime to TimeOfDay for start and end times
      _startTime = TimeOfDay.fromDateTime(_currentReminder!.time);

      if (_currentReminder!.endTime != null) {
        _endTime = TimeOfDay.fromDateTime(_currentReminder!.endTime!);
      }

      print('Initialized selected course ID: $_selectedCourseId');
    } else {
      print('No reminder data available for initialization');
    }

    // Add listeners to detect changes
    _titleController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _onPriorityChanged(String? newPriority) {
    if (newPriority != null && newPriority != _priority) {
      setState(() {
        _priority = newPriority;
        _hasChanges = true;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.surfaceWhite,
              hourMinuteTextColor: AppTheme.textPrimary,
              dialHandColor: AppTheme.primaryTeal,
              dialBackgroundColor: AppTheme.surfaceWhite,
              entryModeIconColor: AppTheme.primaryTeal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        _hasChanges = true;

        // Validate end time is after start time
        if (_endTime != null && _isEndTimeBeforeStartTime()) {
          _endTime = TimeOfDay(hour: picked.hour + 1, minute: picked.minute);
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          _endTime ??
          (_startTime != null
              ? TimeOfDay(
                  hour: _startTime!.hour + 1,
                  minute: _startTime!.minute,
                )
              : TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.surfaceWhite,
              hourMinuteTextColor: AppTheme.textPrimary,
              dialHandColor: AppTheme.primaryTeal,
              dialBackgroundColor: AppTheme.surfaceWhite,
              entryModeIconColor: AppTheme.primaryTeal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
        _hasChanges = true;
      });
    }
  }

  bool _isEndTimeBeforeStartTime() {
    if (_startTime == null || _endTime == null) return false;

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    return endMinutes <= startMinutes;
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select Time';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return AppTheme.primaryTeal;
      case 'Low':
        return Colors.green;
      default:
        return AppTheme.primaryTeal;
    }
  }

  String? _getValidDropdownValue() {
    // If courses are still loading, return null
    if (_isLoadingCourses) {
      return null;
    }

    // If no course is selected, return null
    if (_selectedCourseId == null) {
      return null;
    }

    // If the selected course exists in enrolled courses, return it
    if (_enrolledCourses.any((course) => course.id == _selectedCourseId)) {
      return _selectedCourseId;
    }

    // If selected course doesn't exist in enrolled courses, return null
    return null;
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both start and end times'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_isEndTimeBeforeStartTime()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    // Use the existing reminder's date for start and end DateTime
    final DateTime date = _currentReminder?.time ?? DateTime.now();
    final DateTime startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final DateTime endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final String? error = await ReminderService.updateReminder(
      reminderId: _currentReminder?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
      courseId: _selectedCourseId,
      priority: _priority,
    );

    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task updated successfully'),
          backgroundColor: AppTheme.primaryTeal,
        ),
      );
      Navigator.of(context).pop(true); // Indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Task',
          style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
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

    if (confirmed == true) {
      Navigator.of(
        context,
      ).pop({'action': 'delete', 'taskId': _currentReminder?.id});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.close,
                          color: AppTheme.textPrimary,
                          size: 5.w,
                        ),
                      ),
                    ),
                    Text(
                      'Edit Task',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontFamily: 'Jost',
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _deleteTask,
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 5.w,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        GestureDetector(
                          onTap: _hasChanges && !_isLoading ? _saveTask : null,
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: _hasChanges && !_isLoading
                                  ? AppTheme.primaryTeal
                                  : AppTheme.backgroundLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.surfaceWhite,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.check,
                                    color: _hasChanges
                                        ? AppTheme.surfaceWhite
                                        : AppTheme.textSecondary,
                                    size: 5.w,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task Title
                        Text(
                          'Task Title',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Jost',
                          ),
                        ),
                        SizedBox(height: 1.h),
                        TextFormField(
                          controller: _titleController,
                          maxLength: 50,
                          style: TextStyle(
                            fontFamily: 'Jost',
                            color: AppTheme.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter task title',
                            counterText: '${_titleController.text.length}/50',
                            counterStyle: TextStyle(
                              fontFamily: 'Jost',
                              fontSize: 10.sp,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppTheme.borderSubtle,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppTheme.primaryTeal,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: AppTheme.backgroundLight,
                            hintStyle: TextStyle(
                              fontFamily: 'Jost',
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Task title is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 3.h),

                        // Time Selection
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Time',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textPrimary,
                                      fontFamily: 'Jost',
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  GestureDetector(
                                    onTap: _selectStartTime,
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.backgroundLight,
                                        borderRadius: BorderRadius.circular(12),
                                        border: _startTime == null
                                            ? Border.all(
                                                color: AppTheme.borderSubtle,
                                              )
                                            : Border.all(
                                                color: AppTheme.primaryTeal,
                                                width: 2,
                                              ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatTime(_startTime),
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: _startTime == null
                                                  ? AppTheme.textSecondary
                                                  : AppTheme.textPrimary,
                                              fontFamily: 'Jost',
                                            ),
                                          ),
                                          Icon(
                                            Icons.access_time,
                                            color: _startTime == null
                                                ? AppTheme.textSecondary
                                                : AppTheme.primaryTeal,
                                            size: 5.w,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'End Time',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textPrimary,
                                      fontFamily: 'Jost',
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  GestureDetector(
                                    onTap: _selectEndTime,
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.backgroundLight,
                                        borderRadius: BorderRadius.circular(12),
                                        border: _endTime == null
                                            ? Border.all(
                                                color: AppTheme.borderSubtle,
                                              )
                                            : Border.all(
                                                color: AppTheme.primaryTeal,
                                                width: 2,
                                              ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatTime(_endTime),
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: _endTime == null
                                                  ? AppTheme.textSecondary
                                                  : AppTheme.textPrimary,
                                              fontFamily: 'Jost',
                                            ),
                                          ),
                                          Icon(
                                            Icons.access_time,
                                            color: _endTime == null
                                                ? AppTheme.textSecondary
                                                : AppTheme.primaryTeal,
                                            size: 5.w,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 3.h),

                        // Enrolled Courses Selection
                        Row(
                          children: [
                            Text(
                              'Enrolled Courses',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                                fontFamily: 'Jost',
                              ),
                            ),
                            if (_isLoadingCourses) ...[
                              SizedBox(width: 2.w),
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
                            ],
                          ],
                        ),
                        SizedBox(height: 1.h),
                        DropdownButtonFormField<String>(
                          value: _getValidDropdownValue(),
                          decoration: InputDecoration(
                            hintText: _isLoadingCourses
                                ? 'Loading courses...'
                                : 'Select a course (optional)',
                            hintStyle: TextStyle(
                              color: AppTheme.textSecondary,
                              fontFamily: 'Jost',
                              fontSize: 14.sp,
                            ),
                            contentPadding: EdgeInsets.all(16),
                            filled: true,
                            fillColor: AppTheme.backgroundLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppTheme.borderSubtle,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppTheme.borderSubtle,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppTheme.primaryTeal,
                                width: 2,
                              ),
                            ),
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                'No course selected',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontFamily: 'Jost',
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                            if (!_isLoadingCourses &&
                                _enrolledCourses.isNotEmpty)
                              ..._enrolledCourses.map((course) {
                                return DropdownMenuItem<String>(
                                  value: course.id,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        course.title,
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontFamily: 'Jost',
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (course.description.isNotEmpty)
                                        Text(
                                          course.description.length > 30
                                              ? '${course.description.substring(0, 30)}...'
                                              : course.description,
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontFamily: 'Jost',
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            if (!_isLoadingCourses && _enrolledCourses.isEmpty)
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(
                                  'No enrolled courses found',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontFamily: 'Jost',
                                    fontSize: 14.sp,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                          onChanged: _isLoadingCourses
                              ? null
                              : (String? newValue) {
                                  setState(() {
                                    _selectedCourseId = newValue;
                                    _hasChanges = true;
                                  });
                                },
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontFamily: 'Jost',
                            fontSize: 14.sp,
                          ),
                          dropdownColor: AppTheme.surfaceWhite,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppTheme.textSecondary,
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // Priority Selection
                        Text(
                          'Priority',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Jost',
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: _priorityOptions.map((priority) {
                              final isSelected = _priority == priority;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => _onPriorityChanged(priority),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _getPriorityColor(priority)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      priority,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Jost',
                                        color: isSelected
                                            ? AppTheme.surfaceWhite
                                            : AppTheme.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // Description
                        Text(
                          'Description (Optional)',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Jost',
                          ),
                        ),
                        SizedBox(height: 1.h),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          maxLength: 200,
                          style: TextStyle(
                            fontFamily: 'Jost',
                            color: AppTheme.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Add task description, notes, or study materials...',
                            counterText:
                                '${_descriptionController.text.length}/200',
                            counterStyle: TextStyle(
                              fontFamily: 'Jost',
                              fontSize: 10.sp,
                            ),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppTheme.borderSubtle,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppTheme.primaryTeal,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: AppTheme.backgroundLight,
                            hintStyle: TextStyle(
                              fontFamily: 'Jost',
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // Update Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _hasChanges && !_isLoading
                                ? _saveTask
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasChanges && !_isLoading
                                  ? AppTheme.primaryTeal
                                  : AppTheme.backgroundLight,
                              foregroundColor: _hasChanges && !_isLoading
                                  ? AppTheme.surfaceWhite
                                  : AppTheme.textSecondary,
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.surfaceWhite,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Update Task',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Jost',
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ), // Close Column
        ), // Close Container
      ), // Close SafeArea
    ); // Close Scaffold
  }
}
