import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../config/theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../core/services/student/feedback_service.dart';
import '../../../data/models/feedback.dart' as feedback_model;
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
  final FeedbackService _feedbackService = FeedbackService();

  bool _isLoading = true;
  final String _searchQuery = '';
  final List<String> _activeFilters = [];
  DateTime? _lastSyncTime;

  // Real feedback data from Supabase
  List<feedback_model.Feedback> _allFeedback = [];
  List<feedback_model.Feedback> _filteredFeedback = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load real feedback data from Supabase
      final feedbackList = await _feedbackService.getFeedbackHistory();

      setState(() {
        _allFeedback = feedbackList;
        _filteredFeedback = List.from(_allFeedback);
        _lastSyncTime = DateTime.now();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading feedback history: $e');
      setState(() {
        _allFeedback = [];
        _filteredFeedback = [];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load feedback history'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    try {
      // Refresh feedback data from Supabase
      final feedbackList = await _feedbackService.getFeedbackHistory();

      setState(() {
        _allFeedback = feedbackList;
        _filteredFeedback = List.from(_allFeedback);
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
    } catch (e) {
      print('Error refreshing feedback history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh feedback history'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredFeedback = _allFeedback.where((feedback) {
        // Search query filter
        if (_searchQuery.isNotEmpty) {
          final message = feedback.message.toLowerCase();
          final type = feedback.type.toLowerCase();
          final category = feedback.category.toLowerCase();

          if (!message.contains(_searchQuery.toLowerCase()) &&
              !type.contains(_searchQuery.toLowerCase()) &&
              !category.contains(_searchQuery.toLowerCase())) {
            return false;
          }
        }

        // Active filters
        if (_activeFilters.isNotEmpty) {
          final type = feedback.type;
          final category = feedback.category;

          if (!_activeFilters.contains(type) &&
              !_activeFilters.contains(category)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _showFeedbackDetail(feedback_model.Feedback feedback) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: AppTheme.lightTheme,
        child: FeedbackDetailDialog(feedback: feedback.toMap()),
      ),
    );
  }

  void _showContextMenu(feedback_model.Feedback feedback) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        color: AppTheme.surfaceWhite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                size: 24,
                color: AppTheme.primaryTeal,
              ),
              title: Text(
                'View Details',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                _showFeedbackDetail(feedback);
              },
            ),
            if (feedback.status.toLowerCase() != 'resolved' &&
                feedback.status.toLowerCase() != 'closed')
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'add_comment',
                  size: 24,
                  color: AppTheme.primaryTeal,
                ),
                title: Text(
                  'Follow Up',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/feedback-form');
                },
              ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete_outline',
                size: 24,
                color: AppTheme.errorRed,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                // Note: Feedback deletion would require backend implementation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Feedback deletion is not currently available',
                    ),
                    backgroundColor: AppTheme.errorRed,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _deleteAllFeedback() {
    final backupData = List<feedback_model.Feedback>.from(_allFeedback);

    setState(() {
      _allFeedback.clear();
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
              _allFeedback.addAll(backupData);
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        title: Text(
          'Delete All Feedback',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete all feedback? This action cannot be undone.',
          style: TextStyle(color: AppTheme.textPrimary),
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
            onPressed: () {
              Navigator.pop(context);
              _deleteAllFeedback();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: AppTheme.surfaceWhite,
            ),
            child: Text(
              'Delete All',
              style: TextStyle(color: AppTheme.surfaceWhite),
            ),
          ),
        ],
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
        cardTheme: CardThemeData(
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
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _refreshData,
              icon: CustomIconWidget(
                iconName: 'refresh',
                size: 24,
                color: AppTheme.textPrimary,
              ),
            ),
            IconButton(
              onPressed: _showDeleteAllConfirmation,
              icon: CustomIconWidget(
                iconName: 'delete_outline',
                size: 20,
                color: AppTheme.errorRed,
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
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
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
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      color: AppTheme.surfaceWhite,
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
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 15.w,
                  height: 2.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
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
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              width: 70.w,
              height: 2.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
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
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 18.w,
                  height: 2.5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
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
            feedback: feedback.toMap(),
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
