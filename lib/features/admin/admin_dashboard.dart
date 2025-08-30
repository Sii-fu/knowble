import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Knowble/config/theme.dart';
import './widgets/admin_info_card.dart';
import './widgets/admin_list_item_card.dart';
import './widgets/quick_action_button.dart';
import './widgets/enrollment_chart.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../core/services/admin/admin_dashboard_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _refreshController;
  bool _isRefreshing = false;

  // Service instance
  final AdminDashboardService _dashboardService = AdminDashboardService();

  // Real data state
  Map<String, dynamic>? _dashboardMetrics;
  List<Map<String, dynamic>>? _activityFeed;
  List<Map<String, dynamic>>? _enrollmentChartData;
  bool _isLoading = true;
  String? _error;

  // Mock data for quick actions with updated routes
  final List<Map<String, dynamic>> _quickActions = [
    {
      "title": "Verify Instructors",
      "icon": "verified_user",
      "route": "/admin/instructors",
    },
    {"title": "Review Courses", "icon": "school", "route": "/admin/courses"},
    {
      "title": "Manage Users",
      "icon": "manage_accounts",
      "route": "/admin/users",
    },
    {"title": "View Reports", "icon": "analytics", "route": "/admin/dashboard"},
  ];

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load all dashboard data
      final metrics = await _dashboardService.getDashboardMetrics();
      final activities = await _dashboardService.getActivityFeed();
      final chartData = await _dashboardService.getEnrollmentChartData();

      setState(() {
        _dashboardMetrics = metrics;
        _activityFeed = activities;
        _enrollmentChartData = chartData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('Error loading dashboard data: $e');
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
      }
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _refreshController.forward();

    // Load real data instead of simulation
    await _loadDashboardData();

    _refreshController.reverse();

    setState(() {
      _isRefreshing = false;
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        Navigator.pushNamed(context, '/admin/instructors');
        break;
      case 2:
        Navigator.pushNamed(context, '/admin/courses');
        break;
      case 3:
        Navigator.pushNamed(context, '/admin/users');
        break;
    }
  }

  void _onQuickActionTap(String route) {
    Navigator.pushNamed(context, route);
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildMetricsLoadingState() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          width: double.infinity,
          height: 15.h,
          margin: EdgeInsets.only(bottom: 3.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.primaryTeal,
                strokeWidth: 2,
              ),
              SizedBox(width: 4.w),
              Text(
                'Loading metrics...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      height: 20.h,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppTheme.errorRed, size: 40),
          SizedBox(height: 2.h),
          Text(
            'Error loading dashboard data',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.errorRed,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: _loadDashboardData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCards() {
    if (_dashboardMetrics == null) return const SizedBox();

    final metricsData = [
      {
        "title": "Total Users",
        "value": _dashboardMetrics!['totalUsers']['value'].toString(),
        "growth":
            "${_dashboardMetrics!['totalUsers']['growth'].toStringAsFixed(1)}%",
        "isPositive": _dashboardMetrics!['totalUsers']['isPositive'],
        "icon": "people",
        "color": AppTheme.primaryTeal,
      },
      {
        "title": "Verified Instructors",
        "value": _dashboardMetrics!['verifiedInstructors']['value'].toString(),
        "growth":
            "${_dashboardMetrics!['verifiedInstructors']['growth'].toStringAsFixed(1)}%",
        "isPositive": _dashboardMetrics!['verifiedInstructors']['isPositive'],
        "icon": "verified_user",
        "color": AppTheme.successGreen,
      },
      {
        "title": "Total Courses",
        "value": _dashboardMetrics!['totalCourses']['value'].toString(),
        "growth":
            "${_dashboardMetrics!['totalCourses']['growth'].toStringAsFixed(1)}%",
        "isPositive": _dashboardMetrics!['totalCourses']['isPositive'],
        "icon": "school",
        "color": AppTheme.errorRed,
      },
    ];

    return Column(
      children: metricsData.map((metric) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 3.h),
          child: AdminInfoCard(
            title: metric["title"] as String,
            value: metric["value"] as String,
            growth: metric["growth"] as String,
            isPositive: metric["isPositive"] as bool,
            iconName: metric["icon"] as String,
            color: metric["color"] as Color,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityLoadingState() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: EdgeInsets.only(bottom: 3.h),
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircularProgressIndicator(
                color: AppTheme.primaryTeal,
                strokeWidth: 2,
              ),
              SizedBox(width: 5.w),
              Text(
                'Loading activity...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyActivityState() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 56,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: 3.h),
          Text(
            'No recent activity',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            'Activity will appear here as users interact with the platform',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 2.0,
        shadowColor: AppTheme.shadowLight,
        automaticallyImplyLeading: false,
        title: Text(
          'Admin Dashboard',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
            icon: CustomIconWidget(
              iconName: 'notifications',
              color: AppTheme.textSecondary,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              // Handle logout
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
            icon: CustomIconWidget(
              iconName: 'logout',
              color: AppTheme.textSecondary,
              size: 24,
            ),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.primaryTeal,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metrics Cards Section
                Text(
                  'Platform Overview',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                _isLoading
                    ? _buildMetricsLoadingState()
                    : _error != null
                    ? _buildErrorState()
                    : _buildMetricsCards(),

                SizedBox(height: 4.h),

                // Enrollment Chart Section
                Text(
                  'Enrollment Trends',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                EnrollmentChart(
                  chartData: _enrollmentChartData ?? [],
                  isLoading: _isLoading,
                ),

                SizedBox(height: 4.h),

                // Quick Actions Section
                Text(
                  'Quick Actions',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5.w,
                    mainAxisSpacing: 3.h,
                    childAspectRatio: 2.0,
                  ),
                  itemCount: _quickActions.length,
                  itemBuilder: (context, index) {
                    final action = _quickActions[index];
                    return QuickActionButton(
                      title: action["title"] as String,
                      iconName: action["icon"] as String,
                      onTap: () => _onQuickActionTap(action["route"] as String),
                    );
                  },
                ),

                SizedBox(height: 4.h),

                // Activity Feed Section
                Text(
                  'Recent Activity',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                _isLoading
                    ? _buildActivityLoadingState()
                    : (_activityFeed?.isEmpty ?? true)
                    ? _buildEmptyActivityState()
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _activityFeed!.length,
                        itemBuilder: (context, index) {
                          final activity = _activityFeed![index];
                          return AdminListItemCard(
                            title: activity["title"] as String,
                            description: activity["description"] as String,
                            timestamp: _formatTimestamp(
                              activity["timestamp"] as DateTime,
                            ),
                            status: activity["status"] as String,
                            avatarUrl: activity["avatar"] as String? ?? '',
                            onTap: () {
                              // Handle activity item tap
                            },
                            onLongPress: () {
                              // Show context menu for quick actions
                              _showContextMenu(context, activity);
                            },
                          );
                        },
                      ),

                SizedBox(height: 12.h), // Bottom padding for navigation bar
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surfaceWhite,
        selectedItemColor: AppTheme.primaryTeal,
        unselectedItemColor: AppTheme.textSecondary,
        elevation: 8.0,
        selectedLabelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: AppTheme.lightTheme.textTheme.labelMedium
            ?.copyWith(fontWeight: FontWeight.w400),
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              color: _currentIndex == 0
                  ? AppTheme.primaryTeal
                  : AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'school',
              color: _currentIndex == 1
                  ? AppTheme.primaryTeal
                  : AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Instructors',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'book',
              color: _currentIndex == 2
                  ? AppTheme.primaryTeal
                  : AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'people',
              color: _currentIndex == 3
                  ? AppTheme.primaryTeal
                  : AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Users',
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context, Map<String, dynamic> activity) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Quick Actions',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            if (activity["status"] == "pending") ...[
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.successGreen,
                  size: 24,
                ),
                title: Text(
                  'Approve',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Handle approve action
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'cancel',
                  color: AppTheme.errorRed,
                  size: 24,
                ),
                title: Text(
                  'Reject',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Handle reject action
                },
              ),
            ],
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                color: AppTheme.primaryTeal,
                size: 24,
              ),
              title: Text(
                'View Details',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle view details action
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
