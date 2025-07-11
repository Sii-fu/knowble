import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import './scheduler/widgets/date_strip_widget.dart';
import './scheduler/widgets/empty_state_widget.dart';
import './scheduler/widgets/task_card_widget.dart';

class CalendarDashboard extends StatefulWidget {
  const CalendarDashboard({super.key});

  @override
  State<CalendarDashboard> createState() => _CalendarDashboardState();
}

class _CalendarDashboardState extends State<CalendarDashboard> {
  DateTime selectedDate = DateTime.now();
  bool isCalendarViewExpanded = false;
  final ScrollController _scrollController = ScrollController();

  // Mock data for tasks
  final List<Map<String, dynamic>> mockTasks = [
    {
      "id": 1,
      "title": "Mathematics Study Session",
      "description":
          "Review calculus concepts and practice integration problems for upcoming exam",
      "startTime": "09:00 AM",
      "endTime": "11:00 AM",
      "date": DateTime.now(),
      "priority": "High",
      "subject": "Mathematics",
    },
    {
      "id": 2,
      "title": "Physics Lab Report",
      "description":
          "Complete lab report on electromagnetic induction experiment",
      "startTime": "02:00 PM",
      "endTime": "04:00 PM",
      "date": DateTime.now(),
      "priority": "Medium",
      "subject": "Physics",
    },
    {
      "id": 3,
      "title": "History Essay Writing",
      "description": "Draft essay on World War II causes and consequences",
      "startTime": "07:00 PM",
      "endTime": "09:00 PM",
      "date": DateTime.now(),
      "priority": "Low",
      "subject": "History",
    },
    {
      "id": 4,
      "title": "Chemistry Quiz Preparation",
      "description": "Study organic chemistry reactions and mechanisms",
      "startTime": "10:00 AM",
      "endTime": "12:00 PM",
      "date": DateTime.now().add(Duration(days: 1)),
      "priority": "High",
      "subject": "Chemistry",
    },
    {
      "id": 5,
      "title": "English Literature Reading",
      "description":
          "Read chapters 5-8 of Pride and Prejudice for class discussion",
      "startTime": "03:00 PM",
      "endTime": "05:00 PM",
      "date": DateTime.now().add(Duration(days: 1)),
      "priority": "Medium",
      "subject": "English",
    },
  ];

  List<Map<String, dynamic>> get filteredTasks {
    return mockTasks.where((task) {
      final taskDate = task["date"] as DateTime;
      return taskDate.year == selectedDate.year &&
          taskDate.month == selectedDate.month &&
          taskDate.day == selectedDate.day;
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

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  void _toggleCalendarView() async {
    final DateTime? selectedDateFromCalendar =
        await Navigator.pushNamed(context, '/full-month-calendar-view')
            as DateTime?;

    if (selectedDateFromCalendar != null) {
      setState(() {
        selectedDate = selectedDateFromCalendar;
      });
    }
  }

  void _onTaskTap(Map<String, dynamic> task) {
    Navigator.pushNamed(context, '/task-detail-view');
  }

  void _onTaskEdit(Map<String, dynamic> task) {
    Navigator.pushNamed(context, '/task-edit-modal');
  }

  void _onTaskDelete(Map<String, dynamic> task) {
    setState(() {
      mockTasks.removeWhere((t) => t["id"] == task["id"]);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task deleted successfully'),
        backgroundColor: AppTheme.textPrimary,
      ),
    );
  }

  void _onAddTask() {
    Navigator.pushNamed(context, '/task-creation-modal');
  }

  Future<void> _onRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      // Refresh task data
    });
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

            // Date strip
            DateStripWidget(
              selectedDate: selectedDate,
              onDateSelected: _onDateSelected,
              tasks: mockTasks,
            ),

            // Main content area
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.primaryTeal,
                child:
                    filteredTasks.isEmpty
                        ? EmptyStateWidget(onAddTask: _onAddTask)
                        : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.h,
                          ),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return TaskCardWidget(
                              task: task,
                              onTap: () => _onTaskTap(task),
                              onEdit: () => _onTaskEdit(task),
                              onDelete: () => _onTaskDelete(task),
                            );
                          },
                        ),
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
}
