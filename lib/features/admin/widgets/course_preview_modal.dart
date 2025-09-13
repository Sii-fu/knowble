import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:Knowble/config/theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class CoursePreviewModal extends StatefulWidget {
  final Map<String, dynamic> course;
  final Function(String decision, String? reason)? onDecision;

  const CoursePreviewModal({super.key, required this.course, this.onDecision});

  @override
  State<CoursePreviewModal> createState() => _CoursePreviewModalState();
}

class _CoursePreviewModalState extends State<CoursePreviewModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _handleDecision(String decision) {
    if (decision == 'approve') {
      _showDecisionConfirmation(decision);
    } else {
      _showReasonDialog(decision);
    }
  }

  void _showReasonDialog(String decision) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${decision == 'reject' ? 'Reject' : 'Flag'} Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason for ${decision == 'reject' ? 'rejecting' : 'flagging'} this course:',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.primaryTeal),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _reasonController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _showDecisionConfirmation(decision);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: decision == 'reject'
                  ? AppTheme.errorRed
                  : Colors.orange,
            ),
            child: Text(decision == 'reject' ? 'Reject' : 'Flag'),
          ),
        ],
      ),
    );
  }

  void _showDecisionConfirmation(String decision) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm ${decision.toUpperCase()}'),
        content: Text(
          'Are you sure you want to $decision the course "${widget.course['title']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close confirmation
              Navigator.pop(context); // Close preview modal
              widget.onDecision?.call(decision, _reasonController.text.trim());
              _reasonController.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: decision == 'approve'
                  ? AppTheme.successGreen
                  : decision == 'reject'
                  ? AppTheme.errorRed
                  : Colors.orange,
            ),
            child: Text(decision.toUpperCase()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      child: Container(
        width: double.infinity,
        height: 90.h,
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Course Review',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          widget.course['title'] as String? ?? 'Untitled Course',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.textSecondary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderSubtle),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryTeal,
                labelColor: AppTheme.primaryTeal,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Content'),
                  Tab(text: 'Details'),
                  Tab(text: 'Reports'),
                ],
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildContentTab(),
                  _buildDetailsTab(),
                  _buildReportsTab(),
                ],
              ),
            ),
            // Action Buttons
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleDecision('reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'close',
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          const Text('Reject'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleDecision('flag'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'flag',
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          const Text('Flag'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _handleDecision('approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'check',
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          const Text('Approve Course'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Thumbnail
          Container(
            width: double.infinity,
            height: 25.h,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.course['banner'] as String? ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.borderSubtle,
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'school',
                        color: AppTheme.textSecondary,
                        size: 60,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 3.h),
          // Course Title
          Text(
            widget.course['title'] as String? ?? 'Untitled Course',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          // Instructor
          Row(
            children: [
              CustomIconWidget(
                iconName: 'person',
                color: AppTheme.textSecondary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'By ${widget.course['instructor']}',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Quick Stats
          Row(
            children: [
              _buildStatChip(
                icon: 'people',
                value: '${widget.course['enrollmentCount'] ?? 0}',
                label: 'Students',
              ),
              SizedBox(width: 3.w),
              _buildStatChip(
                icon: 'schedule',
                value: widget.course['duration_days']?.toString() ?? 'N/A',
                label: 'Duration',
              ),
              SizedBox(width: 3.w),
              _buildStatChip(
                icon: 'star',
                value: '${widget.course['rating'] ?? 0}',
                label: 'Rating',
              ),
              SizedBox(width: 3.w),
              _buildStatChip(
                icon: 'attach_money',
                value: widget.course['isPaid'] == true
                    ? '৳${(widget.course['price'] ?? 0.0).toStringAsFixed(0)}'
                    : 'Free',
                label: 'Price',
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Status Information
          _buildInfoSection(
            title: 'Course Status',
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: _getStatusColor(
                  widget.course['status'],
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor(
                    widget.course['status'],
                  ).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: _getStatusIcon(widget.course['status']),
                    color: _getStatusColor(widget.course['status']),
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.course['status'].toString().toUpperCase(),
                        style: AppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(widget.course['status']),
                            ),
                      ),
                      Text(
                        _getStatusDescription(widget.course['status']),
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
          // Course Description
          _buildInfoSection(
            title: 'Course Description',
            child: Text(
              _generateDescription(),
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            title: 'Course Curriculum',
            child: Column(
              children: [
                _buildCurriculumItem(
                  'Introduction to the Course',
                  '15 min',
                  true,
                ),
                _buildCurriculumItem(
                  'Basic Concepts and Theory',
                  '45 min',
                  true,
                ),
                _buildCurriculumItem(
                  'Practical Applications',
                  '1.2 hours',
                  true,
                ),
                _buildCurriculumItem('Advanced Topics', '2 hours', false),
                _buildCurriculumItem('Final Assessment', '30 min', false),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          _buildInfoSection(
            title: 'Learning Objectives',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildObjectiveItem('Master fundamental concepts'),
                _buildObjectiveItem('Apply theoretical knowledge practically'),
                _buildObjectiveItem('Develop problem-solving skills'),
                _buildObjectiveItem('Complete real-world projects'),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          _buildInfoSection(
            title: 'Prerequisites',
            child: Text(
              'Basic understanding of the subject matter, access to required software/tools, and commitment to complete the course.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            title: 'Course Information',
            child: Column(
              children: [
                _buildDetailRow('Category', widget.course['category'] ?? 'N/A'),
                _buildDetailRow(
                  'Created',
                  _formatDate(widget.course['created_at']),
                ),
                _buildDetailRow('Duration', widget.course['duration_days']?.toString() ?? 'N/A'),
                _buildDetailRow(
                  'Price',
                  widget.course['isPaid'] == true
                      ? '৳${(widget.course['price'] ?? 0.0).toStringAsFixed(0)}'
                      : 'Free',
                ),
                _buildDetailRow(
                  'Course Type',
                  widget.course['isPaid'] == true ? 'Paid' : 'Free',
                ),
                _buildDetailRow('Difficulty', 'Intermediate'),
                _buildDetailRow('Language', 'English'),
                _buildDetailRow('Certificate', 'Yes'),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          _buildInfoSection(
            title: 'Instructor Details',
            child: Column(
              children: [
                _buildDetailRow('Name', widget.course['instructor'] ?? 'N/A'),
                _buildDetailRow('Experience', '5+ years'),
                _buildDetailRow('Courses Created', '12'),
                _buildDetailRow('Student Rating', '4.8/5'),
                _buildDetailRow('Total Students', '15,000+'),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          _buildInfoSection(
            title: 'Engagement Metrics',
            child: Column(
              children: [
                _buildDetailRow(
                  'Enrollments',
                  '${widget.course['enrollmentCount'] ?? 0}',
                ),
                _buildDetailRow('Completion Rate', '87%'),
                _buildDetailRow(
                  'Average Rating',
                  '${widget.course['rating'] ?? 0}/5',
                ),
                _buildDetailRow('Reviews Count', '342'),
                _buildDetailRow('Active Students', '156'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    final reportCount = widget.course['reportCount'] as int? ?? 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reportCount == 0) ...[
            Center(
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  CustomIconWidget(
                    iconName: 'verified',
                    color: AppTheme.successGreen,
                    size: 80,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No Reports',
                    style: AppTheme.lightTheme.textTheme.headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'This course has no reports or complaints',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _buildInfoSection(
              title: 'Report Summary',
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.errorRed.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'warning',
                      color: AppTheme.errorRed,
                      size: 24,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '$reportCount ${reportCount == 1 ? 'Report' : 'Reports'} Received',
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.errorRed,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 3.h),
            _buildInfoSection(
              title: 'Recent Reports',
              child: Column(
                children: [
                  _buildReportItem(
                    'Inappropriate Content',
                    'User reported content as inappropriate',
                    '2 days ago',
                    'high',
                  ),
                  _buildReportItem(
                    'Copyright Issue',
                    'Potential copyright violation reported',
                    '1 week ago',
                    'medium',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: AppTheme.primaryTeal,
            size: 16,
          ),
          SizedBox(width: 1.w),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryTeal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({required String title, required Widget child}) {
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
        SizedBox(height: 1.h),
        child,
      ],
    );
  }

  Widget _buildCurriculumItem(String title, String duration, bool isCompleted) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: isCompleted ? 'check_circle' : 'radio_button_unchecked',
            color: isCompleted ? AppTheme.successGreen : AppTheme.textSecondary,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              title,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            duration,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveItem(String objective) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 0.8.h),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              objective,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
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
              value.toString(),
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(
    String type,
    String description,
    String date,
    String severity,
  ) {
    Color severityColor = severity == 'high'
        ? AppTheme.errorRed
        : severity == 'medium'
        ? Colors.orange
        : AppTheme.warningAmber;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  severity.toUpperCase(),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: severityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Spacer(),
              Text(
                date,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            type,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            description,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppTheme.successGreen;
      case 'pending':
        return AppTheme.warningAmber;
      case 'rejected':
        return AppTheme.errorRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'verified';
      case 'pending':
        return 'schedule';
      case 'rejected':
        return 'cancel';
      default:
        return 'help';
    }
  }

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Course is live and available to students';
      case 'pending':
        return 'Awaiting admin review and approval';
      case 'rejected':
        return 'Course was rejected and needs revision';
      default:
        return 'Status unknown';
    }
  }

  String _generateDescription() {
    return 'This comprehensive course covers fundamental and advanced concepts in ${widget.course['category']}. '
        'Designed for learners who want to build strong foundations and practical skills, this course combines '
        'theoretical knowledge with hands-on exercises. Students will engage with real-world scenarios and '
        'complete projects that demonstrate their understanding of key principles.';
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is String) {
      try {
        final parsedDate = DateTime.parse(date);
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
      } catch (e) {
        return 'N/A';
      }
    }
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'N/A';
  }
}
