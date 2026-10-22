import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/badges/kitty_status_badge.dart';
import '../../domain/entities/passbook_entry_entity.dart';

/// Clean luxury mobile-scrollable table view rendering all 12 monthly installment nodes.
class PassbookTimelineTable extends StatelessWidget {
  const PassbookTimelineTable({
    super.key,
    required this.entries,
    required this.onViewReceipt,
    required this.onPayEmi,
    required this.onPerksInfo,
  });

  final List<PassbookEntryEntity> entries;
  final ValueChanged<PassbookEntryEntity> onViewReceipt;
  final ValueChanged<PassbookEntryEntity> onPayEmi;
  final VoidCallback onPerksInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceCardBg,
        borderRadius: AppRadius.border18,
        border: Border.all(
          color: AppColors.surfaceCardBorder,
          width: 1,
        ),
        boxShadow: AppShadows.cardSubtle,
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Table Header Row
              _buildTableHeader(),

              // Table Body Rows
              ...entries.asMap().entries.map((MapEntry<int, PassbookEntryEntity> mapEntry) {
                final bool isLast = mapEntry.key == entries.length - 1;
                return _buildTableRow(context, mapEntry.value, isLast);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceCardBorder, width: 1),
        ),
      ),
      child: const Row(
        children: <Widget>[
          SizedBox(
            width: 36,
            child: _HeaderCell('#'),
          ),
          SizedBox(
            width: 140,
            child: _HeaderCell('INSTALLMENT'),
          ),
          SizedBox(
            width: 90,
            child: _HeaderCell('AMOUNT'),
          ),
          SizedBox(
            width: 110,
            child: _HeaderCell('DATE'),
          ),
          SizedBox(
            width: 110,
            child: _HeaderCell('24K GOLD'),
          ),
          SizedBox(
            width: 130,
            child: _HeaderCell('MODE'),
          ),
          SizedBox(
            width: 125,
            child: _HeaderCell('STATUS'),
          ),
          SizedBox(
            width: 150,
            child: _HeaderCell('ACTION', textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, PassbookEntryEntity item, bool isLast) {
    final bool isPaid = item.isPaid;
    final bool isCurrent = item.isCurrent;
    final bool isBonus = item.isBonus;
    final bool isPreJoin = item.isPreJoin;

    // Row Background
    final Color rowBg;
    if (isCurrent) {
      rowBg = const Color(0xFFFFFBEB); // Amber tint
    } else if (isBonus) {
      rowBg = const Color(0xFFFEFCE8); // Yellow gold tint
    } else if (isPreJoin) {
      rowBg = const Color(0xFFF8FAFC); // Muted gray
    } else {
      rowBg = Colors.white;
    }

    // Date Cell Content
    final Widget dateWidget;
    if (isPaid) {
      dateWidget = Text(
        DateFormatter.formatUtcToIst(item.paidAt),
        style: AppTypography.bodySmall(
          color: AppColors.textSecondaryMuted,
        ).copyWith(fontSize: 11.5),
      );
    } else if (isCurrent) {
      dateWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            DateFormatter.formatUtcToIst(item.dueDate),
            style: AppTypography.bodySmall(
              color: AppColors.textSecondaryMuted,
            ).copyWith(fontSize: 11.5),
          ),
          Text(
            '5d left',
            style: AppTypography.labelMeta(
              color: AppColors.statusWarningTextAlt,
            ).copyWith(fontSize: 10.5, fontWeight: FontWeight.w700),
          ),
        ],
      );
    } else if (isBonus) {
      dateWidget = Text(
        '15 Dec 2026',
        style: AppTypography.bodySmall(
          color: AppColors.textSecondaryMuted,
        ).copyWith(fontSize: 11.5),
      );
    } else if (isPreJoin) {
      dateWidget = Text(
        '—',
        style: AppTypography.bodySmall(
          color: AppColors.textTertiary,
        ).copyWith(fontSize: 11.5),
      );
    } else {
      dateWidget = Text(
        DateFormatter.formatUtcToIst(item.dueDate),
        style: AppTypography.bodySmall(
          color: AppColors.textSecondaryMuted,
        ).copyWith(fontSize: 11.5),
      );
    }

    // Gold Cell Content
    final Widget goldWidget;
    if (isPaid) {
      goldWidget = Text(
        '✦ +${(item.goldGrams ?? 0.0).toStringAsFixed(3)} g',
        style: AppTypography.labelMeta(
          color: AppColors.goldPrimary,
        ).copyWith(fontSize: 11.5, fontWeight: FontWeight.w700),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else if (isCurrent) {
      goldWidget = Text(
        'Pending Credit',
        style: AppTypography.bodySmall(
          color: AppColors.textSecondaryMuted,
        ).copyWith(fontSize: 11, fontWeight: FontWeight.w600),
      );
    } else if (isBonus) {
      goldWidget = Text(
        '✦ Sponsored',
        style: AppTypography.labelMeta(
          color: AppColors.goldPrimary,
        ).copyWith(fontSize: 11, fontWeight: FontWeight.w700),
      );
    } else if (isPreJoin) {
      goldWidget = Text(
        'Excluded',
        style: AppTypography.bodySmall(
          color: AppColors.textTertiary,
        ).copyWith(fontSize: 11),
      );
    } else {
      goldWidget = Text(
        'At Live IBJA',
        style: AppTypography.bodySmall(
          color: AppColors.textSecondaryMuted,
        ).copyWith(fontSize: 11),
      );
    }

    // Mode Text
    final String modeText;
    if (isPaid) {
      modeText = item.paymentMethod?.name.toUpperCase() ?? 'Mandate';
    } else if (isCurrent) {
      modeText = 'Instant UPI / Card';
    } else if (isBonus) {
      modeText = '100% Swastik';
    } else if (isPreJoin) {
      modeText = 'Joined M${item.month}';
    } else {
      modeText = 'Auto-Debit';
    }

    // Status Pill
    final Widget statusWidget = switch (item.status) {
      InstallmentStatusEnum.paid => const KittyStatusBadge(
          status: KittyInstallmentStatus.paid,
          fontSize: 10,
        ),
      InstallmentStatusEnum.current => const KittyStatusBadge(
          status: KittyInstallmentStatus.current,
          customLabel: 'DUE NOW',
          fontSize: 10,
        ),
      InstallmentStatusEnum.upcoming => const KittyStatusBadge(
          status: KittyInstallmentStatus.upcoming,
          fontSize: 10,
        ),
      InstallmentStatusEnum.bonus => const KittyStatusBadge(
          status: KittyInstallmentStatus.bonus,
          customLabel: '✦ BONUS',
          fontSize: 10,
        ),
      InstallmentStatusEnum.preJoin => const KittyStatusBadge(
          status: KittyInstallmentStatus.preJoin,
          fontSize: 10,
        ),
      InstallmentStatusEnum.defaulted => const KittyStatusBadge(
          status: KittyInstallmentStatus.failed,
          customLabel: 'DEFAULTED',
          fontSize: 10,
        ),
      _ => KittyStatusBadge(
          status: KittyInstallmentStatus.custom,
          customLabel: item.status.name.toUpperCase(),
          fontSize: 10,
        ),
    };

    // Action Cell
    final Widget actionWidget;
    if (isPaid) {
      actionWidget = Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton.icon(
          onPressed: () => onViewReceipt(item),
          icon: const Icon(Icons.description_outlined, size: 12, color: AppColors.textPrimaryDark),
          label: const Text('Receipt'),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimaryDark,
            side: const BorderSide(color: Color(0xFFD1D5DB)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.border20),
            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );
    } else if (isCurrent) {
      actionWidget = Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () => onPayEmi(item),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deepEmeraldBase,
            foregroundColor: Colors.white,
            elevation: 1,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.border20),
            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text('Pay (${CurrencyFormatter.formatRupees(item.amount)})'),
        ),
      );
    } else if (isBonus) {
      actionWidget = Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton(
          onPressed: onPerksInfo,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.statusBonusBg,
            foregroundColor: AppColors.statusBonusText,
            side: BorderSide(color: AppColors.goldPrimary.withValues(alpha: 0.35)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.border20),
            textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Perks Info'),
        ),
      );
    } else if (isPreJoin) {
      actionWidget = Align(
        alignment: Alignment.centerRight,
        child: Text(
          'Joined Month ${item.month}',
          style: AppTypography.labelMeta(
            color: AppColors.textSecondaryMuted,
          ).copyWith(fontSize: 10.5),
        ),
      );
    } else {
      actionWidget = Align(
        alignment: Alignment.centerRight,
        child: Text(
          'Auto-debits',
          style: AppTypography.labelMeta(
            color: AppColors.textSecondaryMuted,
          ).copyWith(fontSize: 10.5),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rowBg,
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : const Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          // #
          SizedBox(
            width: 36,
            child: Text(
              '${item.month}',
              style: AppTypography.labelMeta(
                color: AppColors.textSecondaryMuted,
              ).copyWith(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ),

          // Installment
          SizedBox(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  item.label,
                  style: AppTypography.cardTitle(
                    color: isPreJoin ? AppColors.textTertiary : AppColors.textPrimaryDark,
                  ).copyWith(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Suvarna Varsha Chit',
                  style: AppTypography.labelMeta(
                    color: AppColors.textSecondaryMuted,
                  ).copyWith(fontSize: 10),
                ),
              ],
            ),
          ),

          // Amount
          SizedBox(
            width: 90,
            child: Text(
              CurrencyFormatter.formatRupees(item.amount),
              style: AppTypography.cardTitle(
                color: isPreJoin || item.status == InstallmentStatusEnum.upcoming
                    ? AppColors.textTertiary
                    : AppColors.textPrimaryDark,
              ).copyWith(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),

          // Date
          SizedBox(
            width: 110,
            child: dateWidget,
          ),

          // 24K Gold
          SizedBox(
            width: 110,
            child: goldWidget,
          ),

          // Mode
          SizedBox(
            width: 130,
            child: Text(
              modeText,
              style: AppTypography.bodySmall(
                color: AppColors.textSecondaryMuted,
              ).copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Status
          SizedBox(
            width: 125,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: statusWidget,
              ),
            ),
          ),

          // Action
          SizedBox(
            width: 150,
            child: actionWidget,
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text, {this.textAlign});

  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: AppTypography.labelMeta(
        color: AppColors.textSecondaryMuted,
      ).copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}
