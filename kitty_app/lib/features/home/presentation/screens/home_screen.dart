import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../../shared/widgets/feedback/kitty_error_state.dart';
import '../../../checkout/presentation/screens/checkout_screen.dart';
import '../../../dashboard/domain/entities/dashboard_summary_entity.dart';
import '../../../dashboard/presentation/providers/dashboard_controller.dart';
import '../../../dashboard/presentation/providers/dashboard_state.dart';
import '../providers/home_controller.dart';
import '../providers/home_state.dart';
import '../widgets/home_skeleton_loader.dart';

/// Rebuilt Home Screen matching DDDD specifications from `dddd/index.html`.
///
/// Complete Visual Source of Truth:
/// 1. Emerald Header (`.app-header`):
///    - Top Greeting Row: "Good Morning", "Mahak 👋" + Notification Bell
///    - Today's Gold Price Card (22KT) with gold bar visual & trend badge
/// 2. Ivory Body Canvas (`.app-body`):
///    - Quick Actions (Gold Plans, Pay Installment, Explore Jewellery, Instagram)
///    - Your Active Plan Card (Thumbnail, Plan ID, Circular Progress 45%, Paid/Total, Next Installment, Pay Now button)
///    - Gold Schemes (6M Popular, 9M, 11M with Select buttons)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomeState homeState = ref.watch(homeControllerProvider);
    final DashboardState dashboardState = ref.watch(dashboardControllerProvider);
    final AppAuthState auth = ref.watch(appAuthStateProvider);

    // Show floating error notification if pull-to-refresh fails while data is already loaded
    ref.listen<HomeState>(homeControllerProvider, (previous, next) {
      if (next.status == HomeStatus.loaded &&
          next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.statusErrorText,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    if (homeState.isLoading && homeState.data == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAF7F2),
        body: SafeArea(child: HomeSkeletonLoader()),
      );
    }

    if (homeState.isError && homeState.data == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF7F2),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space24),
            child: KittyErrorState(
              title: 'Unable to Load Home',
              message: homeState.errorMessage ??
                  'Unable to load your kitty details and catalog. Please check your internet connection.',
              retryLabel: 'Try Again',
              isDarkSurface: false,
              onRetry: () {
                ref.read(homeControllerProvider.notifier).loadHomeData();
                ref.read(dashboardControllerProvider.notifier).loadDashboard();
              },
            ),
          ),
        ),
      );
    }

    final data = homeState.data;
    final DashboardSummaryEntity? activeKitty = (dashboardState.data?.hasActiveScheme == true)
        ? (dashboardState.selectedScheme ?? dashboardState.data)
        : data?.activeKitty;

    // Resolve user display name
    final String greetingName = (auth.userName.isNotEmpty &&
            auth.userName != 'Patron' &&
            auth.userName != 'Rihan' &&
            auth.userName != 'Mahak')
        ? auth.userName
        : 'Patron';

    // Resolve gold rate for 22KT
    final double gold22kRate = data?.goldRate?.effectiveRate22k ?? 7485.0;
    final String gold22kFormatted = NumberFormat('#,##0', 'en_IN').format(gold22kRate.round());

    // Resolve active plan metrics
    final bool hasActiveKitty = (activeKitty != null &&
        activeKitty.hasActiveScheme &&
        (activeKitty.targetAmount ?? 0) > 0);
    final int paidAmount = activeKitty?.totalPaidAmount ?? 0;
    final int totalPlanAmount = activeKitty?.targetAmount ?? 0;
    final int installmentAmount = activeKitty?.nextInstallment?.amount ?? activeKitty?.customMonthlyEmi ?? 5000;
    final double progressFraction = totalPlanAmount > 0
        ? (paidAmount / totalPlanAmount).clamp(0.0, 1.0)
        : 0.0;
    final int progressPercent = (progressFraction * 100).round();
    final String planTitle = activeKitty?.schemeName ?? 'Gold Kitty Scheme';
    final String planId = activeKitty?.chitToken ?? '-';
    final String nextDueText = activeKitty?.nextInstallment?.dueDate != null
        ? DateFormat('d MMM yyyy').format(activeKitty!.nextInstallment!.dueDate)
        : 'Upcoming';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: RefreshIndicator(
        color: const Color(0xFF063B2C),
        backgroundColor: const Color(0xFFFAF7F2),
        onRefresh: () async {
          await Future.wait<void>(<Future<void>>[
            ref.read(homeControllerProvider.notifier).refresh(),
            ref.read(dashboardControllerProvider.notifier).loadDashboard(refresh: true),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            children: <Widget>[
              // ===============================================================
              // 1. EMERALD APP HEADER (.app-header)
              // ===============================================================
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.7, -0.6),
                    radius: 1.2,
                    colors: <Color>[
                      Color(0xFF0A4A34),
                      Color(0xFF053826),
                      Color(0xFF02261A),
                    ],
                    stops: <double>[0.0, 0.5, 1.0],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Column(
                      children: <Widget>[
                        // Top Greeting Row (.greeting-row)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Good Morning',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFA3C5B5),
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      greetingName,
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFFFFFFF),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '👋',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Notification Bell Button (.notification-btn)
                            InkWell(
                              onTap: () => context.push(RoutePaths.notifications),
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.08),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/bell.svg',
                                    width: 22,
                                    height: 22,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Today's Gold Price Card (.gold-rate-card)
                        InkWell(
                          onTap: () => context.push(RoutePaths.liveRates),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 106,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                begin: Alignment(-0.8, -0.6),
                                end: Alignment(0.9, 0.7),
                                colors: <Color>[
                                  Color(0xFFFAF4E9),
                                  Color(0xFFF4E8D3),
                                  Color(0xFFEBD5B6),
                                ],
                                stops: <double>[0.0, 0.45, 1.0],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 1.0,
                              ),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: Color(0x24000000),
                                  blurRadius: 14,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: <Widget>[
                                // Gold bar visual on right
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  bottom: 0,
                                  width: 128,
                                  child: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: <Color>[
                                          Colors.transparent,
                                          Colors.black,
                                        ],
                                        stops: <double>[0.0, 0.25],
                                      ).createShader(bounds);
                                    },
                                    blendMode: BlendMode.dstIn,
                                    child: Image.asset(
                                      'assets/images/gold-bar.jpg',
                                      fit: BoxFit.cover,
                                      alignment: const Alignment(0.0, -0.4),
                                      errorBuilder: (context, error, stackTrace) =>
                                          const SizedBox.shrink(),
                                    ),
                                  ),
                                ),

                                // Content details on left (.gold-card-details)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(13, 12, 0, 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "Today's Gold Price (22KT)",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF5C5549),
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: <Widget>[
                                          const Text(
                                            '₹',
                                            style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF141715),
                                            ),
                                          ),
                                          Text(
                                            gold22kFormatted,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 21,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF141715),
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          Text(
                                            ' / gm',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF58534B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          const Text(
                                            '▲ ',
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: Color(0xFF0E7B50),
                                            ),
                                          ),
                                          Text(
                                            '+120 (3.9%)',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF0E7B50),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ===============================================================
              // 2. MAIN APP BODY CANVAS (.app-body)
              // ===============================================================
              Transform.translate(
                offset: const Offset(0, -8),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAF7F2),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Quick Action Icons Row (.quick-actions)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _buildQuickActionItem(
                            label: 'Gold Plans',
                            iconSvg: 'assets/icons/gold-plans.svg',
                            onTap: () => context.go(RoutePaths.offers),
                          ),
                          _buildQuickActionItem(
                            label: 'Pay\nInstallment',
                            iconSvg: 'assets/icons/pay-installment.svg',
                            onTap: () {
                              if (hasActiveKitty) {
                                context.push(
                                  RoutePaths.checkout,
                                  extra: CheckoutArgs(
                                    membershipId: activeKitty.membershipId ?? '',
                                    chitToken: activeKitty.chitToken ?? '',
                                    monthFor: activeKitty.nextInstallment?.month ?? 1,
                                    amount: installmentAmount,
                                  ),
                                );
                              } else {
                                context.go(RoutePaths.offers);
                              }
                            },
                          ),
                          _buildQuickActionItem(
                            label: 'Explore\nJewellery',
                            iconSvg: 'assets/icons/explore-jewellery.svg',
                            onTap: () => UrlLauncherHelper.launchJewelleryCatalog(context),
                          ),
                          _buildQuickActionItem(
                            label: 'Instagram',
                            iconSvg: 'assets/icons/instagram.svg',
                            onTap: () => UrlLauncherHelper.launchInstagram(context),
                          ),
                        ],
                      ),

                      // Doorstep Cash Pickup Quick Strip
                      InkWell(
                        onTap: () => context.push(RoutePaths.cashPickup),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          margin: const EdgeInsets.only(top: 14),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFEADBCA)),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x08000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.local_shipping_outlined,
                                  color: Color(0xFF063B2C),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          'Free Doorstep Cash Pickup',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF141715),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'AVAILABLE',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFFB45309),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Schedule cash installment collection from your home',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF9CA3AF),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Section: Your Active Plan (.active-plan-section)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Your Active Plan',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1C2420),
                              letterSpacing: -0.1,
                            ),
                          ),
                          InkWell(
                            onTap: () => context.go(RoutePaths.dashboard),
                            child: Text(
                              'View All',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0A6B48),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Active Plan Card (.plan-card)
                      if (hasActiveKitty)
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEFEAE0)),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x08000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            // Top Row: Thumbnail + Title + Circular Progress Ring
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAF4EB),
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(color: const Color(0xFFEDE2D0)),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.asset(
                                    'assets/images/gold-coins.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Center(child: Text('🪙')),
                                  ),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        planTitle,
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1C2420),
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        'Plan ID: $planId',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF7D786F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Circular Progress Ring 44x44
                                SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      CircularProgressIndicator(
                                        value: progressFraction,
                                        strokeWidth: 4,
                                        backgroundColor: const Color(0xFFEFE2CF),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF084E37)),
                                      ),
                                      Text(
                                        '$progressPercent%',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1C2420),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Middle Row: Paid vs Total Plan
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.only(top: 9),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Color(0xFFF6F2E9)),
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Paid',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF7D786F),
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          CurrencyFormatter.formatRupees(paidAmount),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1C2420),
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Total Plan',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF7D786F),
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          CurrencyFormatter.formatRupees(totalPlanAmount),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1C2420),
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Bottom Row: Next Installment & Pay Now Button
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Next Installment',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF7D786F),
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            CurrencyFormatter.formatRupees(installmentAmount),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF1C2420),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Due on $nextDueText',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF7D786F),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      context.push(
                                        RoutePaths.checkout,
                                        extra: CheckoutArgs(
                                          membershipId: activeKitty.membershipId ?? '',
                                          chitToken: activeKitty.chitToken ?? '',
                                          monthFor: activeKitty.nextInstallment?.month ?? 1,
                                          amount: installmentAmount,
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        gradient: const LinearGradient(
                                          colors: <Color>[
                                            Color(0xFF053826),
                                            Color(0xFF0A4E36),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: const <BoxShadow>[
                                          BoxShadow(
                                            color: Color(0x33053826),
                                            blurRadius: 7,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'Pay Now',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!hasActiveKitty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFEFEAE0)),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x08000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBF5EB),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFEDE2D0)),
                                ),
                                child: const Icon(
                                  Icons.stars_rounded,
                                  color: Color(0xFFC88A35),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Start Your Gold Kitty',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1C2420),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Accumulate 24K gold with 1-month bonus from Swastik.',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: const Color(0xFF7D786F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => context.go(RoutePaths.offers),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: <Color>[Color(0xFF053826), Color(0xFF03281B)],
                                    ),
                                  ),
                                  child: Text(
                                    'Join Plan',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 18),

                      // Section: Gold Schemes (.gold-schemes-section)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Gold Schemes',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1C2420),
                              letterSpacing: -0.1,
                            ),
                          ),
                          InkWell(
                            onTap: () => context.go(RoutePaths.offers),
                            child: Text(
                              'View All',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0A6B48),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 11),

                      // Schemes List (6M, 9M, 11M)
                      _buildSchemeCard(
                        context,
                        monthsText: '6M',
                        title: '6 Month Plan',
                        subtitle: '₹5,000 / mo • Total ₹30,000',
                        isPopular: true,
                        onSelect: () => context.go(RoutePaths.offers),
                      ),
                      const SizedBox(height: 11),
                      _buildSchemeCard(
                        context,
                        monthsText: '9M',
                        title: '9 Month Plan',
                        subtitle: '₹5,000 / mo • Total ₹45,000',
                        isPopular: false,
                        onSelect: () => context.go(RoutePaths.offers),
                      ),
                      const SizedBox(height: 11),
                      _buildSchemeCard(
                        context,
                        monthsText: '11M',
                        title: '11 Month Plan',
                        subtitle: '₹5,000 / mo • Total ₹55,000',
                        isPopular: false,
                        onSelect: () => context.go(RoutePaths.offers),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required String label,
    required String iconSvg,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF7EFE3),
                border: Border.all(color: const Color(0xFFEADBCA)),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x14B4966E),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconSvg,
                  width: 22,
                  height: 22,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF38322B),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemeCard(
    BuildContext context, {
    required String monthsText,
    required String title,
    required String subtitle,
    required bool isPopular,
    required VoidCallback onSelect,
  }) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFECE4D8)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF2E5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEFE2CF)),
                  ),
                  child: Center(
                    child: Text(
                      monthsText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9C5F05),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF121A16),
                          ),
                        ),
                        if (isPopular) ...<Widget>[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF063B2C),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Popular',
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: const Color(0xFF68726E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF063B2C),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Select',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
