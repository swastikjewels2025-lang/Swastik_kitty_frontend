import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../../shared/widgets/dialogs/edit_profile_dialog.dart';

/// Destination / Launch Choice Screen.
///
/// Displayed on EVERY application launch (for authenticated patrons)
/// and immediately following successful registration / statutory KYC.
///
/// Layout:
/// - Scaffold Background: Warm Pearl / Light Parchment (#FAF7F2 - Gold Plans baseline)
/// - Top Bar:
///   - Top-left: Swastik Jewels official logo asset
///   - Top-right: Patron profile icon launching Edit Profile dialog
/// - 3 Luxury Destination Cards matching the approved visual structure:
///   1. "View Gold Schemes" -> Enters internal Kitty App Gold Plans (/offers)
///   2. "Shop Jewellery" -> Official Swastik Jewels jewellery website catalog external link
///   3. "View Our Instagram" -> Official Swastik Jewels Instagram external link
class OnboardingChoiceScreen extends ConsumerWidget {
  const OnboardingChoiceScreen({super.key});

  Future<void> _launchInstagram(BuildContext context) =>
      UrlLauncherHelper.launchInstagram(context);

  Future<void> _launchShopJewellery(BuildContext context) =>
      UrlLauncherHelper.launchJewelleryCatalog(context);

  void _navigateToShopGold(BuildContext context) {
    HapticFeedback.lightImpact();
    context.go(RoutePaths.offers);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppAuthState authState = ref.watch(appAuthStateProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        // On hardware back press, default to entering the Gold experience
        _navigateToShopGold(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF7F2), // Exact Gold Plans Background
        body: SafeArea(
          child: Column(
            children: <Widget>[
              // Top Bar: Positioned slightly higher near the top
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // Top-left: Swastik Jewels Logo
                        SvgPicture.asset(
                          'assets/icons/swastiklogo.svg',
                          height: 36,
                          fit: BoxFit.contain,
                          semanticsLabel: 'Swastik Jewels',
                        ),

                        // Top-right: Profile Icon
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              showEditProfileDialog(context, authState: authState);
                            },
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF063B2C).withValues(alpha: 0.08),
                                border: Border.all(
                                  color: const Color(0xFFEFE7DA),
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: authState.photoPath != null &&
                                        authState.photoPath!.isNotEmpty
                                    ? ClipOval(
                                        child: kIsWeb
                                            ? Image.network(
                                                authState.photoPath!,
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                io.File(authState.photoPath!),
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              ),
                                      )
                                    : const Icon(
                                        Icons.person_outline_rounded,
                                        size: 22,
                                        color: Color(0xFF063B2C),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // The 3 destination options centered in their original position
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Destination 1: View Gold Schemes
                          _buildDestinationCard(
                            iconPath: 'assets/icons/gold-plans.svg',
                            title: 'View Gold Schemes',
                            description:
                                'Explore gold savings schemes, lock in live rates & grow wealth.',
                            onTap: () => _navigateToShopGold(context),
                          ),

                          const SizedBox(height: 16),

                          // Destination 2: Shop Jewellery
                          _buildDestinationCard(
                            iconPath: 'assets/icons/explore-jewellery.svg',
                            title: 'Shop Jewellery',
                            description:
                                'Browse handcrafted bridal, gold & diamond jewellery collections.',
                            onTap: () => _launchShopJewellery(context),
                          ),

                          const SizedBox(height: 16),

                          // Destination 3: View Our Instagram
                          _buildDestinationCard(
                            iconPath: 'assets/icons/instagram.svg',
                            title: 'View Our Instagram',
                            description:
                                'Follow our daily jewellery showcases, stories & latest designs.',
                            onTap: () => _launchInstagram(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Destination Card:
  /// - Icon placed at the top center of each card
  /// - Heading below the icon, centered
  /// - Description below the heading, centered
  Widget _buildDestinationCard({
    required String iconPath,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEFE6DB)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 14,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF2E5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFE2CF)),
                    ),
                    padding: const EdgeInsets.all(13),
                    child: SvgPicture.asset(
                      iconPath,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF9A7342),
                        BlendMode.srcIn,
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A221C),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF55605B),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
