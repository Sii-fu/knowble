import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'student/unenrolled_courses_page.dart';

/// Example widget showing how to integrate the UnenrolledCoursesPage
/// This can be used in a home page, navigation drawer, or as a tab
class BrowseCoursesButton extends StatelessWidget {
  const BrowseCoursesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UnenrolledCoursesPage(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryTeal,
          foregroundColor: AppTheme.surfaceWhite,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        icon: const Icon(Icons.explore_outlined, size: 20),
        label: Text(
          'Browse All Courses',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.surfaceWhite,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

/// Example of how to add this as a floating action button
class BrowseCoursesFloatingButton extends StatelessWidget {
  const BrowseCoursesFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UnenrolledCoursesPage(),
          ),
        );
      },
      backgroundColor: AppTheme.primaryTeal,
      foregroundColor: AppTheme.surfaceWhite,
      icon: const Icon(Icons.explore),
      label: const Text('Browse Courses'),
    );
  }
}

/// Example of how to add this as a card widget in a dashboard
class BrowseCoursesCard extends StatelessWidget {
  const BrowseCoursesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surfaceWhite,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UnenrolledCoursesPage(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.explore_outlined,
                      color: AppTheme.primaryTeal,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.textSecondary,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Discover New Courses',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Browse all available courses and find your next learning adventure',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
