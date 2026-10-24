import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../checkout/presentation/screens/checkout_screen.dart';
import '../../../dashboard/presentation/providers/dashboard_controller.dart';
import '../../../home/presentation/providers/home_controller.dart';
import '../../domain/entities/scheme_entity.dart';
import '../providers/offers_controller.dart';

/// Review Your Plan screen matching dddd/review.html specifications.
/// Enrolls the patron directly in backend MongoDB via POST /api/v1/memberships/join
class ReviewPlanScreen extends ConsumerStatefulWidget {
  const ReviewPlanScreen({super.key, this.args});

  final Map<String, dynamic>? args;

  @override
  ConsumerState<ReviewPlanScreen> createState() => _ReviewPlanScreenState();
}

class _ReviewPlanScreenState extends ConsumerState<ReviewPlanScreen> {
  SchemeEntity? _scheme;
  String _planTitle = '6 Month Gold Plan';
  int _monthlyAmount = 5000;
  int _totalAmount = 30000;
  int _durationMonths = 6;
  String _selectedSlot = '01';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final dynamic schemeArg = widget.args?['scheme'];
    if (schemeArg is SchemeEntity) {
      _scheme = schemeArg;
      _planTitle = schemeArg.name;
      _monthlyAmount = schemeArg.monthlyInstallment;
      _totalAmount = schemeArg.targetAmount;
      _durationMonths = schemeArg.durationMonths;
    }
    final dynamic slotArg = widget.args?['selectedSlot'];
    if (slotArg is String && slotArg.isNotEmpty) {
      _selectedSlot = slotArg;
    }
  }

  void _showEditPlanModal() {
    final offers = ref.read(offersControllerProvider).schemes;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Select Plan Duration',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111A16),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (offers.isNotEmpty)
                ...offers.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildPlanOption(
                    title: s.name,
                    monthly: s.monthlyInstallment,
                    total: s.targetAmount,
                    duration: s.durationMonths,
                    isSelected: _scheme?.id == s.id || _durationMonths == s.durationMonths,
                    onSelect: () {
                      setState(() {
                        _scheme = s;
                        _planTitle = s.name;
                        _monthlyAmount = s.monthlyInstallment;
                        _totalAmount = s.targetAmount;
                        _durationMonths = s.durationMonths;
                      });
                      Navigator.of(ctx).pop();
                    },
                  ),
                ))
              else ...<Widget>[
                _buildPlanOption(
                  title: '6 Month Gold Plan',
                  monthly: 5000,
                  total: 30000,
                  duration: 6,
                  isSelected: _durationMonths == 6,
                  onSelect: () {
                    setState(() {
                      _planTitle = '6 Month Gold Plan';
                      _monthlyAmount = 5000;
                      _totalAmount = 30000;
                      _durationMonths = 6;
                    });
                    Navigator.of(ctx).pop();
                  },
                ),
                const SizedBox(height: 10),
                _buildPlanOption(
                  title: '11 Month Gold Plan',
                  monthly: 5000,
                  total: 55000,
                  duration: 11,
                  isSelected: _durationMonths == 11,
                  onSelect: () {
                    setState(() {
                      _planTitle = '11 Month Gold Plan';
                      _monthlyAmount = 5000;
                      _totalAmount = 55000;
                      _durationMonths = 11;
                    });
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlanOption({
    required String title,
    required int monthly,
    required int total,
    required int duration,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryEmerald : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111A16),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '₹$monthly/mo • Total: ₹$total',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) ...<Widget>[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryEmerald,
                size: 22,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleProceedToPayment() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final DioClient dio = ref.read(dioClientProvider);

      // Resolve scheme ID
      String schemeId = _scheme?.id ?? '';
      if (schemeId.isEmpty) {
        final res = await dio.get<Map<String, dynamic>>('/api/v1/schemes/active');
        final list = res.data?['data']?['schemes'] as List<dynamic>?;
        if (list != null && list.isNotEmpty) {
          schemeId = (list.first as Map<String, dynamic>)['_id']?.toString() ?? '';
        }
      }

      final int slotNumber = int.tryParse(_selectedSlot) ?? 1;

      // 1. Join Scheme in backend MongoDB
      String membershipId = '';
      String chitToken = '#SW-${_selectedSlot.padLeft(3, '0')}';

      try {
        final response = await dio.post<Map<String, dynamic>>(
          '/api/v1/memberships/join',
          data: <String, dynamic>{
            'schemeId': schemeId,
            'selectedNumber': slotNumber,
          },
        );

        final dynamic mem = response.data?['data']?['membership'];
        if (mem is Map<String, dynamic>) {
          membershipId = mem['id']?.toString() ?? mem['_id']?.toString() ?? '';
          chitToken = mem['chitToken']?.toString() ?? chitToken;
        }
      } catch (err) {
        // If already enrolled in this scheme, fetch existing active dashboard
        final dashRes = await dio.get<Map<String, dynamic>>('/api/v1/memberships/my-dashboard');
        final dashData = dashRes.data?['data']?['dashboard'] as Map<String, dynamic>?;
        if (dashData != null) {
          membershipId = dashData['membershipId']?.toString() ?? '';
          chitToken = dashData['chitToken']?.toString() ?? chitToken;
        }
      }

      // 2. Refresh controllers so purchased plan shows in My Plan / Home instantly
      ref.invalidate(dashboardControllerProvider);
      ref.invalidate(homeControllerProvider);

      if (!mounted) return;

      // 3. Navigate to checkout for first installment
      await context.push(
        RoutePaths.checkout,
        extra: CheckoutArgs(
          membershipId: membershipId.isNotEmpty ? membershipId : 'mem_${DateTime.now().millisecondsSinceEpoch}',
          chitToken: chitToken,
          monthFor: 1,
          amount: _monthlyAmount,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enrollment: ${e.toString()}'),
          backgroundColor: const Color(0xFF063B2C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(appAuthStateProvider);
    final String userName = authState.userName.isNotEmpty ? authState.userName : 'Member Patron';
    final String userPhone = authState.userPhone.isNotEmpty ? authState.userPhone : '-';
    final String userEmail = authState.userEmail.isNotEmpty ? authState.userEmail : '-';
    final String userAddress = authState.address.isNotEmpty
        ? (authState.city.isNotEmpty ? '${authState.address}, ${authState.city}' : authState.address)
        : '-';
    final String nomineeName = authState.nomineeName.isNotEmpty ? authState.nomineeName : 'Not Registered';
    final String nomineeRel = authState.nomineeRelation.isNotEmpty ? authState.nomineeRelation : 'Beneficiary';
    final String nomineePhone = authState.nomineePhone.isNotEmpty ? authState.nomineePhone : '-';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 20, top: 8, bottom: 4),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(RoutePaths.book);
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF111A16),
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 4),

                    // Header Title (Playfair Display)
                    Text(
                      'Review Your Plan',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111A16),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Please review your scheme details and allocated slot before proceeding.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        color: const Color(0xFF6B6864),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Plan Details Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFEFE8DE)),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Card Header
                          Row(
                            children: <Widget>[
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBE9CE),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.monetization_on_outlined,
                                    color: Color(0xFFB45309),
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _planTitle,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111A16),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: _showEditPlanModal,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        'Edit',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryEmerald,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.edit_outlined,
                                        color: AppColors.primaryEmerald,
                                        size: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          const Divider(color: Color(0xFFF5EFE7), height: 1),
                          const SizedBox(height: 10),

                          _buildDetailRow('Allocated Chit Slot', '#$_selectedSlot'),
                          _buildDetailRow('Monthly Installment', '₹$_monthlyAmount'),
                          _buildDetailRow('Total Target Contribution', '₹$_totalAmount'),
                          _buildDetailRow('Duration', '$_durationMonths Months'),
                          _buildDetailRow('Installments Count', '$_durationMonths'),
                          _buildDetailRow('Bonus Eligibility', 'Guaranteed bonus on completion'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Account Details Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFEFE8DE)),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  'Patron Details',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111A16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => context.push(RoutePaths.profile),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        'Edit',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryEmerald,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.edit_outlined,
                                        color: AppColors.primaryEmerald,
                                        size: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFF5EFE7), height: 1),
                          const SizedBox(height: 8),
                          _buildDetailRow('Name', userName, labelFlex: 3, valueFlex: 5),
                          _buildDetailRow('Mobile', userPhone, labelFlex: 3, valueFlex: 5),
                          _buildDetailRow('Email', userEmail, labelFlex: 3, valueFlex: 5, isEmail: true),
                          if (userAddress != '-') _buildDetailRow('Address', userAddress, labelFlex: 3, valueFlex: 5),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Nominee Details Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFEFE8DE)),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  'Nominee Registration',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111A16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => context.push(RoutePaths.profile),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        'Edit',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryEmerald,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.edit_outlined,
                                        color: AppColors.primaryEmerald,
                                        size: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFF5EFE7), height: 1),
                          const SizedBox(height: 8),
                          _buildDetailRow('Nominee Name', nomineeName, labelFlex: 4, valueFlex: 5),
                          _buildDetailRow('Relationship', nomineeRel, labelFlex: 4, valueFlex: 5),
                          _buildDetailRow('Nominee Mobile', nomineePhone, labelFlex: 4, valueFlex: 5),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Proceed to Payment CTA Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleProceedToPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryEmerald,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: const Color(0x33063B2C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Enroll & Proceed to Payment',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
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

  Widget _buildBonusEligibilityRow(String label, String value) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // On narrow card widths (< 270px, e.g. 320px screens), stack vertically for optimal readability.
        // On standard screens (>= 270px), render side-by-side with the description wrapping naturally on the right.
        final bool isNarrow = constraints.maxWidth < 270;

        if (isNarrow) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B6864),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111A16),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B6864),
                  height: 1.35,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111A16),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    int labelFlex = 5,
    int valueFlex = 3,
    bool isEmail = false,
  }) {
    if (label == 'Bonus Eligibility') {
      return _buildBonusEligibilityRow(label, value);
    }

    final String formattedValue = isEmail
        ? value.replaceAll('@', '@\u200B').replaceAll('.', '.\u200B')
        : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: labelFlex,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B6864),
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: valueFlex,
            child: Text(
              formattedValue,
              textAlign: TextAlign.end,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111A16),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
