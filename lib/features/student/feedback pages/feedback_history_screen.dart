import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../config/theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/feedback_card_widget.dart';
import './widgets/feedback_detail_dialog.dart';

class FeedbackHistoryScreen extends StatefulWidget {
  const FeedbackHistoryScreen({super.key});

  @override
  State<FeedbackHistoryScreen> createState() => _FeedbackHistoryScreenState();
}

class _FeedbackHistoryScreenState extends State<FeedbackHistoryScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool _isLoading = true;
  final bool _isSearchVisible = false;
  final String _searchQuery = '';
  final List<String> _activeFilters = [];
  DateTime? _lastSyncTime;

  // Mock feedback data - in real app this would come from Supabase
  final List<Map<String, dynamic>> _allFeedbackData = [
    {
      "id": 1,
      "user_id": "user_123",
      "feedback_type": "Bug",
      "category": "App UI",
      "message":
          "The submit button on the feedback form is not responding properly when tapped multiple times. This creates confusion as users don't know if their feedback was submitted successfully.",
      "status": "Under Review",
      "created_at": "2025-08-03T14:30:00.000Z",
      "updated_at": "2025-08-03T16:45:00.000Z",
      "admin_response": null,
    },
    {
      "id": 2,
      "user_id": "user_123",
      "feedback_type": "Feature Request",
      "category": "Course",
      "message":
          "It would be great to have offline video downloads for courses so students can learn without internet connectivity during commutes.",
      "status": "Resolved",
      "created_at": "2025-08-01T09:15:00.000Z",
      "updated_at": "2025-08-02T11:20:00.000Z",
      "admin_response":
          "Thank you for your suggestion! We're happy to inform you that offline video downloads are now available in the latest app update. You can find this feature in the course settings.",
    },
    {
      "id": 3,
      "user_id": "user_123",
      "feedback_type": "Complaint",
      "category": "Payment",
      "message":
          "I was charged twice for the same course enrollment. The payment went through successfully but I received two separate charges on my credit card statement.",
      "status": "Closed",
      "created_at": "2025-07-30T16:20:00.000Z",
      "updated_at": "2025-07-31T10:30:00.000Z",
      "admin_response":
          "We sincerely apologize for the duplicate charge. Our billing team has processed a full refund for the duplicate transaction. You should see the refund in your account within 3-5 business days.",
    },
    {
      "id": 4,
      "user_id": "user_123",
      "feedback_type": "General Feedback",
      "category": "Instructor",
      "message":
          "Professor Johnson's teaching style is excellent and very engaging. The interactive examples really help understand complex concepts better.",
      "status": "Submitted",
      "created_at": "2025-07-28T13:45:00.000Z",
      "updated_at": "2025-07-28T13:45:00.000Z",
      "admin_response": null,
    },
    {
      "id": 5,
      "user_id": "user_123",
      "feedback_type": "Bug",
      "category": "Course",
      "message":
          "Video playback keeps buffering even with good internet connection. This makes it difficult to follow along with the lectures smoothly.",
      "status": "Under Review",
      "created_at": "2025-07-25T11:10:00.000Z",
      "updated_at": "2025-07-26T14:15:00.000Z",
      "admin_response": null,
    },
  ];

  List<Map<String, dynamic>> _filteredFeedback = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _filteredFeedback = List.from(_allFeedbackData);
      _lastSyncTime = DateTime.now();
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    // Simulate refresh with real-time updates
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _filteredFeedback = List.from(_allFeedbackData);
      _lastSyncTime = DateTime.now();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feedback history updated'),
          backgroundColor: AppTheme.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredFeedback = _allFeedbackData.where((feedback) {
        // Search query filter
        if (_searchQuery.isNotEmpty) {
          final message = (feedback['message'] as String? ?? '').toLowerCase();
          final type = (feedback['feedback_type'] as String? ?? '')
              .toLowerCase();
          final category = (feedback['category'] as String? ?? '')
              .toLowerCase();

          if (!message.contains(_searchQuery.toLowerCase()) &&
              !type.contains(_searchQuery.toLowerCase()) &&
              !category.contains(_searchQuery.toLowerCase())) {
            return false;
          }
        }

        // Active filters
        if (_activeFilters.isNotEmpty) {
          final type = feedback['feedback_type'] as String? ?? '';
          final category = feedback['category'] as String? ?? '';

          if (!_activeFilters.contains(type) &&
              !_activeFilters.contains(category)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _showFeedbackDetail(Map<String, dynamic> feedback) {
    showDialog(
      context: context,
      builder: (context) => FeedbackDetailDialog(feedback: feedback),
    );
  }

  void _showContextMenu(Map<String, dynamic> feedback) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                size: 24,
                color: theme.colorScheme.primary,
              ),
              title: Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _showFeedbackDetail(feedback);
              },
            ),
            if ((feedback['status'] as String? ?? '').toLowerCase() !=
                    'resolved' &&
                (feedback['status'] as String? ?? '').toLowerCase() != 'closed')
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'add_comment',
                  size: 24,
                  color: theme.colorScheme.secondary,
                ),
                title: Text('Follow Up'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/feedback-form-screen');
                },
              ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete_outline',
                size: 24,
                color: theme.colorScheme.error,
              ),
              title: Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(feedback);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> feedback) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Feedback'),
        content: Text(
          'Are you sure you want to delete this feedback? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFeedback(feedback);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteFeedback(Map<String, dynamic> feedback) {
    setState(() {
      _allFeedbackData.removeWhere((item) => item['id'] == feedback['id']);
      _applyFilters();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Feedback deleted successfully'),
        backgroundColor: AppTheme.successGreen,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _allFeedbackData.add(feedback);
              _allFeedbackData.sort(
                (a, b) => DateTime.parse(
                  b['created_at'] as String,
                ).compareTo(DateTime.parse(a['created_at'] as String)),
              );
              _applyFilters();
            });
          },
        ),
      ),
    );
  }

  void _navigateToSubmitFeedback() {
    Navigator.pushNamed(context, '/feedback-form-screen');
  }

  void _showDeleteAllConfirmation() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete All Feedback'),
        content: Text(
          'Are you sure you want to delete all feedback? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllFeedback();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _deleteAllFeedback() {
    final backupData = List<Map<String, dynamic>>.from(_allFeedbackData);

    setState(() {
      _allFeedbackData.clear();
      _filteredFeedback.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All feedback deleted successfully'),
        backgroundColor: AppTheme.successGreen,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _allFeedbackData.addAll(backupData);
              _applyFilters();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: AppTheme.backgroundLight,
        appBarTheme: AppBarTheme(
          backgroundColor: AppTheme.surfaceWhite,
          foregroundColor: AppTheme.textPrimary,
          elevation: 2.0,
          shadowColor: Colors.black26,
          titleTextStyle: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardTheme(
          color: AppTheme.surfaceWhite,
          elevation: 2.0,
          shadowColor: Colors.black26,
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(color: AppTheme.textPrimary),
          titleMedium: TextStyle(color: AppTheme.textPrimary),
          bodyMedium: TextStyle(color: AppTheme.textPrimary),
          bodySmall: TextStyle(color: AppTheme.textSecondary),
          labelSmall: TextStyle(color: AppTheme.textSecondary),
        ),
        colorScheme: ColorScheme.light(
          primary: AppTheme.primaryTeal,
          onSurface: AppTheme.textPrimary,
          onSurfaceVariant: AppTheme.textSecondary,
          error: AppTheme.errorRed,
          onError: AppTheme.surfaceWhite,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'My Feedback',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: CustomIconWidget(
              iconName: 'refresh',
              size: 24,
              color: theme.colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: _showDeleteAllConfirmation,
            icon: CustomIconWidget(
              iconName: 'delete_outline',
              size: 20,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_lastSyncTime != null && !_isLoading)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Text(
                'Last synced: ${_formatSyncTime(_lastSyncTime!)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredFeedback.isEmpty
                ? _buildEmptyState()
                : _buildFeedbackList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      itemCount: 5,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 20.w,
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 15.w,
                  height: 2.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              height: 2.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              width: 70.w,
              height: 2.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Container(
                  width: 15.w,
                  height: 2.5.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 18.w,
                  height: 2.5.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(onSubmitFeedback: _navigateToSubmitFeedback);
  }

  Widget _buildFeedbackList() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        itemCount: _filteredFeedback.length,
        itemBuilder: (context, index) {
          final feedback = _filteredFeedback[index];
          return FeedbackCardWidget(
            feedback: feedback,
            onTap: () => _showFeedbackDetail(feedback),
            onLongPress: () => _showContextMenu(feedback),
          );
        },
      ),
    );
  }

  String _formatSyncTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
