import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:Knowble/config/theme.dart';

class UserVerificationCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isMultiSelectMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onRefresh;

  const UserVerificationCard({
    super.key,
    required this.user,
    required this.isMultiSelectMode,
    required this.isSelected,
    required this.onTap,
    this.onRefresh,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppTheme.successGreen;
      case 'rejected':
        return AppTheme.errorRed;
      case 'pending':
        return AppTheme.warningAmber;
      default:
        return AppTheme.borderSubtle;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Verified';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending';
      default:
        return 'Not Submitted';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.verified_user;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.description;
    }
  }

  IconData _getDocumentIcon(String? documentType) {
    if (documentType == null) return Icons.description;

    switch (documentType.toLowerCase()) {
      case 'national_id':
      case 'national id':
        return Icons.credit_card;
      case 'birth_certificate':
      case 'birth certificate':
        return Icons.child_care;
      default:
        return Icons.description;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final name = user['name'] as String? ?? 'Unknown User';
    final email = user['email'] as String? ?? '';
    final profileImage = user['profileImage'] as String?;
    final verificationStatus =
        user['verificationStatus'] as String? ?? 'not_submitted';
    // documentType no longer stored; we show generic label
    final String? documentType = null;
    final isVerified = user['isVerified'] as bool? ?? false;
    final submittedAt = user['verificationSubmittedAt'] as DateTime?;
    final registrationDate = user['registrationDate'] as DateTime?;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryTeal : AppTheme.borderSubtle,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Multi-select checkbox
                    if (isMultiSelectMode)
                      Padding(
                        padding: EdgeInsets.only(right: 3.w),
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (_) => onTap(),
                          activeColor: AppTheme.primaryTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),

                    // Profile Image
                    CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          profileImage != null && profileImage.isNotEmpty
                          ? NetworkImage(profileImage)
                          : null,
                      backgroundColor: AppTheme.backgroundLight,
                      child: profileImage == null || profileImage.isEmpty
                          ? Icon(
                              Icons.person,
                              color: AppTheme.textSecondary,
                              size: 24,
                            )
                          : null,
                    ),

                    SizedBox(width: 3.w),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isVerified)
                                Icon(
                                  Icons.verified,
                                  color: AppTheme.successGreen,
                                  size: 18,
                                ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          verificationStatus,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(verificationStatus),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(verificationStatus),
                            size: 14,
                            color: _getStatusColor(verificationStatus),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            _getStatusText(verificationStatus),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(verificationStatus),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Details Row
                Row(
                  children: [
                    // Document Info
                    Expanded(
                      child: Container(
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
                                Icon(
                                  _getDocumentIcon(documentType),
                                  size: 16,
                                  color: AppTheme.primaryTeal,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Document',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              verificationStatus == 'not_submitted'
                                  ? 'Not Submitted'
                                  : 'UPLOADED',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 3.w),

                    // Submission Date
                    Expanded(
                      child: Container(
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
                                Icon(
                                  Icons.schedule,
                                  size: 16,
                                  color: AppTheme.primaryTeal,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Submitted',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              _formatDate(submittedAt),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Registration Date
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_add,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Registered: ${_formatDate(registrationDate)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons for pending status
                if (verificationStatus == 'pending' && !isMultiSelectMode) ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // This will be handled by the parent dialog
                            onTap();
                          },
                          icon: Icon(Icons.visibility, size: 16),
                          label: Text('Review'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryTeal,
                            side: BorderSide(color: AppTheme.primaryTeal),
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
