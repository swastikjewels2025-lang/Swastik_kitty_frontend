import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/storage/secure_storage_service.dart';
import 'package:kitty_app/features/notifications/data/repositories/mock_notification_repository.dart';
import 'package:kitty_app/features/notifications/domain/entities/notification_entity.dart';

class _FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _store = <String, String>{};

  @override
  Future<void> write({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _store[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _store.clear();
  }
}

void main() {
  group('MockNotificationRepository Unit Tests (Phase 14)', () {
    late MockEngineConfig mockEngine;
    late _FakeSecureStorageService fakeStorage;
    late MockNotificationRepository repository;

    setUp(() {
      mockEngine = MockEngineConfig(latency: MockLatency.instant);
      fakeStorage = _FakeSecureStorageService();
      repository = MockNotificationRepository(
        engineConfig: mockEngine,
        storageService: fakeStorage,
      );
    });

    test('1. Loads initial notifications from fixtures with variety of types', () async {
      final List<NotificationEntity> list = await repository.getNotifications();

      expect(list.length, greaterThanOrEqualTo(5));
      expect(list.any((n) => n.type == NotificationTypeEnum.transaction), isTrue);
      expect(list.any((n) => n.type == NotificationTypeEnum.scheme), isTrue);
      expect(list.any((n) => n.type == NotificationTypeEnum.offer), isTrue);
      expect(list.any((n) => n.type == NotificationTypeEnum.system), isTrue);
      expect(list.any((n) => n.type == NotificationTypeEnum.unknown), isTrue);

      final int unread = await repository.getUnreadCount();
      expect(unread, equals(3));
    });

    test('2. markAsRead updates in-memory status and persists across restart', () async {
      final List<NotificationEntity> initial = await repository.getNotifications();
      final NotificationEntity unreadItem = initial.firstWhere((n) => !n.isRead);

      await repository.markAsRead(unreadItem.id);

      final List<NotificationEntity> updated = await repository.getNotifications();
      expect(updated.firstWhere((n) => n.id == unreadItem.id).isRead, isTrue);

      // Verify persistence by creating a fresh repository instance with the same storage
      final MockNotificationRepository reloadedRepo = MockNotificationRepository(
        engineConfig: mockEngine,
        storageService: fakeStorage,
      );

      final List<NotificationEntity> reloaded = await reloadedRepo.getNotifications();
      expect(reloaded.firstWhere((n) => n.id == unreadItem.id).isRead, isTrue);
    });

    test('3. markAllAsRead sets unread count to 0 and persists state', () async {
      final int initialUnread = await repository.getUnreadCount();
      expect(initialUnread, greaterThan(0));

      await repository.markAllAsRead();

      final int afterUnread = await repository.getUnreadCount();
      expect(afterUnread, equals(0));

      // Simulate app restart
      final MockNotificationRepository restartedRepo = MockNotificationRepository(
        engineConfig: mockEngine,
        storageService: fakeStorage,
      );

      final int restartedUnread = await restartedRepo.getUnreadCount();
      expect(restartedUnread, equals(0));
    });

    test('4. addLocalNotification prepends new notification and persists it', () async {
      final NotificationEntity localNotif = NotificationEntity(
        id: 'notif_test_event_001',
        title: 'Local Installment Paid',
        message: '₹5,000 recorded via UPI AutoPay.',
        type: NotificationTypeEnum.transaction,
        isRead: false,
        createdAt: DateTime.now().toUtc(),
        actionUrl: '/passbook',
      );

      await repository.addLocalNotification(localNotif);

      final List<NotificationEntity> list = await repository.getNotifications();
      expect(list.first.id, equals('notif_test_event_001'));
      expect(list.first.title, equals('Local Installment Paid'));

      // Check restart persistence
      final MockNotificationRepository reloadedRepo = MockNotificationRepository(
        engineConfig: mockEngine,
        storageService: fakeStorage,
      );

      final List<NotificationEntity> reloadedList = await reloadedRepo.getNotifications();
      expect(reloadedList.first.id, equals('notif_test_event_001'));
    });

    test('5. Safe fallback for unknown notification type does not crash', () async {
      final NotificationTypeEnum unknownType =
          NotificationTypeEnum.fromString('NONEXISTENT_TYPE_RANDOM');
      expect(unknownType, equals(NotificationTypeEnum.unknown));

      final NotificationTypeEnum paymentType =
          NotificationTypeEnum.fromString('PAYMENT');
      expect(paymentType, equals(NotificationTypeEnum.transaction));
    });
  });
}
