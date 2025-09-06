import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme_instructor.dart';
import 'course_screen.dart';
import 'create_course_screen.dart';

import 'package:Knowble/features/instructor/chat/chat_list_page.dart';
import '../../core/services/Instructor/teacher_dashboard.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int _selectedIndex = 0;
  String _selectedRevenueYear = '${DateTime.now().year}';
  final _dashboardService = TeacherDashboardService();
  int _totalCourses = 0;
  int _totalStudents = 0;
  int _totalDays = 0;
  List<Map<String, dynamic>> _recentCourses = [];
  // Session start timestamp used to scope recent activity to the current login/session
  DateTime? _sessionStart;
  // Dynamic recent activities (created from activity_logs or synthesized)
  List<Map<String, dynamic>> _recentActivities = [];
  String _teacherName = 'Instructor';
  List<double> _monthlyRevenue = List.filled(12, 0.0);
  double _totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
  // no session initialization; fetch server activities directly
    _loadDashboard();
  }

  @override
  void dispose() {
    // Note: Don't clear session here as user might navigate back
    // Session should only be cleared on actual logout
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    final data = await _dashboardService.fetchInstructorOverview(
      recentLimit: 4,
    );
    setState(() {
      _totalCourses = data['totalCourses'] as int? ?? 0;
      _totalStudents = data['totalStudents'] as int? ?? 0;
      _totalDays = data['totalDays'] as int? ?? 0;
      _recentCourses = List<Map<String, dynamic>>.from(
        data['recentCourses'] as List? ?? [],
      );
      _teacherName = data['teacherName'] as String? ?? _teacherName;
    });

  // Load revenue for selected year (default to current year)
  _loadRevenue();

  // Load recent activities scoped to this session
    try {
      final acts = await _dashboardService.fetchAllActivities(limit: 6);
      setState(() {
        _recentActivities = acts;
      });
    } catch (e) {
      print('loadDashboard: failed to load activities: $e');
    }
  }

  

  Future<void> _loadRevenue({int? year}) async {
    final rev = await _dashboardService.fetchAnnualRevenue(year: year);
    setState(() {
      _monthlyRevenue = List<double>.from(rev['monthly'] as List? ?? List.filled(12, 0.0));
      _totalRevenue = (rev['total'] as num?)?.toDouble() ?? 0.0;
    });
    // Debug logging from UI so developer can inspect values easily
    final debug = rev['debug'] as Map<String, dynamic>?;
    if (debug != null) {
      print('revenue debug: courseIds=${debug['courseIds']}, priceKeys=${debug['priceByCourseKeys']}, enrollmentCourseIds=${debug['enrollmentCourseIds']}');
    }
    if (_totalRevenue == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Revenue is zero — check console logs for debug details')),
      );
    }
  }

  void _onTabSelected(int index) {
    // kept for backward-compat but no bottom nav is shown anymore
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CourseScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeInstructor.lightTheme;

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: AppThemeInstructor.backgroundLight,

        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppThemeInstructor.surfaceWhite,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppThemeInstructor.textSecondary,
                ),
              ),
              Text(
                _teacherName,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppThemeInstructor.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppThemeInstructor.accentLight,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: AppThemeInstructor.primaryBlue,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions (kept offstage to avoid UI change but reference the method)
              Offstage(offstage: true, child: _buildQuickActions()),

              // const SizedBox(height: 24),

              // Statistics Overview
              _buildStatisticsSection(),

              const SizedBox(height: 24),

              // Course Progress
              _buildCourseProgressSection(),

              const SizedBox(height: 24),

              // Revenue Chart
              _buildRevenueSection(),

              const SizedBox(height: 24),

              // Recent Activity
              _buildRecentActivitySection(),

              const SizedBox(height: 100),
            ],
          ),
        ),
  // Bottom nav removed as requested
      ),
    );
  }


  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppThemeInstructor.primaryBlue,
            AppThemeInstructor.primaryBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppThemeInstructor.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppThemeInstructor.lightTheme.textTheme.titleMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'New Course',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateCourseScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.chat_outlined,
                  label: 'Messages',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatListPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.analytics_outlined,
                  label: 'Analytics',
                  onTap: () {
                    // Handle analytics
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overview',
              style: AppThemeInstructor.lightTheme.textTheme.titleLarge
                  ?.copyWith(
                    color: AppThemeInstructor.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppThemeInstructor.accentLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppThemeInstructor.primaryBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'This Month',
                    style: TextStyle(
                      color: AppThemeInstructor.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.school_outlined,
                title: 'Active Courses',
                value: _totalCourses.toString(),
                change: '',
                isPositive: true,
                color: AppThemeInstructor.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.people_outline,
                title: 'Total Students',
                value: _totalStudents.toString(),
                change: '',
                isPositive: true,
                color: AppThemeInstructor.successGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.access_time_outlined,
                title: 'Days Taught',
                value: _totalDays.toString(),
                change: '',
                isPositive: true,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.star_outline,
                title: 'Average Rating',
                value: '4.8',
                change: '+0.2 this month',
                isPositive: true,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeInstructor.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeInstructor.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppThemeInstructor.shadowLight.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive
                    ? AppThemeInstructor.successGreen
                    : AppThemeInstructor.errorRed,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppThemeInstructor.lightTheme.textTheme.headlineSmall
                ?.copyWith(
                  color: AppThemeInstructor.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppThemeInstructor.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppThemeInstructor.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            change,
            style: TextStyle(
              color: isPositive
                  ? AppThemeInstructor.successGreen
                  : AppThemeInstructor.errorRed,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Course Progress',
              style: AppThemeInstructor.lightTheme.textTheme.titleLarge
                  ?.copyWith(
                    color: AppThemeInstructor.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CourseScreen()),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: AppThemeInstructor.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recentCourses.length,
            itemBuilder: (context, index) {
              final c = _recentCourses[index];
              final title = c['title'] as String? ?? 'Untitled';
              final students = c['students'] as int? ?? 0;
              // Placeholder subject and progress — you can enhance if more data is available
              return _buildCourseCard(
                title: title,
                subject: '',
                progress: 0.0,
                students: students,
                color: AppThemeInstructor.primaryBlue,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard({
    required String title,
    required String subject,
    required double progress,
    required int students,
    required Color color,
  }) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeInstructor.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeInstructor.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppThemeInstructor.shadowLight.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  subject,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.more_horiz, color: AppThemeInstructor.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppThemeInstructor.lightTheme.textTheme.titleMedium
                ?.copyWith(
                  color: AppThemeInstructor.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 16,
                color: AppThemeInstructor.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '$students students',
                style: TextStyle(
                  color: AppThemeInstructor.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      color: AppThemeInstructor.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppThemeInstructor.borderSubtle,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSection() {
    // Build spots from monthly revenue data
    final spots = <FlSpot>[];
    for (int i = 0; i < _monthlyRevenue.length; i++) {
      spots.add(FlSpot(i.toDouble(), _monthlyRevenue[i]));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeInstructor.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeInstructor.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppThemeInstructor.shadowLight.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue Overview',
                    style: AppThemeInstructor.lightTheme.textTheme.titleLarge
                        ?.copyWith(
                          color: AppThemeInstructor.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${_totalRevenue.toStringAsFixed(2)} total',
                    style: AppThemeInstructor.lightTheme.textTheme.bodyMedium
                        ?.copyWith(color: AppThemeInstructor.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  color: AppThemeInstructor.accentLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRevenueYear,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppThemeInstructor.primaryBlue,
                    ),
                    items: ['2022', '2023', '2024', '2025']
                        .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() {
                        _selectedRevenueYear = val;
                      });
                      _loadRevenue(year: int.tryParse(val));
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                    final idx = value.toInt();
                    if (idx < 0 || idx >= months.length) return const SizedBox.shrink();
                    return Text(months[idx], style: TextStyle(fontSize: 10, color: AppThemeInstructor.textSecondary));
                  }, interval: 1)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppThemeInstructor.primaryBlue,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      color: AppThemeInstructor.primaryBlue.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(enabled: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: AppThemeInstructor.lightTheme.textTheme.titleLarge
                  ?.copyWith(
                    color: AppThemeInstructor.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.refresh, color: AppThemeInstructor.primaryBlue),
                  onPressed: () async {
                    final acts = await _dashboardService.fetchAllActivities(limit: 6);
                    setState(() {
                      _recentActivities = acts;
                    });
                  },
                ),
                TextButton(
                  onPressed: () {
                    // Handle view all
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: AppThemeInstructor.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppThemeInstructor.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemeInstructor.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: AppThemeInstructor.shadowLight.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _recentActivities.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No recent activity for this session.',
                        style: TextStyle(color: AppThemeInstructor.textSecondary),
                      ),
                    )
                  ]
                : List.generate(_recentActivities.length * 2 - 1, (i) {
                    // interleave items with Dividers
                    if (i.isOdd) return Divider(color: AppThemeInstructor.borderSubtle, height: 1);
                    final idx = i ~/ 2;
                    final a = _recentActivities[idx];
                    final title = a['message']?.toString() ?? a['type']?.toString() ?? 'Activity';
                    final createdRaw = a['created_at'] as String? ?? '';
                    String timeText = '';
                    try {
                      final dt = DateTime.tryParse(createdRaw);
                      if (dt != null) {
                        final diff = DateTime.now().difference(dt);
                        if (diff.inMinutes < 60) timeText = '${diff.inMinutes}m ago';
                        else if (diff.inHours < 24) timeText = '${diff.inHours}h ago';
                        else timeText = '${diff.inDays}d ago';
                      }
                    } catch (_) {}
                    
                    IconData activityIcon = Icons.info_outline;
                    Color activityColor = AppThemeInstructor.primaryBlue;
                    
                    final type = a['type']?.toString() ?? '';
                    if (type.contains('course_created')) {
                      activityIcon = Icons.add_circle_outline;
                      activityColor = AppThemeInstructor.successGreen;
                    } else if (type.contains('course_updated') || type.contains('updated')) {
                      activityIcon = Icons.edit_outlined;
                      activityColor = Colors.orange;
                    } else if (type.contains('module')) {
                      activityIcon = Icons.folder_outlined;
                      activityColor = AppThemeInstructor.primaryBlue;
                    } else if (type.contains('section') || type.contains('lesson')) {
                      activityIcon = Icons.article_outlined;
                      activityColor = Colors.purple;
                    } else if (type.contains('content')) {
                      activityIcon = Icons.attachment_outlined;
                      activityColor = Colors.teal;
                    }
                    
                    return _buildActivityItem(
                      icon: activityIcon,
                      title: title,
                      subtitle: '',
                      time: timeText,
                      color: activityColor,
                    );
                  }),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppThemeInstructor.lightTheme.textTheme.bodyMedium
                      ?.copyWith(
                        color: AppThemeInstructor.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppThemeInstructor.lightTheme.textTheme.bodySmall
                      ?.copyWith(color: AppThemeInstructor.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppThemeInstructor.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppThemeInstructor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
