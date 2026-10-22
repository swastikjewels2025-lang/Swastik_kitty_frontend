import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Semantic status types for Kitty App badges and chips.
enum KittyInstallmentStatus {
  paid,
  current,
  upcoming,
  bonus,
  preJoin,
  active,
  due,
  pending,
  available,
  selected,
  booked,
  reserved,
  completed,
  failed,
  custom,
}

/// Standardized status badge / pill component for Kitty App.
///
/// Implements the approved badge styles for passbook installments,
/// active kitty indicators, slot matrix numbers, and lifecycle tags.
class KittyStatusBadge extends StatelessWidget {
  const KittyStatusBadge({
    super.key,
    this.status = KittyInstallmentStatus.paid,
    this.customLabel,
    this.customBgColor,
    this.customTextColor,
    this.customBorderColor,
    this.customIcon,
    this.showDot = true,
    this.fontSize = 11.0,
    this.padding,
    this.borderRadius,
  });

  /// Preset installment or lifecycle status.
  final KittyInstallmentStatus status;

  /// Custom text label (overrides default status label if provided).
  final String? customLabel;

  /// Custom background color override.
  final Color? customBgColor;

  /// Custom text color override.
  final Color? customTextColor;

  /// Custom border color override.
  final Color? customBorderColor;

  /// Custom leading icon.
  final Widget? customIcon;

  /// Whether to render a leading status dot indicator.
  final bool showDot;

  /// Font size (default: 11px).
  final double fontSize;

  /// Custom inner padding.
  final EdgeInsetsGeometry? padding;

  /// Custom border radius.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final Color borderColor;
    final Color dotColor;
    final String defaultLabel;
    final Widget? icon = customIcon;

    switch (status) {
      case KittyInstallmentStatus.paid:
        bgColor = AppColors.statusSuccessBg;
        textColor = AppColors.statusSuccessText;
        borderColor = AppColors.statusSuccessBorder;
        dotColor = AppColors.statusSuccessText;
        defaultLabel = 'PAID';
        break;
      case KittyInstallmentStatus.current:
        bgColor = AppColors.statusWarningBg;
        textColor = AppColors.statusWarningText;
        borderColor = AppColors.statusWarningBorder;
        dotColor = AppColors.statusWarningText;
        defaultLabel = 'CURRENT';
        break;
      case KittyInstallmentStatus.upcoming:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        borderColor = const Color(0xFFE5E7EB);
        dotColor = const Color(0xFF9CA3AF);
        defaultLabel = 'UPCOMING';
        break;
      case KittyInstallmentStatus.bonus:
        bgColor = AppColors.statusBonusBg;
        textColor = AppColors.statusBonusText;
        borderColor = const Color(0x66CA8A04);
        dotColor = AppColors.statusBonusText;
        defaultLabel = '100% BONUS';
        break;
      case KittyInstallmentStatus.preJoin:
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF2563EB);
        borderColor = const Color(0xFFBFDBFE);
        dotColor = const Color(0xFF3B82F6);
        defaultLabel = 'READY TO START';
        break;
      case KittyInstallmentStatus.active:
        bgColor = AppColors.statusSuccessBg;
        textColor = AppColors.statusSuccessText;
        borderColor = AppColors.statusSuccessBorder;
        dotColor = const Color(0xFF10B981);
        defaultLabel = 'ACTIVE KITTY';
        break;
      case KittyInstallmentStatus.due:
        bgColor = AppColors.statusWarningBg;
        textColor = AppColors.statusWarningTextAlt;
        borderColor = AppColors.statusWarningBorder;
        dotColor = AppColors.statusWarningTextAlt;
        defaultLabel = 'PAYMENT DUE';
        break;
      case KittyInstallmentStatus.pending:
        bgColor = AppColors.statusWarningBg;
        textColor = AppColors.statusWarningText;
        borderColor = AppColors.statusWarningBorder;
        dotColor = AppColors.statusWarningText;
        defaultLabel = 'PENDING';
        break;
      case KittyInstallmentStatus.available:
        bgColor = AppColors.statusSuccessBg;
        textColor = AppColors.statusSuccessText;
        borderColor = AppColors.statusSuccessBorder;
        dotColor = AppColors.statusSuccessText;
        defaultLabel = 'AVAILABLE';
        break;
      case KittyInstallmentStatus.selected:
        bgColor = AppColors.goldPrimary;
        textColor = AppColors.primaryEmerald;
        borderColor = AppColors.goldPrimary;
        dotColor = AppColors.primaryEmerald;
        defaultLabel = 'SELECTED';
        break;
      case KittyInstallmentStatus.booked:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF94A3B8);
        borderColor = const Color(0xFFE2E8F0);
        dotColor = const Color(0xFFCBD5E1);
        defaultLabel = 'BOOKED';
        break;
      case KittyInstallmentStatus.reserved:
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF2563EB);
        borderColor = const Color(0xFFBFDBFE);
        dotColor = const Color(0xFF3B82F6);
        defaultLabel = 'RESERVED';
        break;
      case KittyInstallmentStatus.completed:
        bgColor = AppColors.statusSuccessBg;
        textColor = AppColors.statusSuccessText;
        borderColor = AppColors.statusSuccessBorder;
        dotColor = AppColors.statusSuccessText;
        defaultLabel = 'COMPLETED';
        break;
      case KittyInstallmentStatus.failed:
        bgColor = AppColors.statusErrorBg;
        textColor = AppColors.statusErrorText;
        borderColor = AppColors.statusErrorBorder;
        dotColor = AppColors.statusErrorText;
        defaultLabel = 'FAILED';
        break;
      case KittyInstallmentStatus.custom:
        bgColor = customBgColor ?? AppColors.surfaceCardBg;
        textColor = customTextColor ?? AppColors.textPrimaryDark;
        borderColor = customBorderColor ?? AppColors.surfaceCardBorder;
        dotColor = textColor;
        defaultLabel = customLabel ?? '';
        break;
    }

    final Color effectiveBg = customBgColor ?? bgColor;
    final Color effectiveText = customTextColor ?? textColor;
    final Color effectiveBorder = customBorderColor ?? borderColor;
    final String label = customLabel ?? defaultLabel;

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.space8,
            vertical: 3.5,
          ),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.radiusPill),
        border: Border.all(
          color: effectiveBorder,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            icon,
            const SizedBox(width: AppSpacing.space4),
          ] else if (showDot) ...<Widget>[
            Container(
              width: 5.5,
              height: 5.5,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.space6),
          ],
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: effectiveText,
            ),
          ),
        ],
      ),
    );
  }
}
