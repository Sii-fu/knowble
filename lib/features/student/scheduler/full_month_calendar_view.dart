import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';

class FullMonthCalendarView extends StatefulWidget {
  const FullMonthCalendarView({super.key});

  @override
  State<FullMonthCalendarView> createState() => _FullMonthCalendarViewState();
}

class _FullMonthCalendarViewState extends State<FullMonthCalendarView> {
  late DateTime currentMonth;
  DateTime? selectedDate;

  // Mock data for tasks
  final Map<DateTime, List<Map<String, dynamic>>> tasksPerDate = {
    DateTime(2025, 7, 11): [
      {"title": "Math Study", "priority": "High"},
      {"title": "Physics Lab", "priority": "Medium"},
    ],
    DateTime(2025, 7, 12): [
      {"title": "Chemistry Quiz", "priority": "High"},
    ],
    DateTime(2025, 7, 15): [
      {"title": "History Essay", "priority": "Low"},
      {"title": "English Reading", "priority": "Medium"},
      {"title": "Biology Review", "priority": "High"},
    ],
    DateTime(2025, 7, 18): [
      {"title": "Math Exam", "priority": "High"},
    ],
    DateTime(2025, 7, 22): [
      {"title": "Science Project", "priority": "Medium"},
    ],
  };

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
    selectedDate = DateTime.now();
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final startDate = firstDay.subtract(Duration(days: firstDay.weekday - 1));

    List<DateTime> days = [];
    for (int i = 0; i < 42; i++) {
      // 6 weeks * 7 days
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }

  bool _isCurrentMonth(DateTime date) {
    return date.month == currentMonth.month && date.year == currentMonth.year;
  }

  List<Map<String, dynamic>> _getTasksForDate(DateTime date) {
    final key = tasksPerDate.keys.firstWhere(
      (d) => _isSameDay(d, date),
      orElse: () => DateTime(0),
    );

    if (key.year == 0) return [];
    return tasksPerDate[key] ?? [];
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

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  void _navigateMonth(int direction) {
    setState(() {
      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month + direction,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(currentMonth);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 6.w),
        ),
        title: Text(
          'Calendar',
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
            onPressed: () {
              setState(() {
                currentMonth = DateTime.now();
                selectedDate = DateTime.now();
              });
            },
            icon: Icon(Icons.today, color: AppTheme.primaryTeal, size: 6.w),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Navigation
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _navigateMonth(-1),
                  icon: Icon(
                    Icons.chevron_left,
                    color: AppTheme.primaryTeal,
                    size: 7.w,
                  ),
                ),
                Text(
                  '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Jost',
                  ),
                ),
                IconButton(
                  onPressed: () => _navigateMonth(1),
                  icon: Icon(
                    Icons.chevron_right,
                    color: AppTheme.primaryTeal,
                    size: 7.w,
                  ),
                ),
              ],
            ),
          ),

          // Weekday Headers
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children:
                  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map(
                        (day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                                fontFamily: 'Jost',
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),

          SizedBox(height: 1.h),

          // Calendar Grid
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 1.w,
                  mainAxisSpacing: 1.h,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final date = days[index];
                  final tasks = _getTasksForDate(date);
                  final isSelected =
                      selectedDate != null && _isSameDay(date, selectedDate!);
                  final isToday = _isToday(date);
                  final isCurrentMonth = _isCurrentMonth(date);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = date;
                      });
                      // Navigate back to calendar dashboard with selected date
                      Navigator.pop(context, date);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppTheme.primaryTeal
                                : (isToday
                                    ? AppTheme.primaryTeal.withOpacity(0.1)
                                    : null),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            isToday && !isSelected
                                ? Border.all(
                                  color: AppTheme.primaryTeal,
                                  width: 2,
                                )
                                : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Date number
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  !isCurrentMonth
                                      ? AppTheme.textSecondary.withOpacity(0.5)
                                      : isSelected
                                      ? AppTheme.surfaceWhite
                                      : AppTheme.textPrimary,
                              fontFamily: 'Jost',
                            ),
                          ),

                          SizedBox(height: 0.5.h),

                          // Task indicators
                          if (tasks.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  tasks.take(3).map((task) {
                                    return Container(
                                      width: 6,
                                      height: 6,
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? AppTheme.surfaceWhite
                                                : _getPriorityColor(
                                                  task['priority'],
                                                ),
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }).toList(),
                            ),

                          // More tasks indicator
                          if (tasks.length > 3)
                            Text(
                              '+${tasks.length - 3}',
                              style: TextStyle(
                                fontSize: 8.sp,
                                color:
                                    isSelected
                                        ? AppTheme.surfaceWhite
                                        : AppTheme.textSecondary,
                                fontFamily: 'Jost',
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Selected Date Tasks
          if (selectedDate != null) ...[
            Container(
              height: 25.h,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected date header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tasks for ${selectedDate!.day} ${_getMonthName(selectedDate!.month)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          fontFamily: 'Jost',
                        ),
                      ),
                      if (_getTasksForDate(selectedDate!).isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_getTasksForDate(selectedDate!).length}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryTeal,
                              fontFamily: 'Jost',
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Tasks list
                  Expanded(
                    child:
                        _getTasksForDate(selectedDate!).isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_note,
                                    size: 10.w,
                                    color: AppTheme.textSecondary,
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    'No tasks for this day',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppTheme.textSecondary,
                                      fontFamily: 'Jost',
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              itemCount: _getTasksForDate(selectedDate!).length,
                              itemBuilder: (context, index) {
                                final task =
                                    _getTasksForDate(selectedDate!)[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: 1.h),
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundLight,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _getPriorityColor(
                                        task['priority'],
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _getPriorityColor(
                                            task['priority'],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      Expanded(
                                        child: Text(
                                          task['title'],
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.textPrimary,
                                            fontFamily: 'Jost',
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2.w,
                                          vertical: 0.5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getPriorityColor(
                                            task['priority'],
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          task['priority'],
                                          style: TextStyle(
                                            fontSize: 8.sp,
                                            fontWeight: FontWeight.w500,
                                            color: _getPriorityColor(
                                              task['priority'],
                                            ),
                                            fontFamily: 'Jost',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/task-creation-modal');
        },
        backgroundColor: AppTheme.primaryTeal,
        child: Icon(Icons.add, color: AppTheme.surfaceWhite, size: 7.w),
      ),
    );
  }
}
