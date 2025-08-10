import 'package:flutter/material.dart';
import 'package:knowble_app/config/theme.dart';
import './widgets/user_filter_chip.dart';
import './widgets/user_list_item_card.dart';
import '../../widgets/custom_icon_widget.dart';

class AdminUsersManagement extends StatefulWidget {
  const AdminUsersManagement({super.key});

  @override
  State<AdminUsersManagement> createState() => _AdminUsersManagementState();
}

class _AdminUsersManagementState extends State<AdminUsersManagement>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentIndex = 3; // Users tab active

  final List<Map<String, dynamic>> _mockUsers = [
    {
      "id": 1,
      "name": "Sarah Johnson",
      "email": "sarah.johnson@email.com",
      "profileImage":
          "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400",
      "role": "Student",
      "registrationDate": DateTime.now().subtract(const Duration(days: 45)),
      "status": "Active",
      "lastActivity": DateTime.now().subtract(const Duration(hours: 2)),
      "feedbacks": [
        {
          "id": "fb1",
          "type": "Bug Report",
          "category": "Video Playback",
          "message": "Videos are not loading properly in course module 3",
          "status": "pending",
          "submitted_at": DateTime.now().subtract(const Duration(days: 2)),
          "admin_notes": null,
        },
        {
          "id": "fb2",
          "type": "Feature Request",
          "category": "UI/UX",
          "message": "Would like dark mode option for the app",
          "status": "resolved",
          "submitted_at": DateTime.now().subtract(const Duration(days: 10)),
          "admin_notes": "Added to development roadmap for next release",
        },
      ],
    },
    {
      "id": 2,
      "name": "Michael Rodriguez",
      "email": "m.rodriguez@university.edu",
      "profileImage":
          "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400",
      "role": "Instructor",
      "registrationDate": DateTime.now().subtract(const Duration(days: 120)),
      "status": "Active",
      "lastActivity": DateTime.now().subtract(const Duration(minutes: 30)),
      "feedbacks": [
        {
          "id": "fb3",
          "type": "Bug Report",
          "category": "Course Management",
          "message": "Unable to upload large PDF files to course materials",
          "status": "pending",
          "submitted_at": DateTime.now().subtract(const Duration(hours: 5)),
          "admin_notes": null,
        },
      ],
    },
    {
      "id": 3,
      "name": "Emily Chen",
      "email": "emily.chen@email.com",
      "profileImage":
          "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400",
      "role": "Student",
      "registrationDate": DateTime.now().subtract(const Duration(days: 15)),
      "status": "Active",
      "lastActivity": DateTime.now().subtract(const Duration(minutes: 45)),
      "feedbacks": [
        {
          "id": "fb4",
          "type": "General Feedback",
          "category": "Course Content",
          "message":
              "The mathematics course is excellent! Very clear explanations.",
          "status": "resolved",
          "submitted_at": DateTime.now().subtract(const Duration(days: 3)),
          "admin_notes": "Forwarded positive feedback to instructor team",
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredUsers = List.from(_mockUsers);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreUsers();
    }
  }

  void _loadMoreUsers() {
    if (!_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });

      // Simulate loading more users
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty && _selectedFilter == 'All') {
        _filteredUsers = List.from(_mockUsers);
      } else {
        _filteredUsers = _mockUsers.where((user) {
          final matchesQuery =
              query.isEmpty ||
              (user['name'] as String).toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              (user['email'] as String).toLowerCase().contains(
                query.toLowerCase(),
              );

          final matchesFilter =
              _selectedFilter == 'All' ||
              (user['role'] as String) == _selectedFilter;

          return matchesQuery && matchesFilter;
        }).toList();
      }
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _filterUsers(_searchController.text);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _filteredUsers = List.from(_mockUsers);
      });
    }
  }

  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/admin/instructors');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/admin/courses');
        break;
      case 3:
        // Already on users screen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Users Management',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.primaryTeal,
          child: Column(
            children: [
              // Search Bar
              Container(
                padding: EdgeInsets.all(16),
                color: AppTheme.surfaceWhite,
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterUsers,
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    prefixIcon: CustomIconWidget(
                      iconName: 'search',
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _filterUsers('');
                            },
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                ),
              ),

              // Filter Chips
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppTheme.surfaceWhite,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      UserFilterChip(
                        label: 'All',
                        isSelected: _selectedFilter == 'All',
                        onTap: () => _onFilterChanged('All'),
                      ),
                      SizedBox(width: 8),
                      UserFilterChip(
                        label: 'Students',
                        isSelected: _selectedFilter == 'Student',
                        onTap: () => _onFilterChanged('Student'),
                      ),
                      SizedBox(width: 8),
                      UserFilterChip(
                        label: 'Instructors',
                        isSelected: _selectedFilter == 'Instructor',
                        onTap: () => _onFilterChanged('Instructor'),
                      ),
                      SizedBox(width: 8),
                      UserFilterChip(
                        label: 'Admins',
                        isSelected: _selectedFilter == 'Admin',
                        onTap: () => _onFilterChanged('Admin'),
                      ),
                    ],
                  ),
                ),
              ),

              // Users List
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryTeal,
                        ),
                      )
                    : _filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount:
                            _filteredUsers.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _filteredUsers.length) {
                            return Container(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                            );
                          }

                          final user = _filteredUsers[index];
                          return UserListItemCard(
                            user: user,
                            onTap: () => _showUserActions(user),
                            onLongPress: () => _showUserActions(user),
                          );
                        },
                      ),
              ),
            ],
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
        elevation: 8,
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

  void _showUserActions(Map<String, dynamic> user) {
    _showUserFeedbacks(user);
  }

  void _showUserFeedbacks(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(user['profileImage'] ?? ''),
                    backgroundColor: AppTheme.primaryTeal,
                    child: user['profileImage'] == null
                        ? Text(
                            user['name'][0].toUpperCase(),
                            style: TextStyle(
                              color: AppTheme.surfaceWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'],
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          user['email'],
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user['role'],
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                                  color: AppTheme.primaryTeal,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'User Feedback',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${user['feedbacks']?.length ?? 0} issues',
                      style: AppTheme.lightTheme.textTheme.labelMedium
                          ?.copyWith(
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: user['feedbacks'] == null || user['feedbacks'].isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'feedback',
                              color: AppTheme.textSecondary,
                              size: 48,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No feedback submitted',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: user['feedbacks'].length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final feedback = user['feedbacks'][index];
                          return _buildFeedbackCard(feedback, user);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(
    Map<String, dynamic> feedback,
    Map<String, dynamic> user,
  ) {
    Color statusColor;
    IconData statusIcon;

    switch (feedback['status']) {
      case 'pending':
        statusColor = AppTheme.warningAmber;
        statusIcon = Icons.pending;
        break;
      case 'resolved':
        statusColor = AppTheme.successGreen;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = AppTheme.textSecondary;
        statusIcon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  feedback['category'],
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Spacer(),
              Icon(statusIcon, color: statusColor, size: 16),
              SizedBox(width: 4),
              Text(
                feedback['status'].toUpperCase(),
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            feedback['type'],
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            feedback['message'],
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
              SizedBox(width: 4),
              Text(
                _formatFeedbackDate(feedback['submitted_at']),
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () => _showFeedbackDetails(feedback, user),
                child: Text(
                  'View Details',
                  style: TextStyle(
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFeedbackDetails(
    Map<String, dynamic> feedback,
    Map<String, dynamic> user,
  ) {
    Navigator.pop(context); // Close the feedbacks sheet

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 2 - 20,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Feedback Details',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: feedback['status'] == 'pending'
                          ? AppTheme.warningAmber.withOpacity(0.1)
                          : AppTheme.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      feedback['status'].toUpperCase(),
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: feedback['status'] == 'pending'
                            ? AppTheme.warningAmber
                            : AppTheme.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('User Information', [
                        _buildDetailItem('Name', user['name']),
                        _buildDetailItem('Email', user['email']),
                        _buildDetailItem('Role', user['role']),
                      ]),
                      SizedBox(height: 20),
                      _buildDetailSection('Feedback Information', [
                        _buildDetailItem('Type', feedback['type']),
                        _buildDetailItem('Category', feedback['category']),
                        _buildDetailItem(
                          'Submitted',
                          _formatFeedbackDate(feedback['submitted_at']),
                        ),
                        _buildDetailItem('Status', feedback['status']),
                      ]),
                      SizedBox(height: 20),
                      _buildDetailSection('Message', [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Text(
                            feedback['message'],
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ),
                      ]),
                      if (feedback['admin_notes'] != null) ...[
                        SizedBox(height: 20),
                        _buildDetailSection('Admin Notes', [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.primaryTeal.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              feedback['admin_notes'],
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.textPrimary),
                            ),
                          ),
                        ]),
                      ],
                      SizedBox(height: 80), // Extra space for button
                    ],
                  ),
                ),
              ),
              if (feedback['status'] == 'pending')
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                    onPressed: () => _showSolveDialog(feedback, user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: AppTheme.surfaceWhite,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Solve Issue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSolveDialog(
    Map<String, dynamic> feedback,
    Map<String, dynamic> user,
  ) {
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit_note, color: AppTheme.primaryTeal),
            SizedBox(width: 8),
            Text(
              'Solve Issue',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add your admin notes to resolve this issue:',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter your response and resolution notes...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primaryTeal),
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              notesController.dispose();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (notesController.text.trim().isNotEmpty) {
                _solveFeedback(feedback, notesController.text.trim());
                notesController.dispose();
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close details sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Issue resolved successfully!'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: AppTheme.surfaceWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Resolve Issue'),
          ),
        ],
      ),
    );
  }

  void _solveFeedback(Map<String, dynamic> feedback, String adminNotes) {
    setState(() {
      feedback['status'] = 'resolved';
      feedback['admin_notes'] = adminNotes;
      feedback['resolved_at'] = DateTime.now();
    });
  }

  String _formatFeedbackDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'people_outline',
              color: AppTheme.textSecondary,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter criteria',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                _onFilterChanged('All');
              },
              child: Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
