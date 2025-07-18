import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:knowble_app/config/theme.dart';
import './widgets/admin_info_card.dart';
import './widgets/admin_list_item_card.dart';
import './widgets/quick_action_button.dart';
import '../../widgets/custom_icon_widget.dart';

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

  // Mock data for dashboard metrics
  final List<Map<String, dynamic>> _dashboardMetrics = [
    {
      "title": "Active Users",
      "value": "2,458",
      "growth": "+12.5%",
      "isPositive": true,
      "icon": "people",
      "color": AppTheme.primaryTeal,
    },
    {
      "title": "Pending Verifications",
      "value": "23",
      "growth": "-8.2%",
      "isPositive": false,
      "icon": "pending_actions",
      "color": AppTheme.errorRed,
    },
    {
      "title": "Course Reports",
      "value": "7",
      "growth": "+3.1%",
      "isPositive": true,
      "icon": "report",
      "color": AppTheme.successGreen,
    },
  ];

  // Mock data for activity feed
  final List<Map<String, dynamic>> _activityFeed = [
    {
      "id": 1,
      "type": "instructor_application",
      "title": "New Instructor Application",
      "description": "Dr. Sarah Johnson submitted verification documents",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 15)),
      "status": "pending",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
    },
    {
      "id": 2,
      "type": "course_report",
      "title": "Course Content Reported",
      "description": "Advanced Mathematics course flagged for review",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "status": "pending",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
    },
    {
      "id": 3,
      "type": "instructor_application",
      "title": "Instructor Verification Complete",
      "description": "Prof. Michael Chen has been approved",
      "timestamp": DateTime.now().subtract(const Duration(hours: 4)),
      "status": "approved",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
    },
    {
      "id": 4,
      "type": "course_report",
      "title": "Course Review Completed",
      "description": "Physics 101 content has been approved",
      "timestamp": DateTime.now().subtract(const Duration(hours: 6)),
      "status": "approved",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
    },
    {
      "id": 5,
      "type": "instructor_application",
      "title": "Application Rejected",
      "description": "Incomplete documentation from Alex Rodriguez",
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
      "status": "rejected",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
    },
  ];

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

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

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
            onPressed: () {},
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
                builder:
                    (context) => AlertDialog(
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
          SizedBox(width: 2.w),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.primaryTeal,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                SizedBox(height: 2.h),
                SizedBox(
                  height: 20.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _dashboardMetrics.length,
                    itemBuilder: (context, index) {
                      final metric = _dashboardMetrics[index];
                      return Container(
                        width: 70.w,
                        margin: EdgeInsets.only(right: 4.w),
                        child: AdminInfoCard(
                          title: metric["title"] as String,
                          value: metric["value"] as String,
                          growth: metric["growth"] as String,
                          isPositive: metric["isPositive"] as bool,
                          iconName: metric["icon"] as String,
                          color: metric["color"] as Color,
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 3.h),

                // Quick Actions Section
                Text(
                  'Quick Actions',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.w,
                    mainAxisSpacing: 2.h,
                    childAspectRatio: 2.2,
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

                SizedBox(height: 3.h),

                // Activity Feed Section
                Text(
                  'Recent Activity',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _activityFeed.length,
                  itemBuilder: (context, index) {
                    final activity = _activityFeed[index];
                    return AdminListItemCard(
                      title: activity["title"] as String,
                      description: activity["description"] as String,
                      timestamp: _formatTimestamp(
                        activity["timestamp"] as DateTime,
                      ),
                      status: activity["status"] as String,
                      avatarUrl: activity["avatar"] as String,
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

                SizedBox(height: 10.h), // Bottom padding for navigation bar
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
              color:
                  _currentIndex == 0
                      ? AppTheme.primaryTeal
                      : AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'school',
              color:
                  _currentIndex == 1
                      ? AppTheme.primaryTeal
                      : AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Instructors',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'book',
              color:
                  _currentIndex == 2
                      ? AppTheme.primaryTeal
                      : AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'people',
              color:
                  _currentIndex == 3
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
      builder:
          (context) => Container(
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
