import 'package:flutter/material.dart';
import '../../core/services/student/course_services.dart';
import '../../data/models/course.dart';
import '../../config/theme.dart';
import 'course_layout.dart';
import 'courses_lessons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Widget buildCourseCard(BuildContext context, Course course, ThemeData theme, bool isCompleted) {
  return Container(
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: AppTheme.shadowLight,
          blurRadius: 5,
          offset: const Offset(0, 4),
        )
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            bottomLeft: Radius.circular(18),
          ),
          child: course.banner.isNotEmpty && (course.banner.startsWith('http://') || course.banner.startsWith('https://'))
              ? Image.network(
                  course.banner,
                  height: 100,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/gd1.jpg',
                    height: 100,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  'assets/images/gd1.jpg',
                  height: 100,
                  width: 80,
                  fit: BoxFit.cover,
                ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
                ),
                const SizedBox(height: 4),
                Text(
                  course.title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                if (isCompleted) ...[
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('4.2', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      Text('', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'VIEW CERTIFICATE',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  Text('', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      value: 0.5, // Replace with actual progress
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('0/100', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (isCompleted)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.successGreen,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
          ),
      ],
    ),
  );
}

class CompletedCoursesTab extends StatelessWidget {
  const CompletedCoursesTab({super.key});

  Future<List<Course>> _fetchCompletedCourses(String userId) async {
    final client = Supabase.instance.client;
    final courseServices = CourseServices();

    // 1. Get all enrollments for this student with progress = 100
    final response = await client
        .from('enrollments')
        .select('course_id')
        .eq('student_id', userId)
        .eq('progress', 100);

    // 2. Extract course_ids
    final completedCourseIds = (response as List<dynamic>)
        .map((row) => row['course_id'] as String)
        .toSet();

    // 3. Fetch all courses
    final allCourses = await courseServices.fetchAllCourses();

    // 4. Filter only completed courses
    return allCourses
        .where((course) => completedCourseIds.contains(course.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    return FutureBuilder<List<Course>>(
      future: _fetchCompletedCourses(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading courses'));
        }
        final courses = snapshot.data ?? [];
        if (courses.isEmpty) {
          return const Center(child: Text('No finished courses yet.'));
        }
        return ListView.separated(
          itemCount: courses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            final course = courses[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseLessonsPage(courseId: course.id),
                  ),
                );
              },
              child: buildCourseCard(context, course, theme, true),
            );
          },
        );
      },
    );
  }
}

class OngoingCoursesTab extends StatelessWidget {
  const OngoingCoursesTab({super.key});

  Future<List<Course>> _fetchOngoingCourses(String userId) async {
    final client = Supabase.instance.client;
    final courseServices = CourseServices();

    // 1. Fetch enrollments where progress < 100 OR progress IS NULL
    final response = await client
        .from('enrollments')
        .select('course_id, progress')
        .eq('student_id', userId);

    // 2. Extract course IDs where progress is NULL or < 100
    final ongoingCourseIds = (response as List<dynamic>)
        .where((row) => row['progress'] == null || (row['progress'] as int) < 100)
        .map((row) => row['course_id'] as String)
        .toSet();

    // 3. Fetch all courses
    final allCourses = await courseServices.fetchAllCourses();

    // 4. Filter only ongoing courses
    return allCourses
        .where((course) => ongoingCourseIds.contains(course.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    return FutureBuilder<List<Course>>(
      future: _fetchOngoingCourses(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading courses'));
        }
        final courses = snapshot.data ?? [];
        if (courses.isEmpty) {
          return const Center(child: Text('No ongoing courses.'));
        }
        return ListView.separated(
          itemCount: courses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            final course = courses[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseLessonsPage(courseId: course.id),
                  ),
                );
              },
              child: buildCourseCard(context, course, theme, false),
            );
          },
        );
      },
    );
  }
}


class StudentCoursesPageRefactored extends StatelessWidget {
  const StudentCoursesPageRefactored({super.key});

  @override
  Widget build(BuildContext context) {
    return CourseLayout(
      title: 'My Courses',
      showBackButton: false,
      bodyBuilder: (selectedTab) {
        final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
        switch (selectedTab) {
          case CourseTab.all:
            return AllCoursesTab(userId: userId);
          case CourseTab.ongoing:
            return const OngoingCoursesTab();
          case CourseTab.completed:
            return const CompletedCoursesTab();
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

class AllCoursesTab extends StatelessWidget {
  final String userId;
  const AllCoursesTab({super.key, required this.userId});

  Future<List<Course>> _fetchAllCourses(String userId) async {
    final courseServices = CourseServices();
    final enrollments = await courseServices.fetchUserEnrollments(userId);
    final enrolledCourseIds = enrollments.map((e) => e.courseId).toSet();
    final client = Supabase.instance.client;
    final response = await client
        .from('certificates')
        .select('course_id')
        .eq('student_id', userId);
    final completedCourseIds = (response as List<dynamic>)
        .map((row) => row['course_id'] as String)
        .toSet();
    final allCourses = await courseServices.fetchAllCourses();
    return allCourses.where((course) => enrolledCourseIds.contains(course.id) || completedCourseIds.contains(course.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<Course>>(
      future: _fetchAllCourses(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading courses'));
        }
        final courses = snapshot.data ?? [];
        if (courses.isEmpty) {
          return Center(child: Text('No courses found.'));
        }
        return ListView.separated(
          itemCount: courses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            final course = courses[index];
            final isCompleted = false; // Optional dynamic flag
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseLessonsPage(courseId: course.id),
                  ),
                );
              },
              child: buildCourseCard(context, course, theme, isCompleted),
            );
          },
        );
      },
    );
  }
}
