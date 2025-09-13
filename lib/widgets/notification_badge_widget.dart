import 'package:flutter/material.dart';

/// Widget that shows a notification button with a red dot badge when there are unread notifications
class NotificationBadgeWidget extends StatelessWidget {
  final VoidCallback onTap;
  final int unreadCount;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? size;
  final EdgeInsets? padding;

  const NotificationBadgeWidget({
    super.key,
    required this.onTap,
    required this.unreadCount,
    this.icon = Icons.notifications_outlined,
    this.iconColor,
    this.backgroundColor,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = unreadCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Icon(
              icon,
              size: size ?? 24,
              color: iconColor ?? theme.colorScheme.primary,
            ),
            if (hasUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Simple notification button with badge for app bars
class NotificationAppBarButton extends StatelessWidget {
  final VoidCallback onTap;
  final int unreadCount;
  final Color? iconColor;
  final double? iconSize;

  const NotificationAppBarButton({
    super.key,
    required this.onTap,
    required this.unreadCount,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = unreadCount > 0;

    return Stack(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(
            Icons.notifications_outlined,
            color: iconColor,
            size: iconSize ?? 24,
          ),
        ),
        if (hasUnread)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Circular notification button with badge
class NotificationCircularButton extends StatelessWidget {
  final VoidCallback onTap;
  final int unreadCount;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;

  const NotificationCircularButton({
    super.key,
    required this.onTap,
    required this.unreadCount,
    this.backgroundColor,
    this.iconColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = unreadCount > 0;

    return Stack(
      children: [
        Container(
          width: size ?? 40,
          height: size ?? 40,
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(
              Icons.notifications_outlined,
              color: iconColor ?? theme.colorScheme.primary,
              size: (size ?? 40) * 0.5,
            ),
          ),
        ),
        if (hasUnread)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
