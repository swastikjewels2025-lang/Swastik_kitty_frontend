import '../../domain/entities/notification_entity.dart';
import '../models/notification_dto.dart';

/// Mapper between NotificationDto and NotificationEntity.
class NotificationMapper {
  static NotificationEntity toEntity(NotificationDto dto) {
    return NotificationEntity(
      id: dto.id,
      title: dto.title,
      message: dto.message,
      type: dto.type,
      isRead: dto.isRead,
      createdAt: DateTime.tryParse(dto.createdAt)?.toUtc() ?? DateTime.now().toUtc(),
      actionUrl: dto.actionUrl,
      metadata: dto.metadata,
    );
  }

  static NotificationDto toDto(NotificationEntity entity) {
    return NotificationDto(
      id: entity.id,
      title: entity.title,
      message: entity.message,
      type: entity.type,
      isRead: entity.isRead,
      createdAt: entity.createdAt.toIso8601String(),
      actionUrl: entity.actionUrl,
      metadata: entity.metadata,
    );
  }
}
