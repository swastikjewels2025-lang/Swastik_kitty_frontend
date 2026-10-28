import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/widgets/navigation/kitty_hamburger_button.dart';
import '../../../live_rates/presentation/providers/live_rate_controller.dart';
import '../../../live_rates/presentation/providers/live_rate_state.dart';
import '../../../orders/domain/entities/order_booking_entity.dart';
import '../../../orders/presentation/providers/orders_controller.dart';

/// Legacy enum retained for backwards compatibility with tests and callers.
enum CoinMetal {
  gold('GOLD COIN', Icons.monetization_on_rounded),
  silver('SILVER COIN', Icons.shield_outlined);

  const CoinMetal(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}

/// Gold Karat options for calculation and custom booking.
enum GoldKarat {
  k24('24K', '24K (99.9%)', 1.0, 7485.0),
  k22('22K', '22K (91.6%)', 22.0 / 24.0, 6860.0),
  k18('18K', '18K (75.0%)', 18.0 / 24.0, 5615.0);

  const GoldKarat(this.shortLabel, this.label, this.purityFraction, this.fallbackRate);
  final String shortLabel;
  final String label;
  final double purityFraction;
  final double fallbackRate;

  double dynamicRate(double base24k) => (base24k * purityFraction);
}

/// Gold Coins Screen reproducing `dddd/coins.html` exactly.
class CoinRatesScreen extends ConsumerStatefulWidget {
  const CoinRatesScreen({
    this.initialMetal = CoinMetal.gold,
    super.key,
  });

  final CoinMetal initialMetal;

  @override
  ConsumerState<CoinRatesScreen> createState() => _CoinRatesScreenState();
}

class _CoinRatesScreenState extends ConsumerState<CoinRatesScreen> {
  static const Color _pineDark = AppColors.primaryEmerald; // #063B2C
  static const Color _canvasBg = AppColors.warmPearl; // #FAF7F2
  static const Color _surfaceBg = Color(0xFFFFFFFF);
  static const Color _softBorder = AppColors.surfaceCardBorder; // #EFE6DB
  static const Color _textDark = AppColors.deepForestCharcoal; // #0A221C
  static const Color _textMuted = AppColors.mutedSlateGray; // #68726E

  int _selectedKarat = 24; // 24 | 22 | 18
  double _selectedWeight = 10.0;
  final TextEditingController _customWeightController = TextEditingController(text: '10');

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _customWeightController.dispose();
    super.dispose();
  }

  double _getRatePerGram(double base24k, int karat) {
    switch (karat) {
      case 22:
        return base24k * (22.0 / 24.0);
      case 18:
        return base24k * (18.0 / 24.0);
      case 24:
      default:
        return base24k;
    }
  }

  void _onQuickWeightSelected(double weight) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedWeight = weight;
      _customWeightController.text = weight == weight.roundToDouble()
          ? weight.toInt().toString()
          : weight.toString();
    });
  }

  void _onCustomWeightChanged(String val) {
    final double? parsed = double.tryParse(val.trim());
    if (parsed != null && parsed > 0) {
      setState(() {
        _selectedWeight = parsed;
      });
    }
  }

  void _openBookingModal({
    required String itemName,
    required String purity,
    required double weight,
    required double totalAmount,
  }) {
    HapticFeedback.selectionClick();
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      builder: (BuildContext ctx) => _CoinBookingDialog(
        itemName: itemName,
        purity: purity,
        weight: weight,
        totalAmount: totalAmount,
        onConfirmed: () async {
          final DioClient dio = ref.read(dioClientProvider);
          String bookingId = 'COIN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

          try {
            final response = await dio.post<Map<String, dynamic>>(
              '/api/v1/bookings',
              data: <String, dynamic>{
                'category': 'COINS',
                'itemName': itemName,
                'karat': purity,
                'weightGrams': weight,
                'unitPrice': totalAmount,
                'quantity': 1,
              },
            );
            final dynamic data = response.data?['data'];
            if (data is Map && data['bookingId'] != null) {
              bookingId = data['bookingId'].toString();
            }
          } catch (_) {
            // Keep local booking if offline or mock
          }

          final OrderBookingEntity booking = OrderBookingEntity(
            id: bookingId,
            title: itemName,
            category: OrderCategory.coins,
            description: '$weight Grams • $purity',
            amount: totalAmount,
            formattedAmount: _inrFormat.format(totalAmount),
            status: 'Confirmed',
            createdAt: DateTime.now(),
            badgeText: purity,
          );

          ref.read(ordersControllerProvider.notifier).addBooking(booking);

          if (ctx.mounted) {
            Navigator.of(ctx).pop();
          }

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Booking confirmed for $itemName!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: _pineDark,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'View Bookings',
                textColor: const Color(0xFFECCF96),
                onPressed: () => context.push(RoutePaths.orders),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LiveRateState rateState = ref.watch(liveRateControllerProvider);
    final double base24kRate = rateState.data?.rate24k ?? 7485.0;

    // Rates for 4g and 5g predefined coins
    final double price4g = (base24kRate * 4.0).roundToDouble();
    final double price5g = (base24kRate * 5.0).roundToDouble();

    // Custom coin calculation
    final double currentRate = _getRatePerGram(base24kRate, _selectedKarat);
    final double customTotal = (currentRate * _selectedWeight).roundToDouble();

    return Scaffold(
      backgroundColor: _canvasBg,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // =================================================================
            // TOP HEADER (Gold Plans Light Luxury Header)
            // =================================================================
            Container(
              color: AppColors.warmPearl,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                children: <Widget>[
                  // Back Button (White circular card with subtle border)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RoutePaths.offers);
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surfaceCardBorder,
                            width: 1,
                          ),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.deepForestCharcoal,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Title
                  Expanded(
                    child: Center(
                      child: Text(
                        'Gold Coins',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepForestCharcoal,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  // Top-Right Hamburger Menu Button
                  const KittyHamburgerButton(isLightSurface: true),
                ],
              ),
            ),

            // =================================================================
            // SCROLLABLE BODY CONTENT (Ivory Sheet matching coins.html)
            // =================================================================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // ---------------------------------------------------------
                    // SECTION 1: AVAILABLE GOLD COINS (4g & 5g ONLY)
                    // ---------------------------------------------------------
                    Text(
                      'Available Gold Coins',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card 1: 4 Gram Gold Coin
                    _buildCoinCard(
                      weightLabel: '4g',
                      title: '4g Gold Coin',
                      puritySubtitle: '24K • 999 Purity',
                      price: price4g,
                      onBookPressed: () => _openBookingModal(
                        itemName: '4g Gold Coin (24K)',
                        purity: '24 Karat (999)',
                        weight: 4.0,
                        totalAmount: price4g,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Card 2: 5 Gram Gold Coin
                    _buildCoinCard(
                      weightLabel: '5g',
                      title: '5g Gold Coin',
                      puritySubtitle: '24K • 999 Purity',
                      price: price5g,
                      onBookPressed: () => _openBookingModal(
                        itemName: '5g Gold Coin (24K)',
                        purity: '24 Karat (999)',
                        weight: 5.0,
                        totalAmount: price5g,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---------------------------------------------------------
                    // SECTION 2: CUSTOM GOLD COIN (matching coins.html line 163)
                    // ---------------------------------------------------------
                    Container(
                      decoration: BoxDecoration(
                        color: _surfaceBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _softBorder),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 12,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Custom Gold Coin',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Select karat and custom weight to book',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: _textMuted,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Karat Selector (3 tabs)
                          Text(
                            'Select Karat',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              _buildKaratTab(24, '24K (99.9%)'),
                              const SizedBox(width: 8),
                              _buildKaratTab(22, '22K (91.6%)'),
                              const SizedBox(width: 8),
                              _buildKaratTab(18, '18K (75.0%)'),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Weight Selection & Input
                          Text(
                            'Select Weight (Grams)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Quick Weight Chips (1g, 2g, 8g, 10g, 20g)
                          Row(
                            children: const <double>[1, 2, 8, 10, 20].map((double w) {
                              final bool isSelected = _selectedWeight == w;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _onQuickWeightSelected(w),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? _pineDark : _canvasBg,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected ? _pineDark : _softBorder,
                                          ),
                                        ),
                                        child: Text(
                                          '${w.toInt()}g',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected ? Colors.white : _textDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 10),

                          // Exact Custom Input Box
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: _canvasBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _softBorder),
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    controller: _customWeightController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: _onCustomWeightChanged,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: _textDark,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Enter custom weight',
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                                Text(
                                  'grams',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: _textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Live Price Calculation Strip (matching coins.html line 208)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _canvasBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _softBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Estimated Booking Price',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: _textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_selectedWeight == _selectedWeight.roundToDouble() ? _selectedWeight.toInt() : _selectedWeight}g • $_selectedKarat Karat',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: _textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _inrFormat.format(customTotal),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: _pineDark,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Book Custom Coin Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_selectedWeight <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter a valid weight')),
                                  );
                                  return;
                                }
                                _openBookingModal(
                                  itemName: 'Custom Gold Coin (${_selectedKarat}K)',
                                  purity: '$_selectedKarat Karat',
                                  weight: _selectedWeight,
                                  totalAmount: customTotal,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _pineDark,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Book Custom Coin',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKaratTab(int karat, String label) {
    final bool isSelected = _selectedKarat == karat;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedKarat = karat);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? _pineDark : _canvasBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? _pineDark : _softBorder,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : _textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoinCard({
    required String weightLabel,
    required String title,
    required String puritySubtitle,
    required double price,
    required VoidCallback onBookPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _softBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Left: Coin Visual + Info
          Expanded(
            child: Row(
              children: <Widget>[
                // Authentic Coin Vector Visual (matching coins.html .coin-radial)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      center: Alignment(-0.3, -0.4),
                      radius: 0.8,
                      colors: <Color>[
                        Color(0xFFFFE9B8),
                        Color(0xFFD4A95B),
                        Color(0xFF8C6520),
                      ],
                      stops: <double>[0.0, 0.45, 1.0],
                    ),
                    border: Border.all(
                      color: const Color(0xFFFFF0C8).withValues(alpha: 0.60),
                      width: 2.0,
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x2B000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            weightLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF451A03),
                              height: 1.0,
                            ),
                          ),
                          Text(
                            '999',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF451A03).withValues(alpha: 0.80),
                              letterSpacing: -0.5,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Title, Purity, Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        puritySubtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: _textMuted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _inrFormat.format(price),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _pineDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right: Action Button
          ElevatedButton(
            onPressed: onBookPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _pineDark,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(80, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Book Now',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Booking Confirmation Dialog strictly matching `coins.html` lines 233-277.
class _CoinBookingDialog extends StatelessWidget {
  const _CoinBookingDialog({
    required this.itemName,
    required this.purity,
    required this.weight,
    required this.totalAmount,
    required this.onConfirmed,
  });

  final String itemName;
  final String purity;
  final double weight;
  final double totalAmount;
  final VoidCallback onConfirmed;

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Emerald Checkmark Icon Circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD1FAE5)),
              ),
              child: const Center(
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.primaryEmerald,
                  size: 26,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Title & Subtitle
            Text(
              'Confirm Coin Booking',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2120),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Please review your booking details below.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6E7876),
              ),
            ),

            const SizedBox(height: 16),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF8F4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEBE5D8)),
              ),
              child: Column(
                children: <Widget>[
                  _buildRow('Product:', itemName),
                  const SizedBox(height: 6),
                  _buildRow('Purity:', purity),
                  const SizedBox(height: 6),
                  _buildRow('Weight:', '$weight Grams'),
                  const Divider(height: 16, color: Color(0xFFEBE5D8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Total Amount',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A2120),
                        ),
                      ),
                      Text(
                        _inrFormat.format(totalAmount),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryEmerald,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Buttons
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepForestCharcoal,
                      side: const BorderSide(color: AppColors.surfaceCardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirmed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryEmerald,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Confirm',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6E7876),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A2120),
          ),
        ),
      ],
    );
  }
}
