import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onAddTask;

  const EmptyStateWidget({super.key, required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration or icon
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 20.w,
                color: AppTheme.primaryTeal.withOpacity(0.6),
              ),
            ),

            SizedBox(height: 4.h),

            // Empty state title
            Text(
              'No Tasks for Today',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontFamily: 'Jost',
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Empty state description
            Text(
              'You don\'t have any scheduled tasks for this day.\nTap the button below to create your first task.',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
                fontFamily: 'Jost',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Add task button
            ElevatedButton.icon(
              onPressed: onAddTask,
              icon: Icon(Icons.add, color: AppTheme.surfaceWhite, size: 5.w),
              label: Text(
                'Add New Task',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.surfaceWhite,
                  fontFamily: 'Jost',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: AppTheme.surfaceWhite,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: AppTheme.primaryTeal.withOpacity(0.3),
              ),
            ),

            SizedBox(height: 2.h),

            // Secondary action (optional)
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/full-month-calendar-view');
              },
              child: Text(
                'View Full Calendar',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryTeal,
                  fontFamily: 'Jost',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
