import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/notification_entity.dart';

/// Reusable luxury notification list item strictly matching Swastik Jewellers design system.
///
/// Visually distinguishes UNREAD from READ with distinct borders, subtle tints,
/// bold typography, and metallic gold unread indicator dots.
class NotificationItemTile extends StatelessWidget {
  const NotificationItemTile({
    super.key,
    required this.notification,
    required this.onTap,
    this.isDark = false,
  });

  final NotificationEntity notification;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification.isRead;
    final _TypeStyle typeStyle = _resolveTypeStyle(notification.type, isDark);

    final Color cardBg = isDark
        ? (isUnread ? const Color(0xFF0D362B) : AppColors.emeraldCard)
        : (isUnread ? const Color(0xFFFFFDF5) : Colors.white);

    final Color borderColor = isDark
        ? (isUnread
            ? AppColors.goldPrimary.withValues(alpha: 0.5)
            : AppColors.emeraldBorder)
        : (isUnread
            ? AppColors.goldBorder.withValues(alpha: 0.7)
            : AppColors.surfaceCardBorder);

    final Color titleColor = isDark
        ? AppColors.textPrimaryLight
        : (isUnread ? const Color(0xFF0F172A) : const Color(0xFF334155));

    final Color messageColor = isDark
        ? (isUnread ? AppColors.textPrimaryLightOff : AppColors.emeraldTextSubtle)
        : (isUnread ? const Color(0xFF475569) : AppColors.textSecondaryMuted);

    final String formattedDate = _formatTimestamp(notification.createdAt);

    return Semantics(
      label: 'Notification: ${notification.title}, ${isUnread ? "Unread" : "Read"}',
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.space12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          border: Border.all(
            color: borderColor,
            width: isUnread ? 1.4 : 1.0,
          ),
          boxShadow: isUnread
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.08 : 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. Notification Category Icon Circle
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: typeStyle.backgroundColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: typeStyle.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        typeStyle.icon,
                        color: typeStyle.iconColor,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.space14),

                  // 2. Notification Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Category Label + Timestamp Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              typeStyle.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: typeStyle.labelColor,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                                    color: isDark
                                        ? (isUnread ? AppColors.goldLight : AppColors.emeraldTextSubtle)
                                        : (isUnread ? const Color(0xFF64748B) : AppColors.textTertiary),
                                  ),
                                ),
                                if (isUnread) ...<Widget>[
                                  const SizedBox(width: AppSpacing.space6),
                                  Container(
                                    key: const Key('unread_indicator_dot'),
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.goldPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.space6),

                        // Title
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                            color: titleColor,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.space4),

                        // Message Preview
                        Text(
                          notification.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: messageColor,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.space8),

                  // 3. Right Chevron Indicator
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.space16),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: isDark ? AppColors.emeraldTextSubtle : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final DateTime local = dt.toLocal();
    final DateTime now = DateTime.now();
    final Duration diff = now.difference(local);

    if (diff.inMinutes < 60 && diff.inMinutes >= 0) {
      if (diff.inMinutes <= 1) return 'Just now';
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24 && diff.inHours > 0 && local.day == now.day) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return DateFormat('d MMM').format(local);
    } else {
      return DateFormat('d MMM yyyy').format(local);
    }
  }

  _TypeStyle _resolveTypeStyle(NotificationTypeEnum type, bool isDark) {
    switch (type) {
      case NotificationTypeEnum.transaction:
        return _TypeStyle(
          icon: Icons.payments_rounded,
          iconColor: AppColors.goldPrimary,
          backgroundColor: isDark ? AppColors.goldSubtle : const Color(0xFFFFFBEB),
          borderColor: AppColors.goldBorder.withValues(alpha: 0.5),
          label: 'TRANSACTION',
          labelColor: isDark ? AppColors.goldPrimary : const Color(0xFFB45309),
        );
      case NotificationTypeEnum.scheme:
        return _TypeStyle(
          icon: Icons.workspace_premium_rounded,
          iconColor: AppColors.honeyGoldAccent,
          backgroundColor: isDark ? AppColors.goldSubtle : const Color(0xFFFFFBEB),
          borderColor: AppColors.goldBorder.withValues(alpha: 0.5),
          label: 'GOLD SCHEME',
          labelColor: AppColors.honeyGoldAccent,
        );
      case NotificationTypeEnum.offer:
        return _TypeStyle(
          icon: Icons.loyalty_rounded,
          iconColor: const Color(0xFFD97706),
          backgroundColor: isDark ? const Color(0x1FF59E0B) : const Color(0xFFFFF7ED),
          borderColor: const Color(0x47F59E0B),
          label: 'PATRON PRIVILEGE',
          labelColor: const Color(0xFFD97706),
        );
      case NotificationTypeEnum.system:
        return _TypeStyle(
          icon: Icons.verified_user_rounded,
          iconColor: const Color(0xFF059669),
          backgroundColor: isDark ? const Color(0x1F10B981) : const Color(0xFFECFDF5),
          borderColor: const Color(0x4710B981),
          label: 'SECURITY & VAULT',
          labelColor: const Color(0xFF059669),
        );
      case NotificationTypeEnum.unknown:
        return _TypeStyle(
          icon: Icons.notifications_active_rounded,
          iconColor: isDark ? AppColors.emeraldTextSubtle : const Color(0xFF64748B),
          backgroundColor: isDark ? const Color(0x1FFFFFFF) : const Color(0xFFF1F5F9),
          borderColor: isDark ? AppColors.emeraldBorder : const Color(0xFFE2E8F0),
          label: 'NOTICE',
          labelColor: isDark ? AppColors.emeraldTextSubtle : const Color(0xFF64748B),
        );
    }
  }
}

class _TypeStyle {
  const _TypeStyle({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.label,
    required this.labelColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final String label;
  final Color labelColor;
}
