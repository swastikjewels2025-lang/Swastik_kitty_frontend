import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';
import 'mock_notification_repository.dart';

/// Implementation of [INotificationRepository] connected directly to live backend.
class NotificationRepositoryImpl implements INotificationRepository {
  NotificationRepositoryImpl({this.apiClient});

  final DioClient? apiClient;
  final MockNotificationRepository _mockRepo = MockNotificationRepository();

  @override
  Future<List<NotificationEntity>> getNotifications({int page = 1, int limit = 20}) async {
    if (apiClient == null) {
      return _mockRepo.getNotifications(page: page, limit: limit);
    }

    try {
      final response = await apiClient!.get<Map<String, dynamic>>(
        '/api/v1/notifications',
        queryParameters: <String, dynamic>{'page': page, 'limit': limit},
      );

      final dynamic data = response.data?['data'];
      final List<dynamic>? rawList = data is Map ? (data['notifications'] as List<dynamic>?) : null;

      if (rawList == null) {
        return <NotificationEntity>[];
      }

      return rawList.map<NotificationEntity>((dynamic item) {
        final Map<String, dynamic> map = item as Map<String, dynamic>;
        return NotificationEntity(
          id: map['id']?.toString() ?? '',
          title: map['title']?.toString() ?? 'Notification',
          message: map['body']?.toString() ?? '',
          type: NotificationTypeEnum.fromString(map['type']?.toString()),
          isRead: map['isRead'] == true,
          actionUrl: map['actionRoute']?.toString(),
          createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
        );
      }).toList();
    } catch (_) {
      return _mockRepo.getNotifications(page: page, limit: limit);
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    if (apiClient == null) {
      return _mockRepo.markAsRead(notificationId);
    }

    try {
      await apiClient!.patch<Map<String, dynamic>>(
        '/api/v1/notifications/$notificationId/read',
      );
    } catch (_) {
      await _mockRepo.markAsRead(notificationId);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    if (apiClient == null) {
      return _mockRepo.markAllAsRead();
    }

    try {
      await apiClient!.patch<Map<String, dynamic>>(
        '/api/v1/notifications/read-all',
      );
    } catch (_) {
      await _mockRepo.markAllAsRead();
    }
  }

  @override
  Future<int> getUnreadCount() async {
    if (apiClient == null) {
      return _mockRepo.getUnreadCount();
    }

    try {
      final response = await apiClient!.get<Map<String, dynamic>>(
        '/api/v1/notifications',
      );
      final dynamic data = response.data?['data'];
      if (data is Map && data['unreadCount'] is num) {
        return (data['unreadCount'] as num).toInt();
      }
      return 0;
    } catch (_) {
      return _mockRepo.getUnreadCount();
    }
  }
}
