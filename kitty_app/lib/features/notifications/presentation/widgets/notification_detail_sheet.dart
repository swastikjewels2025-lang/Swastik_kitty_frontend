import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../shared/widgets/buttons/kitty_primary_button.dart';
import '../../../../shared/widgets/sheets/kitty_bottom_sheet.dart';
import '../../domain/entities/notification_entity.dart';

/// Luxury bottom sheet modal presenting the full notification details and deep link action.
abstract final class NotificationDetailSheet {
  /// Displays the notification detail bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required NotificationEntity notification,
    required bool isDark,
  }) {
    final String formattedDate = DateFormat('EEEE, d MMMM yyyy • h:mm a')
        .format(notification.createdAt.toLocal());

    return KittyBottomSheet.show<void>(
      context: context,
      isDarkSurface: isDark,
      title: 'Notification Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // 1. Category Tag + Timestamp
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.goldSubtle : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(AppRadius.radiusPill),
                  border: Border.all(
                    color: AppColors.goldBorder.withValues(alpha: 0.6),
                  ),
                ),
                child: Text(
                  _categoryName(notification.type),
                  style: const TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space8),
              Expanded(
                child: Text(
                  formattedDate,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.emeraldTextSubtle : AppColors.textSecondaryMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.space16),

          // 2. Notification Title
          Text(
            notification.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryLight : const Color(0xFF0F172A),
              height: 1.35,
            ),
          ),

          const SizedBox(height: AppSpacing.space12),

          // 3. Notification Message Body
          Container(
            padding: const EdgeInsets.all(AppSpacing.space16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF07241D) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(AppRadius.radius12),
              border: Border.all(
                color: isDark ? AppColors.emeraldBorder : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              notification.message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.textPrimaryLightOff : const Color(0xFF334155),
                height: 1.55,
              ),
            ),
          ),

          // 4. Optional Metadata Cards
          if (notification.metadata != null && notification.metadata!.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.space16),
            Container(
              padding: const EdgeInsets.all(AppSpacing.space14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.emeraldCard : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.radius10),
                border: Border.all(
                  color: isDark ? AppColors.emeraldBorder : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: notification.metadata!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          _formatMetadataKey(entry.key),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.emeraldTextSubtle : AppColors.textSecondaryMuted,
                          ),
                        ),
                        Text(
                          '${entry.value}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.goldLight : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.space24),

          // 5. Action Deep Link Button if Available
          if (notification.actionUrl != null && notification.actionUrl!.trim().isNotEmpty) ...<Widget>[
            KittyPrimaryButton(
              label: _actionLabel(notification.actionUrl!),
              onPressed: () {
                Navigator.of(context).pop();
                context.push(notification.actionUrl!);
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.space10),
          ],

          // 6. Dismiss Button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Dismiss',
              style: TextStyle(
                color: isDark ? AppColors.emeraldTextSubtle : AppColors.textSecondaryMuted,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _categoryName(NotificationTypeEnum type) {
    switch (type) {
      case NotificationTypeEnum.transaction:
        return 'TRANSACTION ALERT';
      case NotificationTypeEnum.scheme:
        return 'SCHEME REMINDER';
      case NotificationTypeEnum.offer:
        return 'EXCLUSIVE OFFER';
      case NotificationTypeEnum.system:
        return 'SYSTEM & VAULT';
      case NotificationTypeEnum.unknown:
        return 'GENERAL ANNOUNCEMENT';
    }
  }

  static String _actionLabel(String route) {
    if (route.contains('passbook')) return 'View in Gold Passbook';
    if (route.contains('checkout') || route.contains('payment')) return 'Pay Installment Now';
    if (route.contains('offers')) return 'Explore Privileges';
    if (route.contains('kyc')) return 'Complete Verification';
    if (route.contains('settings')) return 'Open Settings';
    if (route.contains('dashboard')) return 'Go to Dashboard';
    return 'View Details';
  }

  static String _formatMetadataKey(String key) {
    switch (key) {
      case 'transactionId':
        return 'Transaction ID';
      case 'month':
        return 'Month Cycle';
      case 'amount':
        return 'Amount';
      case 'goldGrams':
        return 'Gold Weight';
      default:
        return key;
    }
  }
}
