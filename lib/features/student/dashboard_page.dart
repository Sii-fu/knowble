import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/student/course_services.dart';
import '../../core/services/reminder_service.dart';
import '../../data/models/course.dart';
import '../../data/models/module.dart';
import '../../data/models/reminder.dart';
import 'Course_Details.dart';
import 'search/search_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'courses_lessons.dart';

class StudentDashboardPage extends StatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  final CourseServices _courseServices = CourseServices();
  List<Course> _recommendedCourses = [];
  List<Course> _recentLearningCourses = [];
  List<Reminder> _todaysTasks = [];
  bool _isLoading = true;
  bool _isLoadingTasks = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadRecommendedCourses();
    _loadTodaysTasks();
  }

  Future<void> _loadUserName() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final userData = await Supabase.instance.client
        .from('users')
        .select('name')
        .eq('id', userId)
        .maybeSingle();
    setState(() {
      _userName = userData?['name'] ?? 'Student';
    });
  }

  Future<void> _loadRecommendedCourses() async {
    try {
      final studentId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final recommended = await _courseServices.fetchRecommendedCourses(
        studentId,
      );
      final recentLearning = await _courseServices.fetchRecentLearningCourses(
        studentId,
      );

      if (mounted) {
        setState(() {
          _recommendedCourses = recommended;
          _recentLearningCourses = recentLearning;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading courses: $e');
      if (mounted) {
        setState(() {
          _recommendedCourses = [];
          _recentLearningCourses = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadTodaysTasks() async {
    try {
      setState(() {
        _isLoadingTasks = true;
      });

      // Get today's date
      final today = DateTime.now();

      // Fetch reminders for today using ReminderService
      final todaysReminders = await ReminderService.getRemindersForDate(today);

      if (mounted) {
        setState(() {
          _todaysTasks = todaysReminders;
          _isLoadingTasks = false;
        });
      }
    } catch (e) {
      print('Error loading today\'s tasks: $e');
      if (mounted) {
        setState(() {
          _todaysTasks = [];
          _isLoadingTasks = false;
        });
      }
    }
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
                  _Header(userName: _userName),
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
                  _isLoadingTasks
                      ? const Center(child: CircularProgressIndicator())
                      : _TodaysTasksList(tasks: _todaysTasks),
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
      return Text(
        'No recommended courses found.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
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
                image: course.banner.isNotEmpty
                    ? course.banner
                    : 'assets/images/geo.jpg',
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
  final String? userName;
  const _Header({this.userName});

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
              'Hi, ${userName ?? ''}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'What do you want to learn today?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/notifications');
          },
          child: Icon(
            Icons.notifications_none_rounded,
            size: 26,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.95,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollCtrl) {
              return Material(
                color: theme.colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.borderSubtle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Expanded(child: const SearchPage()),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppTheme.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
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
      return Text(
        'No recent learning courses.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final course = courses[index];
          return FutureBuilder<List<Module>>(
            future: CourseServices().fetchModules(course.id),
            builder: (context, snapshot) {
              final modules = snapshot.data ?? [];
              final totalModules = modules.length;
              // For demo, assume completedModules = half of totalModules (replace with real quiz logic)
              final completedModules = totalModules > 0
                  ? (totalModules / 2).floor()
                  : 0;
              final progress = totalModules > 0
                  ? completedModules / totalModules
                  : 0.0;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseLessonsPage(courseId: course.id),
                    ),
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
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                      'assets/images/default_course.jpg',
                                      width: double.infinity,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                              )
                            : Image.asset(
                                course.banner.isNotEmpty
                                    ? course.banner
                                    : 'assets/images/default_course.jpg',
                                width: double.infinity,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          course.title,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Progress bar always shown under the name
                      Row(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: progress,
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$completedModules/$totalModules',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
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
          MaterialPageRoute(
            builder: (_) => CourseDetailPage(courseId: courseId),
          ), // Use courseId here
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
                        'assets/images/geo.jpg',
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
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  lessons,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                if (duration.isNotEmpty) ...[
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    duration,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaysTasksList extends StatelessWidget {
  final List<Reminder> tasks;
  const _TodaysTasksList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              'No tasks for today',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'You\'re all caught up! 🎉',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: tasks.map((task) {
        // Format the time range
        final startTime = task.time;
        final endTime = task.endTime;
        final timeRange = endTime != null
            ? '${_formatTime(startTime)} - ${_formatTime(endTime)}'
            : _formatTime(startTime);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TaskCard(
            time: timeRange,
            title: task.title,
            subtitle: task.description?.isNotEmpty == true
                ? task.description!
                : 'No description',
            location: _getPriorityBadge(task.priority),
            priority: task.priority,
            reminderId: task.id,
          ),
        );
      }).toList(),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _getPriorityBadge(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return '🔴 High Priority';
      case 'medium':
        return '🟡 Medium Priority';
      case 'low':
        return '🟢 Low Priority';
      default:
        return '📋 Task';
    }
  }
}

class _TaskCard extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final String location;
  final String? priority;
  final String? reminderId;

  const _TaskCard({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.location,
    this.priority,
    this.reminderId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get priority color
    Color priorityColor = _getPriorityColor(priority);

    return GestureDetector(
      onTap: reminderId != null
          ? () {
              // Navigate to task detail page - you can implement this later
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task: $title'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: priorityColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: priorityColor,
                        ),
                      ),
                    ),
                    if (priority != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          priority!.toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: priorityColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return const Color.fromARGB(255, 249, 169, 163);
      case 'medium':
        return const Color.fromARGB(255, 253, 202, 126);
      case 'low':
        return const Color.fromARGB(255, 173, 250, 175);
      default:
        return AppTheme.primaryTeal;
    }
  }
}
