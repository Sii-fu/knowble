import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:Knowble/config/theme.dart';
import './widgets/instructor_list_item_card.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../core/services/admin_instructor_verification_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminInstructorsManagement extends StatefulWidget {
  const AdminInstructorsManagement({super.key});

  @override
  State<AdminInstructorsManagement> createState() =>
      _AdminInstructorsManagementState();
}

class _AdminInstructorsManagementState
    extends State<AdminInstructorsManagement> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isMultiSelectMode = false;
  final List<String> _selectedInstructors = [];
  int _currentIndex = 1; // Instructors tab active

  // Real data instead of mock data
  List<Map<String, dynamic>> _allInstructors = [];
  List<Map<String, dynamic>> _filteredInstructors = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Filter options
  String _currentFilter =
      'unverified'; // 'all', 'unverified', 'verified', 'rejected'

  @override
  void initState() {
    super.initState();
    _loadInstructors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInstructors() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      List<Map<String, dynamic>> instructors;

      switch (_currentFilter) {
        case 'all':
          instructors =
              await AdminInstructorVerificationService.getAllInstructorsWithStatus();
          break;
        case 'unverified':
        default:
          instructors =
              await AdminInstructorVerificationService.getUnverifiedInstructors();
          break;
      }

      if (!mounted) return;

      setState(() {
        _allInstructors = instructors;
        _filteredInstructors = instructors;
        _isLoading = false;
      });

      // Apply search filter if active
      if (_searchQuery.isNotEmpty) {
        _filterInstructors(_searchQuery);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load instructors: $e';
      });
    }
  }

  void _filterInstructors(String query) {
    if (!mounted) return;

    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredInstructors = _allInstructors;
      } else {
        _filteredInstructors = _allInstructors.where((instructor) {
          final name = (instructor['name'] as String? ?? '').toLowerCase();
          final email = (instructor['email'] as String? ?? '').toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || email.contains(searchLower);
        }).toList();
      }
    });
  }

  void _onSearchChanged(String value) {
    _filterInstructors(value);
  }

  void _changeFilter(String filter) {
    if (_currentFilter != filter) {
      setState(() {
        _currentFilter = filter;
      });
      _loadInstructors();
    }
  }

  void _onBottomNavTap(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
        break;
      case 1:
        // Already on instructors screen
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/admin/courses');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/admin/users');
        break;
    }
  }

  Future<void> _onRefresh() async {
    await _loadInstructors();
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedInstructors.clear();
      }
    });
  }

  void _toggleInstructorSelection(String instructorId) {
    setState(() {
      if (_selectedInstructors.contains(instructorId)) {
        _selectedInstructors.remove(instructorId);
      } else {
        _selectedInstructors.add(instructorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
        title: Text(
          'Instructor Management',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 22, // Increased font size
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        actions: [
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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 2.w,
          ), // Reduced from 4.w to 2.w
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h), // Increased space from top
              // Page Title and Description
              Text(
                _currentFilter == 'all'
                    ? 'All Instructors'
                    : 'Pending Verification',
                style: TextStyle(
                  fontSize: 28, // Increased font size
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                _currentFilter == 'all'
                    ? 'Manage all instructor accounts and their verification status'
                    : 'Review and approve instructor applications',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
              ),
              SizedBox(height: 3.h),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by name or email...',
                          hintStyle: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          prefixIcon: CustomIconWidget(
                            iconName: 'search',
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
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
                    SizedBox(width: 3.w),
                    PopupMenuButton<String>(
                      onSelected: _changeFilter,
                      color: AppTheme.surfaceWhite, // Fix dropdown background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      icon: CustomIconWidget(
                        iconName: 'filter_list',
                        color: AppTheme.primaryTeal,
                        size: 24,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'unverified',
                          child: Row(
                            children: [
                              Icon(
                                Icons.pending_actions,
                                color: _currentFilter == 'unverified'
                                    ? AppTheme.primaryTeal
                                    : AppTheme.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Unverified Only',
                                style: TextStyle(
                                  color: _currentFilter == 'unverified'
                                      ? AppTheme.primaryTeal
                                      : AppTheme.textPrimary,
                                  fontWeight: _currentFilter == 'unverified'
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'all',
                          child: Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: _currentFilter == 'all'
                                    ? AppTheme.primaryTeal
                                    : AppTheme.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'All Instructors',
                                style: TextStyle(
                                  color: _currentFilter == 'all'
                                      ? AppTheme.primaryTeal
                                      : AppTheme.textPrimary,
                                  fontWeight: _currentFilter == 'all'
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),

              // Instructors List
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _errorMessage.isNotEmpty
                    ? _buildErrorState()
                    : _filteredInstructors.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppTheme.primaryTeal,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          itemCount: _filteredInstructors.length,
                          itemBuilder: (context, index) {
                            final instructor = _filteredInstructors[index];
                            final instructorId = instructor['id'] as String;
                            final isSelected = _selectedInstructors.contains(
                              instructorId,
                            );

                            return Padding(
                              padding: EdgeInsets.only(bottom: 1.h),
                              child: InstructorListItemCard(
                                instructor: _convertToCardFormat(instructor),
                                isMultiSelectMode: _isMultiSelectMode,
                                isSelected: isSelected,
                                onTap: () {
                                  if (_isMultiSelectMode) {
                                    _toggleInstructorSelection(instructorId);
                                  } else {
                                    // Navigate to instructor detail
                                    _showInstructorDetail(instructor);
                                  }
                                },
                                onApprove: () => _approveInstructor(instructor),
                                onReject: () => _rejectInstructor(instructor),
                                onViewDocuments: () =>
                                    _viewDocuments(instructor),
                              ),
                            );
                          },
                        ),
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
              iconName: 'group',
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryTeal),
          SizedBox(height: 2.h),
          Text(
            'Loading instructors...',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
            SizedBox(height: 2.h),
            Text(
              'Error Loading Instructors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _loadInstructors,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
              ),
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'school',
              color: AppTheme.textSecondary,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              _currentFilter == 'all'
                  ? 'No Instructors Found'
                  : 'No Unverified Instructors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No instructors match your search criteria'
                  : _currentFilter == 'all'
                  ? 'There are no instructors registered yet'
                  : 'All instructors have been verified',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            if (_searchQuery.isNotEmpty) ...[
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
                ),
                child: Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper method to convert instructor data to card format
  Map<String, dynamic> _convertToCardFormat(Map<String, dynamic> instructor) {
    // Determine status based on both users.is_verified and instructor_info.verification_status
    String status;
    if (instructor['isVerified'] == true) {
      status = 'approved';
    } else if (instructor['verificationStatus'] == 'rejected') {
      status = 'rejected';
    } else {
      status = 'pending';
    }

    return {
      'id': instructor['id'],
      'name': instructor['name'] ?? 'Unknown',
      'email': instructor['email'] ?? '',
      'profileImage': instructor['profileImage'] ?? '',
      'status': status,
      'specialization':
          (instructor['subjectExpertise'] as List?)?.join(', ') ??
          'Not specified', // Card expects 'specialization'
      'location': instructor['currentLocation'] ?? 'Not specified',
      'experience':
          '${instructor['teachingExperience'] ?? 0} years', // Card expects 'experience' as String
      'registrationDate': instructor['registrationDate'],
      'hasDocuments':
          (instructor['cvFileName'] as String?)?.isNotEmpty ?? false,
    };
  }

  void _approveInstructor(Map<String, dynamic> instructor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Approve Instructor',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to approve ${instructor['name']}?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              navigator.pop();

              try {
                // Show loading
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Approving instructor...'),
                      backgroundColor: AppTheme.primaryTeal,
                    ),
                  );
                }

                print(
                  '[DEBUG UI] About to approve instructor: ${instructor['id']}, instructorInfoId: ${instructor['instructorInfoId']}',
                );

                await AdminInstructorVerificationService.approveInstructor(
                  instructor['id'] as String,
                  instructor['instructorInfoId'] as String?,
                );

                print('[DEBUG UI] Instructor approved, refreshing list...');

                // Refresh the list immediately
                await _loadInstructors();

                print('[DEBUG UI] List refreshed');

                if (mounted) {
                  scaffoldMessenger.hideCurrentSnackBar();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('${instructor['name']} has been approved'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                }
              } catch (e) {
                print('[ERROR UI] Failed to approve instructor: $e');
                if (mounted) {
                  scaffoldMessenger.hideCurrentSnackBar();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to approve instructor: $e'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: Colors.white,
            ),
            child: Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectInstructor(Map<String, dynamic> instructor) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reject Instructor',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 80.w, maxHeight: 60.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to reject ${instructor['name']}?',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                SizedBox(height: 2.h),
                TextField(
                  controller: reasonController,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Reason (optional)',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    hintText: 'Enter rejection reason...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.textSecondary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.primaryTeal),
                    ),
                    isDense: true,
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              reasonController.dispose();
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Get the reason before disposing the controller
              final reason = reasonController.text.trim();

              // Close dialog and dispose controller immediately
              Navigator.of(dialogContext).pop();
              reasonController.dispose();

              // Now perform the async operation with safe context references
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              try {
                // Show loading
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Rejecting instructor and sending email...',
                      ),
                      backgroundColor: AppTheme.primaryTeal,
                    ),
                  );
                }

                await AdminInstructorVerificationService.rejectInstructorWithEmail(
                  instructor['id'] as String,
                  instructor['instructorInfoId'] as String?,
                  instructor['name'] as String,
                  instructor['email'] as String,
                  reason: reason.isNotEmpty ? reason : null,
                );

                // Refresh the list
                await _loadInstructors();

                if (mounted) {
                  scaffoldMessenger.hideCurrentSnackBar();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        '${instructor['name']} has been rejected and notified via email',
                      ),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.hideCurrentSnackBar();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to reject instructor: $e'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _viewDocuments(Map<String, dynamic> instructor) {
    final cvFilePath = instructor['cvFilePath'] as String?;

    if (cvFilePath == null || cvFilePath.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No documents available for this instructor'),
            backgroundColor: AppTheme.warningAmber,
          ),
        );
      }
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Instructor Documents',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents for ${instructor['name']}:',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: Icon(Icons.description, color: AppTheme.primaryTeal),
              title: Text(
                instructor['cvFileName'] ?? 'CV Document',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'PDF Document',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              trailing: IconButton(
                icon: Icon(Icons.open_in_new, color: AppTheme.primaryTeal),
                onPressed: () {
                  Navigator.pop(context);
                  _openDocument(cvFilePath);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openDocument(cvFilePath);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
            ),
            child: Text('View Document'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDocument(String filePath) async {
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Show loading
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Opening document...'),
          backgroundColor: AppTheme.primaryTeal,
          duration: Duration(seconds: 2),
        ),
      );

      final documentUrl =
          await AdminInstructorVerificationService.getInstructorDocumentUrl(
            filePath,
          );

      if (await canLaunchUrl(Uri.parse(documentUrl))) {
        await launchUrl(
          Uri.parse(documentUrl),
          mode: LaunchMode.externalApplication,
        );

        if (mounted) {
          scaffoldMessenger.hideCurrentSnackBar();
        }
      } else {
        throw Exception('Could not launch document URL');
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to open document: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showInstructorDetail(Map<String, dynamic> instructor) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 90.w,
          constraints: BoxConstraints(maxHeight: 85.h, maxWidth: 90.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                      backgroundImage:
                          instructor['profileImage'] != null &&
                              instructor['profileImage'].toString().isNotEmpty
                          ? NetworkImage(instructor['profileImage'])
                          : null,
                      child:
                          instructor['profileImage'] == null ||
                              instructor['profileImage'].toString().isEmpty
                          ? Text(
                              (instructor['name'] as String? ?? 'U')[0]
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryTeal,
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            instructor['name'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            instructor['email'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: instructor['isVerified'] == true
                                  ? AppTheme.successGreen.withOpacity(0.1)
                                  : AppTheme.warningAmber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              instructor['isVerified'] == true
                                  ? 'Verified'
                                  : 'Pending',
                              style: TextStyle(
                                color: instructor['isVerified'] == true
                                    ? AppTheme.successGreen
                                    : AppTheme.warningAmber,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Contact Information', [
                        _buildDetailItem(
                          'Email',
                          instructor['email'] ?? 'Not provided',
                        ),
                        _buildDetailItem(
                          'Phone',
                          instructor['phoneNumber'] ?? 'Not provided',
                        ),
                        _buildDetailItem(
                          'Location',
                          instructor['currentLocation'] ?? 'Not provided',
                        ),
                      ]),

                      SizedBox(height: 2.h),

                      _buildDetailSection('Education & Experience', [
                        _buildDetailItem(
                          'Education Degree',
                          instructor['educationDegree'] ?? 'Not provided',
                        ),
                        _buildDetailItem(
                          'Teaching Experience',
                          '${instructor['teachingExperience'] ?? 0} years',
                        ),
                        _buildDetailItem(
                          'Subject Expertise',
                          (instructor['subjectExpertise'] as List?)?.join(
                                ', ',
                              ) ??
                              'Not provided',
                        ),
                      ]),

                      if (instructor['bio'] != null &&
                          (instructor['bio'] as String).isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        _buildDetailSection('Bio', [
                          Text(
                            instructor['bio'],
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ]),
                      ],

                      SizedBox(height: 2.h),

                      _buildDetailSection('Registration Details', [
                        _buildDetailItem(
                          'Registration Date',
                          instructor['registrationDate'] != null
                              ? (instructor['registrationDate'] as DateTime)
                                    .toString()
                                    .split(' ')[0]
                              : 'Not available',
                        ),
                        _buildDetailItem(
                          'Verification Status',
                          instructor['isVerified'] == true
                              ? 'Verified'
                              : instructor['verificationStatus'] == 'rejected'
                              ? 'Rejected'
                              : 'Pending',
                        ),
                        if (instructor['submittedAt'] != null)
                          _buildDetailItem(
                            'Application Submitted',
                            (instructor['submittedAt'] as DateTime)
                                .toString()
                                .split(' ')[0],
                          ),
                        if (instructor['verifiedAt'] != null)
                          _buildDetailItem(
                            'Verified Date',
                            (instructor['verifiedAt'] as DateTime)
                                .toString()
                                .split(' ')[0],
                          ),
                      ]),
                    ],
                  ),
                ),
              ),

              // Action Buttons - Fixed at bottom
              if (!instructor['isVerified']) ...[
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Document button (full width)
                      if (instructor['cvFilePath'] != null &&
                          (instructor['cvFilePath'] as String).isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _viewDocuments(instructor);
                            },
                            icon: Icon(Icons.description, size: 18),
                            label: Text('View CV Document'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryTeal,
                              side: BorderSide(color: AppTheme.primaryTeal),
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            ),
                          ),
                        ),

                      if (instructor['cvFilePath'] != null &&
                          (instructor['cvFilePath'] as String).isNotEmpty)
                        SizedBox(height: 1.h),

                      // Approve and Reject buttons (side by side)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _approveInstructor(instructor);
                              },
                              icon: Icon(Icons.check, size: 18),
                              label: Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successGreen,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _rejectInstructor(instructor);
                              },
                              icon: Icon(Icons.close, size: 18),
                              label: Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorRed,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 1.h),
        ...children,
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
