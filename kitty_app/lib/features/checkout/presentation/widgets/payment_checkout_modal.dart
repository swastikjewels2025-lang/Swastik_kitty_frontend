import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/payment_state.dart';

/// Payment checkout modal card component matching approved UI design.
class PaymentCheckoutModal extends StatelessWidget {
  const PaymentCheckoutModal({
    super.key,
    required this.state,
    required this.onSelectMethod,
    this.onSelectChannel,
    this.onSelectMonthsCount,
    required this.onConfirmPayment,
    this.onProceedPickCash,
    required this.onClose,
  });

  final PaymentState state;
  final ValueChanged<PaymentMethodEnum> onSelectMethod;
  final ValueChanged<PaymentChannel>? onSelectChannel;
  final ValueChanged<int>? onSelectMonthsCount;
  final VoidCallback onConfirmPayment;
  final VoidCallback? onProceedPickCash;
  final VoidCallback onClose;

  void _handleSelectChannel(PaymentChannel channel) {
    if (onSelectChannel != null) {
      onSelectChannel!(channel);
    } else {
      onSelectMethod(channel.methodEnum);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedAmount = CurrencyFormatter.formatRupees(state.amount);
    final bool isPickCash = state.selectedChannel == PaymentChannel.pickCash;

    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.surfaceCardBorder,
          width: 1.2,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 40,
            offset: Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header Row with Title and Close Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Pay Kitty Installment',
                      key: const Key('checkout_modal_title'),
                      style: AppTypography.cardTitle(color: AppColors.espressoCharcoal).copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Month ${state.monthFor} Installment (${state.chitToken})',
                      key: const Key('checkout_modal_subtitle'),
                      style: AppTypography.labelMeta(
                        color: AppColors.warmTaupeBrown,
                      ).copyWith(fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('checkout_modal_close_btn'),
                icon: const Icon(Icons.close_rounded, color: AppColors.espressoCharcoal, size: 20),
                onPressed: state.isBusy ? null : onClose,
                splashRadius: 20,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F3),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.space16),

          // Payment Summary Box
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.space14,
              horizontal: AppSpacing.space16,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryEmerald,
              borderRadius: AppRadius.border14,
              border: Border.all(
                color: const Color(0xFFC99A2E).withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  'EMI AMOUNT DUE',
                  style: AppTypography.labelMeta(
                    color: const Color(0xFFC7D9D1),
                  ).copyWith(letterSpacing: 1.1, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedAmount,
                  key: const Key('checkout_modal_amount_text'),
                  style: AppTypography.amountDisplay(
                    color: const Color(0xFFFFE28A),
                  ).copyWith(fontSize: 28),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.space14),

          // Multi-Month Installment Selector
          Text(
            'SELECT INSTALLMENT MONTHS',
            style: AppTypography.labelMeta(
              color: AppColors.warmTaupeBrown,
            ).copyWith(letterSpacing: 1.0, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.space8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _buildMonthPill(
                  label: '1 Month',
                  count: 1,
                  isSelected: state.selectedMonthsCount == 1,
                  isEnabled: state.remainingMonthsCount >= 1 && !state.isBusy,
                ),
                const SizedBox(width: 8),
                _buildMonthPill(
                  label: '2 Months',
                  count: 2,
                  isSelected: state.selectedMonthsCount == 2,
                  isEnabled: state.remainingMonthsCount >= 2 && !state.isBusy,
                ),
                const SizedBox(width: 8),
                _buildMonthPill(
                  label: '3 Months',
                  count: 3,
                  isSelected: state.selectedMonthsCount == 3,
                  isEnabled: state.remainingMonthsCount >= 3 && !state.isBusy,
                ),
                const SizedBox(width: 8),
                _buildMonthPill(
                  pillKey: const Key('month_pill_all_remaining'),
                  label: 'All Remaining (${state.remainingMonthsCount} Mos)',
                  count: state.remainingMonthsCount,
                  isSelected: state.selectedMonthsCount == state.remainingMonthsCount &&
                      state.remainingMonthsCount > 1,
                  isEnabled: state.remainingMonthsCount > 1 && !state.isBusy,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (state.selectedMonthsCount > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFF0FDF4),
                borderRadius: AppRadius.border8,
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.primaryEmerald,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Paying Months ${state.selectedMonthsList.join(", ")} (${state.selectedMonthsCount} × ${CurrencyFormatter.formatRupees(state.monthlyInstallment)})',
                      style: const TextStyle(
                        color: AppColors.deepEmeraldBase,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.space12),

          // Payment Methods Header
          Text(
            'SELECT PAYMENT METHOD',
            style: AppTypography.labelMeta(
              color: AppColors.warmTaupeBrown,
            ).copyWith(letterSpacing: 1.0, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: AppSpacing.space10),

          // Method 1: Instant UPI
          _buildMethodItem(
            key: const Key('checkout_method_upi'),
            icon: Icons.bolt_rounded,
            iconColor: const Color(0xFFD97706),
            title: 'Instant UPI (GPay / PhonePe / Paytm)',
            subtitle: 'Instant zero-fee gold allocation',
            isSelected: state.selectedChannel == PaymentChannel.upi,
            onTap: () => _handleSelectChannel(PaymentChannel.upi),
          ),

          const SizedBox(height: AppSpacing.space10),

          // Method 2: Net Banking
          _buildMethodItem(
            key: const Key('checkout_method_netbanking'),
            icon: Icons.account_balance_rounded,
            iconColor: AppColors.primaryEmerald,
            title: 'Net Banking',
            subtitle: 'HDFC, ICICI, SBI & 40+ banks',
            isSelected: state.selectedChannel == PaymentChannel.netbanking,
            onTap: () => _handleSelectChannel(PaymentChannel.netbanking),
          ),

          const SizedBox(height: AppSpacing.space10),

          // Method 3: Debit / Credit Card
          _buildMethodItem(
            key: const Key('checkout_method_card'),
            icon: Icons.credit_card_rounded,
            iconColor: const Color(0xFF2563EB),
            title: 'Debit / Credit Card',
            subtitle: 'Visa, Mastercard, RuPay',
            isSelected: state.selectedChannel == PaymentChannel.card,
            onTap: () => _handleSelectChannel(PaymentChannel.card),
          ),

          const SizedBox(height: AppSpacing.space10),

          // Method 4: Pick Cash (Doorstep Cash Collection)
          _buildMethodItem(
            key: const Key('checkout_method_pick_cash'),
            icon: Icons.payments_outlined,
            iconColor: const Color(0xFFB45309),
            title: 'PICK CASH (Doorstep Pickup)',
            subtitle: 'Swastik verified executive collects cash at doorstep',
            isSelected: state.selectedChannel == PaymentChannel.pickCash,
            onTap: () => _handleSelectChannel(PaymentChannel.pickCash),
          ),

          const SizedBox(height: AppSpacing.space20),

          // Error Message Display if any
          if (state.errorMessage != null && !state.isBusy)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space12),
              child: Text(
                state.errorMessage!,
                key: const Key('checkout_modal_error_text'),
                style: AppTypography.labelMeta(
                  color: const Color(0xFFDC2626),
                ).copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),

          // Confirm & Pay CTA Button
          ElevatedButton(
            key: const Key('btn_confirm_payment'),
            onPressed: state.isBusy
                ? null
                : (isPickCash ? (onProceedPickCash ?? onConfirmPayment) : onConfirmPayment),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primaryEmerald.withValues(alpha: 0.5),
              disabledForegroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space14),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.border12,
              ),
              elevation: 2,
            ),
            child: state.isInitiating
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space10),
                      Text(
                        'Processing Secure Payment...',
                        style: AppTypography.bodyBold(
                          color: Colors.white,
                        ).copyWith(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ],
                  )
                : Text(
                    isPickCash
                        ? 'Proceed with Cash Pickup'
                        : 'Confirm & Pay $formattedAmount',
                    style: AppTypography.bodyBold(
                      color: Colors.white,
                    ).copyWith(fontSize: 14.5, fontWeight: FontWeight.w800),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodItem({
    required Key key,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      onTap: state.isBusy ? null : onTap,
      borderRadius: AppRadius.border12,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space14,
          vertical: AppSpacing.space12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEAF5F0)
              : const Color(0xFFF8F9FA),
          borderRadius: AppRadius.border12,
          border: Border.all(
            color: isSelected
                ? AppColors.primaryEmerald
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: AppTypography.bodyBold(
                      color: isSelected ? AppColors.primaryEmerald : AppColors.espressoCharcoal,
                    ).copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.labelMeta(
                      color: isSelected ? const Color(0xFF2E6352) : AppColors.warmTaupeBrown,
                    ).copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryEmerald
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryEmerald,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthPill({
    Key? pillKey,
    required String label,
    required int count,
    required bool isSelected,
    required bool isEnabled,
  }) {
    return InkWell(
      key: pillKey ?? Key('month_pill_$count'),
      onTap: isEnabled && onSelectMonthsCount != null
          ? () => onSelectMonthsCount!(count)
          : null,
      borderRadius: AppRadius.border10,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryEmerald
              : (isEnabled ? const Color(0xFFF8FAF9) : const Color(0xFFF1F5F9)),
          borderRadius: AppRadius.border10,
          border: Border.all(
            color: isSelected
                ? AppColors.goldPrimary
                : (isEnabled ? const Color(0xFFD1D5DB) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isEnabled ? AppColors.espressoCharcoal : const Color(0xFF94A3B8)),
          ),
        ),
      ),
    );
  }
}
