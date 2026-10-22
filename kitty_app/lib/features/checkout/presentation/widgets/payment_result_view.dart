import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/payment_state.dart';

/// Presentation view for all terminal payment results:
/// Success, Failed, Cancelled, Timeout, and Error.
class PaymentResultView extends StatelessWidget {
  const PaymentResultView({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onViewPassbook,
    required this.onReturnToDashboard,
    required this.onClose,
  });

  final PaymentState state;
  final VoidCallback onRetry;
  final VoidCallback onViewPassbook;
  final VoidCallback onReturnToDashboard;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    if (state.isSuccess) {
      return _buildSuccessResult(context);
    } else if (state.isFailed) {
      return _buildFailedResult(context);
    } else if (state.isCancelled) {
      return _buildCancelledResult(context);
    } else if (state.isTimeout) {
      return _buildTimeoutResult(context);
    } else {
      return _buildErrorResult(context);
    }
  }

  /// 1. Approved Success UI
  Widget _buildSuccessResult(BuildContext context) {
    final String formattedAmount = CurrencyFormatter.formatRupees(state.amount);
    final String txnId = state.statusEntity?.transactionId ?? 'TXN-SW-50291';
    final int monthsPaid = state.statusEntity?.monthsPaid ?? 9;
    final int totalPaid = state.statusEntity?.totalPaidAmount ?? (monthsPaid * state.amount);
    final String formattedTotalPaid = CurrencyFormatter.formatRupees(totalPaid);

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
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Success Checkmark Halo
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle_rounded,
                  key: Key('payment_success_check_icon'),
                  color: Color(0xFF10B981),
                  size: 44,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space16),

          // Status Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0x1F10B981),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0x4D10B981),
                ),
              ),
              child: Text(
                'PAYMENT CONFIRMED',
                style: AppTypography.labelMeta(
                  color: const Color(0xFF047857),
                ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.0),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space10),

          Text(
            'Installment Paid Successfully',
            key: const Key('payment_success_title'),
            style: AppTypography.cardTitle(
              color: AppColors.deepForestCharcoal,
            ).copyWith(fontSize: 20, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          Text(
            formattedAmount,
            key: const Key('payment_success_amount_text'),
            style: AppTypography.amountDisplay(
              color: AppColors.primaryEmerald,
            ).copyWith(fontSize: 32),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.space16),

          // Reconciliation Ledger Details
          Container(
            padding: const EdgeInsets.all(AppSpacing.space14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8F5),
              borderRadius: AppRadius.border14,
              border: Border.all(color: AppColors.surfaceCardBorder),
            ),
            child: Column(
              children: <Widget>[
                _buildSummaryRow('Transaction ID', txnId),
                const SizedBox(height: 6),
                _buildSummaryRow('Kitty Plan', state.chitToken),
                const SizedBox(height: 6),
                _buildSummaryRow('Installment', 'Month ${state.monthFor} of 12'),
                const SizedBox(height: 6),
                _buildSummaryRow('Total Paid So Far', formattedTotalPaid),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.space20),

          // Action 1: View Passbook
          ElevatedButton(
            key: const Key('btn_payment_view_passbook'),
            onPressed: onViewPassbook,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space14),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.border12,
              ),
              elevation: 0,
            ),
            child: Text(
              'View Official Passbook',
              style: AppTypography.bodyBold(
                color: Colors.white,
              ).copyWith(fontWeight: FontWeight.w800),
            ),
          ),

          const SizedBox(height: AppSpacing.space10),

          // Action 2: Back to Dashboard
          OutlinedButton(
            key: const Key('btn_payment_back_dashboard'),
            onPressed: onReturnToDashboard,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.deepForestCharcoal,
              side: const BorderSide(color: AppColors.surfaceCardBorder, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.border12,
              ),
            ),
            child: Text(
              'Back to Kitty Dashboard',
              style: AppTypography.bodyBold(
                color: AppColors.deepForestCharcoal,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Approved Failed UI
  Widget _buildFailedResult(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
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
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  key: Key('payment_failed_icon'),
                  color: Color(0xFFEF4444),
                  size: 40,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space16),

          Text(
            'Payment Could Not Be Completed',
            key: const Key('payment_failed_title'),
            style: AppTypography.cardTitle(
              color: AppColors.deepForestCharcoal,
            ).copyWith(fontSize: 19, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.space8),

          Text(
            state.errorMessage ??
                'Your bank was unable to authorize the transaction. No amount was deducted.',
            key: const Key('payment_failed_message'),
            style: AppTypography.bodySmall(
              color: AppColors.mutedSlateGray,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.space24),

          // Primary: Try Again
          ElevatedButton(
            key: const Key('btn_payment_retry'),
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space14),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.border12,
              ),
              elevation: 0,
            ),
            child: Text(
              'Try Again',
              style: AppTypography.bodyBold(
                color: Colors.white,
              ).copyWith(fontWeight: FontWeight.w800),
            ),
          ),

          const SizedBox(height: AppSpacing.space10),

          // Secondary: Cancel
          OutlinedButton(
            key: const Key('btn_payment_dismiss'),
            onPressed: onClose,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.deepForestCharcoal,
              side: const BorderSide(color: AppColors.surfaceCardBorder),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.border12,
              ),
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// 3. Approved Cancelled UI
  Widget _buildCancelledResult(BuildContext context) {
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
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF3EDE4),
              ),
              child: const Center(
                child: Icon(
                  Icons.cancel_outlined,
                  key: Key('payment_cancelled_icon'),
                  color: AppColors.mutedSlateGray,
                  size: 36,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space14),

          Text(
            'Payment Cancelled',
            key: const Key('payment_cancelled_title'),
            style: AppTypography.cardTitle(
              color: AppColors.deepForestCharcoal,
            ).copyWith(fontSize: 19, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.space8),

          Text(
            'The payment was cancelled before completion. You can retry at any time.',
            style: AppTypography.bodySmall(
              color: AppColors.mutedSlateGray,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.space24),

          ElevatedButton(
            key: const Key('btn_payment_cancelled_retry'),
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space14),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.border12,
              ),
              elevation: 0,
            ),
            child: const Text('Try Again'),
          ),

          const SizedBox(height: AppSpacing.space10),

          OutlinedButton(
            key: const Key('btn_payment_cancelled_close'),
            onPressed: onClose,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.deepForestCharcoal,
              side: const BorderSide(color: AppColors.surfaceCardBorder),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.border12,
              ),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// 4. Approved Timeout UI (Pending Verification)
  Widget _buildTimeoutResult(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
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
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.access_time_rounded,
                  key: Key('payment_timeout_icon'),
                  color: Color(0xFFD97706),
                  size: 40,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space16),

          Text(
            'Payment Under Bank Verification',
            key: const Key('payment_timeout_title'),
            style: AppTypography.cardTitle(
              color: AppColors.deepForestCharcoal,
            ).copyWith(fontSize: 19, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.space8),

          Text(
            'Verification is taking longer than expected with your bank. If the amount was deducted, your gold kitty passbook will update once confirmed.',
            key: const Key('payment_timeout_message'),
            style: AppTypography.bodySmall(
              color: AppColors.mutedSlateGray,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.space24),

          // Primary: Check Status Again
          ElevatedButton(
            key: const Key('btn_payment_check_status'),
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space14),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.border12,
              ),
              elevation: 0,
            ),
            child: const Text('Check Status Again'),
          ),

          const SizedBox(height: AppSpacing.space10),

          // Secondary: View Passbook
          OutlinedButton(
            key: const Key('btn_payment_timeout_passbook'),
            onPressed: onViewPassbook,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.deepForestCharcoal,
              side: const BorderSide(color: AppColors.surfaceCardBorder),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.border12,
              ),
            ),
            child: const Text('Go to Passbook'),
          ),
        ],
      ),
    );
  }

  /// 5. Error Result UI
  Widget _buildErrorResult(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
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
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Center(
            child: Icon(
              Icons.wifi_off_rounded,
              key: Key('payment_error_icon'),
              color: Color(0xFFEF4444),
              size: 48,
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          Text(
            'Connection Error',
            key: const Key('payment_error_title'),
            style: AppTypography.cardTitle(
              color: AppColors.deepForestCharcoal,
            ).copyWith(fontSize: 19, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            state.errorMessage ?? 'Unable to complete payment request. Please check your connection.',
            style: AppTypography.bodySmall(color: AppColors.mutedSlateGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space24),
          ElevatedButton(
            key: const Key('btn_payment_error_retry'),
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space14),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.border12,
              ),
              elevation: 0,
            ),
            child: const Text('Try Again'),
          ),
          const SizedBox(height: AppSpacing.space10),
          OutlinedButton(
            key: const Key('btn_payment_error_dismiss'),
            onPressed: onClose,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.deepForestCharcoal,
              side: const BorderSide(color: AppColors.surfaceCardBorder),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.border12,
              ),
            ),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: AppTypography.labelMeta(color: AppColors.mutedSlateGray),
        ),
        Text(
          value,
          style: AppTypography.labelMeta(color: AppColors.deepForestCharcoal).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
