import 'package:flutter/material.dart';
import 'package:knowble_app/config/theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class UserListItemCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const UserListItemCard({
    super.key,
    required this.user,
    this.onTap,
    this.onLongPress,
  });

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Student':
        return AppTheme.warningAmber;
      case 'Instructor':
        return AppTheme.primaryTeal;
      case 'Admin':
        return AppTheme.errorRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = user['name'] as String? ?? 'Unknown User';
    final userEmail = user['email'] as String? ?? 'No email';
    final userRole = user['role'] as String? ?? 'Student';
    final userStatus = user['status'] as String? ?? 'Active';
    final profileImage = user['profileImage'] as String? ?? '';
    final lastActivity = user['lastActivity'] as DateTime? ?? DateTime.now();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2.0,
      color: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header
              Row(
                children: [
                  // Profile Image
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.borderSubtle,
                        width: 1,
                      ),
                    ),
                    child: ClipOval(
                      child:
                          profileImage.isNotEmpty
                              ? Image.network(
                                profileImage,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppTheme.accentLight,
                                    child: Center(
                                      child: Text(
                                        userName.isNotEmpty
                                            ? userName[0].toUpperCase()
                                            : 'U',
                                        style: AppTheme
                                            .lightTheme
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: AppTheme.primaryTeal,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              )
                              : Container(
                                color: AppTheme.accentLight,
                                child: Center(
                                  child: Text(
                                    userName.isNotEmpty
                                        ? userName[0].toUpperCase()
                                        : 'U',
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: AppTheme.primaryTeal,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                    ),
                  ),
                  SizedBox(width: 12),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                userName,
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getRoleColor(
                                  userRole,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                userRole,
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                      color: _getRoleColor(userRole),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    userStatus == 'Active'
                                        ? AppTheme.successGreen
                                        : AppTheme.textSecondary,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              userStatus,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                            Spacer(),
                            CustomIconWidget(
                              iconName: 'access_time',
                              color: AppTheme.textSecondary,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              _formatDate(lastActivity),
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action indicator
                  CustomIconWidget(
                    iconName: 'chevron_right',
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
