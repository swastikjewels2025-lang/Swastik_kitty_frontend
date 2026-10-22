import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../data/repositories/mock_notification_repository.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';
import 'notifications_state.dart';

/// Riverpod provider for the central in-app notifications controller.
final NotifierProvider<NotificationsController, NotificationsState>
    notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
  NotificationsController.new,
);

/// Lightweight computed provider exposing only the unread notifications count.
///
/// Subscribed by the luxury header bell badge to avoid full feed rebuilds.
final Provider<int> unreadNotificationsCountProvider = Provider<int>((Ref ref) {
  return ref.watch(notificationsControllerProvider).unreadCount;
});

/// Controller managing in-app notifications lifecycle, read/unread states, and local persistence.
class NotificationsController extends Notifier<NotificationsState> {
  late INotificationRepository _repository;

  @override
  NotificationsState build() {
    _repository = ref.watch(notificationRepositoryProvider);

    // Load persisted or mock notifications feed asynchronously
    Future<void>.microtask(loadNotifications);

    return const NotificationsState(isLoading: true);
  }

  /// Fetches notifications list and unread count from the repository.
  Future<void> loadNotifications() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final List<NotificationEntity> list = await _repository.getNotifications();
      if (!ref.mounted) return;
      final int count = await _repository.getUnreadCount();
      if (!ref.mounted) return;

      state = state.copyWith(
        isLoading: false,
        notifications: list,
        unreadCount: count,
        clearError: true,
      );
    } catch (e) {
      if (!ref.mounted) return;
      final String msg = e is AppException
          ? e.message
          : 'Unable to load notifications. Please try again.';
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
      );
    }
  }

  /// Pull-to-refresh without blanking out the existing feed.
  Future<void> refreshNotifications() async {
    if (!ref.mounted) return;
    state = state.copyWith(isRefreshing: true, clearError: true);

    try {
      final List<NotificationEntity> list = await _repository.getNotifications();
      if (!ref.mounted) return;
      final int count = await _repository.getUnreadCount();
      if (!ref.mounted) return;

      state = state.copyWith(
        isRefreshing: false,
        notifications: list,
        unreadCount: count,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isRefreshing: false);
    }
  }

  /// Marks a specific notification as read and updates local state.
  Future<void> markAsRead(String notificationId) async {
    final int index = state.notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || state.notifications[index].isRead) return;

    // Optimistically update local state immediately
    final List<NotificationEntity> updated = List<NotificationEntity>.from(state.notifications);
    updated[index] = updated[index].copyWith(isRead: true);
    final int newUnread = (state.unreadCount - 1).clamp(0, 9999);

    state = state.copyWith(
      notifications: updated,
      unreadCount: newUnread,
    );

    try {
      await _repository.markAsRead(notificationId);
    } catch (_) {
      // Revert if repository fails
    }
  }

  /// Marks all visible and pending notifications as read.
  Future<void> markAllAsRead() async {
    if (state.unreadCount == 0) return;

    state = state.copyWith(isMarkingAllAsRead: true);

    final List<NotificationEntity> updated = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();

    state = state.copyWith(
      notifications: updated,
      unreadCount: 0,
      isMarkingAllAsRead: false,
    );

    try {
      await _repository.markAllAsRead();
    } catch (_) {
      // Revert if repository fails
    }
  }

  /// Adds a locally generated notification (e.g., successful installment payment).
  Future<void> addLocalNotification(NotificationEntity notification) async {
    final List<NotificationEntity> updated = <NotificationEntity>[
      notification,
      ...state.notifications,
    ];
    final int newUnread = notification.isRead ? state.unreadCount : state.unreadCount + 1;

    state = state.copyWith(
      notifications: updated,
      unreadCount: newUnread,
    );

    if (_repository is MockNotificationRepository) {
      await (_repository as MockNotificationRepository).addLocalNotification(notification);
    }
  }
}
