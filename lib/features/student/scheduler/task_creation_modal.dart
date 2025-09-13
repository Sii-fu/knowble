import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:Knowble/config/theme.dart';
import '../../../core/services/reminder_service.dart';
import '../../../core/services/reminder_course_service.dart';
import '../../../data/models/course.dart';

class TaskCreationModal extends StatefulWidget {
  final DateTime? selectedDate;

  const TaskCreationModal({super.key, this.selectedDate});

  @override
  State<TaskCreationModal> createState() => _TaskCreationModalState();
}

class _TaskCreationModalState extends State<TaskCreationModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ReminderCourseService _reminderCourseService = ReminderCourseService();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _priority = 'Medium';
  String? _selectedCourseId;
  bool _isLoading = false;
  bool _isLoadingCourses = true;
  DateTime _selectedDate = DateTime.now();

  final List<String> _priorities = ['High', 'Medium', 'Low'];
  List<Course> _enrolledCourses = [];

  @override
  void initState() {
    super.initState();
    // Set selected date from widget parameter or default to today
    _selectedDate = widget.selectedDate ?? DateTime.now();
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
      });
    } catch (e) {
      print('Error fetching enrolled courses: $e');
      setState(() {
        _isLoadingCourses = false;
      });
    }
  }

  bool get _isFormValid {
    return _titleController.text.trim().isNotEmpty &&
        _startTime != null &&
        _endTime != null &&
        (_endTime!.hour > _startTime!.hour ||
            (_endTime!.hour == _startTime!.hour &&
                _endTime!.minute > _startTime!.minute));
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
              dayPeriodTextColor: AppTheme.textPrimary,
              dialHandColor: AppTheme.primaryTeal,
              dialBackgroundColor: AppTheme.surfaceWhite,
              dialTextColor: AppTheme.textPrimary,
              entryModeIconColor: AppTheme.primaryTeal,
              helpTextStyle: TextStyle(
                color: AppTheme.textPrimary,
                fontFamily: 'Jost',
              ),
              cancelButtonStyle: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(AppTheme.primaryTeal),
              ),
              confirmButtonStyle: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(AppTheme.primaryTeal),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      // Check if widget is still mounted
      setState(() {
        _startTime = picked;
        // Reset end time if it's now invalid
        if (_endTime != null &&
            (_endTime!.hour < picked.hour ||
                (_endTime!.hour == picked.hour &&
                    _endTime!.minute <= picked.minute))) {
          _endTime = null;
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    if (_startTime == null) {
      if (mounted) {
        // Check before accessing context
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select start time first'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          _endTime ??
          TimeOfDay(hour: _startTime!.hour + 1, minute: _startTime!.minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.surfaceWhite,
              hourMinuteTextColor: AppTheme.textPrimary,
              dayPeriodTextColor: AppTheme.textPrimary,
              dialHandColor: AppTheme.primaryTeal,
              dialBackgroundColor: AppTheme.surfaceWhite,
              dialTextColor: AppTheme.textPrimary,
              entryModeIconColor: AppTheme.primaryTeal,
              helpTextStyle: TextStyle(
                color: AppTheme.textPrimary,
                fontFamily: 'Jost',
              ),
              cancelButtonStyle: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(AppTheme.primaryTeal),
              ),
              confirmButtonStyle: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(AppTheme.primaryTeal),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      // Check if widget is still mounted
      // Validate end time is after start time
      if (picked.hour > _startTime!.hour ||
          (picked.hour == _startTime!.hour &&
              picked.minute > _startTime!.minute)) {
        setState(() {
          _endTime = picked;
        });
      } else {
        if (mounted) {
          // Check before accessing context
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('End time must be after start time'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(
        const Duration(days: 1),
      ), // Allow today
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ), // Allow up to 1 year in future
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppTheme.surfaceWhite,
              headerBackgroundColor: AppTheme.primaryTeal,
              headerForegroundColor: AppTheme.surfaceWhite,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.surfaceWhite;
                }
                return AppTheme.textPrimary;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.primaryTeal;
                }
                return Colors.transparent;
              }),
              todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.primaryTeal;
                }
                return AppTheme.primaryTeal.withOpacity(0.1);
              }),
              todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.surfaceWhite;
                }
                return AppTheme.primaryTeal;
              }),
              yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.surfaceWhite;
                }
                return AppTheme.textPrimary;
              }),
              yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.primaryTeal;
                }
                return Colors.transparent;
              }),
              cancelButtonStyle: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(AppTheme.primaryTeal),
              ),
              confirmButtonStyle: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(AppTheme.primaryTeal),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDateOnly = DateTime(date.year, date.month, date.day);

    if (selectedDateOnly == today) {
      return 'Today, ${date.day}/${date.month}/${date.year}';
    } else if (selectedDateOnly == tomorrow) {
      return 'Tomorrow, ${date.day}/${date.month}/${date.year}';
    } else if (selectedDateOnly == yesterday) {
      return 'Yesterday, ${date.day}/${date.month}/${date.year}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _saveTask() async {
    if (!_isFormValid) return;
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    // Prepare start and end DateTime using _selectedDate and _startTime/_endTime
    final DateTime startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final DateTime endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final String? error = await ReminderService.createReminder(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
      courseId: _selectedCourseId,
      priority: _priority,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Task "${_titleController.text.trim()}" created successfully',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.primaryTeal,
        ),
      );
      Navigator.of(context).pop(true); // Indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
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
                      'Add Task',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontFamily: 'Jost',
                      ),
                    ),
                    GestureDetector(
                      onTap: _isFormValid && !_isLoading ? _saveTask : null,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: _isFormValid && !_isLoading
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
                                color: _isFormValid
                                    ? AppTheme.surfaceWhite
                                    : AppTheme.textSecondary,
                                size: 5.w,
                              ),
                      ),
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
                          onChanged: (value) => setState(() {}),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Task title is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 3.h),

                        // Date Selection
                        Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Jost',
                          ),
                        ),
                        SizedBox(height: 1.h),
                        GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.primaryTeal,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDate(_selectedDate),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppTheme.textPrimary,
                                    fontFamily: 'Jost',
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  color: AppTheme.primaryTeal,
                                  size: 5.w,
                                ),
                              ],
                            ),
                          ),
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
                        Text(
                          'Enrolled Courses',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Jost',
                          ),
                        ),
                        SizedBox(height: 1.h),
                        DropdownButtonFormField<String>(
                          // Ensure the selected value exists in the items. If not, fall back to null
                          value: _selectedCourseId != null && _enrolledCourses.any((c) => c.id == _selectedCourseId)
                              ? _selectedCourseId
                              : null,
                          // Prevent overflow by expanding to available width
                          isExpanded: true,
                          decoration: InputDecoration(
                            hintText: 'Select a course (optional)',
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
                            // While loading, show a single loading item (null value)
                            if (_isLoadingCourses)
                              DropdownMenuItem<String>(
                                value: null,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppTheme.primaryTeal,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Loading courses...',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontFamily: 'Jost',
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (!_isLoadingCourses && _enrolledCourses.isEmpty)
                              // No enrolled courses: single informative null item
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
                              )
                            else
                              // When courses are available, show them only (no duplicate null items)
                              ..._enrolledCourses.map((course) {
                                return DropdownMenuItem<String>(
                                  value: course.id,
                                  child: Text(
                                    course.title,
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontFamily: 'Jost',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCourseId = newValue;
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
                            children: _priorities.map((priority) {
                              final isSelected = _priority == priority;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _priority = priority),
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
                          onChanged: (value) => setState(() {}),
                        ),

                        SizedBox(height: 4.h),

                        // Save Button (Mobile)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isFormValid && !_isLoading
                                ? _saveTask
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFormValid && !_isLoading
                                  ? AppTheme.primaryTeal
                                  : AppTheme.backgroundLight,
                              foregroundColor: _isFormValid && !_isLoading
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
                                    'Create Task',
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
