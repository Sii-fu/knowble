import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../core/services/student/search_service.dart';

class CourseListPage extends StatelessWidget {
  final List<Course> courses; // Changed to use Course model

  const CourseListPage({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
        title: Text(
          'Courses',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final course = courses[index];
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.accentLight, // Use color instead of image for now
                ),
                child: Icon(
                  Icons.play_circle_outline,
                  color: AppTheme.primaryTeal,
                  size: 24,
                ),
              ),
              title: Text(
                course.title,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    course.instructorName,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppTheme.warningAmber, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        course.avgRating.toStringAsFixed(1),
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${course.studentsCount} students',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    course.isPaid ? '\$${course.price.toStringAsFixed(2)}' : 'Free',
                    style: TextStyle(
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
