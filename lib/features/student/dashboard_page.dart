import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/student/course_services.dart';
import '../../data/models/course.dart';
import '../../data/models/module.dart'; // Import the Module type
import 'Course_Details.dart';
import 'courses_lessons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentDashboardPage extends StatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  final CourseServices _courseServices = CourseServices();
  List<Course> _recommendedCourses = [];
  List<Course> _recentLearningCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendedCourses();
  }

  Future<void> _loadRecommendedCourses() async {
    final studentId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final recommended = await _courseServices.fetchRecommendedCourses(studentId);
    final recentLearning = await _courseServices.fetchRecentLearningCourses(studentId);
    setState(() {
      _recommendedCourses = recommended;
      _recentLearningCourses = recentLearning;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const _Header(),
                  const SizedBox(height: 16),
                  const _SearchBar(),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Recent learning'),
                  const SizedBox(height: 12),
                  _RecentLearning(courses: _recentLearningCourses),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Recommended'),
                  const SizedBox(height: 12),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _RecommendedCoursesList(courses: _recommendedCourses),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: "Today's Task"),
                  const SizedBox(height: 12),
                  const _TaskCard(
                    time: '7AM - 8PM',
                    title: 'Go to office',
                    subtitle: 'meeting with client singapure',
                    location: 'Plaza Indonesia',
                  ),
                  const SizedBox(height: 12),
                  const _TaskCard(
                    time: '7AM - 8PM',
                    title: 'Project app baparekraf',
                    subtitle: 'talk to environment',
                    location: 'Pondok indah mall',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendedCoursesList extends StatelessWidget {
  final List<Course> courses;
  const _RecommendedCoursesList({required this.courses});

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return Text('No recommended courses found.', style: Theme.of(context).textTheme.bodyMedium);
    }
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final course = courses[index];
          // Show chapter count (modules) on the left of duration
          return FutureBuilder<List<Module>>(
            future: CourseServices().fetchModules(course.id),
            builder: (context, snapshot) {
              final chapterCount = snapshot.hasData ? snapshot.data!.length : 0;
              return _RecommendedCard(
                title: course.title,
                lessons: chapterCount > 0 ? '$chapterCount Chapters' : '',
                duration: '${course.durationDays} Days',
                image: course.banner.isNotEmpty ? course.banner : 'assets/images/default_course.jpg',
                courseId: course.id,
              );
            },
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, Christina',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('What do you want to learn today?', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
          ],
        ),
        Icon(Icons.notifications_none_rounded, size: 26, color: theme.colorScheme.primary),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Search', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
          )
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _RecentLearning extends StatelessWidget {
  final List<Course> courses;
  const _RecentLearning({required this.courses});

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return Text('No recent learning courses.', style: Theme.of(context).textTheme.bodyMedium);
    }
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final course = courses[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CourseDetailPage(courseId: course.id)),
              );
            },
            child: Container(
              width: 120,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: course.banner.startsWith('http')
                        ? Image.network(
                            course.banner,
                            width: double.infinity,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/images/default_course.jpg',
                              width: double.infinity,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            course.banner.isNotEmpty ? course.banner : 'assets/images/default_course.jpg',
                            width: double.infinity,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(course.title, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class _RecommendedCard extends StatelessWidget {
  final String title;
  final String lessons;
  final String duration;
  final String image;
  final String courseId; // Add this

  const _RecommendedCard({
    required this.title,
    required this.lessons,
    required this.duration,
    required this.image,
    required this.courseId, // Add this
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNetworkImage = image.startsWith('http');
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CourseDetailPage(courseId: courseId)), // Use courseId here
        );
      },
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isNetworkImage
                  ? Image.network(
                      image,
                      width: double.infinity,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/default_course.jpg',
                        width: double.infinity,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      image,
                      width: double.infinity,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 6),
            Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(lessons, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                const Spacer(),
                if (duration.isNotEmpty) ...[
                  Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(duration, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary))
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final String location;

  const _TaskCard({required this.time, required this.title, required this.subtitle, required this.location});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(time, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accentLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(location, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

