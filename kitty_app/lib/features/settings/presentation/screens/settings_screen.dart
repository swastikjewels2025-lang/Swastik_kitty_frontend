import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/widgets/feedback/kitty_error_state.dart';
import '../../../../shared/widgets/navigation/kitty_hamburger_button.dart';
import '../providers/settings_controller.dart';
import '../providers/settings_state.dart';
import '../widgets/mpin_dialog.dart';
import '../widgets/nominee_details_modal.dart';
import '../widgets/patron_profile_card.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/settings_skeleton_loader.dart';
import '../widgets/terms_and_compliance_modal.dart';

/// Luxury Patron Settings, Security & Profile screen strictly matching `settings.html`.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SettingsState state = ref.watch(settingsControllerProvider);
    final SettingsController controller = ref.read(settingsControllerProvider.notifier);
    const bool isDark = false;
    const Color pageBg = AppColors.settingsBg;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: _buildBody(context, ref, state, controller, isDark),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    SettingsState state,
    SettingsController controller,
    bool isDark,
  ) {
    if (state.isLoading && state.user == null) {
      return const SettingsSkeletonLoader();
    }

    if (state.errorMessage != null && state.user == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: KittyErrorState(
            title: 'Unable to Load Profile',
            message: state.errorMessage!,
            retryLabel: 'Try Again',
            isDarkSurface: isDark,
            onRetry: () => controller.loadInitialData(),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Top Bar with Back Button, Title, and Hamburger Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(RoutePaths.offers);
                  }
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 22, color: Color(0xFF1E1B18)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              Text(
                'Settings & Security',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1B18),
                ),
              ),
              const KittyHamburgerButton(isLightSurface: true),
            ],
          ),
          const SizedBox(height: 12),

          // Patron Profile Quick Card
          PatronProfileCard(user: state.user),
                    const SizedBox(height: AppSpacing.space20),

                    // Section 1: Gold Kitty & Scheme Automation
                    SettingsGroupCard(
                      title: 'Gold Scheme & Savings Settings',
                      items: <SettingsItemModel>[
                        SettingsItemModel(
                          icon: Icons.autorenew_rounded,
                          title: 'UPI AutoPay / e-Mandate',
                          subtitle: 'Auto-deduct ₹5,000 on 15th every month',
                          trailing: Switch(
                            value: state.preferences.autoPayEnabled,
                            activeThumbColor: AppColors.settingsAccentGold,
                            activeTrackColor: AppColors.settingsAccentGold.withValues(alpha: 0.35),
                            inactiveThumbColor: AppColors.settingsTextSecondary,
                            inactiveTrackColor: AppColors.settingsBorder,
                            onChanged: (bool value) => controller.toggleAutoPay(value),
                          ),
                        ),
                        SettingsItemModel(
                          icon: Icons.people_outline_rounded,
                          title: 'Nominee Registration',
                          subtitle: ref.watch(appAuthStateProvider).nomineeName.isNotEmpty
                              ? '${ref.watch(appAuthStateProvider).nomineeName} (${ref.watch(appAuthStateProvider).nomineeRelation.isNotEmpty ? ref.watch(appAuthStateProvider).nomineeRelation : 'Beneficiary'}) • 100% Share'
                              : (state.user?.nomineeName?.isNotEmpty == true
                                  ? '${state.user!.nomineeName} (${state.user?.nomineeRelationship ?? 'Beneficiary'}) • 100% Share'
                                  : 'Not Registered'),
                          badgeText: (ref.watch(appAuthStateProvider).nomineeName.isNotEmpty || state.user?.nomineeName?.isNotEmpty == true) ? 'Registered' : 'Pending',
                          onTap: () => NomineeDetailsModal.show(
                            context,
                            nomineeName: ref.read(appAuthStateProvider).nomineeName.isNotEmpty
                                ? ref.read(appAuthStateProvider).nomineeName
                                : state.user?.nomineeName,
                            relationship: ref.read(appAuthStateProvider).nomineeRelation.isNotEmpty
                                ? ref.read(appAuthStateProvider).nomineeRelation
                                : state.user?.nomineeRelationship,
                          ),
                        ),
                        SettingsItemModel(
                          icon: Icons.star_border_rounded,
                          title: 'Maturity Gold Redemption',
                          subtitle: 'Physical 24K Gold or Showroom Jewellery',
                          onTap: () => TermsAndComplianceModal.show(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space20),

                    // Section 2: Security & App Privacy
                    SettingsGroupCard(
                      title: 'Security & PIN',
                      items: <SettingsItemModel>[
                        SettingsItemModel(
                          icon: Icons.fingerprint_rounded,
                          title: 'Biometric App Lock',
                          subtitle: 'Fingerprint / Face ID for Passbook',
                          trailing: Switch(
                            value: state.preferences.biometricEnabled,
                            activeThumbColor: AppColors.settingsAccentGold,
                            activeTrackColor: AppColors.settingsAccentGold.withValues(alpha: 0.35),
                            inactiveThumbColor: AppColors.settingsTextSecondary,
                            inactiveTrackColor: AppColors.settingsBorder,
                            onChanged: (bool value) => controller.toggleBiometric(value),
                          ),
                        ),
                        SettingsItemModel(
                          icon: Icons.lock_outline_rounded,
                          title: 'Change 4-Digit MPIN',
                          subtitle: state.hasMpin
                              ? 'MPIN configured • Tap to update'
                              : 'Required for payment authorization',
                          onTap: () => MpinDialog.show(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space20),

                    // Section 3: KYC Verification
                    SettingsGroupCard(
                      title: 'KYC Verification',
                      items: <SettingsItemModel>[
                        SettingsItemModel(
                          icon: Icons.badge_outlined,
                          title: '${state.user?.kyc.documentType?.toJson() ?? 'PAN'} Verification (Government ID)',
                          subtitle: state.user?.kyc.documentNumberMasked?.isNotEmpty == true
                              ? '${state.user!.kyc.documentNumberMasked} (${state.user?.name ?? 'Rajesh Sharma'})'
                              : 'XXXX XXXX 9012 (${state.user?.name ?? 'Patron'})',
                          badgeText: state.user?.kyc.isVerified == true ? 'Verified' : 'Pending',
                          onTap: () => context.push(RoutePaths.kyc),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space20),

                    // Section 4: App Preferences & Legal
                    SettingsGroupCard(
                      title: 'App & Legal',
                      items: <SettingsItemModel>[
                        SettingsItemModel(
                          icon: Icons.verified_outlined,
                          title: 'Gold Scheme Terms & BIS 24K Hallmarking',
                          subtitle: '100% Guaranteed 999 purity compliance',
                          onTap: () => TermsAndComplianceModal.show(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space24),

                    // Destructive Sign Out Button
                    _buildLogoutButton(context, ref),
                    const SizedBox(height: AppSpacing.space20),

                    // Footer Legal Text
                    _buildFooterLegal(),
                    const SizedBox(height: AppSpacing.space64),
                  ],
                ),
              );
  }


  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        final bool? confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext ctx) => AlertDialog(
            backgroundColor: AppColors.emeraldCard,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.border20),
            title: const Text(
              'Log Out of Account?',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            content: const Text(
              'Are you sure you want to end your current session?',
              style: TextStyle(color: AppColors.emeraldTextSubtle),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel', style: TextStyle(color: AppColors.emeraldTextSubtle)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusErrorText,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
                ),
                child: const Text('Log Out'),
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          await ref.read(settingsControllerProvider.notifier).logout();
          if (context.mounted) {
            context.go(RoutePaths.login);
          }
        }
      },
      borderRadius: AppRadius.border16,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: AppRadius.border16,
          border: Border.all(color: const Color(0xFFFEE2E2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.logout_rounded, size: 18, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text(
              'Log Out of Account',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLegal() {
    return const Column(
      children: <Widget>[
        Text(
          'Swastik Jewellers Active Gold Vault • v2.4.0',
          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
        SizedBox(height: 3),
        Text(
          '256-bit Bank Grade Encryption • ISO 9001 Certified',
          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }
}

