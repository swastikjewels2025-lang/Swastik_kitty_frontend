import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/payment_state.dart';

/// Luxury payment processing and reconciliation polling view.
class PaymentProcessingView extends StatelessWidget {
  const PaymentProcessingView({
    super.key,
    required this.state,
  });

  final PaymentState state;

  @override
  Widget build(BuildContext context) {
    final String formattedAmount = CurrencyFormatter.formatRupees(state.amount);
    final String orderId = state.order?.orderId ?? 'gokwik_ord_771829';

    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.surfaceCardBorder,
          width: 1.2,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.space28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Animated Gold Spinner with Shield
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryEmerald.withValues(alpha: 0.08),
              border: Border.all(
                color: AppColors.surfaceCardBorder,
                width: 1.5,
              ),
            ),
            child: const Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryEmerald),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space20),

          // Polling Step Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EDE4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'RECONCILIATION STEP ${state.pollCount}/5',
              style: AppTypography.labelMeta(
                color: AppColors.primaryEmerald,
              ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
            ),
          ),

          const SizedBox(height: AppSpacing.space12),

          // Dynamic Message
          Text(
            state.pollingMessage,
            key: const Key('payment_polling_message_text'),
            style: AppTypography.cardTitle(
              color: AppColors.deepForestCharcoal,
            ).copyWith(fontSize: 17, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.space8),

          Text(
            'Securely confirming bank settlement with Swastik Gold Vault.',
            style: AppTypography.bodySmall(
              color: AppColors.mutedSlateGray,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.space20),

          // Details Box
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8F5),
              borderRadius: AppRadius.border12,
              border: Border.all(color: AppColors.surfaceCardBorder),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Amount',
                      style: AppTypography.labelMeta(color: AppColors.mutedSlateGray),
                    ),
                    Text(
                      formattedAmount,
                      style: AppTypography.labelMeta(color: AppColors.primaryEmerald).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Order Ref',
                      style: AppTypography.labelMeta(color: AppColors.mutedSlateGray),
                    ),
                    Text(
                      orderId,
                      style: AppTypography.labelMeta(color: AppColors.deepForestCharcoal).copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.space16),

          // Safety Reassurance
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.mutedSlateGray,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Please do not close this window',
                style: AppTypography.labelMeta(
                  color: AppColors.mutedSlateGray,
                ).copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
