import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/scheme_entity.dart';
import '../../../../shared/widgets/feedback/kitty_error_state.dart';
import '../../../../shared/widgets/navigation/kitty_hamburger_button.dart';
import '../providers/offers_controller.dart';
import '../providers/offers_state.dart';
import '../widgets/offers_skeleton_loader.dart';

/// Gold Savings Plans Screen recreating `dddd/goldPlan.html` exactly.
///
/// Features:
/// 1. Top Navigation with Back Arrow & Header:
///    - Title: "Gold Savings Plans" (Playfair Display 28-30px bold)
///    - Subtitle: "Start your gold journey with flexible plans and secure your tomorrow."
/// 2. Segmented Pill Toggle Buttons:
///    - "Popular Plans" vs "How It Works"
/// 3. Popular Plans View:
///    - 6 Month Plan (with "Most Popular" green badge)
///    - 9 Month Plan
///    - 11 Month Plan
///    - Feature bullets with warm gold dots
///    - "Select a Plan" CTA buttons
/// 4. How It Works View:
///    - 3 Simple Steps to Pure Gold (Choose Duration, Lock in Live Rates, Redeem)
/// 5. Start Plan Modal Drawer:
///    - First Month Instalment, Total Maturity Value, Estimated Gold Accrual, Pay Today
///    - "Confirm & Pay First Instalment →"
class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  String _activeTab = 'popular'; // 'popular' | 'how'

  @override
  Widget build(BuildContext context) {
    final OffersState state = ref.watch(offersControllerProvider);
    final OffersController controller = ref.read(offersControllerProvider.notifier);

    if (state.status == OffersStatus.loading && state.schemes.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAF7F2),
        body: SafeArea(child: OffersSkeletonLoader()),
      );
    }

    if (state.status == OffersStatus.error && state.schemes.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF7F2),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space24),
            child: KittyErrorState(
              title: 'Unable to Load Plans',
              message: state.errorMessage ?? 'Please check your connection and try again.',
              retryLabel: 'Try Again',
              onRetry: controller.retry,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Top Header with Swastik Logo & Top-Right Hamburger Menu Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/icons/swastiklogo.svg',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  const KittyHamburgerButton(isLightSurface: true),
                ],
              ),

              const SizedBox(height: 4),

              // Screen Title (Two lines below heading removed per requirement #2)
              Center(
                child: Text(
                  'Gold Savings Plans',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A221C),
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Segmented Pill Toggle Buttons [Popular Plans] / [How It Works]
              Row(
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _activeTab = 'popular'),
                      borderRadius: BorderRadius.circular(100),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _activeTab == 'popular'
                              ? const Color(0xFF063B2C)
                              : const Color(0xFFF3EDE4),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: _activeTab == 'popular'
                              ? const <BoxShadow>[
                                  BoxShadow(
                                    color: Color(0x1F000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'Popular Plans',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: _activeTab == 'popular' ? FontWeight.w700 : FontWeight.w500,
                            color: _activeTab == 'popular' ? Colors.white : const Color(0xFF25332E),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _activeTab = 'how'),
                      borderRadius: BorderRadius.circular(100),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _activeTab == 'how'
                              ? const Color(0xFF063B2C)
                              : const Color(0xFFF3EDE4),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: _activeTab == 'how'
                              ? const <BoxShadow>[
                                  BoxShadow(
                                    color: Color(0x1F000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'How It Works',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: _activeTab == 'how' ? FontWeight.w700 : FontWeight.w500,
                            color: _activeTab == 'how' ? Colors.white : const Color(0xFF25332E),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tab Views
              if (_activeTab == 'popular') ...<Widget>[
                if (state.schemes.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    alignment: Alignment.center,
                    child: Column(
                      children: <Widget>[
                        const Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFFC7BCAE)),
                        const SizedBox(height: 12),
                        Text(
                          'No Savings Schemes Active',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0A221C),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Check back soon or contact your branch for exclusive gold kitty enrollment.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: const Color(0xFF756E63),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  for (final SchemeEntity scheme in state.schemes) ...<Widget>[
                    _buildPlanCard(
                      title: scheme.name,
                      monthly: CurrencyFormatter.formatRupees(scheme.monthlyInstallment),
                      total: CurrencyFormatter.formatRupees(scheme.targetAmount),
                      isPopular: scheme.isPopular || state.schemes.indexOf(scheme) == 0,
                      bullets: scheme.benefits.isNotEmpty
                          ? scheme.benefits
                          : <String>[
                              '${scheme.durationMonths} Months Systematic Gold Savings',
                              'Guaranteed Sponsor Bonus at Maturity',
                              'Zero Making Charges on Hallmark Jewellery',
                            ],
                      onSelect: () => context.push(RoutePaths.book, extra: scheme),
                    ),
                    const SizedBox(height: 16),
                  ],
              ] else ...<Widget>[
                // How It Works View
                _buildHowItWorksView(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String monthly,
    required String total,
    required bool isPopular,
    required List<String> bullets,
    required VoidCallback onSelect,
  }) {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Top Row: Thumbnail + Titles + Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Golden Coin Stack Thumbnail
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF2E5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFE2CF)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/gold-coins.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Text('🪙', style: TextStyle(fontSize: 28))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0A221C),
                            ),
                          ),
                        ),
                        if (isPopular) ...<Widget>[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF063B2C),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'Most Popular',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Monthly Investment',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF68726E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                monthly,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF121A16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Total Contribution',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF68726E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                total,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF121A16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Feature Bullets with Warm Gold Dots (#C88A35)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: bullets.map((bullet) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFC88A35),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bullet,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF33423D),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // CTA Pill Button
          InkWell(
            onTap: onSelect,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF063B2C),
                borderRadius: BorderRadius.circular(100),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x1F063B2C),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Select a Plan',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksView() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Text(
            '3 Simple Steps to Pure Gold',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A221C),
            ),
          ),
          const SizedBox(height: 18),

          // Step 1
          _buildStepRow(
            number: '1',
            badgeBg: const Color(0xFFFAF0E1),
            badgeColor: const Color(0xFFA56B12),
            title: 'Choose Duration & Amount',
            desc: 'Select from 6, 9 or 11 month periods starting at just ₹5,000 per month.',
            showDivider: true,
          ),

          // Step 2
          _buildStepRow(
            number: '2',
            badgeBg: const Color(0xFFFAF0E1),
            badgeColor: const Color(0xFFA56B12),
            title: 'Lock In Live Rates',
            desc: 'Each installment buys 22KT/24KT gold at current rates, insulating you from price spikes.',
            showDivider: true,
          ),

          // Step 3
          _buildStepRow(
            number: '3',
            badgeBg: const Color(0xFFEAF5EF),
            badgeColor: const Color(0xFF063B2C),
            title: 'Redeem for Exquisite Jewellery',
            desc: 'Redeem your accumulated gold value across all collections with zero making charge discounts.',
            showDivider: false,
          ),

          const SizedBox(height: 18),

          InkWell(
            onTap: () => setState(() => _activeTab = 'popular'),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF063B2C),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Browse Popular Plans',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String number,
    required Color badgeBg,
    required Color badgeColor,
    required String title,
    required String desc,
    required bool showDivider,
  }) {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: badgeBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0A221C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF68726E),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFF4EFE6)),
          )
        else
          const SizedBox(height: 6),
      ],
    );
  }

}
