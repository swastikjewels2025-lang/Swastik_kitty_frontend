import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../shared/widgets/feedback/kitty_empty_state.dart';
import '../../../../shared/widgets/feedback/kitty_error_state.dart';
import '../../../../shared/widgets/navigation/kitty_hamburger_button.dart';
import '../../../checkout/presentation/screens/checkout_screen.dart';
import '../../../passbook/domain/entities/passbook_entry_entity.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../providers/dashboard_controller.dart';
import '../providers/dashboard_state.dart';
import '../widgets/dashboard_prejoin_banner.dart';
import '../widgets/dashboard_skeleton_loader.dart';

/// Recreated 100% identically from `dddd/scheme.html`.
///
/// Features:
/// - Light App Background: #F8F6F0
/// - Header: Back arrow & "Your Active Plan" (Playfair Display 20px bold #1A2024)
/// - Card 1: Top Main Plan Card (#FFFFFF, rounded 24px, border #EFEAE2)
///   * 3D Stack of Gold Coins Vector Graphic in rounded 16px gradient box
///   * Plan Title ("11 Month Gold Plan") & Plan ID ("SJ360123")
///   * Circular 45% Progress Wheel (70x70) with dark pine progress ring (#063B2C)
///   * Financial Split: Paid ("₹55,000") vs Total Plan ("₹1,20,000")
///   * Lower Inner Panel: Next Instalment Due ("₹5,000" on 5 Oct 2026) & "Pay Now" CTA (#063B2C)
/// - Card 2: Your Plan Details Card (#FFFFFF, rounded 22px, border #EFEAE2)
///   * Golden Icon Rows: Start Date, End Date, Monthly Instalment, Total Plan Amount
/// - Card 3: Your Progress Card (#FFFFFF, rounded 22px, border #EFEAE2)
///   * 11-Month Horizontal Stepper Tracker (Jan to Nov nodes with green checkmarks)
///   * Split stats pills: Instalments Paid (5 / 11) & Instalments Remaining (6)
///   * "View All" button opening All 11 Instalments bottom sheet
/// - Card 4: Upcoming Payment Card (#FFFFFF, rounded 22px, border #EFEAE2)
///   * Mint Inner Container (#EFF7F3) with calendar icon, Next Instalment, and "Pay Now" CTA
/// - Payment Confirmation Modal with Breakdown & Gokwik/Checkout authorization
/// - View All Instalments History Bottom Sheet
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static const Color _appBg = Color(0xFFFAF7F2);
  static const Color _cardBg = Color(0xFFFFFFFF);
  static const Color _cardBorder = Color(0xFFEFE6DB);
  static const Color _darkPine = Color(0xFF063B2C);
  static const Color _goldAccent = Color(0xFFC88A35);
  static const Color _textMain = Color(0xFF0A221C);
  static const Color _textMuted = Color(0xFF68726E);
  static const Color _textSub = Color(0xFF8D969F);
  static const Color _amberBg = Color(0xFFFBF5EB);

  void _openPaymentModal(DashboardSummaryEntity? scheme, int emiAmount, String planTitle) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return _PaymentModalSheet(
          emiAmount: emiAmount,
          planTitle: planTitle,
          onAuthorizePay: () {
            Navigator.of(ctx).pop();
            context.push(
              RoutePaths.checkout,
              extra: CheckoutArgs(
                membershipId: scheme?.membershipId ?? '',
                chitToken: scheme?.chitToken ?? '',
                monthFor: (scheme?.monthsPaid ?? 0) + 1,
                amount: emiAmount,
              ),
            );
          },
        );
      },
    );
  }

  void _openHistoryDrawer(List<_MonthInstallment> months, String planId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return _HistoryModalSheet(months: months, planId: planId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('=============================================');
    debugPrint('>>> DASHBOARD_SCREEN: BUILD METHOD STARTED <<<');
    debugPrint('=============================================');
    final DashboardState state = ref.watch(dashboardControllerProvider);
    final DashboardController controller = ref.read(dashboardControllerProvider.notifier);
    debugPrint('>>> DASHBOARD_SCREEN: state status = ${state.status} <<<');

    // 1. Loading State (Initial fetch)
    if (state.status == DashboardStatus.loading && state.data == null && state.schemes.isEmpty) {
      return const Scaffold(
        backgroundColor: _appBg,
        body: SafeArea(
          child: DashboardSkeletonLoader(),
        ),
      );
    }

    // 2. Error State (Failed with no cached data)
    if (state.status == DashboardStatus.error && state.data == null && state.schemes.isEmpty) {
      return Scaffold(
        backgroundColor: _appBg,
        body: SafeArea(
          child: Center(
            child: KittyErrorState(
              title: 'Unable to Load Scheme Details',
              message: state.errorMessage ??
                  'Unable to load your kitty details. Please check your connection and try again.',
              onRetry: () => controller.loadDashboard(refresh: true),
            ),
          ),
        ),
      );
    }

    // 3. Empty State (Patron has no active enrolled scheme)
    if (state.status == DashboardStatus.empty ||
        (state.status != DashboardStatus.loading &&
            state.data == null &&
            state.schemes.isEmpty &&
            state.selectedScheme == null)) {
      return Scaffold(
        backgroundColor: _appBg,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Row(
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
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: _textMain,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                    Text(
                      'Your Active Plan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _textMain,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const KittyHamburgerButton(isLightSurface: true),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: KittyEmptyState(
                    title: 'No Active Gold Scheme',
                    description:
                        'You do not have any active gold savings schemes. Explore our curated 6, 9, and 11-month plans to start saving today.',
                    actionLabel: 'Explore Gold Plans',
                    onAction: () => context.go(RoutePaths.offers),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final DashboardSummaryEntity? scheme = state.selectedScheme ??
        (state.schemes.isNotEmpty
            ? state.schemes.first
            : state.data);

    // Live backend metrics with fallback
    final int totalCount = scheme?.totalMonths ?? 11;
    final int paidCount = scheme?.monthsPaid ?? 0;
    final double calculatedProgress = totalCount > 0 ? (paidCount / totalCount) * 100.0 : 0.0;
    final double progressPercent = scheme?.progressPercentage != null
        ? scheme!.progressPercentage.toDouble().clamp(0.0, 100.0)
        : calculatedProgress;

    final String paidAmount = scheme?.totalPaidAmount != null
        ? '₹${NumberFormat('#,##,###').format(scheme!.totalPaidAmount)}'
        : '₹0';
    final String targetAmount = scheme?.targetAmount != null
        ? '₹${NumberFormat('#,##,###').format(scheme!.targetAmount)}'
        : '₹0';
    final String planTitle = scheme?.schemeName?.isNotEmpty == true
        ? scheme!.schemeName!
        : 'Gold Savings Plan';
    final String planId = scheme?.membershipId?.isNotEmpty == true
        ? scheme!.membershipId!
        : (scheme?.chitToken ?? '');

    final String startDate = scheme?.startDate != null
        ? DateFormat('d MMM yyyy').format(scheme!.startDate!)
        : (scheme != null && scheme.passbook.isNotEmpty && scheme.passbook.first.dueDate != null
            ? DateFormat('d MMM yyyy').format(scheme.passbook.first.dueDate!)
            : DateFormat('d MMM yyyy').format(DateTime.now()));

    final String endDate = scheme?.endDate != null
        ? DateFormat('d MMM yyyy').format(scheme!.endDate!)
        : (scheme != null && scheme.passbook.isNotEmpty && scheme.passbook.last.dueDate != null
            ? DateFormat('d MMM yyyy').format(scheme.passbook.last.dueDate!)
            : DateFormat('d MMM yyyy').format(DateTime.now().add(Duration(days: 30 * totalCount))));

    final int emiAmount = scheme?.nextInstallment?.amount ?? scheme?.customMonthlyEmi ?? 5000;
    final String monthlyAmountStr = '₹${NumberFormat('#,##,###').format(emiAmount)}';

    final String nextDueDate = scheme?.nextInstallment?.dueDate != null
        ? DateFormat('d MMM yyyy').format(scheme!.nextInstallment!.dueDate)
        : (scheme != null && scheme.passbook.isNotEmpty && paidCount < scheme.passbook.length && scheme.passbook[paidCount].dueDate != null
            ? DateFormat('d MMM yyyy').format(scheme.passbook[paidCount].dueDate!)
            : DateFormat('d MMM yyyy').format(DateTime.now().add(const Duration(days: 30))));

    final List<_MonthInstallment> displayMonths;
    if (scheme != null && scheme.passbook.isNotEmpty) {
      displayMonths = scheme.passbook.take(totalCount).map<_MonthInstallment>((PassbookEntryEntity p) {
        final String name = p.monthName ??
            (p.dueDate != null
                ? DateFormat('MMM').format(p.dueDate!)
                : (p.paidAt != null ? DateFormat('MMM').format(p.paidAt!) : 'M${p.month}'));
        final String dateStr = p.paidAt != null
            ? DateFormat('d MMM yyyy').format(p.paidAt!)
            : (p.dueDate != null ? DateFormat('d MMM yyyy').format(p.dueDate!) : 'Month ${p.month}');
        final String amtStr = '₹${NumberFormat('#,##,###').format(p.amount > 0 ? p.amount : emiAmount)}';
        return _MonthInstallment(
          name: name,
          isPaid: p.isPaid,
          date: dateStr,
          amount: amtStr,
          txnId: p.transactionId,
        );
      }).toList();
    } else {
      final DateTime baseDate = scheme?.startDate ?? DateTime.now();
      displayMonths = List<_MonthInstallment>.generate(totalCount, (int index) {
        final DateTime mDate = DateTime(baseDate.year, baseDate.month + index, baseDate.day);
        final String name = DateFormat('MMM').format(mDate);
        final String dateStr = DateFormat('d MMM yyyy').format(mDate);
        final bool isPaid = index < paidCount;
        return _MonthInstallment(
          name: name,
          isPaid: isPaid,
          date: dateStr,
          amount: monthlyAmountStr,
          txnId: null,
        );
      });
    }

    return Scaffold(
      backgroundColor: _appBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.loadDashboard(refresh: true),
          color: _darkPine,
          backgroundColor: Colors.white,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            children: <Widget>[
              // -------------------------------------------------------------
              // SCREEN HEADER (scheme.html line 106)
              // -------------------------------------------------------------
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
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: _textMain,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  Text(
                    'Your Active Plan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _textMain,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const KittyHamburgerButton(isLightSurface: true),
                ],
              ),

              const SizedBox(height: 16),

              if (scheme?.isPreJoin == true) ...<Widget>[
                const DashboardPrejoinBanner(),
                const SizedBox(height: 16),
              ],

              // 1. TOP MAIN PLAN CARD (scheme.html line 123)
              _buildTopPlanCard(
                planTitle: planTitle,
                planId: planId,
                progressPercent: progressPercent,
                paidAmount: paidAmount,
                targetAmount: targetAmount,
                monthlyAmountStr: monthlyAmountStr,
                nextDueDate: nextDueDate,
                onPayNow: () => _openPaymentModal(scheme, emiAmount, planTitle),
              ),

              const SizedBox(height: 16),

              // 2. YOUR PLAN DETAILS CARD (scheme.html line 253)
              _buildPlanDetailsCard(
                startDate: startDate,
                endDate: endDate,
                monthlyAmountStr: monthlyAmountStr,
                targetAmount: targetAmount,
              ),

              const SizedBox(height: 16),

              // 3. YOUR PROGRESS CARD (scheme.html line 334)
              _buildProgressCard(
                paidCount: paidCount,
                totalCount: totalCount,
                months: displayMonths,
                onViewAll: () => _openHistoryDrawer(displayMonths, planId),
              ),

              const SizedBox(height: 16),

              // 4. UPCOMING PAYMENT CARD (scheme.html line 372)
              _buildUpcomingPaymentCard(
                monthlyAmountStr: monthlyAmountStr,
                nextDueDate: nextDueDate,
                onPayNow: () => _openPaymentModal(scheme, emiAmount, planTitle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. TOP MAIN PLAN CARD
  // ---------------------------------------------------------------------------
  Widget _buildTopPlanCard({
    required String planTitle,
    required String planId,
    required double progressPercent,
    required String paidAmount,
    required String targetAmount,
    required String monthlyAmountStr,
    required String nextDueDate,
    required VoidCallback onPayNow,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _cardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          // Upper part of card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Left: 3D Stack of Gold Coins Vector Graphic in rounded 16px gradient box
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Color(0xFFFBF3E4),
                            Color(0xFFF1DFC0),
                          ],
                        ),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/images/swastik/kitty_coins_exact.png',
                        fit: BoxFit.contain,
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => const Icon(
                          Icons.monetization_on_rounded,
                          size: 36,
                          color: Color(0xFFC88A35),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Plan Title & ID
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            planTitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: _textMain,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Plan ID: $planId',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right: Circular Progress Wheel (70x70)
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              value: (progressPercent / 100.0).clamp(0.0, 1.0),
                              backgroundColor: const Color(0xFFEFE5D5),
                              valueColor: const AlwaysStoppedAnimation<Color>(_darkPine),
                              strokeWidth: 7,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Text(
                            '${progressPercent.toInt()}%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _textMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Financial Split: Paid vs Total Plan
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Paid',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              paidAmount,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _textMain,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 38,
                        width: 1,
                        color: const Color(0xFFECE6DE),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Total Plan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              targetAmount,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _textMain,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lower Inner Panel: Next Instalment Due & Pay Now CTA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFFAF7F2),
              border: Border(
                top: BorderSide(color: Color(0xFFF2ECE2)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Next Instalment',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          monthlyAmountStr,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _textMain,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Due on $nextDueDate',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                ElevatedButton(
                  onPressed: onPayNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkPine,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Pay Now',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. YOUR PLAN DETAILS CARD
  // ---------------------------------------------------------------------------
  Widget _buildPlanDetailsCard({
    required String startDate,
    required String endDate,
    required String monthlyAmountStr,
    required String targetAmount,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Your Plan Details',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textMain,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),

          _buildDetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Start Date',
            value: startDate,
          ),
          const Divider(color: Color(0xFFF4EFE7), height: 16),

          _buildDetailRow(
            icon: Icons.event_available_rounded,
            label: 'End Date',
            value: endDate,
          ),
          const Divider(color: Color(0xFFF4EFE7), height: 16),

          _buildDetailRow(
            icon: Icons.monetization_on_outlined,
            label: 'Monthly Instalment',
            value: monthlyAmountStr,
          ),
          const Divider(color: Color(0xFFF4EFE7), height: 16),

          _buildDetailRow(
            icon: Icons.adjust_rounded,
            label: 'Total Plan Amount',
            value: targetAmount,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFAF5EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(icon, size: 16, color: _goldAccent),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: _textMuted,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: _textMain,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. YOUR PROGRESS CARD (11-Month Horizontal Stepper)
  // ---------------------------------------------------------------------------
  Widget _buildProgressCard({
    required int paidCount,
    required int totalCount,
    required List<_MonthInstallment> months,
    required VoidCallback onViewAll,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header with "View All" action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Your Progress',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textMain,
                  letterSpacing: -0.2,
                ),
              ),
              InkWell(
                onTap: onViewAll,
                child: Text(
                  'View All',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _darkPine,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Horizontal Stepper Tracker
          SizedBox(
            height: 56,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double totalWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 340.0;
                final double nodeWidth = totalCount > 0 ? (totalWidth / totalCount) : totalWidth;
                final double progressWidth = (totalCount > 1 && paidCount > 1)
                    ? (((paidCount - 1) / (totalCount - 1)).clamp(0.0, 1.0) * (totalWidth - nodeWidth))
                    : 0.0;

                return SizedBox(
                  width: totalWidth,
                  height: 56,
                  child: Stack(
                    children: <Widget>[
                      // Inactive Background Line
                      Positioned(
                        top: 9,
                        left: nodeWidth / 2,
                        right: nodeWidth / 2,
                        height: 2,
                        child: Container(
                          color: const Color(0xFFE9E1D5),
                        ),
                      ),

                      // Active Green Segment Line
                      if (paidCount > 1 && progressWidth > 0)
                        Positioned(
                          top: 9,
                          left: nodeWidth / 2,
                          width: progressWidth,
                          height: 2,
                          child: Container(
                            color: _darkPine,
                          ),
                        ),

                      // Month Nodes
                      SizedBox(
                        width: totalWidth,
                        child: Row(
                          children: months.map((_MonthInstallment m) {
                            return Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  if (m.isPaid)
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                        color: _darkPine,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.check_rounded,
                                          size: 11,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFD8CEBF),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      m.name,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: m.isPaid ? _textMain : _textSub,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Stats Counter Split Cards
          Row(
            children: <Widget>[
              // Paid Pill
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xCCECF6F1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDCEDE3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$paidCount / $totalCount',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _darkPine,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Instalments Paid',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4E7667),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Remaining Pill
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _amberBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF2E5D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${totalCount - paidCount}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9E641B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Instalments Remaining',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF937553),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. UPCOMING PAYMENT CARD
  // ---------------------------------------------------------------------------
  Widget _buildUpcomingPaymentCard({
    required String monthlyAmountStr,
    required String nextDueDate,
    required VoidCallback onPayNow,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Upcoming Payment',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textMain,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),

          // Mint Tint Inner Container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF7F3),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFDCEEE3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDF1E6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.calendar_month_rounded,
                            size: 20,
                            color: _darkPine,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Next Instalment',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _textMuted,
                              ),
                            ),
                            Text(
                              monthlyAmountStr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _textMain,
                              ),
                            ),
                            Text(
                              'Due on $nextDueDate',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onPayNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkPine,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Pay Now',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MONTH MODEL
// -----------------------------------------------------------------------------
class _MonthInstallment {
  const _MonthInstallment({
    required this.name,
    required this.isPaid,
    required this.date,
    required this.amount,
    this.txnId,
  });

  final String name;
  final bool isPaid;
  final String date;
  final String amount;
  final String? txnId;
}



// -----------------------------------------------------------------------------
// PAYMENT CONFIRMATION MODAL BOTTOM SHEET (scheme.html line 413)
// -----------------------------------------------------------------------------
class _PaymentModalSheet extends StatelessWidget {
  const _PaymentModalSheet({
    required this.emiAmount,
    required this.planTitle,
    required this.onAuthorizePay,
  });

  final int emiAmount;
  final String planTitle;
  final VoidCallback onAuthorizePay;

  @override
  Widget build(BuildContext context) {
    final String formattedAmount = NumberFormat('#,##,###.00').format(emiAmount);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header with Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Confirm Payment',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A2024),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF67717A)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            const Divider(color: Color(0xFFF0EBE1), height: 16),

            const SizedBox(height: 8),

            // Amount Display
            Text(
              'Instalment Amount',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF67717A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '₹$formattedAmount',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A2024),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF5EB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Month 6 of 11 • June 2026',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9E641B),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Details card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF0EBE1)),
              ),
              child: Column(
                children: <Widget>[
                  _buildModalRow('Gold Plan', planTitle),
                  const SizedBox(height: 8),
                  _buildModalRow('Payment Method', 'UPI / NetBanking'),
                  const SizedBox(height: 8),
                  _buildModalRow('Convenience Fee', '₹0 (Free)', isFree: true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Authorize & Pay Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onAuthorizePay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF063B2C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Authorize & Pay ₹${NumberFormat('#,##,###').format(emiAmount)}',
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
      ),
    );
  }

  Widget _buildModalRow(String label, String value, {bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            color: const Color(0xFF67717A),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isFree ? const Color(0xFF047857) : const Color(0xFF1A2024),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// ALL INSTALMENTS HISTORY BOTTOM SHEET (scheme.html line 459)
// -----------------------------------------------------------------------------
class _HistoryModalSheet extends StatelessWidget {
  const _HistoryModalSheet({
    required this.months,
    this.planId = '',
  });

  final List<_MonthInstallment> months;
  final String planId;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.78,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'All ${months.length} Instalments',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A2024),
                        ),
                      ),
                      if (planId.isNotEmpty)
                        Text(
                          'Plan ID: $planId',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF67717A),
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF67717A)),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFF0EBE1), height: 1),

            // Scrollable List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: months.length,
                separatorBuilder: (BuildContext _, int index) => const SizedBox(height: 8),
                itemBuilder: (BuildContext context, int index) {
                  final _MonthInstallment m = months[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF0EBE1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: m.isPaid
                                    ? const Color(0xFFECF6F1)
                                    : const Color(0xFFEAE4DC),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: m.isPaid
                                        ? const Color(0xFF063B2C)
                                        : const Color(0xFF8D969F),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${m.name} Instalment',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A2024),
                                  ),
                                ),
                                Text(
                                  m.date,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: const Color(0xFF67717A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              m.amount,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A2024),
                              ),
                            ),
                            Text(
                              m.isPaid ? 'Completed' : 'Upcoming',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: m.isPaid
                                    ? const Color(0xFF047857)
                                    : const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Close CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A2024),
                    side: const BorderSide(color: Color(0xFFEFEAE2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
