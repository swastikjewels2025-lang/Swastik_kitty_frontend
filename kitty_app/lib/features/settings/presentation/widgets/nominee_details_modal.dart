import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/buttons/kitty_primary_button.dart';

/// Modal bottom sheet displaying registered Nominee details for the patron's kitty scheme.
class NomineeDetailsModal extends StatelessWidget {
  const NomineeDetailsModal({
    required this.nomineeName,
    required this.relationship,
    super.key,
  });

  final String nomineeName;
  final String relationship;

  static Future<void> show(
    BuildContext context, {
    required String? nomineeName,
    required String? relationship,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => NomineeDetailsModal(
        nomineeName: nomineeName?.isNotEmpty == true ? nomineeName! : 'Not Registered',
        relationship: relationship?.isNotEmpty == true ? relationship! : 'Beneficiary',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color modalBg = isDark ? AppColors.emeraldCard : Colors.white;
    final Color titleColor = isDark ? AppColors.textPrimaryLight : const Color(0xFF0F172A);
    final Color subColor = isDark ? AppColors.emeraldTextSubtle : const Color(0xFF64748B);
    final Color boxBg = isDark ? AppColors.deepEmeraldBase : const Color(0xFFF8FAFC);
    final Color boxBorder = isDark ? AppColors.emeraldBorder : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: modalBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Drag Handle
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),

          // Header
          Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.goldSubtle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.people_alt_outlined,
                  color: AppColors.goldPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Nominee Registration',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    'Statutory Beneficiary Details',
                    style: TextStyle(fontSize: 12, color: subColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space20),

          // Details Box
          Container(
            padding: AppSpacing.all16,
            decoration: BoxDecoration(
              color: boxBg,
              borderRadius: AppRadius.border16,
              border: Border.all(color: boxBorder),
            ),
            child: Column(
              children: <Widget>[
                _buildRow('Beneficiary Name', nomineeName, titleColor, subColor),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),
                _buildRow('Relationship', relationship, titleColor, subColor),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),
                _buildRow('Benefit Allocation', '100% Share', titleColor, subColor),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),
                _buildRow('Statutory Status', 'Registered & Verified', AppColors.statusSuccessText, subColor),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space16),

          Text(
            'In the event of unforeseen circumstances, all accumulated gold weight and scheme maturity benefits will be disbursed to the registered nominee per legal compliance.',
            style: TextStyle(fontSize: 11.5, color: subColor, height: 1.4),
          ),
          const SizedBox(height: AppSpacing.space20),

          KittyPrimaryButton(
            label: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color valueColor, Color labelColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: TextStyle(fontSize: 13, color: labelColor)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: valueColor),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
