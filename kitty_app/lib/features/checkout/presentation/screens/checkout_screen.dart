import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../dashboard/presentation/providers/dashboard_controller.dart';
import '../providers/payment_controller.dart';
import '../providers/payment_state.dart';

/// Arguments optionally passed to `/checkout` route.
class CheckoutArgs {
  const CheckoutArgs({
    required this.membershipId,
    required this.chitToken,
    required this.monthFor,
    required this.amount,
    this.planTitle,
    this.slotsCount,
  });

  final String membershipId;
  final String chitToken;
  final int monthFor;
  final int amount;
  final String? planTitle;
  final int? slotsCount;
}

/// Recreated 100% identically from dddd/payment.html
/// Features:
/// - Light cream background #FAF7F0
/// - Header with back arrow & "Make Payment" (Playfair Display 21px bold)
/// - Plan Summary Card with 3D coin stack icon, plan title, ID, amount and due date
/// - Payment Methods list:
///   1. UPI (Recommended) with mini GPay, PhonePe, Paytm, BHIM badges
///   2. Scan UPI QR with "Scan & Pay" badge
///   3. Debit / Credit Card with VISA, Mastercard, RuPay badges
///   4. Net Banking
///   5. Wallets
///   6. Pick Cash (Doorstep Collection)
/// - 100% Secure Payment shield badge
/// - Fixed bottom button with dynamic label
/// - Interactive QR Code Modal with UPI ID copy action
/// - Payment Processing & Success Modal
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({
    super.key,
    this.args,
  });

  final CheckoutArgs? args;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedMethod = 'upi';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.args != null) {
        ref.read(paymentControllerProvider.notifier).setInstallmentContext(
              membershipId: widget.args!.membershipId,
              chitToken: widget.args!.chitToken,
              monthFor: widget.args!.monthFor,
              amount: widget.args!.amount,
            );
      } else {
        try {
          final dashboard = ref.read(dashboardControllerProvider);
          if (dashboard.isLoaded && dashboard.data != null) {
            final data = dashboard.data!;
            final next = data.nextInstallment;
            final int month = next?.month ?? ((data.monthsPaid ?? 8) + 1);
            final int amount = next?.amount ?? (data.customMonthlyEmi ?? 5000);
            ref.read(paymentControllerProvider.notifier).setInstallmentContext(
                  membershipId: data.membershipId ?? 'mem_994411',
                  chitToken: data.chitToken ?? '#SW-042',
                  monthFor: month,
                  amount: amount,
                );
          }
        } catch (_) {}
      }
    });
  }

  void _showQrModal(int amount) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Close button row
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ),

              // Title
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.qr_code_2_rounded, color: Color(0xFF187A64), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'SCAN UPI QR TO PAY',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: Color(0xFF187A64),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '₹${NumberFormat('#,##,###').format(amount)}',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1917),
                ),
              ),
              Text(
                '${widget.args?.planTitle ?? "Gold Kitty Plan"} (${widget.args?.chitToken ?? widget.args?.membershipId ?? "SJG00123"})',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11.5,
                  color: Color(0xFF78716C),
                ),
              ),
              const SizedBox(height: 14),

              // QR Code Frame
              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x33063B2C), width: 2),
                ),
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.qr_code_2_rounded,
                      size: 150,
                      color: Color(0xFF063B2C),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Supported Apps Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildAppBadge('GPay', const Color(0xFFF5F5F4), const Color(0xFF44403C)),
                  const SizedBox(width: 6),
                  _buildAppBadge('PhonePe', const Color(0xFFF3E8FF), const Color(0xFF6739B7)),
                  const SizedBox(width: 6),
                  _buildAppBadge('Paytm', const Color(0xFFE0F2FE), const Color(0xFF002E6E)),
                  const SizedBox(width: 6),
                  _buildAppBadge('BHIM', const Color(0xFFFEF3C7), const Color(0xFF92400E)),
                ],
              ),

              const SizedBox(height: 12),

              // UPI ID Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE7E5E4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'UPI ID: shreejewellers@icici',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF44403C),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(const ClipboardData(text: 'shreejewellers@icici'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('UPI ID copied to clipboard'),
                            backgroundColor: Color(0xFF063B2C),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text(
                        'Copy',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF187A64),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Confirm CTA Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _triggerPaymentSuccess();
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text('I Have Paid ₹${NumberFormat('#,##,###').format(amount)}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF063B2C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildAppBadge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textCol,
        ),
      ),
    );
  }

  void _triggerPaymentSuccess() {
    setState(() {
      _isProcessing = true;
    });

    final PaymentState paymentState = ref.read(paymentControllerProvider);
    final int amount = widget.args?.amount ?? paymentState.amount;
    final String formattedAmount = '₹${NumberFormat('#,##,###').format(amount)}';
    final DateTime nextDate = DateTime.now().add(const Duration(days: 30));
    final String nextDueDate = DateFormat('d MMM yyyy').format(nextDate);
    final String planTitle = widget.args?.planTitle ?? 'Gold Kitty Plan';

    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        context.go(
          RoutePaths.authSuccess,
          extra: <String, dynamic>{
            'planTitle': planTitle,
            'amount': formattedAmount,
            'nextDueDate': nextDueDate,
          },
        );
      }
    });
  }

  void _handlePayAction(int amount) {
    if (_selectedMethod == 'cash') {
      context.push(
        RoutePaths.cashPickup,
        extra: widget.args ??
            CheckoutArgs(
              membershipId: '',
              chitToken: '',
              monthFor: 1,
              amount: amount,
            ),
      );
      return;
    }

    if (_selectedMethod == 'qr') {
      _showQrModal(amount);
      return;
    }

    _triggerPaymentSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final PaymentState paymentState = ref.watch(paymentControllerProvider);
    final int amount = widget.args?.amount ?? paymentState.amount;
    final String formattedAmount = '₹${NumberFormat('#,##,###').format(amount)}';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                // Top Header
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 16, top: 8, bottom: 4),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(RoutePaths.dashboard);
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF1C1917),
                          size: 24,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Make Payment',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1C1917),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 6),

                        // Plan Summary Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEFE8DD)),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x05000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: <Color>[Color(0xFFF6EDE0), Color(0xFFE7D6BA)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFEBDCC5)),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.monetization_on_rounded,
                                        color: Color(0xFFC88A35),
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        widget.args?.planTitle ?? 'Gold Kitty Plan',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1C1917),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      RichText(
                                        text: TextSpan(
                                          text: 'Plan ID: ',
                                          style: const TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF78716C),
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: widget.args?.membershipId ?? 'SJG00123',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF57534E),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: Color(0xFFF5F5F4), height: 1),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const Text(
                                        'Installment Amount',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFFA8A29E),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        formattedAmount,
                                        style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1C1917),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      const Text(
                                        'Due Date',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFFA8A29E),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        DateFormat('d MMM yyyy').format(DateTime.now().add(const Duration(days: 30))),
                                        style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF292524),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Section Title
                        Text(
                          'Choose Payment Method',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1C1917),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Method 1: UPI (Recommended)
                        _buildMethodCard(
                          methodKey: 'upi',
                          title: 'UPI',
                          badge: '(Recommended)',
                          badgeColor: const Color(0xFF197561),
                          icon: Icons.flash_on_rounded,
                          iconColor: const Color(0xFFE67E38),
                          extraWidget: Row(
                            children: <Widget>[
                              _buildAppBadge('GPay', const Color(0xFFF5F5F4), const Color(0xFF44403C)),
                              const SizedBox(width: 4),
                              _buildAppBadge('PhonePe', const Color(0xFFF3E8FF), const Color(0xFF6739B7)),
                              const SizedBox(width: 4),
                              _buildAppBadge('Paytm', const Color(0xFFE0F2FE), const Color(0xFF002E6E)),
                              const SizedBox(width: 4),
                              _buildAppBadge('BHIM', const Color(0xFFFEF3C7), const Color(0xFF92400E)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Method 2: Scan UPI QR
                        _buildMethodCard(
                          methodKey: 'qr',
                          title: 'Scan UPI QR',
                          badge: 'Scan & Pay',
                          badgeColor: const Color(0xFF187A64),
                          badgeBg: const Color(0xFFE6F4F0),
                          subtitle: 'Scan with GPay, PhonePe, Paytm or any UPI App',
                          icon: Icons.qr_code_scanner_rounded,
                          iconColor: const Color(0xFF063B2C),
                        ),

                        const SizedBox(height: 10),

                        // Method 3: Debit / Credit Card
                        _buildMethodCard(
                          methodKey: 'card',
                          title: 'Debit / Credit Card',
                          icon: Icons.credit_card_rounded,
                          iconColor: const Color(0xFF2563EB),
                          extraWidget: const Row(
                            children: <Widget>[
                              Text(
                                'VISA',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF1A1F71),
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Mastercard',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFEB001B),
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'RuPay',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF18398B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Method 4: Net Banking
                        _buildMethodCard(
                          methodKey: 'netbanking',
                          title: 'Net Banking',
                          subtitle: 'All major banks',
                          icon: Icons.account_balance_rounded,
                          iconColor: const Color(0xFF063B2C),
                        ),

                        const SizedBox(height: 10),

                        // Method 5: Wallets
                        _buildMethodCard(
                          methodKey: 'wallets',
                          title: 'Wallets',
                          subtitle: 'Amazon Pay, Mobikwik etc.',
                          icon: Icons.account_balance_wallet_outlined,
                          iconColor: const Color(0xFF44403C),
                        ),

                        const SizedBox(height: 10),

                        // Method 6: Pick Cash
                        _buildMethodCard(
                          methodKey: 'cash',
                          title: 'Pick Cash',
                          badge: 'Doorstep',
                          badgeColor: const Color(0xFF187A64),
                          badgeBg: const Color(0xFFE6F4F0),
                          subtitle: 'Store executive collects cash at your home',
                          icon: Icons.payments_outlined,
                          iconColor: const Color(0xFF063B2C),
                        ),

                        const SizedBox(height: 18),

                        // 100% Secure Payment Badge
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.security_rounded,
                              color: Color(0xFF17725D),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '100% Secure Payment',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF145344),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Your payment information is always safe with us.',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11.5,
                                    color: Color(0xFF78716C),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 100), // Clearance for fixed bottom button
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Fixed Bottom Bar with Pay Button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAF7F2),
                  border: Border(
                    top: BorderSide(color: Color(0x33E7E5E4)),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _handlePayAction(amount),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF063B2C),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: const Color(0x33063B2C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: Text(
                      _selectedMethod == 'cash'
                          ? 'Schedule Cash Pickup →'
                          : (_selectedMethod == 'qr'
                              ? 'Scan QR & Pay $formattedAmount'
                              : 'Pay $formattedAmount'),
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Processing Modal Overlay
            if (_isProcessing)
              Container(
                color: Colors.black.withValues(alpha: 0.65),
                child: Center(
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF063B2C)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Connecting to Bank',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1C1917),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Authenticating payment securely...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            color: Color(0xFF78716C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard({
    required String methodKey,
    required String title,
    String? badge,
    Color? badgeColor,
    Color? badgeBg,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    Widget? extraWidget,
  }) {
    final bool isSelected = _selectedMethod == methodKey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = methodKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF063B2C) : const Color(0xFFEFE8DD),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEBE1D0)),
                    ),
                    child: Center(
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              title,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C1917),
                              ),
                            ),
                            if (badge != null) ...<Widget>[
                              const SizedBox(width: 6),
                              if (badgeBg != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    badge,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: badgeColor,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  badge,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: badgeColor,
                                  ),
                                ),
                            ],
                          ],
                        ),
                        if (subtitle != null) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF78716C),
                            ),
                          ),
                        ],
                        if (extraWidget != null) ...<Widget>[
                          const SizedBox(height: 4),
                          extraWidget,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Radio Circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF063B2C) : const Color(0xFFD6D3D1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF063B2C),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
