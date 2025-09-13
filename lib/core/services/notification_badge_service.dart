import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to track unread notification count and notify listeners
class NotificationBadgeService extends ChangeNotifier {
  static final NotificationBadgeService _instance = NotificationBadgeService._internal();
  factory NotificationBadgeService() => _instance;
  NotificationBadgeService._internal();

  static final SupabaseClient _supabase = Supabase.instance.client;
  
  int _unreadCount = 0;
  StreamSubscription? _subscription;
  Timer? _refreshTimer;

  /// Get current unread count
  int get unreadCount => _unreadCount;

  /// Check if there are unread notifications
  bool get hasUnreadNotifications => _unreadCount > 0;

  /// Initialize the service and start listening for changes
  Future<void> initialize() async {
    try {
      print('🔔 Initializing notification badge service...');
      
      // Load initial unread count
      await _loadUnreadCount();
      
      // Start listening for real-time changes
      _startRealtimeListener();
      
      // Set up periodic refresh (every 30 seconds) as backup
      _startPeriodicRefresh();
      
      print('✅ Notification badge service initialized with $_unreadCount unread notifications');
    } catch (e) {
      print('❌ Error initializing notification badge service: $e');
    }
  }

  /// Load unread notification count from database
  Future<void> _loadUnreadCount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _unreadCount = 0;
        notifyListeners();
        return;
      }

      final response = await _supabase
          .from('notification')
          .select('id')
          .eq('user_id', user.id)
          .eq('is_read', false);

      _unreadCount = response.length;
      notifyListeners();
      
      print('📊 Loaded $_unreadCount unread notifications');
    } catch (e) {
      print('❌ Error loading unread count: $e');
      _unreadCount = 0;
      notifyListeners();
    }
  }

  /// Start real-time listener for notification changes
  void _startRealtimeListener() {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      _subscription = _supabase
          .from('notification')
          .stream(primaryKey: ['id'])
          .listen((data) {
        // Filter for current user's notifications
        final userNotifications = data
            .where((notification) => notification['user_id'] == user.id)
            .toList();

        // Count unread notifications
        final unreadCount = userNotifications
            .where((notification) => notification['is_read'] == false)
            .length;

        if (unreadCount != _unreadCount) {
          _unreadCount = unreadCount;
          notifyListeners();
          print('🔔 Unread count updated: $_unreadCount');
        }
      });
    } catch (e) {
      print('❌ Error starting real-time listener: $e');
    }
  }

  /// Start periodic refresh as backup
  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadUnreadCount();
    });
  }

  /// Manually refresh unread count
  Future<void> refresh() async {
    await _loadUnreadCount();
  }

  /// Mark a notification as read and update count
  Future<void> markAsRead(String notificationId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('notification')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', user.id);

      // Refresh count
      await _loadUnreadCount();
      
      print('✅ Notification $notificationId marked as read');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('notification')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);

      // Refresh count
      await _loadUnreadCount();
      
      print('✅ All notifications marked as read');
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
    }
  }

  /// Increment unread count (when new notification is added)
  void incrementUnreadCount() {
    _unreadCount++;
    notifyListeners();
    print('🔔 Unread count incremented to $_unreadCount');
  }

  /// Decrement unread count (when notification is read)
  void decrementUnreadCount() {
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
      print('🔔 Unread count decremented to $_unreadCount');
    }
  }

  /// Reset unread count to zero
  void resetUnreadCount() {
    _unreadCount = 0;
    notifyListeners();
    print('🔔 Unread count reset to 0');
  }

  /// Dispose resources
  @override
  void dispose() {
    _subscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Clean up when user logs out
  void cleanup() {
    _subscription?.cancel();
    _refreshTimer?.cancel();
    _unreadCount = 0;
    notifyListeners();
    print('🧹 Notification badge service cleaned up');
  }
}
