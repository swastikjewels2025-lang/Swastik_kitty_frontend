import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../providers/settings_controller.dart';

/// Dialog allowing patron to set or change their 4-digit transaction MPIN.
class MpinDialog extends ConsumerStatefulWidget {
  const MpinDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => const MpinDialog(),
    );
  }

  @override
  ConsumerState<MpinDialog> createState() => _MpinDialogState();
}

class _MpinDialogState extends ConsumerState<MpinDialog> {
  final TextEditingController _pinController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _submit() {
    final String pin = _pinController.text.trim();
    if (pin.length != 4 || int.tryParse(pin) == null) {
      setState(() {
        _error = 'Please enter a valid 4-digit PIN';
      });
      return;
    }

    ref.read(settingsControllerProvider.notifier).setMpin(pin);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction MPIN updated successfully'),
        backgroundColor: AppColors.statusSuccessText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color dialogBg = isDark ? AppColors.emeraldCard : Colors.white;
    final Color titleColor = isDark ? AppColors.textPrimaryLight : const Color(0xFF0F172A);
    final Color subColor = isDark ? AppColors.emeraldTextSubtle : const Color(0xFF64748B);

    return AlertDialog(
      backgroundColor: dialogBg,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.border20),
      title: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.goldSubtle,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.lock_outline_rounded, color: AppColors.goldPrimary, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'Change MPIN',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Enter a new 4-digit MPIN for payment and passbook authorization.',
            style: TextStyle(fontSize: 13, color: subColor, height: 1.35),
          ),
          const SizedBox(height: AppSpacing.space16),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            textAlign: TextAlign.center,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            style: TextStyle(
              fontSize: 24,
              letterSpacing: 12,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••',
              errorText: _error,
              filled: true,
              fillColor: isDark ? AppColors.deepEmeraldBase : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: AppRadius.border12,
                borderSide: BorderSide(color: isDark ? AppColors.emeraldBorder : const Color(0xFFE2E8F0)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadius.border12,
                borderSide: BorderSide(color: AppColors.goldPrimary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: subColor)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.goldPrimary,
            foregroundColor: AppColors.emeraldPrimary,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
          ),
          child: const Text('Save PIN', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
