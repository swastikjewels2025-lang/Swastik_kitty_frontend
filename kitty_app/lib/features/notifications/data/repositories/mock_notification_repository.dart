import 'dart:convert';
import '../../../../core/config/app_constants.dart';
import '../../../../core/mock/mock_engine_config.dart';
import '../../../../core/mock/mock_fixtures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../mappers/notification_mapper.dart';
import '../models/notification_dto.dart';

/// Mock implementation of INotificationRepository with in-memory state and local persistence.
class MockNotificationRepository implements INotificationRepository {
  MockNotificationRepository({
    MockEngineConfig? engineConfig,
    this.storageService,
  }) : _engineConfig = engineConfig ?? MockEngineConfig();

  final MockEngineConfig _engineConfig;
  final SecureStorageService? storageService;

  List<NotificationEntity>? _inMemoryNotifications;
  final Set<String> _persistedReadIds = <String>{};
  final List<NotificationEntity> _locallyAddedNotifications = <NotificationEntity>[];
  bool _isRestoredFromStorage = false;

  Future<void> _restoreStateFromStorage() async {
    if (_isRestoredFromStorage) return;
    _isRestoredFromStorage = true;

    final storage = storageService;
    if (storage == null) return;

    try {
      // 1. Restore read IDs
      final String? readIdsRaw = await storage.read(
        key: AppConstants.notificationsReadIdsKey,
      );
      if (readIdsRaw != null && readIdsRaw.trim().isNotEmpty) {
        final dynamic decoded = jsonDecode(readIdsRaw);
        if (decoded is List) {
          _persistedReadIds.addAll(decoded.map((e) => e.toString()));
        }
      }

      // 2. Restore locally generated notifications
      final String? localItemsRaw = await storage.read(
        key: AppConstants.notificationsLocalItemsKey,
      );
      if (localItemsRaw != null && localItemsRaw.trim().isNotEmpty) {
        final dynamic decoded = jsonDecode(localItemsRaw);
        if (decoded is List) {
          _locallyAddedNotifications.clear();
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              _locallyAddedNotifications.add(
                NotificationMapper.toEntity(NotificationDto.fromJson(item)),
              );
            }
          }
        }
      }
    } catch (_) {
      // Fallback gracefully on storage corruption or decode error
    }
  }

  Future<void> _persistReadIds() async {
    final storage = storageService;
    if (storage == null) return;
    try {
      await storage.write(
        key: AppConstants.notificationsReadIdsKey,
        value: jsonEncode(_persistedReadIds.toList()),
      );
    } catch (_) {}
  }

  Future<void> _persistLocalNotifications() async {
    final storage = storageService;
    if (storage == null) return;
    try {
      final List<Map<String, dynamic>> serialized = _locallyAddedNotifications
          .map((n) => NotificationMapper.toDto(n).toJson())
          .toList();
      await storage.write(
        key: AppConstants.notificationsLocalItemsKey,
        value: jsonEncode(serialized),
      );
    } catch (_) {}
  }

  List<NotificationEntity> _getFixtureNotifications() {
    final list = MockFixtures.notificationsListJson['data']?['notifications'] as List<dynamic>? ?? [];
    return list
        .map((json) => NotificationMapper.toEntity(
              NotificationDto.fromJson(json as Map<String, dynamic>),
            ))
        .toList();
  }

  Future<List<NotificationEntity>> _getMergedNotifications() async {
    await _restoreStateFromStorage();
    if (_inMemoryNotifications == null) {
      final base = _getFixtureNotifications();
      _inMemoryNotifications = <NotificationEntity>[
        ..._locallyAddedNotifications,
        ...base,
      ];
    }
    return _inMemoryNotifications!.map((n) {
      if (_persistedReadIds.contains(n.id)) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
  }

  @override
  Future<List<NotificationEntity>> getNotifications({int page = 1, int limit = 20}) async {
    await _engineConfig.simulateResponse();
    final all = await _getMergedNotifications();
    final start = (page - 1) * limit;
    if (start >= all.length) return [];
    final end = (start + limit).clamp(0, all.length);
    return List.unmodifiable(all.sublist(start, end));
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _engineConfig.simulateResponse();
    await _restoreStateFromStorage();
    _persistedReadIds.add(notificationId);
    if (_inMemoryNotifications != null) {
      final index = _inMemoryNotifications!.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _inMemoryNotifications![index] = _inMemoryNotifications![index].copyWith(isRead: true);
      }
    }
    await _persistReadIds();
  }

  @override
  Future<void> markAllAsRead() async {
    await _engineConfig.simulateResponse();
    await _restoreStateFromStorage();
    final all = await _getMergedNotifications();
    for (final n in all) {
      _persistedReadIds.add(n.id);
    }
    if (_inMemoryNotifications != null) {
      for (int i = 0; i < _inMemoryNotifications!.length; i++) {
        _inMemoryNotifications![i] = _inMemoryNotifications![i].copyWith(isRead: true);
      }
    }
    await _persistReadIds();
  }

  @override
  Future<int> getUnreadCount() async {
    await _engineConfig.simulateResponse();
    final all = await _getMergedNotifications();
    return all.where((n) => !n.isRead).length;
  }

  /// Adds a locally created notification entry and persists it.
  Future<void> addLocalNotification(NotificationEntity notification) async {
    await _restoreStateFromStorage();
    _locallyAddedNotifications.insert(0, notification);
    if (_inMemoryNotifications != null) {
      _inMemoryNotifications!.insert(0, notification);
    }
    await _persistLocalNotifications();
  }
}
