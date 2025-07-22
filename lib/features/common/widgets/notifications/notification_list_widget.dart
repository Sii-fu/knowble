import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/theme.dart';
import '../../screens/notifications/notifications_screen.dart';
import './date_section_header_widget.dart';
import './notification_card_widget.dart';

class NotificationListWidget extends StatelessWidget {
  final Map<String, List<NotificationItem>> notificationData;
  final bool isLoading;
  final Function(String)? onNotificationTap;
  final bool Function(String)? isNotificationClicked;

  const NotificationListWidget({
    Key? key,
    required this.notificationData,
    this.isLoading = false,
    this.onNotificationTap,
    this.isNotificationClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 1.h, bottom: 2.h),
      itemCount: notificationData.keys.length,
      itemBuilder: (context, index) {
        final dateKey = notificationData.keys.elementAt(index);
        final notifications = notificationData[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date section header
            DateSectionHeaderWidget(dateLabel: dateKey),

            // Notifications for this date
            ...notifications.map((notification) {
              final isClicked =
                  isNotificationClicked?.call(notification.id) ?? false;
              return NotificationCardWidget(
                notification: notification,
                isClicked: isClicked,
                onTap: () => onNotificationTap?.call(notification.id),
              );
            }).toList(),

            SizedBox(height: 1.5.h),
          ],
        );
      },
    );
  }
}
