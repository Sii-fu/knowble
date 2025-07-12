import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import './widgets/instructor_list_item_card.dart';
import '../../widgets/custom_icon_widget.dart';

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
  List<int> _selectedInstructors = [];
  int _currentIndex = 1; // Instructors tab active

  final List<Map<String, dynamic>> _mockInstructors = [
    {
      "id": 1,
      "name": "Dr. Sarah Johnson",
      "email": "sarah.johnson@university.edu",
      "profileImage":
          "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400",
      "status": "Pending",
      "appliedDate": DateTime.now().subtract(const Duration(hours: 2)),
      "specialization": "Computer Science",
      "experience": "8 years",
      "documents": ["CV", "Degree Certificate", "ID Proof"],
    },
    {
      "id": 2,
      "name": "Prof. Michael Rodriguez",
      "email": "m.rodriguez@university.edu",
      "profileImage":
          "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400",
      "status": "Approved",
      "appliedDate": DateTime.now().subtract(const Duration(days: 5)),
      "specialization": "Mathematics",
      "experience": "12 years",
      "documents": ["CV", "Degree Certificate", "Teaching Certificate"],
    },
  ];

  List<Map<String, dynamic>> get _filteredInstructors {
    if (_searchQuery.isEmpty) {
      return _mockInstructors;
    }
    return _mockInstructors.where((instructor) {
      final name = (instructor['name'] as String).toLowerCase();
      final email = (instructor['email'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _onBottomNavTap(int index) {
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
    setState(() {
      // Simulate refresh
    });
    await Future.delayed(const Duration(seconds: 1));
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedInstructors.clear();
      }
    });
  }

  void _toggleInstructorSelection(int instructorId) {
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
        title: Text('Instructors Management'),
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
        child: Column(
          children: [
            // Search Bar
            Container(
              color: AppTheme.surfaceWhite,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search by name or email...',
                        prefixIcon: CustomIconWidget(
                          iconName: 'search',
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                        suffixIcon:
                            _searchQuery.isNotEmpty
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
                  IconButton(
                    onPressed: () {}, // Filter options
                    icon: CustomIconWidget(
                      iconName: 'filter_list',
                      color: AppTheme.primaryTeal,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Instructors List
            Expanded(
              child:
                  _filteredInstructors.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppTheme.primaryTeal,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          itemCount: _filteredInstructors.length,
                          itemBuilder: (context, index) {
                            final instructor = _filteredInstructors[index];
                            final instructorId = instructor['id'] as int;
                            final isSelected = _selectedInstructors.contains(
                              instructorId,
                            );

                            return InstructorListItemCard(
                              instructor: instructor,
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
                              onViewDocuments: () => _viewDocuments(instructor),
                            );
                          },
                        ),
                      ),
            ),
          ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'school_outlined',
              color: AppTheme.textSecondary,
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              'No Instructors Found',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'All instructor applications have been processed',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _approveInstructor(Map<String, dynamic> instructor) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Approve Instructor'),
            content: Text(
              'Are you sure you want to approve ${instructor['name']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    instructor['status'] = 'Approved';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${instructor['name']} has been approved'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successGreen,
                ),
                child: Text('Approve'),
              ),
            ],
          ),
    );
  }

  void _rejectInstructor(Map<String, dynamic> instructor) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Reject Instructor'),
            content: Text(
              'Are you sure you want to reject ${instructor['name']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    instructor['status'] = 'Rejected';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${instructor['name']} has been rejected'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorRed,
                ),
                child: Text('Reject'),
              ),
            ],
          ),
    );
  }

  void _viewDocuments(Map<String, dynamic> instructor) {
    // Implementation for viewing documents
  }

  void _showInstructorDetail(Map<String, dynamic> instructor) {
    // Implementation for showing instructor details
  }
}
