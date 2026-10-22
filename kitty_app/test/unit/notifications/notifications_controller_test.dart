import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/errors/app_exception.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/notifications/data/repositories/mock_notification_repository.dart';
import 'package:kitty_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:kitty_app/features/notifications/domain/repositories/i_notification_repository.dart';
import 'package:kitty_app/features/notifications/presentation/providers/notifications_controller.dart';

class _FailingNotificationRepository implements INotificationRepository {
  @override
  Future<List<NotificationEntity>> getNotifications({int page = 1, int limit = 20}) async {
    throw const ServerException('Server unavailable');
  }

  @override
  Future<int> getUnreadCount() async {
    throw const ServerException('Server unavailable');
  }

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> markAsRead(String notificationId) async {}
}

void main() {
  group('NotificationsController Unit Tests (Phase 14)', () {
    late MockEngineConfig mockEngine;
    late MockNotificationRepository mockRepo;

    setUp(() {
      mockEngine = MockEngineConfig(latency: MockLatency.instant);
      mockRepo = MockNotificationRepository(engineConfig: mockEngine);
    });

    ProviderContainer createContainer([INotificationRepository? customRepo]) {
      return ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(customRepo ?? mockRepo),
        ],
      );
    }

    test('1. Initial load populates notifications and unread count', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      // Trigger build and microtask
      container.read(notificationsControllerProvider);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(notificationsControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isFalse);
      expect(state.notifications.length, greaterThanOrEqualTo(5));
      expect(state.unreadCount, equals(3));
      expect(container.read(unreadNotificationsCountProvider), equals(3));
    });

    test('2. markAsRead updates specific item and decrements count', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(notificationsControllerProvider);
      await Future<void>.delayed(Duration.zero);

      final controller = container.read(notificationsControllerProvider.notifier);
      final unread = container.read(notificationsControllerProvider).notifications.firstWhere((n) => !n.isRead);

      await controller.markAsRead(unread.id);

      final updatedState = container.read(notificationsControllerProvider);
      expect(updatedState.notifications.firstWhere((n) => n.id == unread.id).isRead, isTrue);
      expect(updatedState.unreadCount, equals(2));
      expect(container.read(unreadNotificationsCountProvider), equals(2));
    });

    test('3. markAllAsRead marks all read and zeroes unread count', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(notificationsControllerProvider);
      await Future<void>.delayed(Duration.zero);

      final controller = container.read(notificationsControllerProvider.notifier);
      await controller.markAllAsRead();

      final state = container.read(notificationsControllerProvider);
      expect(state.unreadCount, equals(0));
      expect(state.notifications.every((n) => n.isRead), isTrue);
      expect(container.read(unreadNotificationsCountProvider), equals(0));
    });

    test('4. addLocalNotification appends notification and increments unread count', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(notificationsControllerProvider);
      await Future<void>.delayed(Duration.zero);

      final controller = container.read(notificationsControllerProvider.notifier);
      final NotificationEntity newNotif = NotificationEntity(
        id: 'local_test_event',
        title: 'New Voucher Received',
        message: 'Flat 50% waiver applied.',
        type: NotificationTypeEnum.offer,
        isRead: false,
        createdAt: DateTime.now().toUtc(),
      );

      await controller.addLocalNotification(newNotif);

      final state = container.read(notificationsControllerProvider);
      expect(state.notifications.first.id, equals('local_test_event'));
      expect(state.unreadCount, equals(4));
      expect(container.read(unreadNotificationsCountProvider), equals(4));
    });

    test('5. Error in repository gracefully populates errorMessage', () async {
      final container = createContainer(_FailingNotificationRepository());
      addTearDown(container.dispose);

      container.read(notificationsControllerProvider);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(notificationsControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isTrue);
      expect(state.errorMessage, contains('Server unavailable'));
    });
  });
}
