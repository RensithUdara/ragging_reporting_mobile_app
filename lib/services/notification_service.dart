import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../constants/app_constants.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get user notifications
  Future<List<NotificationModel>> getUserNotifications({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    bool unreadOnly = false,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      var query = _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // For now, we'll handle unread filtering on the client side
      final from = (page - 1) * limit;
      final to = from + limit - 1;

      final response = await query.range(from, to);

      var notifications = (response as List)
          .map((item) => NotificationModel.fromJson(item))
          .toList();

      // Filter unread on client side if needed
      if (unreadOnly) {
        notifications = notifications.where((n) => !n.isRead).toList();
      }

      return notifications;
    } catch (e) {
      throw Exception('Failed to get notifications: ${e.toString()}');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: ${e.toString()}');
    }
  }

  // Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final response = await _supabase
          .from('notifications')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('user_id', userId)
          .eq('is_read', false);

      return response.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Create notification (for system/admin use)
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationModel(
        id: _generateNotificationId(),
        userId: userId,
        title: title,
        message: message,
        type: type,
        data: data,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _supabase.from('notifications').insert(notification.toJson());
    } catch (e) {
      throw Exception('Failed to create notification: ${e.toString()}');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: ${e.toString()}');
    }
  }

  // Delete all notifications for user
  Future<void> deleteAllNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to delete all notifications: ${e.toString()}');
    }
  }

  // Listen to real-time notification updates
  Stream<List<NotificationModel>> getNotificationStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Stream.empty();
    }

    return _supabase
        .from('notifications')
        .stream(primaryKey: const ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data
            .map((item) => NotificationModel.fromJson(item))
            .toList());
  }

  // Helper methods
  String _generateNotificationId() {
    return 'notif_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Create complaint update notification
  Future<void> createComplaintUpdateNotification({
    required String userId,
    required String complaintNumber,
    required String newStatus,
  }) async {
    await createNotification(
      userId: userId,
      title: 'Complaint Update',
      message: 'Your complaint $complaintNumber status has been updated to $newStatus.',
      type: 'complaint_update',
      data: {
        'complaint_number': complaintNumber,
        'status': newStatus,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Create system notification
  Future<void> createSystemNotification({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    await createNotification(
      userId: userId,
      title: title,
      message: message,
      type: 'system',
      data: data,
    );
  }
}
