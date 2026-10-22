import '../../../../core/enums/app_enums.dart';

/// Domain entity representing an in-app or push notification.
class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.actionUrl,
    this.metadata,
  });

  final String id;
  final String title;
  final String message;
  final NotificationTypeEnum type;
  final bool isRead;
  final DateTime createdAt;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    NotificationTypeEnum? type,
    bool? isRead,
    DateTime? createdAt,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}
