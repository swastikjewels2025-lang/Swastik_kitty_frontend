import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/navigation/kitty_hamburger_button.dart';
import '../../../live_rates/presentation/providers/live_rate_controller.dart';
import '../../../live_rates/presentation/providers/live_rate_state.dart';

/// Dedicated Metal Value Calculator Screen.
///
/// Strictly uses the exact calculator design, logic, and precision
/// from the Live Gold Rate page (`LiveRatesScreen`).
class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({
    this.initialRate24k = 7485.00,
    this.isModal = false,
    this.onClose,
    super.key,
  });

  final double initialRate24k;
  final bool isModal;
  final VoidCallback? onClose;

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  // Calculator State
  String _calcMetal = 'gold'; // 'gold' | 'silver'
  String _calcPurity = '24K'; // '24K' | '22K' | '18K' for gold; '999' | '925' for silver
  String _calcUnit = 'g'; // 'g' | 'kg'
  final TextEditingController _weightController = TextEditingController(text: '10');

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final LiveRateState rateState = ref.watch(liveRateControllerProvider);
    final double baseGold24k = rateState.data?.rate24k ?? widget.initialRate24k;
    final double baseSilver999 = rateState.data?.silverRatePerGram ?? 88.50;

    // Precision calculation supporting up to 3 decimals
    final double weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final double weightInGrams = _calcUnit == 'kg' ? weight * 1000 : weight;

    final double currentCalcRate;
    final double estimatedTotal;

    if (_calcMetal == 'gold') {
      currentCalcRate = _getGoldPriceForPurity(baseGold24k, _calcPurity);
      estimatedTotal = currentCalcRate * weightInGrams;
    } else {
      final double multiplier = _calcPurity == '925' ? 0.925 : 1.0;
      currentCalcRate = baseSilver999 * multiplier;
      estimatedTotal = currentCalcRate * weightInGrams;
    }

    final String parsedWeight = weight == weight.roundToDouble()
        ? weight.toInt().toString()
        : weight.toString();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top Bar with Hamburger Menu on Top-Right
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Calculator',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF141210),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const KittyHamburgerButton(isLightSurface: true),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Metal Value Calculator Heading Card
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

                    const SizedBox(height: 16),

                    // 1. Calculator Metal Switcher (Gold / Silver)
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
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _calcMetal = 'gold';
                                  _calcPurity = '24K';
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
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
                                    fontSize: 13.5,
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
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _calcMetal = 'silver';
                                  _calcPurity = '999';
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
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
                                    fontSize: 13.5,
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

                    const SizedBox(height: 18),

                    // 2. Purity Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Purity',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF504C44),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE3DDD1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _calcPurity,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF646056),
                              ),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
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

                    const SizedBox(height: 16),

                    // 3. Weight Input & Unit Toggle (g vs kg)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Weight',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF504C44),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
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
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F1D19),
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 11),
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
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _calcUnit = 'g');
                                    },
                                    child: Container(
                                      width: 40,
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      decoration: BoxDecoration(
                                        color: _calcUnit == 'g' ? const Color(0xFF063B2C) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'g',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: _calcUnit == 'g' ? Colors.white : const Color(0xFF635E54),
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _calcUnit = 'kg');
                                    },
                                    child: Container(
                                      width: 40,
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      decoration: BoxDecoration(
                                        color: _calcUnit == 'kg' ? const Color(0xFF063B2C) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'kg',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
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

                    const SizedBox(height: 18),

                    // 4. Estimated Value Card (#EBF3ED)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF3ED),
                        borderRadius: BorderRadius.circular(18),
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
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0D382A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '(${_inrFormat.format(currentCalcRate.round())} × $parsedWeight $_calcUnit)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF557F6C),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 5. Calculate Button
                    ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Calculated Value: ${_inrFormat.format(estimatedTotal.round())}',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                            ),
                            backgroundColor: const Color(0xFF063B2C),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF063B2C),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.calculate_outlined,
                            size: 19,
                            color: Color(0xFF6EE7B7),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Calculate',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
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
}
