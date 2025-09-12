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
import 'unenrolled_courses_page.dart';

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
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF8FAFC),
                    Color(0xFFF1F5F9),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _Header(userName: _userName),
                    const SizedBox(height: 24),
                    const _SearchBar(),
                    const SizedBox(height: 32),
                    const _SectionTitle(title: 'Recent learning'),
                    const SizedBox(height: 16),
                    _RecentLearning(courses: _recentLearningCourses),
                    const SizedBox(height: 32),
                    _RecommendedSectionHeader(),
                    const SizedBox(height: 16),
                    _isLoading
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          )
                        : _RecommendedCoursesList(courses: _recommendedCourses),
                    const SizedBox(height: 32),
                    const _SectionTitle(title: "Today's Task"),
                    const SizedBox(height: 16),
                    _isLoadingTasks
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          )
                        : _TodaysTasksList(tasks: _todaysTasks),
                    const SizedBox(height: 32),
                  ],
                ),
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
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.school_outlined,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'No recommended courses found.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
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
                price: course.price,
                isPaid: course.isPaid,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, ${userName ?? ''}! 👋',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'What do you want to learn today?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 24,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Search courses, topics...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedSectionHeader extends StatelessWidget {
  const _RecommendedSectionHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 4, 
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Recommended',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UnenrolledCoursesPage(),
                ),  
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: theme.textTheme.labelMedium,
            ),
            child: const Text('See more'),
          ),
        ],
      ),
    );
  }
}

class _RecentLearning extends StatelessWidget {
  final List<Course> courses;
  const _RecentLearning({required this.courses});

  Future<int?> _fetchProgress(String courseId) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await client
        .from('enrollments')
        .select('progress')
        .eq('student_id', userId)
        .eq('course_id', courseId)
        .maybeSingle(); // gets single row or null

    if (response == null || response['progress'] == null) return null;
    return response['progress'] as int?;
  }

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.history_edu_outlined,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'No recent learning courses.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final course = courses[index];

          return FutureBuilder<int?>(
            future: _fetchProgress(course.id),
            builder: (context, snapshot) {
              final progress = snapshot.data; // int? nullable
              final double progressValue =
                  progress != null ? (progress.clamp(0, 100) / 100.0) : 0.0;

              // Decide progress color
              Color progressColor;
              if (progress == null) {
                progressColor = Colors.grey;
              } else if (progress == 100) {
                progressColor = Colors.green;
              } else {
                progressColor = Colors.teal;
              }

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
                  width: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                Theme.of(context).colorScheme.primary.withOpacity(0.05),
                              ],
                            ),
                          ),
                          child: course.banner.startsWith('http')
                              ? Image.network(
                                  course.banner,
                                  width: double.infinity,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/images/default_course.jpg',
                                    width: double.infinity,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  course.banner.isNotEmpty
                                      ? course.banner
                                      : 'assets/images/default_course.jpg',
                                  width: double.infinity,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: Text(
                          course.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: const Color(0xFF1E293B),
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Progress bar
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progressValue,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: progressColor,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              progress == null ? "0%" : "$progress%",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
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
  final double price;
  final bool isPaid;
  final String image;
  final String courseId;

  const _RecommendedCard({
    required this.title,
    required this.lessons,
    required this.duration,
    required this.price,
    required this.isPaid,
    required this.image,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNetworkImage = image.startsWith('http');
    // Generate a mock rating between 4.0 and 5.0 for demo purposes
    final rating = 4.0 + (courseId.hashCode % 10) / 10.0;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailPage(courseId: courseId),
          ),
        );
      },
      child: Container(
        width: 200, // Increased width from 170 to 200
        height: 220, // Fixed height to match ListView height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section - Fixed height
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.primary.withOpacity(0.05),
                    ],
                  ),
                ),
                child: isNetworkImage
                    ? Image.network(
                        image,
                        width: double.infinity,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/geo.jpg',
                          width: double.infinity,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        image,
                        width: double.infinity,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            // Content section - Expanded to fill remaining space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title - Fixed height with single line
                    SizedBox(
                      height: 20,
                      child: Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Rating and Price row - Fixed height
                    SizedBox(
                      height: 18,
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            isPaid ? '\$${price.toStringAsFixed(0)}' : 'Free',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isPaid ? theme.colorScheme.primary : Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Chapters info - Fixed height
                    SizedBox(
                      height: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          lessons,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Duration info - Fixed height
                    if (duration.isNotEmpty)
                      SizedBox(
                        height: 16,
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              duration,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
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
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 48,
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks for today',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up! 🎉',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
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
          padding: const EdgeInsets.only(bottom: 16),
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
                  backgroundColor: priorityColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: priorityColor.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: priorityColor.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: priorityColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    time,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: priorityColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (priority != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: priorityColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      priority!.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: priorityColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444); // Modern red
      case 'medium':
        return const Color(0xFFF59E0B); // Modern amber
      case 'low':
        return const Color(0xFF10B981); // Modern green
      default:
        return const Color(0xFF06B6D4); // Modern cyan
    }
  }
}
