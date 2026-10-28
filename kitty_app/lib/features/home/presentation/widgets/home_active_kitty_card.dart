import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/progress/kitty_circular_progress_gauge.dart';
import '../../../dashboard/domain/entities/dashboard_summary_entity.dart';

/// Luxury Kitty-First Card on Home showcasing the patron's active Kitty savings scheme.
///
/// Features:
/// - Prominent Kitty Number & Status Badge
/// - Scheme Title and Months Deposited fraction
/// - Circular Progress Gauge with smooth animated track
/// - Prominent Next Payment Due Info Box (Amount & Due Date)
/// - Primary Action CTA: [PAY ₹X,XXX NOW] when due, or [VIEW SAVINGS HISTORY]
/// - Secondary Link to Passbook Savings History
class HomeActiveKittyCard extends StatelessWidget {
  const HomeActiveKittyCard({
    super.key,
    required this.dashboard,
    required this.onPayTap,
    required this.onSavingsHistoryTap,
    this.onCardTap,
  });

  final DashboardSummaryEntity dashboard;
  final VoidCallback onPayTap;
  final VoidCallback onSavingsHistoryTap;
  final VoidCallback? onCardTap;

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final int monthsPaid = dashboard.monthsPaid ?? 0;
    final int totalMonths = dashboard.totalMonths ?? 12;
    final bool isCompleted = dashboard.isCompleted;
    final NextInstallmentEntity? nextInstallment = dashboard.nextInstallment;
    final bool isPaymentDue = !isCompleted && nextInstallment != null;

    final int dueAmount = nextInstallment?.amount ?? dashboard.customMonthlyEmi ?? 5000;
    final String formattedAmount = _currencyFormat.format(dueAmount);

    final String formattedDueDate = nextInstallment != null
        ? DateFormat('dd MMM yyyy').format(nextInstallment.dueDate)
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEFEAE0),
          width: 1.0,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onCardTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Top Row: Thumbnail + Title + Circular Progress
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // 44x44 Plan Thumbnail
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF4EB),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: const Color(0xFFEDE2D0),
                          width: 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/gold-coins.jpg',
                        fit: BoxFit.contain,
                        errorBuilder: (BuildContext _, Object _, StackTrace? _) => const Icon(
                          Icons.monetization_on_rounded,
                          color: Color(0xFFC88A35),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),

                    // Plan Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            dashboard.schemeName ?? 'Swastik Suvarna Varsha',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1C2420),
                              letterSpacing: -0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: <Widget>[
                              Text(
                                'Plan ID: ${dashboard.chitToken ?? "-"}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF7D786F),
                                ),
                              ),
                              if (isPaymentDue) ...<Widget>[
                                const SizedBox(width: 4),
                                const Text(
                                  '•',
                                  style: TextStyle(fontSize: 10, color: Color(0xFF7D786F)),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'PAYMENT DUE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFB71C1C),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Circular Progress Ring (44x44)
                    KittyCircularProgressGauge(
                      currentValue: monthsPaid,
                      totalValue: totalMonths,
                      size: 44,
                      strokeWidth: 4,
                      showPercentageInCenter: true,
                      isDarkSurface: false,
                    ),
                  ],
                ),

                // Middle Row: Metrics (Paid vs Total Plan)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.only(top: 9),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFFF6F2E9),
                        width: 1,
                      ),
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
                              dashboard.totalPaidAmount != null
                                  ? _currencyFormat.format(dashboard.totalPaidAmount)
                                  : _currencyFormat.format(monthsPaid * dueAmount),
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
                              dashboard.targetAmount != null
                                  ? _currencyFormat.format(dashboard.targetAmount)
                                  : _currencyFormat.format(totalMonths * dueAmount),
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
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      // Installment Info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'NEXT PAYMENT',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF7D786F),
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: <Widget>[
                              Text(
                                formattedAmount,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1C2420),
                                ),
                              ),
                              if (formattedDueDate.isNotEmpty) ...<Widget>[
                                const SizedBox(width: 4),
                                Text(
                                  'Due on $formattedDueDate',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF7D786F),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),

                      // Pay Now CTA Button (.pay-now-btn)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isPaymentDue ? onPayTap : onSavingsHistoryTap,
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  Color(0xFF053826),
                                  Color(0xFF0A4E36),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: Color(0x40053826),
                                  blurRadius: 7,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              isPaymentDue ? 'PAY NOW' : 'VIEW HISTORY',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Secondary View Savings History Link
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: InkWell(
                      onTap: onSavingsHistoryTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'View Savings History',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0A6B48),
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 14,
                              color: Color(0xFF0A6B48),
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
      ),
    );
  }
}
