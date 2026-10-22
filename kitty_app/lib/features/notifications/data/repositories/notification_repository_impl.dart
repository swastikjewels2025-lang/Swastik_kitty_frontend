import '../../../../core/network/dio_client.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';
import 'mock_notification_repository.dart';

/// Implementation of [INotificationRepository].
///
/// NOTE: The Swastik Kitty backend does not maintain an in-app notifications database;
/// notifications are dispatched externally via MSG91 / WhatsApp OTP services.
/// The application intentionally uses [MockNotificationRepository] via [notificationRepositoryProvider].
class NotificationRepositoryImpl implements INotificationRepository {
  NotificationRepositoryImpl({this.apiClient});

  final DioClient? apiClient;
  final MockNotificationRepository _mockRepo = MockNotificationRepository();

  @override
  Future<List<NotificationEntity>> getNotifications({int page = 1, int limit = 20}) {
    return _mockRepo.getNotifications(page: page, limit: limit);
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return _mockRepo.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() {
    return _mockRepo.markAllAsRead();
  }

  @override
  Future<int> getUnreadCount() {
    return _mockRepo.getUnreadCount();
  }
}
