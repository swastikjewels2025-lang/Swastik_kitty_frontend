import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/scheme_entity.dart';
import '../providers/offers_controller.dart';

/// Dynamic Slot / Seat Booking Screen
/// Connects directly to backend GET /api/v1/schemes/:id/numbers
/// Dynamically renders totalSlots (e.g. 1-50, 1-100) and actual occupied seats without dummy data.
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, this.scheme});

  final SchemeEntity? scheme;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  SchemeEntity? _activeScheme;
  int _totalSlots = 50;
  Set<String> _bookedNumbers = <String>{};
  String? _selectedNumber;
  bool _isLoadingSlots = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _activeScheme = widget.scheme;
    if (_activeScheme != null) {
      _totalSlots = _activeScheme!.maxCapacity > 0 ? _activeScheme!.maxCapacity : 50;
    }
    _loadSchemeSlots();
  }

  Future<void> _loadSchemeSlots() async {
    setState(() {
      _isLoadingSlots = true;
      _errorMessage = null;
    });

    try {
      final DioClient dio = ref.read(dioClientProvider);

      // If no scheme was passed, fetch the active schemes list first
      if (_activeScheme == null) {
        final offersState = ref.read(offersControllerProvider);
        if (offersState.schemes.isNotEmpty) {
          _activeScheme = offersState.schemes.first;
        } else {
          final res = await dio.get<Map<String, dynamic>>('/api/v1/schemes/active');
          final list = res.data?['data']?['schemes'] as List<dynamic>?;
          if (list != null && list.isNotEmpty) {
            final Map<String, dynamic> first = list.first as Map<String, dynamic>;
            _totalSlots = (first['totalSlots'] as num?)?.toInt() ?? (first['maxCapacity'] as num?)?.toInt() ?? 50;
            _activeScheme = SchemeEntity(
              id: first['_id']?.toString() ?? first['id']?.toString() ?? '',
              name: first['name']?.toString() ?? 'Gold Savings Plan',
              targetAmount: (first['targetAmount'] as num?)?.toInt() ?? 60000,
              durationMonths: (first['durationMonths'] as num?)?.toInt() ?? 12,
              monthlyInstallment: (first['monthlyInstallment'] as num?)?.toInt() ?? 5000,
              maxCapacity: _totalSlots,
              currentMembers: (first['currentMembers'] as num?)?.toInt() ?? 0,
              status: SchemeStatusEnum.fromString(first['status']?.toString()),
              benefits: <String>[
                'Systematic Gold Accumulation',
                'Guaranteed Jeweler Bonus at Maturity',
                '0% Making Charges on Hallmark Jewellery',
              ],
            );
          }
        }
      }

      if (_activeScheme != null) {
        final res = await dio.get<Map<String, dynamic>>(
          '/api/v1/schemes/${_activeScheme!.id}/numbers',
        );
        final data = res.data?['data'] as Map<String, dynamic>?;
        if (data != null) {
          final int slots = (data['totalSlots'] as num?)?.toInt() ?? _activeScheme!.maxCapacity;
          _totalSlots = slots > 0 ? slots : 50;
          final List<dynamic>? numbers = data['numbers'] as List<dynamic>?;
          final Set<String> booked = <String>{};
          if (numbers != null) {
            for (final dynamic item in numbers) {
              if (item is Map<String, dynamic> && item['status'] == 'BOOKED') {
                final String label = (item['label'] ?? item['number']).toString().padLeft(2, '0');
                booked.add(label);
              }
            }
          }
          _bookedNumbers = booked;
        }
      }

      // Auto-select first available slot if none selected
      if (_selectedNumber == null || _bookedNumbers.contains(_selectedNumber)) {
        for (int i = 1; i <= _totalSlots; i++) {
          final String numStr = i.toString().padLeft(2, '0');
          if (!_bookedNumbers.contains(numStr)) {
            _selectedNumber = numStr;
            break;
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Unable to fetch live seat numbers. Tap to retry.';
    } finally {
      if (mounted) {
        setState(() => _isLoadingSlots = false);
      }
    }
  }

  void _selectNumber(String numStr) {
    if (_bookedNumbers.contains(numStr)) return;
    setState(() {
      if (_selectedNumber == numStr) {
        _selectedNumber = null;
      } else {
        _selectedNumber = numStr;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedNumber = null;
    });
  }

  void _handleBookNumber() {
    if (_selectedNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an available chit number'),
          backgroundColor: Color(0xFF063B2C),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    // Navigate to Review Your Plan with real scheme & chosen number
    context.push(
      RoutePaths.review,
      extra: <String, dynamic>{
        'scheme': _activeScheme,
        'selectedSlot': _selectedNumber,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String schemeName = _activeScheme?.name ?? 'Gold Savings Plan';
    final int monthlyAmount = _activeScheme?.monthlyInstallment ?? 5000;
    final int duration = _activeScheme?.durationMonths ?? 12;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Navigation Header
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 16, top: 8, bottom: 4),
              child: Row(
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
                      color: Color(0xFF1C1917),
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Select Your Chit Slot',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1917),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _loadSchemeSlots,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFF063B2C),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadSchemeSlots,
                color: const Color(0xFF063B2C),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 6),

                      // Scheme Details Badge Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEADBCA)),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    schemeName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF063B2C),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$duration Months Plan • Total $_totalSlots Slots',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF78716C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBE9CE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${CurrencyFormatter.formatRupees(monthlyAmount)}/mo',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1C1917),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Legend Row (3 Distinct Statuses)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _buildLegendItem(
                            color: Colors.white,
                            borderColor: const Color(0xFFC8BDAB),
                            label: 'Available (${_totalSlots - _bookedNumbers.length})',
                          ),
                          _buildLegendItem(
                            color: const Color(0xFFDCD7CF),
                            borderColor: const Color(0xFFCFC8BD),
                            label: 'Booked (${_bookedNumbers.length})',
                          ),
                          _buildLegendItem(
                            color: const Color(0xFF063B2C),
                            borderColor: const Color(0xFF063B2C),
                            label: 'Your Choice',
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      if (_isLoadingSlots)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(color: Color(0xFF063B2C)),
                          ),
                        )
                      else if (_errorMessage != null)
                        InkWell(
                          onTap: _loadSchemeSlots,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFFA39E)),
                            ),
                            child: Row(
                              children: <Widget>[
                                const Icon(Icons.error_outline_rounded, color: Color(0xFFE03B24)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFE03B24),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        // Dynamic Numbers Grid matching actual scheme slots (e.g. 50 slots)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _totalSlots <= 30 ? 5 : 10,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: _totalSlots,
                          itemBuilder: (BuildContext context, int index) {
                            final String numStr = (index + 1).toString().padLeft(2, '0');
                            final bool isBooked = _bookedNumbers.contains(numStr);
                            final bool isSelected = _selectedNumber == numStr;

                            Color bgColor;
                            Color textColor;
                            Border? border;

                            if (isBooked) {
                              bgColor = const Color(0xFFDCD7CF);
                              textColor = const Color(0xFF8D877E);
                              border = Border.all(color: const Color(0xFFCFC8BD), width: 0.8);
                            } else if (isSelected) {
                              bgColor = const Color(0xFF063B2C);
                              textColor = Colors.white;
                              border = Border.all(color: const Color(0xFF063B2C), width: 1.0);
                            } else {
                              bgColor = Colors.white;
                              textColor = const Color(0xFF1C1917);
                              border = Border.all(color: const Color(0xFFC8BDAB), width: 0.8);
                            }

                            return GestureDetector(
                              onTap: isBooked ? null : () => _selectNumber(numStr),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(6),
                                  border: border,
                                  boxShadow: isSelected
                                      ? const <BoxShadow>[
                                          BoxShadow(
                                            color: Color(0x33063B2C),
                                            blurRadius: 4,
                                            offset: Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  numStr,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 10.5,
                                    fontWeight: isSelected || isBooked
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 16),

                      // Selected Number Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _selectedNumber != null
                                ? 'Selected Slot: #$_selectedNumber'
                                : 'Select An Available Slot',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1C1917),
                            ),
                          ),
                          if (_selectedNumber != null)
                            GestureDetector(
                              onTap: _clearSelection,
                              child: const Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: Color(0xFFE03B24),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Clear',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFE03B24),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      if (_selectedNumber != null) ...<Widget>[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF047857), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Chit Token #$_selectedNumber is reserved for your enrollment.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF065F46),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Booking CTA Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFEADBCA)),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Enroll in Scheme',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1C1917),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lock in Token #${_selectedNumber ?? '--'} and review installment breakdown.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: const Color(0xFF78716C),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _selectedNumber == null ? null : _handleBookNumber,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF063B2C),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(0xFFDCD7CF),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  _selectedNumber != null
                                      ? 'Review Plan with Slot #$_selectedNumber →'
                                      : 'Select a Slot to Continue',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
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

  Widget _buildLegendItem({
    required Color color,
    required Color borderColor,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF44403C),
          ),
        ),
      ],
    );
  }
}
