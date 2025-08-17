import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../features/common/screens/notifications/notifications_screen.dart';

/// Service to handle fetching and managing notifications from the database
class NotificationDataService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all notifications for the current user
  static Future<List<NotificationData>> fetchUserNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return [];
      }

      print('🔍 Fetching notifications for user: ${user.id}');

      final response = await _supabase
          .from('notification')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      print('✅ Fetched ${response.length} notifications');

      return response.map((data) => NotificationData.fromMap(data)).toList();
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      return [];
    }
  }

  /// Mark a notification as read
  static Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return false;
      }

      await _supabase
          .from('notification')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', user.id);

      print('✅ Notification marked as read: $notificationId');
      return true;
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read for the current user
  static Future<bool> markAllNotificationsAsRead() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return false;
      }

      await _supabase
          .from('notification')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);

      print('✅ All notifications marked as read');
      return true;
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Delete a notification
  static Future<bool> deleteNotification(String notificationId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return false;
      }

      await _supabase
          .from('notification')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', user.id);

      print('✅ Notification deleted: $notificationId');
      return true;
    } catch (e) {
      print('❌ Error deleting notification: $e');
      return false;
    }
  }

  /// Delete all notifications for the current user
  static Future<bool> deleteAllNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return false;
      }

      await _supabase.from('notification').delete().eq('user_id', user.id);

      print('✅ All notifications deleted');
      return true;
    } catch (e) {
      print('❌ Error deleting all notifications: $e');
      return false;
    }
  }

  /// Get count of unread notifications
  static Future<int> getUnreadNotificationsCount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 0;
      }

      final response = await _supabase
          .from('notification')
          .select('id')
          .eq('user_id', user.id)
          .eq('is_read', false);

      return response.length;
    } catch (e) {
      print('❌ Error getting unread notifications count: $e');
      return 0;
    }
  }

  /// Group notifications by date for display
  static Map<String, List<NotificationData>> groupNotificationsByDate(
    List<NotificationData> notifications,
  ) {
    final Map<String, List<NotificationData>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final notification in notifications) {
      final notificationDate = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      String dateKey;
      if (notificationDate == today) {
        dateKey = 'Today';
      } else if (notificationDate == yesterday) {
        dateKey = 'Yesterday';
      } else {
        dateKey = DateFormat('MMM dd yyyy').format(notificationDate);
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(notification);
    }

    return grouped;
  }
}

/// Data model for notifications from the database
class NotificationData {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String priority;
  final DateTime alertTime;
  final String? navigate;
  final DateTime createdAt;
  final bool isRead;

  NotificationData({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.priority,
    required this.alertTime,
    this.navigate,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      priority: map['priority']?.toString() ?? 'medium',
      alertTime: DateTime.parse(
        map['alert_time'] ?? DateTime.now().toIso8601String(),
      ),
      navigate: map['navigate']?.toString(),
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      isRead: map['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'priority': priority,
      'alert_time': alertTime.toIso8601String(),
      'navigate': navigate,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  /// Convert to NotificationItem for UI compatibility
  NotificationItem toNotificationItem() {
    return NotificationItem(
      id: id,
      title: title,
      description: description,
      icon: _getIconForPriority(priority),
      iconColor: _getColorForPriority(priority),
      timestamp: _formatTimestamp(createdAt),
      type: _getTypeForPriority(priority),
      isRead: isRead,
    );
  }

  String _getIconForPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'priority_high';
      case 'medium':
        return 'notifications';
      case 'low':
        return 'info_outline';
      default:
        return 'notifications';
    }
  }

  Color _getColorForPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFE74C3C); // Red
      case 'medium':
        return const Color(0xFF3498DB); // Blue
      case 'low':
        return const Color(0xFF95A5A6); // Gray
      default:
        return const Color(0xFF3498DB);
    }
  }

  NotificationType _getTypeForPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return NotificationType.system;
      case 'medium':
        return NotificationType.course;
      case 'low':
        return NotificationType.account;
      default:
        return NotificationType.course;
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }
}
