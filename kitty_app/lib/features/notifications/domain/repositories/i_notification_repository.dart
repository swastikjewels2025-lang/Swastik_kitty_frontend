import '../entities/notification_entity.dart';

/// Repository contract for in-app notifications.
abstract class INotificationRepository {
  /// Fetches a list of notifications for the current authenticated user.
  Future<List<NotificationEntity>> getNotifications({int page = 1, int limit = 20});

  /// Marks a specific notification as read.
  Future<void> markAsRead(String notificationId);

  /// Marks all notifications as read.
  Future<void> markAllAsRead();

  /// Gets the count of unread notifications.
  Future<int> getUnreadCount();
}
