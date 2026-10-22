import '../../domain/entities/notification_entity.dart';

/// Immutable presentation state for the In-App Notifications Center.
class NotificationsState {
  const NotificationsState({
    this.notifications = const <NotificationEntity>[],
    this.isLoading = false,
    this.isRefreshing = false,
    this.isMarkingAllAsRead = false,
    this.errorMessage,
    this.unreadCount = 0,
  });

  final List<NotificationEntity> notifications;
  final bool isLoading;
  final bool isRefreshing;
  final bool isMarkingAllAsRead;
  final String? errorMessage;
  final int unreadCount;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get isEmpty => !isLoading && notifications.isEmpty;

  NotificationsState copyWith({
    List<NotificationEntity>? notifications,
    bool? isLoading,
    bool? isRefreshing,
    bool? isMarkingAllAsRead,
    String? errorMessage,
    bool clearError = false,
    int? unreadCount,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isMarkingAllAsRead: isMarkingAllAsRead ?? this.isMarkingAllAsRead,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
