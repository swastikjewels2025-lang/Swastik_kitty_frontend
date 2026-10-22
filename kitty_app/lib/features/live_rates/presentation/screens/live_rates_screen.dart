import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/widgets/feedback/kitty_error_state.dart';
import '../../../../shared/widgets/navigation/kitty_hamburger_button.dart';
import '../providers/live_rate_controller.dart';
import '../providers/live_rate_state.dart';
import '../widgets/live_rates_skeleton_loader.dart';

/// Complete Live Rates Screen recreating `dddd/liverate.html` exactly.
///
/// Features:
/// 1. Top Bar Navigation (Back button, "Live Rates" in serif, animated Refresh button)
/// 2. Subtitle description
/// 3. Top Metal Switcher Toggle (Gold / Silver)
/// 4. Interactive Gold Card:
///    - 3D Gold bullion bar illustration
///    - Purity dropdown (24K, 22K, 18K)
///    - Price per gram (dynamic from API or benchmark)
///    - Trend badge with up arrow
///    - Sparkline chart with gradient area
///    - Timeframe selectors (1D, 1W, 1M, 1Y)
/// 5. Interactive Silver Card:
///    - 3D Silver bullion bar illustration
///    - Silver rate (99.9%) per gram
///    - Trend badge
///    - Silver sparkline chart
///    - Timeframe selectors (1D, 1W, 1M, 1Y)
/// 6. Integrated Metal Value Calculator:
///    - Independent Metal Switcher (Gold / Silver)
///    - Purity dropdown & Weight input with (g / kg) unit pills
///    - Dynamic Estimated Value result card in #EBF3ED
///    - Calculate action button
/// 7. Showroom rates disclaimer footer
class LiveRatesScreen extends ConsumerStatefulWidget {
  const LiveRatesScreen({super.key});

  @override
  ConsumerState<LiveRatesScreen> createState() => _LiveRatesScreenState();
}

class _LiveRatesScreenState extends ConsumerState<LiveRatesScreen>
    with SingleTickerProviderStateMixin {
  String _activeRateView = 'gold'; // 'gold' | 'silver'
  String _goldCardPurity = '24K'; // '24K' | '22K' | '18K'
  String _goldTimeframe = '1D'; // '1D' | '1W' | '1M' | '1Y'
  String _silverTimeframe = '1D';

  // Calculator State
  String _calcMetal = 'gold'; // 'gold' | 'silver'
  String _calcPurity = '24K'; // '24K' | '22K' | '18K' for gold; '999' | '925' for silver
  String _calcUnit = 'g'; // 'g' | 'kg'
  final TextEditingController _weightController = TextEditingController(text: '10');

  late AnimationController _refreshAnimController;

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _silverInrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _refreshAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
  }

  @override
  void dispose() {
    _refreshAnimController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  double _getGoldPriceForPurity(double base24k, String purity) {
    switch (purity) {
      case '22K':
        return base24k * (22.0 / 24.0);
      case '18K':
        return base24k * (18.0 / 24.0);
      case '24K':
      default:
        return base24k;
    }
  }

  double _calculateEstimatedValue(double gold24k, double silver999) {
    final double weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final double weightInGrams = _calcUnit == 'kg' ? weight * 1000 : weight;

    if (_calcMetal == 'gold') {
      final double rate = _getGoldPriceForPurity(gold24k, _calcPurity);
      return rate * weightInGrams;
    } else {
      final double multiplier = _calcPurity == '925' ? 0.925 : 1.0;
      final double rate = silver999 * multiplier;
      return rate * weightInGrams;
    }
  }

  void _handleBack() {
    HapticFeedback.lightImpact();
    if (context.canPop()) {
      context.pop();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(RoutePaths.offers);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LiveRateState rateState = ref.watch(liveRateControllerProvider);

    if (rateState.isLoading && rateState.data == null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          _handleBack();
        },
        child: const Scaffold(
          backgroundColor: Color(0xFFFAF7F2),
          body: SafeArea(child: LiveRatesSkeletonLoader()),
        ),
      );
    }

    if (rateState.isError && rateState.data == null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          _handleBack();
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFFAF7F2),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space24),
              child: KittyErrorState(
                title: 'Unable to Load Live Rates',
                message: rateState.errorMessage ??
                    'Failed to fetch latest market bullion rates. Please check your internet connection.',
                retryLabel: 'TRY AGAIN',
                isDarkSurface: false,
                onRetry: () => ref.read(liveRateControllerProvider.notifier).loadRates(force: true),
              ),
            ),
          ),
        ),
      );
    }

    final rates = rateState.data;
    // Default fallback benchmarks from liverate.html
    final double baseGold24k = rates?.rate24k ?? 6842.0;
    final double baseSilver999 = rates?.silverRatePerGram ?? 82.40;

    final double activeGoldDisplayPrice = _getGoldPriceForPurity(baseGold24k, _goldCardPurity);
    final double estimatedTotal = _calculateEstimatedValue(baseGold24k, baseSilver999);
    final double currentCalcRate = _calcMetal == 'gold'
        ? _getGoldPriceForPurity(baseGold24k, _calcPurity)
        : (baseSilver999 * (_calcPurity == '925' ? 0.925 : 1.0));
    final double parsedWeight = double.tryParse(_weightController.text.trim()) ?? 0.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF7F2),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 576),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF7F2),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFECE7DD)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x0F1C1917),
                        blurRadius: 40,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // =========================================================
                      // 1. TOP BAR NAVIGATION (header)
                      // =========================================================
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            InkWell(
                              onTap: _handleBack,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 22,
                                  color: Color(0xFF1E1B18),
                                ),
                              ),
                            ),
                          Text(
                            'Live Rates',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF141210),
                              letterSpacing: -0.3,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              RotationTransition(
                                turns: _refreshAnimController,
                                child: InkWell(
                                  onTap: () async {
                                    _refreshAnimController.forward(from: 0.0);
                                    await ref.read(liveRateControllerProvider.notifier).refresh();
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.refresh_rounded,
                                      size: 22,
                                      color: Color(0xFF1E1B18),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const KittyHamburgerButton(isLightSurface: true),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: Color(0x99ECE7DD)),

                    const SizedBox(height: 14),

                    // Subtitle description
                    Text(
                      'Stay updated with the latest gold and silver rates in real time.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF726E65),
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Top Metal Switcher Toggle (Gold / Silver)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0ECE3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _activeRateView = 'gold'),
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _activeRateView == 'gold'
                                      ? const Color(0xFF063B2C)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _activeRateView == 'gold'
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
                                  'Gold',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _activeRateView == 'gold'
                                        ? Colors.white
                                        : const Color(0xFF6B665C),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _activeRateView = 'silver'),
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _activeRateView == 'silver'
                                      ? const Color(0xFF063B2C)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _activeRateView == 'silver'
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
                                  'Silver',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _activeRateView == 'silver'
                                        ? Colors.white
                                        : const Color(0xFF6B665C),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // =========================================================
                    // 2. RATE CARDS (Gold or Silver)
                    // =========================================================
                    if (_activeRateView == 'gold')
                      _buildGoldRateCard(activeGoldDisplayPrice)
                    else
                      _buildSilverRateCard(baseSilver999),

                    const SizedBox(height: 24),

                    // =========================================================
                    // 3. METAL VALUE CALCULATOR SECTION
                    // =========================================================
                    const Divider(height: 1, color: Color(0xFFECE7DD)),

                    const SizedBox(height: 16),

                    Text(
                      'Metal Value Calculator',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF141210),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Calculate the value of your gold or silver easily.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF78746B),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Calculator Metal Switcher (Gold / Silver)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0ECE3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _calcMetal = 'gold';
                                  _calcPurity = '24K';
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _calcMetal == 'gold'
                                      ? const Color(0xFF063B2C)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _calcMetal == 'gold'
                                      ? const <BoxShadow>[
                                          BoxShadow(
                                            color: Color(0x1F000000),
                                            blurRadius: 3,
                                            offset: Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  'Gold',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _calcMetal == 'gold'
                                        ? Colors.white
                                        : const Color(0xFF6B665C),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _calcMetal = 'silver';
                                  _calcPurity = '999';
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _calcMetal == 'silver'
                                      ? const Color(0xFF063B2C)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _calcMetal == 'silver'
                                      ? const <BoxShadow>[
                                          BoxShadow(
                                            color: Color(0x1F000000),
                                            blurRadius: 3,
                                            offset: Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  'Silver',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _calcMetal == 'silver'
                                        ? Colors.white
                                        : const Color(0xFF6B665C),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Inputs and Result
                    Column(
                      children: <Widget>[
                        // Purity Selector
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Purity',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF504C44),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE3DDD1)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _calcPurity,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF646056)),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F1D19),
                                  ),
                                  items: _calcMetal == 'gold'
                                      ? const <DropdownMenuItem<String>>[
                                          DropdownMenuItem(value: '24K', child: Text('24K (999)')),
                                          DropdownMenuItem(value: '22K', child: Text('22K (916)')),
                                          DropdownMenuItem(value: '18K', child: Text('18K (750)')),
                                        ]
                                      : const <DropdownMenuItem<String>>[
                                          DropdownMenuItem(value: '999', child: Text('999 Fine Silver (99.9%)')),
                                          DropdownMenuItem(value: '925', child: Text('925 Sterling Silver (92.5%)')),
                                        ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _calcPurity = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Weight Input + Unit Toggle (g vs kg)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Weight',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF504C44),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE3DDD1)),
                                    ),
                                    child: TextField(
                                      controller: _weightController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (_) => setState(() {}),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1F1D19),
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0ECE3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () => setState(() => _calcUnit = 'g'),
                                        child: Container(
                                          width: 36,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: _calcUnit == 'g' ? const Color(0xFF063B2C) : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'g',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: _calcUnit == 'g' ? Colors.white : const Color(0xFF635E54),
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => setState(() => _calcUnit = 'kg'),
                                        child: Container(
                                          width: 36,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: _calcUnit == 'kg' ? const Color(0xFF063B2C) : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'kg',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: _calcUnit == 'kg' ? Colors.white : const Color(0xFF635E54),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Estimated Value Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF3ED),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD5E6D9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Estimated Value',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF30664B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _inrFormat.format(estimatedTotal.round()),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0D382A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '(${_inrFormat.format(currentCalcRate.round())} × $parsedWeight $_calcUnit)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF557F6C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Calculate Button
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Calculated: ${_inrFormat.format(estimatedTotal.round())}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            backgroundColor: const Color(0xFF063B2C),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF063B2C),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x1F063B2C),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              Icons.calculate_outlined,
                              size: 18,
                              color: Color(0xFF6EE7B7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Calculate',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================================================
                    // 4. FOOTER NOTE
                    // =========================================================
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EFE7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE9E3D6)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Color(0xFF8E887B),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Rates are updated in real time and may vary by location, making charges and taxes. Please confirm the final rate at the time of purchase in our showroom.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: const Color(0xFF716C62),
                                height: 1.4,
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
          ),
        ),
      ),
    ),
  );
}

  Widget _buildGoldRateCard(double price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFECE7DD)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  // 3D Metallic Gold Bars Icon Artwork
                  Container(
                    width: 78,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: <Color>[
                          Color(0xFFFFF3B0),
                          Color(0xFFE8BE52),
                          Color(0xFFB28221),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '999.9',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF885E0E),
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            'GOLD',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF75500A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            'Gold Rate ($_goldCardPurity)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C1A18),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.info_outline, size: 14, color: Color(0xFFA29E93)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _inrFormat.format(price.round()),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111111),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'per gram',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF868277),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Purity Picker
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5F0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE3DDD1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _goldCardPurity,
                    isDense: true,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2F2C27),
                    ),
                    items: const <String>['24K', '22K', '18K']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _goldCardPurity = val);
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Bottom Row: Trend + Sparkline Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6EC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: <Widget>[
                    const Text('▲ ', style: TextStyle(fontSize: 9, color: Color(0xFF1B8347))),
                    Text(
                      '+ ₹32 (0.47%) Today',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B8347),
                      ),
                    ),
                  ],
                ),
              ),

              // Sparkline graph
              SizedBox(
                width: 140,
                height: 42,
                child: CustomPaint(
                  painter: _SparklinePainter(
                    lineColor: const Color(0xFFDDA833),
                    gradientStartColor: const Color(0xFFE5C158).withValues(alpha: 0.45),
                    gradientEndColor: const Color(0xFFFFF8E0).withValues(alpha: 0.0),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Timeframe Selectors
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const <String>['1D', '1W', '1M', '1Y'].map((tf) {
              final bool isSel = _goldTimeframe == tf;
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: InkWell(
                  onTap: () => setState(() => _goldTimeframe = tf),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF063B2C) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tf,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSel ? Colors.white : const Color(0xFF7E7A6F),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSilverRateCard(double price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFECE7DD)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 3D Silver Metallic artwork
              Container(
                width: 78,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: <Color>[
                      Color(0xFFFFFFFF),
                      Color(0xFFD9DEE3),
                      Color(0xFFA5ACB2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '999.0',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF5A6166),
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'SILVER',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4B5156),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Silver Rate (99.9%)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C1A18),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.info_outline, size: 14, color: Color(0xFFA29E93)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _silverInrFormat.format(price),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111111),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'per gram',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF868277),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Trend + Sparkline Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6EC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: <Widget>[
                    const Text('▲ ', style: TextStyle(fontSize: 9, color: Color(0xFF1B8347))),
                    Text(
                      '+ ₹0.60 (0.73%) Today',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B8347),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: 140,
                height: 42,
                child: CustomPaint(
                  painter: _SparklinePainter(
                    lineColor: const Color(0xFF8E959E),
                    gradientStartColor: const Color(0xFF9CA3AF).withValues(alpha: 0.38),
                    gradientEndColor: const Color(0xFFF3F4F6).withValues(alpha: 0.0),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Timeframe Selectors
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const <String>['1D', '1W', '1M', '1Y'].map((tf) {
              final bool isSel = _silverTimeframe == tf;
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: InkWell(
                  onTap: () => setState(() => _silverTimeframe = tf),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF063B2C) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tf,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSel ? Colors.white : const Color(0xFF7E7A6F),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.lineColor,
    required this.gradientStartColor,
    required this.gradientEndColor,
  });

  final Color lineColor;
  final Color gradientStartColor;
  final Color gradientEndColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(0, h * 0.85);
    path.quadraticBezierTo(w * 0.16, h * 0.74, w * 0.28, h * 0.52);
    path.quadraticBezierTo(w * 0.56, h * 0.60, w * 0.81, h * 0.32);
    path.lineTo(w, h * 0.20);

    final Path areaPath = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientStartColor, gradientEndColor],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(areaPath, fillPaint);

    final Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => false;
}
