import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../constants/app_constants.dart';

class NotificationController extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();

  // Load notifications
  Future<void> loadNotifications({
    int page = 1,
    bool refresh = false,
    bool unreadOnly = false,
  }) async {
    if (!refresh && _isLoading) return;
    
    _setLoading(true);
    if (refresh) _clearError();

    try {
      final newNotifications = await _notificationService.getUserNotifications(
        page: page,
        limit: AppConstants.defaultPageSize,
        unreadOnly: unreadOnly,
      );

      if (refresh || page == 1) {
        _notifications = newNotifications;
      } else {
        _notifications.addAll(newNotifications);
      }

      await _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      _setError(_parseError(e.toString()));
    } finally {
      _setLoading(false);
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      // Update local notification
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        await _updateUnreadCount();
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    _setLoading(true);
    _clearError();

    try {
      await _notificationService.markAllAsRead();
      
      // Update local notifications
      _notifications = _notifications.map((n) => n.copyWith(
        isRead: true,
        readAt: DateTime.now(),
      )).toList();
      
      _unreadCount = 0;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      // Remove from local list
      _notifications.removeWhere((n) => n.id == notificationId);
      await _updateUnreadCount();
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    }
  }

  // Delete all notifications
  Future<bool> deleteAllNotifications() async {
    _setLoading(true);
    _clearError();

    try {
      await _notificationService.deleteAllNotifications();
      
      _notifications.clear();
      _unreadCount = 0;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get recent notifications (last 7 days)
  List<NotificationModel> getRecentNotifications() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _notifications
        .where((n) => n.createdAt.isAfter(sevenDaysAgo))
        .toList();
  }

  // Filter notifications by read status
  List<NotificationModel> filterByReadStatus(bool isRead) {
    return _notifications.where((n) => n.isRead == isRead).toList();
  }

  // Search notifications
  List<NotificationModel> searchNotifications(String query) {
    if (query.isEmpty) return _notifications;
    
    final lowerQuery = query.toLowerCase();
    return _notifications.where((notification) {
      return notification.title.toLowerCase().contains(lowerQuery) ||
             notification.message.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get notifications summary
  Map<String, int> getNotificationsSummary() {
    return {
      'total': _notifications.length,
      'unread': _unreadCount,
      'complaint_update': getNotificationsByType('complaint_update').length,
      'system': getNotificationsByType('system').length,
      'announcement': getNotificationsByType('announcement').length,
    };
  }

  // Private methods
  Future<void> _updateUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadCount();
    } catch (e) {
      debugPrint('Failed to update unread count: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _parseError(String error) {
    if (error.contains('Network')) {
      return AppConstants.networkError;
    } else if (error.contains('Server')) {
      return AppConstants.serverError;
    } else if (error.contains('Authentication')) {
      return AppConstants.authenticationError;
    }
    
    return error.contains('Failed to') ? error : AppConstants.unknownError;
  }

  // Clear error message
  void clearError() {
    _clearError();
  }

  // Check if notification is recent (within 24 hours)
  bool isRecentNotification(NotificationModel notification) {
    final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
    return notification.createdAt.isAfter(oneDayAgo);
  }

  // Get notification icon based on type
  IconData getNotificationIcon(String type) {
    switch (type) {
      case 'complaint_update':
        return Icons.update;
      case 'system':
        return Icons.system_update;
      case 'announcement':
        return Icons.announcement;
      default:
        return Icons.notifications;
    }
  }

  // Get notification color based on type
  Color getNotificationColor(String type) {
    switch (type) {
      case 'complaint_update':
        return Colors.blue;
      case 'system':
        return Colors.orange;
      case 'announcement':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Format notification time
  String formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
