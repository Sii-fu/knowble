import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:Knowble/config/theme.dart';
import './widgets/user_verification_card.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../core/services/admin/admin_user_verification_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminUserVerificationManagement extends StatefulWidget {
  const AdminUserVerificationManagement({super.key});

  @override
  State<AdminUserVerificationManagement> createState() =>
      _AdminUserVerificationManagementState();
}

class _AdminUserVerificationManagementState
    extends State<AdminUserVerificationManagement> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isMultiSelectMode = false;
  final List<String> _selectedUsers = [];
  int _currentIndex = 4; // User verification tab active

  // Real data instead of mock data
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Filter options (simplified to only pending and approved)
  String _currentFilter = 'pending'; // 'all', 'pending', 'approved'

  // Statistics
  Map<String, int> _statistics = {
    'pending': 0,
    'approved': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadStatistics();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      List<Map<String, dynamic>> users;

      switch (_currentFilter) {
        case 'all':
          users =
              await AdminUserVerificationService.getAllUsersWithVerificationStatus();
          break;
        case 'approved':
          users =
              await AdminUserVerificationService.getAllUsersWithVerificationStatus(
                statusFilter: 'approved',
              );
          break;
        case 'pending':
        default:
          users =
              await AdminUserVerificationService.getUsersPendingVerification();
          break;
      }

      if (!mounted) return;

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });

      // Apply search filter if active
      if (_searchQuery.isNotEmpty) {
        _filterUsers(_searchQuery);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load users: $e';
      });
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final stats =
          await AdminUserVerificationService.getVerificationStatistics();
      if (mounted) {
        setState(() {
          _statistics = stats;
        });
      }
    } catch (e) {
      print('Failed to load statistics: $e');
    }
  }

  void _filterUsers(String query) {
    if (!mounted) return;

    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          final name = (user['name'] as String? ?? '').toLowerCase();
          final email = (user['email'] as String? ?? '').toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || email.contains(searchLower);
        }).toList();
      }
    });
  }

  void _onSearchChanged(String value) {
    _filterUsers(value);
  }

  void _changeFilter(String filter) {
    if (_currentFilter != filter) {
      setState(() {
        _currentFilter = filter;
      });
      _loadUsers();
    }
  }

  void _onBottomNavTap(int index) {
    if (_currentIndex == index) return;

    // Don't update _currentIndex since we're navigating away
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
        Navigator.pushReplacementNamed(context, '/admin/users');
        break;
      case 4:
        // Already on user verification screen
        break;
    }
  }

  Future<void> _onRefresh() async {
    await _loadUsers();
    await _loadStatistics();
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedUsers.clear();
      }
    });
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUsers.contains(userId)) {
        _selectedUsers.remove(userId);
      } else {
        _selectedUsers.add(userId);
      }
    });
  }

  Future<void> _bulkApproveUsers() async {
    if (_selectedUsers.isEmpty) return;

    try {
      final successful =
          await AdminUserVerificationService.bulkApproveUserVerifications(
            _selectedUsers,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Approved ${successful.length} users successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );

        setState(() {
          _selectedUsers.clear();
          _isMultiSelectMode = false;
        });

        _loadUsers();
        _loadStatistics();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve users: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Widget _buildStatisticsCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  _statistics['pending'].toString(),
                  AppTheme.warningAmber,
                  Icons.pending,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  'Approved',
                  _statistics['approved'].toString(),
                  AppTheme.successGreen,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 2.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'pending', 'label': 'Pending', 'count': _statistics['pending']},
      {
        'key': 'approved',
        'label': 'Approved',
        'count': _statistics['approved'],
      },
      {'key': 'all', 'label': 'All', 'count': null},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _currentFilter == filter['key'];
            return Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(filter['label'] as String),
                    if (filter['count'] != null) ...[
                      SizedBox(width: 1.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.surfaceWhite
                              : AppTheme.primaryTeal,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          filter['count'].toString(),
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.primaryTeal
                                : AppTheme.surfaceWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => _changeFilter(filter['key'] as String),
                selectedColor: AppTheme.primaryTeal,
                backgroundColor: AppTheme.surfaceWhite,
                checkmarkColor: AppTheme.surfaceWhite,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppTheme.surfaceWhite
                      : AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.primaryTeal
                      : AppTheme.borderSubtle,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'User Verification',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        actions: [
          if (_isMultiSelectMode && _selectedUsers.isNotEmpty)
            TextButton(
              onPressed: _bulkApproveUsers,
              child: Text(
                'Approve (${_selectedUsers.length})',
                style: TextStyle(color: AppTheme.primaryTeal),
              ),
            ),
          if (_isMultiSelectMode)
            TextButton(onPressed: _toggleMultiSelectMode, child: Text('Cancel'))
          else
            IconButton(
              onPressed: _toggleMultiSelectMode,
              icon: CustomIconWidget(
                iconName: 'checklist',
                color: AppTheme.primaryTeal,
                size: 24,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.primaryTeal,
          child: Column(
            children: [
              // Statistics Overview
              _buildStatisticsCards(),

              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppTheme.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primaryTeal),
                    ),
                    filled: true,
                    fillColor: AppTheme.surfaceWhite,
                  ),
                ),
              ),

              // Filter Chips
              _buildFilterChips(),

              // Users List
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryTeal,
                        ),
                      )
                    : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppTheme.errorRed,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _errorMessage,
                              style: TextStyle(
                                color: AppTheme.errorRed,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 2.h),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryTeal,
                              ),
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 48,
                              color: AppTheme.textSecondary,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'No users found',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          final isSelected = _selectedUsers.contains(
                            user['id'],
                          );

                          return UserVerificationCard(
                            user: user,
                            isMultiSelectMode: _isMultiSelectMode,
                            isSelected: isSelected,
                            onTap: () {
                              if (_isMultiSelectMode) {
                                _toggleUserSelection(user['id']);
                              } else {
                                // Handle user detail view or verification actions
                                _showUserVerificationDialog(user);
                              }
                            },
                            onRefresh: _loadUsers,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surfaceWhite,
        selectedItemColor: AppTheme.primaryTeal,
        unselectedItemColor: AppTheme.textSecondary,
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              size: 24,
              color: _currentIndex == 0
                  ? AppTheme.primaryTeal
                  : AppTheme.textSecondary,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'instructor',
              size: 24,
              color: _currentIndex == 1
                  ? AppTheme.primaryTeal
                  : AppTheme.textSecondary,
            ),
            label: 'Instructors',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'course',
              size: 24,
              color: _currentIndex == 2
                  ? AppTheme.primaryTeal
                  : AppTheme.textSecondary,
            ),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'users',
              size: 24,
              color: _currentIndex == 3
                  ? AppTheme.primaryTeal
                  : AppTheme.textSecondary,
            ),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'verification',
              size: 24,
              color: _currentIndex == 4
                  ? AppTheme.primaryTeal
                  : AppTheme.textSecondary,
            ),
            label: 'Verification',
          ),
        ],
      ),
    );
  }

  void _showUserVerificationDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UserVerificationDialog(
          user: user,
          onRefresh: () {
            _loadUsers();
            _loadStatistics();
          },
        );
      },
    );
  }
}

class UserVerificationDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onRefresh;

  const UserVerificationDialog({
    Key? key,
    required this.user,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<UserVerificationDialog> createState() => _UserVerificationDialogState();
}

class _UserVerificationDialogState extends State<UserVerificationDialog> {
  final TextEditingController _rejectionReasonController =
      TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _approveUser() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await AdminUserVerificationService.approveUserVerification(
        widget.user['id'],
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User approved successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        widget.onRefresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve user: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _rejectUser() async {
    if (_rejectionReasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please provide a rejection reason'),
          backgroundColor: AppTheme.warningAmber,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await AdminUserVerificationService.rejectUserVerification(
        widget.user['id'],
        _rejectionReasonController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User verification rejected'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        widget.onRefresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject user: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _viewDocument() async {
    final documentPath = widget.user['documentPath'] as String?;
    if (documentPath == null || documentPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No document available'),
          backgroundColor: AppTheme.warningAmber,
        ),
      );
      return;
    }

    try {
      final url = await AdminUserVerificationService.getUserDocumentUrl(
        documentPath,
      );
      if (url != null) {
        await launchUrl(Uri.parse(url));
      } else {
        throw Exception('Could not generate document URL');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open document: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.user['verificationStatus'] as String? ?? 'pending';
    final documentType = widget.user['documentType'] as String? ?? 'Unknown';
    final submittedAt = widget.user['verificationSubmittedAt'] as DateTime?;

    return Dialog(
      backgroundColor: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: widget.user['profileImage'] != null
                      ? NetworkImage(widget.user['profileImage'])
                      : null,
                  child: widget.user['profileImage'] == null
                      ? Icon(Icons.person, color: AppTheme.textSecondary)
                      : null,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user['name'] ?? 'Unknown User',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        widget.user['email'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: AppTheme.textSecondary),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Document Information
            Text(
              'Document Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(4.w),
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
                      Icon(
                        Icons.description,
                        color: AppTheme.primaryTeal,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Document Type: $documentType',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontFamily: 'Jost',
                        ),
                      ),
                    ],
                  ),
                  if (submittedAt != null) ...[
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Submitted: ${submittedAt.toString().split(' ')[0]}',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontFamily: 'Jost',
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _viewDocument,
                      icon: Icon(Icons.visibility),
                      label: Text(
                        'View Document',
                        style: TextStyle(
                          color: AppTheme.surfaceWhite,
                          fontFamily: 'Jost',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: AppTheme.surfaceWhite,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (status == 'pending') ...[
              SizedBox(height: 3.h),

              // Rejection Reason Input
              Text(
                'Rejection Reason (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              TextField(
                controller: _rejectionReasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter reason for rejection...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.primaryTeal),
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _rejectUser,
                      icon: _isProcessing
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.surfaceWhite,
                              ),
                            )
                          : Icon(Icons.close),
                      label: Text(
                        'Reject',
                        style: TextStyle(
                          color: AppTheme.surfaceWhite,
                          fontFamily: 'Jost',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                        foregroundColor: AppTheme.surfaceWhite,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _approveUser,
                      icon: _isProcessing
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.surfaceWhite,
                              ),
                            )
                          : Icon(Icons.check),
                      label: Text(
                        'Approve',
                        style: TextStyle(
                          color: AppTheme.surfaceWhite,
                          fontFamily: 'Jost',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        foregroundColor: AppTheme.surfaceWhite,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: status == 'approved'
                      ? AppTheme.successGreen.withOpacity(0.1)
                      : AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: status == 'approved'
                        ? AppTheme.successGreen
                        : AppTheme.errorRed,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      status == 'approved' ? Icons.check_circle : Icons.cancel,
                      color: status == 'approved'
                          ? AppTheme.successGreen
                          : AppTheme.errorRed,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      status == 'approved'
                          ? 'Verification Approved'
                          : 'Verification Rejected',
                      style: TextStyle(
                        color: status == 'approved'
                            ? AppTheme.successGreen
                            : AppTheme.errorRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
