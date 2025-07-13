import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import './scheduler/widgets/date_strip_widget.dart';
import './scheduler/widgets/empty_state_widget.dart';
import './scheduler/widgets/task_card_widget.dart';
import '../../core/services/reminder_service.dart';
import '../../data/models/reminder.dart';

class CalendarDashboard extends StatefulWidget {
  const CalendarDashboard({super.key});

  @override
  State<CalendarDashboard> createState() => _CalendarDashboardState();
}

class _CalendarDashboardState extends State<CalendarDashboard> {
  DateTime selectedDate = DateTime.now();
  bool isCalendarViewExpanded = false;
  final ScrollController _scrollController = ScrollController();

  // Replace mock data with real reminders from Supabase
  List<Reminder> _reminders = []; // List of actual Reminder objects
  bool _isLoading = false; // Loading state for data fetching
  String? _errorMessage; // Error message if fetch fails

  // Remove mock data and replace with filtered reminders
  List<Reminder> get filteredReminders {
    return _reminders.where((reminder) {
      return reminder.isOnDate(
        selectedDate,
      ); // Use the built-in method from Reminder model
    }).toList();
  }

  String get currentMonthYear {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[selectedDate.month - 1]} ${selectedDate.year}';
  }

  @override
  void initState() {
    super.initState();
    _loadRemindersForDate(selectedDate); // Load reminders when screen opens
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Load reminders for a specific date using ReminderService
  Future<void> _loadRemindersForDate(DateTime date) async {
    if (!mounted) return; // Check if widget is still mounted
    setState(() {
      _isLoading = true; // Show loading state
      _errorMessage = null; // Clear any previous errors
    });

    try {
      // Fetch reminders from Supabase using ReminderService
      final reminders = await ReminderService.getRemindersForDate(date);

      if (!mounted) return; // Check if widget is still mounted after async operation
      setState(() {
        _reminders = reminders; // Update reminders list
        _isLoading = false; // Hide loading state
      });

      // Log success for debugging
      print(
        '✅ Loaded ${reminders.length} reminders for ${date.toString().split(' ')[0]}',
      );
    } catch (e) {
      // Handle errors gracefully
      if (!mounted) return; // Check if widget is still mounted before setState
      setState(() {
        _errorMessage = 'Failed to load tasks. Please try again.';
        _isLoading = false;
      });

      // Log error for debugging
      print('❌ Error loading reminders: $e');
    }
  }

  void _onDateSelected(DateTime date) {
    if (!mounted) return; // Check if widget is still mounted
    setState(() {
      selectedDate = date;
    });
    _loadRemindersForDate(date); // Load reminders for newly selected date
  }

  void _toggleCalendarView() async {
    final DateTime? selectedDateFromCalendar =
        await Navigator.pushNamed(context, '/full-month-calendar-view')
            as DateTime?;

    if (selectedDateFromCalendar != null) {
      if (!mounted) return; // Check if widget is still mounted after navigation
      setState(() {
        selectedDate = selectedDateFromCalendar;
      });
      _loadRemindersForDate(
        selectedDateFromCalendar,
      ); // Load reminders for selected date
    }
  }

  void _onTaskTap(Reminder reminder) {
    // Pass the actual reminder data to task detail view
    Navigator.pushNamed(
      context,
      '/task-detail-view',
      arguments: reminder, // Pass Reminder object instead of mock data
    );
  }

  void _onTaskEdit(Reminder reminder) {
    Navigator.pushNamed(
      context,
      '/task-edit-modal',
      arguments: reminder, // Pass Reminder object for editing
    );
  }

  void _onTaskDelete(Reminder reminder) async {
    // Show confirmation dialog
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Task',
              style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Jost'),
            ),
            content: Text(
              'Are you sure you want to delete "${reminder.title}"? This action cannot be undone.',
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

    // If user confirmed deletion
    if (shouldDelete == true) {
      try {
        // Delete reminder using ReminderService
        final error = await ReminderService.deleteReminder(reminder.id);

        if (error == null) {
          // Success - reload reminders to update UI
          _loadRemindersForDate(selectedDate);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task "${reminder.title}" deleted successfully'),
              backgroundColor: AppTheme.primaryTeal,
            ),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        // Handle unexpected errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete task. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onAddTask() async {
    // Navigate to task creation modal and pass selected date
    final result = await Navigator.pushNamed(
      context,
      '/task-creation-modal',
      arguments: selectedDate, // Pass selected date to creation modal
    );

    // If task was created successfully, reload reminders
    if (result != null) {
      _loadRemindersForDate(selectedDate);
    }
  }

  Future<void> _onRefresh() async {
    // Reload reminders for current date
    await _loadRemindersForDate(selectedDate);
  }

  // Convert Reminder object to Map for TaskCardWidget compatibility
  Map<String, dynamic> _reminderToTaskMap(Reminder reminder) {
    return {
      "id": reminder.id,
      "title": reminder.title,
      "description": reminder.description ?? '',
      "startTime": reminder.formattedStartTime,
      "endTime": reminder.formattedEndTime,
      "date": reminder.time,
      "priority": reminder.priority,
      "subject": "General", // Default subject since we don't have this field
      "course_id": reminder.courseId,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header with month/year and toggle button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentMonthYear,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontFamily: 'Jost',
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleCalendarView,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        isCalendarViewExpanded
                            ? Icons.view_list
                            : Icons.calendar_view_month,
                        color: AppTheme.primaryTeal,
                        size: 6.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Date strip (update to use real reminders)
            DateStripWidget(
              selectedDate: selectedDate,
              onDateSelected: _onDateSelected,
              tasks:
                  _reminders
                      .map(_reminderToTaskMap)
                      .toList(), // Convert reminders to task maps
            ),

            // Main content area
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.primaryTeal,
                child: _buildMainContent(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddTask,
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: AppTheme.surfaceWhite,
        elevation: 4.0,
        child: Icon(Icons.add, color: AppTheme.surfaceWhite, size: 7.w),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      // Show loading indicator
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
            ),
            SizedBox(height: 2.h),
            Text(
              'Loading tasks...',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontFamily: 'Jost',
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      // Show error state
      return Center(
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
              onPressed: () => _loadRemindersForDate(selectedDate),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: AppTheme.surfaceWhite,
                  fontFamily: 'Jost',
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (filteredReminders.isEmpty) {
      // Show empty state
      return EmptyStateWidget(onAddTask: _onAddTask);
    }

    // Show reminders list
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: filteredReminders.length,
      itemBuilder: (context, index) {
        final reminder = filteredReminders[index];
        final taskMap = _reminderToTaskMap(reminder);

        return TaskCardWidget(
          task: taskMap,
          onTap: () => _onTaskTap(reminder),
          onEdit: () => _onTaskEdit(reminder),
          onDelete: () => _onTaskDelete(reminder),
        );
      },
    );
  }
}
