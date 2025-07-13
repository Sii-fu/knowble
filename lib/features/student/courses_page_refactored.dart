import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'course_layout.dart';
import 'courses_lessons.dart';

class StudentCoursesPageRefactored extends StatelessWidget {
  const StudentCoursesPageRefactored({super.key});

  @override
  Widget build(BuildContext context) {
    return CourseLayout(
      title: 'My Courses',
      showBackButton: false,
      bodyBuilder: (selectedTab) {
        switch (selectedTab) {
          case CourseTab.all:
            return const AllCoursesTab();
          case CourseTab.ongoing:
            return const OngoingCoursesTab();
          case CourseTab.completed:
            return const CompletedCoursesTab();
        }
      },
    );
  }
}

class AllCoursesTab extends StatelessWidget {
  const AllCoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Combined courses from both completed and ongoing
    final allCourses = [
      ..._getCompletedCourses(),
      ..._getOngoingCourses(),
    ];

    return ListView.separated(
      itemCount: allCourses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final course = allCourses[index];
        return _buildCourseCard(context, course, theme);
      },
    );
  }

  List<Map<String, dynamic>> _getCompletedCourses() {
    return [
      {
        'category': 'Graphic Design',
        'title': 'Graphic Design Advanced',
        'rating': '4.2',
        'duration': '2 Hrs 36 Mins',
        'image': 'assets/images/gd1.jpg',
        'isCompleted': true,
      },
      {
        'category': 'Graphic Design',
        'title': 'Advance Diploma in Gra..',
        'rating': '4.7',
        'duration': '3 Hrs 28 Mins',
        'image': 'assets/images/gd2.jpg',
        'isCompleted': true,
      },
      {
        'category': 'Digital Marketing',
        'title': 'Setup your Graphic Des..',
        'rating': '4.2',
        'duration': '4 Hrs 05 Mins',
        'image': 'assets/images/dm.jpg',
        'isCompleted': true,
      },
      {
        'category': 'Web Development',
        'title': 'Web Developer conce..',
        'rating': '4.2',
        'duration': '3 Hrs 45 Mins',
        'image': 'assets/images/web.png',
        'isCompleted': true,
      },
    ];
  }

  List<Map<String, dynamic>> _getOngoingCourses() {
    return [
      {
        'category': 'UI/UX Design',
        'title': 'Intro to UI/UX Design',
        'duration': '3 Hrs 06 Mins',
        'progress': 93,
        'total': 125,
        'color': Colors.teal,
        'image': 'assets/images/gd1.jpg',
        'isCompleted': false,
      },
      {
        'category': 'Web Development',
        'title': 'Wordpress website Dev..',
        'duration': '1 Hrs 58 Mins',
        'progress': 12,
        'total': 31,
        'color': Colors.amber,
        'image': 'assets/images/web.png',
        'isCompleted': false,
      },
    ];
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course, ThemeData theme) {
    final isCompleted = course['isCompleted'] as bool;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CourseLessonsPage()),
        );
      },
      child: Container(
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
              child: Image.asset(
                course['image']!,
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
                      course['category']!,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course['title']!,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    if (isCompleted) ...[
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            course['rating']!,
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            course['duration']!,
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
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
                      Text(
                        course['duration']!,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          value: (course['progress'] as int) / (course['total'] as int),
                          valueColor: AlwaysStoppedAnimation<Color>(course['color']! as Color),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${course['progress']}/${course['total']}',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
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
      ),
    );
  }
}

class CompletedCoursesTab extends StatelessWidget {
  const CompletedCoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courses = [
      {
        'category': 'Graphic Design',
        'title': 'Graphic Design Advanced',
        'rating': '4.2',
        'duration': '2 Hrs 36 Mins',
        'image': 'assets/images/gd1.jpg'
      },
      {
        'category': 'Graphic Design',
        'title': 'Advance Diploma in Gra..',
        'rating': '4.7',
        'duration': '3 Hrs 28 Mins',
        'image': 'assets/images/gd2.jpg'
      },
      {
        'category': 'Digital Marketing',
        'title': 'Setup your Graphic Des..',
        'rating': '4.2',
        'duration': '4 Hrs 05 Mins',
        'image': 'assets/images/dm.jpg'
      },
      {
        'category': 'Web Development',
        'title': 'Web Developer conce..',
        'rating': '4.2',
        'duration': '3 Hrs 45 Mins',
        'image': 'assets/images/web.png'
      },
    ];

    return ListView.separated(
      itemCount: courses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final course = courses[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CourseLessonsPage()),
            );
          },
          child: Container(
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
                  child: Image.asset(
                    course['image']!,
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
                        Text(course['category']!, style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange)),
                        const SizedBox(height: 4),
                        Text(course['title']!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(course['rating']!, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 12),
                            Text(course['duration']!, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('VIEW CERTIFICATE', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
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
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class OngoingCoursesTab extends StatelessWidget {
  const OngoingCoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courses = [
      {
        'category': 'UI/UX Design',
        'title': 'Intro to UI/UX Design',
        'duration': '3 Hrs 06 Mins',
        'progress': 93,
        'total': 125,
        'color': Colors.teal,
        'image': 'assets/images/gd1.jpg',
      },
      {
        'category': 'Web Development',
        'title': 'Wordpress website Dev..',
        'duration': '1 Hrs 58 Mins',
        'progress': 12,
        'total': 31,
        'color': Colors.amber,
        'image': 'assets/images/web.png',
      },
      {
        'category': 'UI/UX Design',
        'title': '3D Blender and UI/UX',
        'duration': '2 Hrs 46 Mins',
        'progress': 56,
        'total': 98,
        'color': Colors.redAccent,
        'image': 'assets/images/gd2.jpg',
      },
      {
        'category': 'UX/UI Design',
        'title': 'Learn UX User Persona',
        'duration': '1 Hrs 58 Mins',
        'progress': 0,
        'total': 31,
        'color': Colors.teal,
        'image': 'assets/images/dm.jpg',
      },
    ];

    return ListView.separated(
      itemCount: courses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final course = courses[index];
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
                child: Image.asset(
                  course['image'] as String,
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
                      Text(course['category'] as String, style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange)),
                      const SizedBox(height: 4),
                      Text(course['title'] as String, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(course['duration'] as String, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          value: (course['progress'] as int) / (course['total'] as int),
                          valueColor: AlwaysStoppedAnimation<Color>(course['color']! as Color),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('${course['progress']}/${course['total']}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
