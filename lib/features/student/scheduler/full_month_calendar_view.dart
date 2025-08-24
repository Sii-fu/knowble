import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:Knowble/config/theme.dart';
import '../../../core/services/reminder_service.dart';
import '../../../data/models/reminder.dart';

class FullMonthCalendarView extends StatefulWidget {
  const FullMonthCalendarView({super.key});

  @override
  State<FullMonthCalendarView> createState() => _FullMonthCalendarViewState();
}

class _FullMonthCalendarViewState extends State<FullMonthCalendarView> {
  late DateTime currentMonth;
  DateTime? selectedDate;
  bool _isLoading = true;
  List<Reminder> _monthlyReminders = [];

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
    selectedDate = DateTime.now();
    _fetchMonthlyReminders();
  }

  Future<void> _fetchMonthlyReminders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reminders = await ReminderService.getRemindersForMonth(
        currentMonth,
      );
      setState(() {
        _monthlyReminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching monthly reminders: $e');
      setState(() {
        _monthlyReminders = [];
        _isLoading = false;
      });
    }
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

  List<Reminder> _getRemindersForDate(DateTime date) {
    return _monthlyReminders.where((reminder) {
      return _isSameDay(reminder.time, date);
    }).toList();
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

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  void _navigateMonth(int direction) {
    setState(() {
      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month + direction,
        1,
      );
    });
    _fetchMonthlyReminders(); // Fetch reminders for the new month
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
              _fetchMonthlyReminders(); // Refresh reminders for current month
            },
            icon: Icon(Icons.today, color: AppTheme.primaryTeal, size: 6.w),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
              ),
            )
          : Column(
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
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
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
                        final reminders = _getRemindersForDate(date);
                        final isSelected =
                            selectedDate != null &&
                            _isSameDay(date, selectedDate!);
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
                              color: isSelected
                                  ? AppTheme.primaryTeal
                                  : (isToday
                                        ? AppTheme.primaryTeal.withOpacity(0.1)
                                        : null),
                              borderRadius: BorderRadius.circular(8),
                              border: isToday && !isSelected
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
                                    color: !isCurrentMonth
                                        ? AppTheme.textSecondary.withOpacity(
                                            0.5,
                                          )
                                        : isSelected
                                        ? AppTheme.surfaceWhite
                                        : AppTheme.textPrimary,
                                    fontFamily: 'Jost',
                                  ),
                                ),

                                SizedBox(height: 0.5.h),

                                // Task indicators - only show if reminders exist
                                if (reminders.isNotEmpty)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: reminders.take(3).map((reminder) {
                                      return Container(
                                        width: 6,
                                        height: 6,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppTheme.surfaceWhite
                                              : _getPriorityColor(
                                                  reminder.priority,
                                                ),
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                // More tasks indicator
                                if (reminders.length > 3)
                                  Text(
                                    '+${reminders.length - 3}',
                                    style: TextStyle(
                                      fontSize: 8.sp,
                                      color: isSelected
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
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
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
                            if (_getRemindersForDate(selectedDate!).isNotEmpty)
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
                                  '${_getRemindersForDate(selectedDate!).length}',
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
                          child: _getRemindersForDate(selectedDate!).isEmpty
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
                                  itemCount: _getRemindersForDate(
                                    selectedDate!,
                                  ).length,
                                  itemBuilder: (context, index) {
                                    final reminder = _getRemindersForDate(
                                      selectedDate!,
                                    )[index];
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 1.h),
                                      padding: EdgeInsets.all(3.w),
                                      decoration: BoxDecoration(
                                        color: AppTheme.backgroundLight,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _getPriorityColor(
                                            reminder.priority,
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
                                                reminder.priority,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 3.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  reminder.title,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppTheme.textPrimary,
                                                    fontFamily: 'Jost',
                                                  ),
                                                ),
                                                if (reminder.description !=
                                                        null &&
                                                    reminder
                                                        .description!
                                                        .isNotEmpty) ...[
                                                  SizedBox(height: 0.5.h),
                                                  Text(
                                                    reminder.description!,
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      color: AppTheme
                                                          .textSecondary,
                                                      fontFamily: 'Jost',
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                                Text(
                                                  _formatTime(reminder.time),
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                    color:
                                                        AppTheme.textSecondary,
                                                    fontFamily: 'Jost',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 2.w,
                                              vertical: 0.5.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getPriorityColor(
                                                reminder.priority,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              reminder.priority,
                                              style: TextStyle(
                                                fontSize: 8.sp,
                                                fontWeight: FontWeight.w500,
                                                color: _getPriorityColor(
                                                  reminder.priority,
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
