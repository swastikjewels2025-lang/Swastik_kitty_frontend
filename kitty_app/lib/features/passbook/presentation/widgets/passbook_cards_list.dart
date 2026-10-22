import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/passbook_entry_entity.dart';
import 'passbook_entry_card.dart';

/// Renders the list of installment cards in Card View mode.
class PassbookCardsList extends StatelessWidget {
  const PassbookCardsList({
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      child: Column(
        children: entries.map((PassbookEntryEntity item) {
          return PassbookEntryCard(
            key: ValueKey<int>(item.month),
            entry: item,
            onViewReceipt: onViewReceipt,
            onPayEmi: onPayEmi,
            onPerksInfo: onPerksInfo,
          );
        }).toList(),
      ),
    );
  }
}
