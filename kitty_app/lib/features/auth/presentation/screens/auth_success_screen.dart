import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/route_paths.dart';

/// Recreated 100% identically from dddd/success.html
/// Features:
/// - Light cream background #FAF7F2
/// - Header with back arrow & "Done" action
/// - Central Celebration Illustration with mint circles and diamond confetti particles
/// - "Payment Successful!" (Playfair Display 28px bold)
/// - Payment Breakdown Card with "Paid Successfully" green badge & key-value rows
/// - "View My Plan" CTA in #063B2C
/// - "Explore Jewellery" outlined CTA in #063B2C
class AuthSuccessScreen extends ConsumerWidget {
  const AuthSuccessScreen({
    super.key,
    this.planTitle = 'Gold Kitty Plan',
    this.amount = '₹5,000',
    this.nextDueDate,
  });

  final String planTitle;
  final String amount;
  final String? nextDueDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String effectiveDueDate = (nextDueDate != null && nextDueDate!.isNotEmpty)
        ? nextDueDate!
        : DateFormat('d MMM yyyy').format(DateTime.now().add(const Duration(days: 30)));

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    onPressed: () => context.go(RoutePaths.offers),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF161616),
                      size: 24,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(RoutePaths.dashboard),
                    child: Text(
                      'Done',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryEmerald,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 12),

                    // Central Celebration Illustration with Confetti
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          // Diamond Confetti Particles
                          Positioned(
                            top: 10,
                            left: 24,
                            child: _buildDiamondConfetti(const Color(0xFFE67E38), 9),
                          ),
                          Positioned(
                            top: 40,
                            left: 8,
                            child: _buildDiamondConfetti(const Color(0xFFF5B738), 9),
                          ),
                          Positioned(
                            bottom: 36,
                            left: 6,
                            child: _buildDiamondConfetti(const Color(0xFF56C288), 9),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 32,
                            child: _buildDiamondConfetti(const Color(0xFF5BBCE4), 9),
                          ),
                          Positioned(
                            top: 14,
                            right: 28,
                            child: _buildDiamondConfetti(const Color(0xFF5BBCE4), 9),
                          ),
                          Positioned(
                            top: 38,
                            right: 8,
                            child: _buildDiamondConfetti(const Color(0xFFF5B738), 9),
                          ),
                          Positioned(
                            bottom: 36,
                            right: 8,
                            child: _buildDiamondConfetti(const Color(0xFFE67E38), 9),
                          ),

                          // Large Outer Pastel Circle
                          Container(
                            width: 128,
                            height: 128,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE5F5EC),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              // Inner Mint Green Circle
                              child: Container(
                                width: 94,
                                height: 94,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF7BD49D),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 52,
                                    color: AppColors.primaryEmerald,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Heading & Subtitle
                    Text(
                      'Payment Successful!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your $planTitle has been activated.\nYou’re one step closer to your dream jewellery.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF555F6D),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Payment Breakdown Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCF8F2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEFE7DC)),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          // Status Header
                          Row(
                            children: <Widget>[
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1EA64E),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    amount,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Paid Successfully',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1EA64E),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          const Divider(color: Color(0xFFEFE7DC), height: 1),
                          const SizedBox(height: 10),

                          // Breakdown Rows
                          _buildBreakdownRow('Plan', planTitle),
                          _buildBreakdownRow('Next Installment', effectiveDueDate),
                          _buildBreakdownRow('Installment Amount', amount),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // View My Plan CTA Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => context.go(RoutePaths.dashboard),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryEmerald,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: const Color(0x33063B2C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: Text(
                          'View My Plan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Explore Jewellery Outlined Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => context.go(RoutePaths.jewellery),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.primaryEmerald,
                          side: const BorderSide(color: AppColors.primaryEmerald, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Explore Jewellery',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryEmerald,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiamondConfetti(Color color, double size) {
    return Transform.rotate(
      angle: 0.785398, // 45 degrees
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF636F7E),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
