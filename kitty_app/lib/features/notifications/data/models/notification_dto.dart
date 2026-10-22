import '../../../../core/enums/app_enums.dart';

/// Data Transfer Object for notifications matching backend JSON.
class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.actionUrl,
    this.metadata,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: NotificationTypeEnum.fromString(json['type'] as String?),
      isRead: json['is_read'] as bool? ?? json['isRead'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      actionUrl: json['action_url'] as String? ??
          json['actionUrl'] as String? ??
          json['actionRoute'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final String title;
  final String message;
  final NotificationTypeEnum type;
  final bool isRead;
  final String createdAt;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toJson(),
      'is_read': isRead,
      'created_at': createdAt,
      if (actionUrl != null) 'action_url': actionUrl,
      if (metadata != null) 'metadata': metadata,
    };
  }
}
