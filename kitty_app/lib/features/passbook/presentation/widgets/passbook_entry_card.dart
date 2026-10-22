import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/badges/kitty_status_badge.dart';
import '../../domain/entities/passbook_entry_entity.dart';

/// Luxury card component for an individual monthly installment node in Card View.
class PassbookEntryCard extends StatelessWidget {
  const PassbookEntryCard({
    super.key,
    required this.entry,
    required this.onViewReceipt,
    required this.onPayEmi,
    required this.onPerksInfo,
  });

  final PassbookEntryEntity entry;
  final ValueChanged<PassbookEntryEntity> onViewReceipt;
  final ValueChanged<PassbookEntryEntity> onPayEmi;
  final VoidCallback onPerksInfo;

  @override
  Widget build(BuildContext context) {
    final bool isPaid = entry.isPaid;
    final bool isCurrent = entry.isCurrent;
    final bool isBonus = entry.isBonus;
    final bool isPreJoin = entry.isPreJoin;
    final bool isUpcoming = entry.status == InstallmentStatusEnum.upcoming;

    // Card border & background
    final Color cardBg;
    final Border border;
    final List<BoxShadow> shadows;

    if (isCurrent) {
      cardBg = AppColors.surfaceCardBg;
      border = Border.all(
        color: AppColors.goldPrimary,
        width: 1.5,
      );
      shadows = const <BoxShadow>[
        BoxShadow(
          color: Color(0x1FC59B27),
          blurRadius: 18,
          offset: Offset(0, 4),
        ),
      ];
    } else if (isBonus) {
      cardBg = const Color(0xFFFFFDF8);
      border = Border.all(
        color: AppColors.goldBorder.withValues(alpha: 0.6),
        width: 1.5,
      );
      shadows = const <BoxShadow>[
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ];
    } else if (isPreJoin) {
      cardBg = const Color(0xFFF8FAFC);
      border = Border.all(
        color: AppColors.surfaceCardBorder,
        width: 1,
      );
      shadows = const <BoxShadow>[
        BoxShadow(
          color: Color(0x05000000),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ];
    } else {
      cardBg = AppColors.surfaceCardBg;
      border = Border.all(
        color: AppColors.surfaceCardBorder,
        width: 1,
      );
      shadows = const <BoxShadow>[
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 14,
          offset: Offset(0, 3),
        ),
      ];
    }

    // Sub-meta text
    final String subMetaText;
    if (isPaid) {
      subMetaText = DateFormatter.formatUtcToIst(entry.paidAt);
    } else if (isCurrent) {
      subMetaText = 'Due: ${DateFormatter.formatUtcToIst(entry.dueDate)}';
    } else if (isBonus) {
      subMetaText = '12th Month Completion';
    } else if (isPreJoin) {
      subMetaText = 'Prior to Enrollment';
    } else {
      subMetaText = 'Scheduled: ${DateFormatter.formatUtcToIst(entry.dueDate)}';
    }

    // Gold allocation text
    final String goldText;
    final Color goldColor;
    if (isPaid) {
      goldText = '✦ +${(entry.goldGrams ?? 0.0).toStringAsFixed(3)} g';
      goldColor = AppColors.goldPrimary;
    } else if (isCurrent) {
      goldText = 'Pending Credit';
      goldColor = AppColors.textSecondaryMuted;
    } else if (isBonus) {
      goldText = '✦ Sponsored Bonus';
      goldColor = AppColors.goldPrimary;
    } else if (isPreJoin) {
      goldText = 'Excluded from Balance';
      goldColor = AppColors.textTertiary;
    } else {
      goldText = 'At Live IBJA Rate';
      goldColor = AppColors.textSecondaryMuted;
    }

    // Footer note
    final String footerNote;
    if (isPaid) {
      footerNote = entry.paymentMethod?.name.toUpperCase() ?? 'Auto-Debit Mandate';
    } else if (isCurrent) {
      footerNote = 'Instant zero-fee gold credit';
    } else if (isBonus) {
      footerNote = entry.bonusNote ?? '100% Swastik Deposit on completion';
    } else if (isPreJoin) {
      footerNote = 'Joined Month ${entry.month} • Excluded';
    } else {
      footerNote = 'Auto-debits on ${DateFormatter.formatUtcToIst(entry.dueDate)}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space12),
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.border18,
        border: border,
        boxShadow: shadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Header: Month Title, Sub-meta, and Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    entry.label,
                    style: AppTypography.cardTitle(
                      color: isPreJoin ? AppColors.textTertiary : AppColors.textPrimaryDark,
                    ).copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subMetaText,
                    style: AppTypography.bodySmall(
                      color: AppColors.textSecondaryMuted,
                    ).copyWith(fontSize: 11.5),
                  ),
                ],
              ),
              _buildStatusBadge(entry),
            ],
          ),

          // Optional Transaction ID Row (with copy action)
          if (entry.transactionId != null && entry.transactionId!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: entry.transactionId!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Transaction ID ${entry.transactionId} copied to clipboard.'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              borderRadius: AppRadius.border6,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Txn: ${entry.transactionId}',
                      style: AppTypography.labelMeta(
                        color: AppColors.textSecondaryMuted,
                      ).copyWith(
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.copy_rounded,
                      size: 11,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.space12),

          // 2. Body: 2 Columns (EMI Amount & 24K Gold Allocation)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'EMI AMOUNT',
                    style: AppTypography.labelMeta(
                      color: AppColors.textSecondaryMuted,
                    ).copyWith(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    CurrencyFormatter.formatRupees(entry.amount),
                    style: AppTypography.cardTitle(
                      color: isPreJoin || isUpcoming
                          ? AppColors.textTertiary
                          : AppColors.textPrimaryDark,
                    ).copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '24K GOLD ALLOCATION',
                    style: AppTypography.labelMeta(
                      color: AppColors.textSecondaryMuted,
                    ).copyWith(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    goldText,
                    style: AppTypography.cardTitle(
                      color: goldColor,
                    ).copyWith(
                      fontSize: isPaid ? 16 : 13,
                      fontWeight: isPaid ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.space12),

          // Divider
          Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
          ),

          const SizedBox(height: AppSpacing.space10),

          // 3. Footer: Note on left, Action Button on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  footerNote,
                  style: AppTypography.bodySmall(
                    color: AppColors.textSecondaryMuted,
                  ).copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildActionButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PassbookEntryEntity item) {
    return switch (item.status) {
      InstallmentStatusEnum.paid => const KittyStatusBadge(
          status: KittyInstallmentStatus.paid,
        ),
      InstallmentStatusEnum.current => const KittyStatusBadge(
          status: KittyInstallmentStatus.current,
          customLabel: 'DUE NOW',
        ),
      InstallmentStatusEnum.upcoming => const KittyStatusBadge(
          status: KittyInstallmentStatus.upcoming,
        ),
      InstallmentStatusEnum.bonus => const KittyStatusBadge(
          status: KittyInstallmentStatus.bonus,
          customLabel: '✦ BONUS FREE',
        ),
      InstallmentStatusEnum.preJoin => const KittyStatusBadge(
          status: KittyInstallmentStatus.preJoin,
        ),
      InstallmentStatusEnum.defaulted => const KittyStatusBadge(
          status: KittyInstallmentStatus.failed,
          customLabel: 'DEFAULTED',
        ),
      _ => KittyStatusBadge(
          status: KittyInstallmentStatus.custom,
          customLabel: item.status.name.toUpperCase(),
        ),
    };
  }

  Widget _buildActionButton(BuildContext context) {
    if (entry.isPaid) {
      return OutlinedButton.icon(
        onPressed: () => onViewReceipt(entry),
        icon: const Icon(
          Icons.description_outlined,
          size: 13,
          color: AppColors.textPrimaryDark,
        ),
        label: const Text('Receipt'),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimaryDark,
          side: const BorderSide(color: Color(0xFFD1D5DB)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.border20),
          textStyle: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }

    if (entry.isCurrent) {
      return ElevatedButton(
        onPressed: () => onPayEmi(entry),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepEmeraldBase,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.border20),
          textStyle: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text('Pay EMI (${CurrencyFormatter.formatRupees(entry.amount)}) >'),
      );
    }

    if (entry.isBonus) {
      return OutlinedButton(
        onPressed: onPerksInfo,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.statusBonusBg,
          foregroundColor: AppColors.statusBonusText,
          side: BorderSide(
            color: AppColors.goldPrimary.withValues(alpha: 0.35),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.border20),
          textStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text('Perks Info'),
      );
    }

    if (entry.isPreJoin) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: const BoxDecoration(
          color: Color(0xFFF1F5F9),
          borderRadius: AppRadius.border20,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.lock_outline, size: 11, color: AppColors.textSecondaryMuted),
            const SizedBox(width: 4),
            Text(
              'Pre-Join',
              style: AppTypography.labelMeta(
                color: AppColors.textSecondaryMuted,
              ).copyWith(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    // Upcoming
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        borderRadius: AppRadius.border20,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.schedule, size: 11, color: AppColors.textSecondaryMuted),
          const SizedBox(width: 4),
          Text(
            'Scheduled',
            style: AppTypography.labelMeta(
              color: AppColors.textSecondaryMuted,
            ).copyWith(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
