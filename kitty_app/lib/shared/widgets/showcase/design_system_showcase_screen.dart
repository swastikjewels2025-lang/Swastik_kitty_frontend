import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../kitty_widgets.dart';

/// Development-only showcase screen for visually and interactively inspecting
/// all Phase 3 design system components.
class DesignSystemShowcaseScreen extends StatefulWidget {
  const DesignSystemShowcaseScreen({super.key});

  @override
  State<DesignSystemShowcaseScreen> createState() =>
      _DesignSystemShowcaseScreenState();
}

class _DesignSystemShowcaseScreenState
    extends State<DesignSystemShowcaseScreen> {
  bool _isDarkSurface = true;
  bool _isLoadingButton = false;
  int _gaugeValue = 8;
  String? _otpCode;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color pageBg = _isDarkSurface
        ? AppColors.deepEmeraldBase
        : AppColors.surfacePageBg;

    final Color sectionHeaderColor = _isDarkSurface
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: const Text('Design System Showcase'),
        backgroundColor: _isDarkSurface
            ? AppColors.deepEmeraldBase
            : AppColors.surfaceCardBg,
        foregroundColor: sectionHeaderColor,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(_isDarkSurface ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme Surface',
            onPressed: () => setState(() => _isDarkSurface = !_isDarkSurface),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. BUTTONS SECTION
            _buildSection(
              title: '1. Button System',
              children: <Widget>[
                KittyPrimaryButton(
                  label: 'Pay Next EMI (₹5,000)',
                  isLoading: _isLoadingButton,
                  onPressed: () async {
                    setState(() => _isLoadingButton = true);
                    await Future<void>.delayed(const Duration(seconds: 2));
                    if (context.mounted) {
                      setState(() => _isLoadingButton = false);
                      KittyToast.show(
                        context,
                        message: 'Payment Simulated Successfully!',
                        type: KittyToastType.success,
                      );
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.space12),
                KittyPrimaryButton(
                  label: 'Disabled Primary CTA',
                  isEnabled: false,
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.space12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: KittySecondaryButton(
                        label: 'View Receipt',
                        icon: const Icon(Icons.receipt_long_outlined, size: 16),
                        isDarkSurface: _isDarkSurface,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space10),
                    Expanded(
                      child: KittySecondaryButton(
                        label: 'Choose File',
                        icon: const Icon(Icons.file_upload_outlined, size: 16),
                        isDarkSurface: _isDarkSurface,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    KittyGhostButton(
                      label: 'Resend OTP',
                      onPressed: () {},
                    ),
                    KittyGhostButton(
                      label: 'Forgot PIN?',
                      underline: true,
                      onPressed: () {},
                    ),
                    KittyIconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      badgeCount: 3,
                      isDarkSurface: _isDarkSurface,
                      onPressed: () {},
                    ),
                    KittyIconButton(
                      icon: const Icon(Icons.arrow_back),
                      isDarkSurface: _isDarkSurface,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.space28),

            // 2. INPUTS SECTION
            _buildSection(
              title: '2. Form & Input System',
              children: <Widget>[
                KittyPhoneInputField(
                  isDarkSurface: _isDarkSurface,
                  onChanged: (String val) {},
                ),
                const SizedBox(height: AppSpacing.space16),
                KittyTextField(
                  label: 'Patron Full Name',
                  hintText: 'e.g. Rajesh Sharma',
                  controller: _textController,
                  isDarkSurface: _isDarkSurface,
                  showClearButton: true,
                ),
                const SizedBox(height: AppSpacing.space16),
                KittyTextField(
                  label: 'Passcode / MPIN',
                  hintText: 'Enter 4-digit PIN',
                  isPassword: true,
                  isDarkSurface: _isDarkSurface,
                ),
                const SizedBox(height: AppSpacing.space16),
                KittyTextField(
                  label: 'Validation Error Field',
                  hintText: 'Enter valid PAN',
                  errorText: 'Invalid PAN number format',
                  isDarkSurface: _isDarkSurface,
                ),
                const SizedBox(height: AppSpacing.space20),
                Text(
                  '6-Digit Segmented OTP Input:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: sectionHeaderColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.space8),
                KittyOtpInput(
                  isDarkSurface: _isDarkSurface,
                  onCompleted: (String code) {
                    setState(() => _otpCode = code);
                    KittyToast.show(
                      context,
                      message: 'Entered OTP: $code',
                      type: KittyToastType.info,
                    );
                  },
                ),
                if (_otpCode != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.space6),
                  Text(
                    'Last Verified Code: $_otpCode',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.goldPrimary,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: AppSpacing.space28),

            // 3. CARDS & HERO
            _buildSection(
              title: '3. Cards & Hero Containers',
              children: <Widget>[
                KittyLuxuryEmeraldCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          KittyStatusBadge(status: KittyInstallmentStatus.active),
                          KittyChitTokenPill(token: '#SW-042'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space16),
                      Text(
                        'Swastik Suvarna Varsha',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹5,000 / month • 12 Months Scheme',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.emeraldTextSubtle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: KittyStatCard(
                        icon: const Icon(Icons.track_changes_outlined),
                        label: 'Scheme Target',
                        value: '₹60,000',
                        deltaText: '+2.59%',
                        isDarkSurface: _isDarkSurface,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: KittyStatCard(
                        icon: const Icon(Icons.account_balance_wallet_outlined),
                        label: 'Gold Accrued',
                        value: '5.482 g',
                        subtitle: '24 Karat 999',
                        isDarkSurface: _isDarkSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.space28),

            // 4. BADGES & PILLS
            _buildSection(
              title: '4. Status Badges & Pills',
              children: const <Widget>[
                Wrap(
                  spacing: AppSpacing.space8,
                  runSpacing: AppSpacing.space8,
                  children: <Widget>[
                    KittyStatusBadge(status: KittyInstallmentStatus.paid),
                    KittyStatusBadge(status: KittyInstallmentStatus.current),
                    KittyStatusBadge(status: KittyInstallmentStatus.upcoming),
                    KittyStatusBadge(status: KittyInstallmentStatus.bonus),
                    KittyStatusBadge(status: KittyInstallmentStatus.preJoin),
                    KittyStatusBadge(status: KittyInstallmentStatus.due),
                    KittyStatusBadge(status: KittyInstallmentStatus.failed),
                    KittyChitTokenPill(token: '#SW-042', isDarkSurface: false),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.space28),

            // 5. CIRCULAR PROGRESS GAUGE
            _buildSection(
              title: '5. Circular Progress Gauge',
              children: <Widget>[
                Center(
                  child: KittyCircularProgressGauge(
                    currentValue: _gaugeValue,
                    totalValue: 12,
                    subtitle: '${12 - _gaugeValue} to Pay • 1 Bonus Free',
                    isDarkSurface: _isDarkSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.space12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    KittySecondaryButton(
                      label: '- Month',
                      isDarkSurface: _isDarkSurface,
                      onPressed: () {
                        if (_gaugeValue > 0) {
                          setState(() => _gaugeValue--);
                        }
                      },
                    ),
                    const SizedBox(width: AppSpacing.space16),
                    KittySecondaryButton(
                      label: '+ Month',
                      isDarkSurface: _isDarkSurface,
                      onPressed: () {
                        if (_gaugeValue < 12) {
                          setState(() => _gaugeValue++);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.space28),

            // 6. FEEDBACK, SKELETONS & LOADERS
            _buildSection(
              title: '6. Skeletons, Loaders & Feedback',
              children: <Widget>[
                KittySkeletonCard(isDarkSurface: _isDarkSurface),
                const SizedBox(height: AppSpacing.space16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    KittyLoadingIndicator(
                      type: KittyLoadingType.spinner,
                      isDarkSurface: _isDarkSurface,
                    ),
                    KittyLoadingIndicator(
                      type: KittyLoadingType.jewel,
                      isDarkSurface: _isDarkSurface,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),
                Wrap(
                  spacing: AppSpacing.space8,
                  runSpacing: AppSpacing.space8,
                  children: <Widget>[
                    KittySecondaryButton(
                      label: 'Show Toast Success',
                      isDarkSurface: _isDarkSurface,
                      onPressed: () => KittyToast.show(
                        context,
                        message: '₹5,000 Installment Deposited!',
                        type: KittyToastType.success,
                      ),
                    ),
                    KittySecondaryButton(
                      label: 'Show Toast Error',
                      isDarkSurface: _isDarkSurface,
                      onPressed: () => KittyToast.show(
                        context,
                        message: 'Payment gateway timeout. Please retry.',
                        type: KittyToastType.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.space28),

            // 7. DISPLAY PRIMITIVES
            _buildSection(
              title: '7. Display Primitives',
              children: <Widget>[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    KittyAvatar(size: 36, initials: 'RS'),
                    KittyAvatar(size: 48, initials: 'SJ'),
                    KittyAvatar(size: 60, initials: 'VK'),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),
                KittySectionHeader(
                  title: 'Passbook Ledger',
                  eyebrow: 'Installments Summary',
                  actionLabel: 'View Table',
                  isDarkSurface: _isDarkSurface,
                  onAction: () {},
                ),
                const SizedBox(height: AppSpacing.space10),
                KittyLabelValueRow(
                  label: 'Gold Accumulation Rate',
                  value: '₹7,120 / g',
                  isDarkSurface: _isDarkSurface,
                ),
                KittyLabelValueRow(
                  label: 'Payment Method',
                  value: 'UPI (GPay)',
                  isDarkSurface: _isDarkSurface,
                ),
                KittyLabelValueRow(
                  label: 'Status',
                  value: '',
                  valueWidget: const KittyStatusBadge(status: KittyInstallmentStatus.paid),
                  isDarkSurface: _isDarkSurface,
                ),
                const SizedBox(height: AppSpacing.space12),
                KittyDivider(showDiamond: true, isDarkSurface: _isDarkSurface),
                const SizedBox(height: AppSpacing.space12),
                KittyDropzone(
                  isDarkSurface: _isDarkSurface,
                  onTakePhoto: () {},
                  onChooseFile: () {},
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.space28),

            // 8. DIALOGS & SHEETS
            _buildSection(
              title: '8. Dialogs & Bottom Sheets',
              children: <Widget>[
                Wrap(
                  spacing: AppSpacing.space8,
                  runSpacing: AppSpacing.space8,
                  children: <Widget>[
                    KittySecondaryButton(
                      label: 'Open Modal Dialog',
                      isDarkSurface: _isDarkSurface,
                      onPressed: () {
                        KittyDialog.show<void>(
                          context: context,
                          title: 'Digital Tax Invoice',
                          subtitle: 'Official Gold Scheme Receipt',
                          isDarkSurface: _isDarkSurface,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              KittyLabelValueRow(label: 'Invoice #', value: 'INV-2026-081'),
                              KittyLabelValueRow(label: 'Amount Paid', value: '₹5,000', isBoldValue: true),
                              KittyLabelValueRow(label: 'Gold Allotted', value: '0.702 g', isGoldValue: true),
                            ],
                          ),
                        );
                      },
                    ),
                    KittySecondaryButton(
                      label: 'Open Confirm Dialog',
                      isDarkSurface: _isDarkSurface,
                      onPressed: () {
                        KittyConfirmDialog.show(
                          context: context,
                          title: 'Sign Out of Kitty App?',
                          message: 'Are you sure you want to securely log out from this session?',
                          confirmLabel: 'Sign Out',
                          isDestructive: true,
                          isDarkSurface: _isDarkSurface,
                        );
                      },
                    ),
                    KittySecondaryButton(
                      label: 'Open Bottom Sheet',
                      isDarkSurface: _isDarkSurface,
                      onPressed: () {
                        KittyBottomSheet.show<void>(
                          context: context,
                          title: 'Select Payment Method',
                          subtitle: 'Instant GoKwik Secured Gateway',
                          isDarkSurface: _isDarkSurface,
                          child: Column(
                            children: <Widget>[
                              KittyCard(
                                variant: _isDarkSurface
                                    ? KittyCardVariant.emeraldDark
                                    : KittyCardVariant.surfaceLight,
                                onTap: () => Navigator.of(context).pop(),
                                child: const Row(
                                  children: <Widget>[
                                    Icon(Icons.account_balance_wallet_outlined, color: AppColors.goldPrimary),
                                    SizedBox(width: AppSpacing.space12),
                                    Text('UPI (Google Pay, PhonePe, Paytm)'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.space48),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.goldPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        ...children,
      ],
    );
  }
}
