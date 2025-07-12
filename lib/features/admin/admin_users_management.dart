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
        _filteredUsers =
            _mockUsers.where((user) {
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
                    suffixIcon:
                        _searchController.text.isNotEmpty
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
                height: 80,
                padding: EdgeInsets.symmetric(horizontal: 16),
                color: AppTheme.surfaceWhite,
                child: ListView(
                  scrollDirection: Axis.horizontal,
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

              // Users List
              Expanded(
                child:
                    _isLoading
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

  void _showUserActions(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'User Actions',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.primaryTeal,
                    size: 24,
                  ),
                  title: Text(
                    'View Profile',
                    style: AppTheme.lightTheme.textTheme.bodyLarge,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle view profile
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'edit',
                    color: AppTheme.primaryTeal,
                    size: 24,
                  ),
                  title: Text(
                    'Edit Role',
                    style: AppTheme.lightTheme.textTheme.bodyLarge,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle edit role
                  },
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
    );
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
