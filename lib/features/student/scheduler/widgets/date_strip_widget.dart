import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';

class DateStripWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final List<Map<String, dynamic>> tasks;

  const DateStripWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.tasks,
  });

  @override
  State<DateStripWidget> createState() => _DateStripWidgetState();
}

class _DateStripWidgetState extends State<DateStripWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Only scroll on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void didUpdateWidget(covariant DateStripWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _scrollToSelectedDate();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate() {
    final List<DateTime> dates = _generateDateList();
    final int selectedIndex = dates.indexWhere((d) =>
      d.year == widget.selectedDate.year &&
      d.month == widget.selectedDate.month &&
      d.day == widget.selectedDate.day);
    if (selectedIndex == -1) return;
    final double itemWidth = 15.w;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scrollPosition = selectedIndex * itemWidth - (screenWidth / 2 - itemWidth / 2);
    print('Scrolling to index: ' + selectedIndex.toString() + ', scrollPosition: ' + scrollPosition.toString());
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _hasTasksOnDate(DateTime date) {
    return widget.tasks.any((task) {
      final taskDate = task["date"] as DateTime;
      return taskDate.year == date.year &&
          taskDate.month == date.month &&
          taskDate.day == date.day;
    });
  }

  List<DateTime> _generateDateList() {
    final DateTime now = DateTime.now();
    final DateTime startDate = now.subtract(Duration(days: 30));
    final DateTime endDate = now.add(Duration(days: 30));

    List<DateTime> dates = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      dates.add(startDate.add(Duration(days: i)));
    }
    return dates;
  }

  String _getDayName(DateTime date) {
    const List<String> dayNames = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return dayNames[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> dates = _generateDateList();

    return Container(
      height: 12.h,
      color: AppTheme.backgroundLight,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final bool isSelected =
              date.year == widget.selectedDate.year &&
              date.month == widget.selectedDate.month &&
              date.day == widget.selectedDate.day;
          final bool isToday =
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day;
          final bool hasTasks = _hasTasksOnDate(date);

          return GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: Container(
              width: 15.w,
              margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
              decoration: BoxDecoration(
                color:
                    isSelected ? AppTheme.primaryTeal : AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday ? AppTheme.primaryTeal : AppTheme.borderSubtle,
                  width: isToday ? 2 : 1,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: AppTheme.primaryTeal.withOpacity(0.3),
                            offset: Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ]
                        : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected
                              ? AppTheme.surfaceWhite
                              : AppTheme.textSecondary,
                      fontFamily: 'Jost',
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected
                              ? AppTheme.surfaceWhite
                              : AppTheme.textPrimary,
                      fontFamily: 'Jost',
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          hasTasks
                              ? (isSelected
                                  ? AppTheme.surfaceWhite
                                  : AppTheme.primaryTeal)
                              : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
