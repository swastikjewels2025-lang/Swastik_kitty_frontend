import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/buttons/kitty_primary_button.dart';
import '../../domain/entities/scheme_entity.dart';

/// Modal dialog for scheme enrollment confirmation.
///
/// Matches `.enroll-modal-card` in `offers.html`.
class OffersEnrollmentDialog extends StatefulWidget {
  const OffersEnrollmentDialog({
    super.key,
    required this.scheme,
    this.onConfirmed,
  });

  final SchemeEntity scheme;
  final ValueChanged<int>? onConfirmed;

  static Future<void> show(
    BuildContext context, {
    required SchemeEntity scheme,
    ValueChanged<int>? onConfirmed,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => OffersEnrollmentDialog(
        scheme: scheme,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  State<OffersEnrollmentDialog> createState() => _OffersEnrollmentDialogState();
}

class _OffersEnrollmentDialogState extends State<OffersEnrollmentDialog> {
  late final TextEditingController _amountController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.scheme.monthlyInstallment.toString(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (!_formKey.currentState!.validate()) return;

    final int amount = int.tryParse(_amountController.text.trim()) ??
        widget.scheme.monthlyInstallment;

    Navigator.of(context).pop();

    if (widget.onConfirmed != null) {
      widget.onConfirmed!(amount);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.deepEmeraldBase,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: <Widget>[
            const Icon(Icons.check_circle_rounded, color: AppColors.goldPrimary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Enrollment requested for ${widget.scheme.name} (${CurrencyFormatter.formatRupees(amount)}/mo)',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String bonusText = widget.scheme.benefits.isNotEmpty
        ? widget.scheme.benefits.first
        : '1 Month Free Jeweler Bonus Deposit';

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.border20),
      backgroundColor: AppColors.surfaceCardBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Close button and eyebrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderPill,
                      border: Border.all(
                        color: AppColors.goldPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      '✦ ENROLLMENT CONFIRMATION',
                      style: TextStyle(
                        color: AppColors.goldPrimary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondaryMuted),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space12),

              // Title
              Text(
                'Enrol in Gold Scheme',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Confirm your monthly installment amount to lock in 24K gold rates today.',
                style: AppTypography.bodySmall(color: AppColors.textSecondaryMuted).copyWith(
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              // Scheme Name (Read Only)
              _buildReadOnlyField(
                label: 'Selected Scheme',
                value: widget.scheme.name,
              ),
              const SizedBox(height: AppSpacing.space12),

              // Privilege Bonus (Read Only)
              _buildReadOnlyField(
                label: 'Scheme Privilege Bonus',
                value: bonusText,
              ),
              const SizedBox(height: AppSpacing.space12),

              // Monthly Amount Input
              Text(
                'Monthly Installment Amount (₹)',
                style: AppTypography.bodySmall(color: AppColors.textPrimaryDark).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('enroll_amount_input'),
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: AppTypography.bodyRegular(color: AppColors.textPrimaryDark).copyWith(
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(
                    color: AppColors.goldPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.border12,
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: AppRadius.border12,
                    borderSide: BorderSide(color: AppColors.goldPrimary, width: 1.5),
                  ),
                ),
                validator: (String? val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter monthly installment amount';
                  }
                  final int? amount = int.tryParse(val.trim());
                  if (amount == null || amount < 1000) {
                    return 'Minimum installment is ₹1,000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.space20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: KittyPrimaryButton(
                  label: 'Confirm & Start Gold Scheme',
                  onPressed: _handleConfirm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AppTypography.bodySmall(color: AppColors.textPrimaryDark).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: AppRadius.border12,
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            value,
            style: AppTypography.bodySmall(color: AppColors.textPrimaryDark).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }
}
