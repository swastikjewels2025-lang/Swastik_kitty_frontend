import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../dashboard/domain/entities/dashboard_summary_entity.dart';
import '../../../dashboard/presentation/providers/dashboard_controller.dart';

/// Recreated 100% identically from dddd/cash-pickup.html
/// Features:
/// - Light cream background #FAF7F0
/// - Header with back arrow & "Doorstep Cash Pickup"
/// - Plan & Amount preview card with Free Doorstep Collection badge
/// - Amount to hand over field
/// - Cash Handover Person section (Name, Mobile, Alternate)
/// - Pickup Location section (GPS button, Flat/Building, Street/Area, City, Pincode)
/// - Pickup Time Window (Today / Tomorrow chips, Morning / Afternoon / Evening slots)
/// - Store Security Guarantee box
/// - "Schedule Pickup & Get OTP" CTA
/// - View 2: OTP & Confirmation View with 4-digit OTP cards,
///   Assigned Shop Executive card (Rajesh Verma, SJ-409), Pickup Summary,
///   "Done - Return to Home", and "View My Gold Plan" buttons
class CashPickupScreen extends ConsumerStatefulWidget {
  const CashPickupScreen({
    super.key,
    this.planTitle = 'Gold Savings Plan',
    this.amount,
    this.membershipId,
    this.monthFor,
  });

  final String planTitle;
  final int? amount;
  final String? membershipId;
  final int? monthFor;

  @override
  ConsumerState<CashPickupScreen> createState() => _CashPickupScreenState();
}

class _CashPickupScreenState extends ConsumerState<CashPickupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;
  final TextEditingController _personNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _altMobileController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  String _selectedDate = 'Today';
  String _selectedTimeSlot = 'Morning (10:00 AM - 01:00 PM)';
  bool _isScheduled = false;
  bool _isSubmitting = false;
  bool _isDetectingLocation = false;
  String? _selectedMembershipId;
  String _generatedOtp = '1234';
  String _generatedRequestId = 'PCK-SW-0001';

  @override
  void initState() {
    super.initState();
    final AppAuthState authState = ref.read(appAuthStateProvider);
    if (authState.userName.isNotEmpty && authState.userName != 'Patron' && authState.userName != 'Rihan') {
      _personNameController.text = authState.userName;
    }
    if (authState.userPhone.isNotEmpty) {
      String clean = authState.userPhone.replaceAll(RegExp(r'\D'), '');
      if (clean.length > 10 && clean.startsWith('91')) {
        clean = clean.substring(clean.length - 10);
      }
      _mobileController.text = clean;
    }
    if (authState.address.isNotEmpty) {
      _address1Controller.text = authState.address;
    }
    if (authState.city.isNotEmpty) {
      _cityController.text = authState.city;
    }
    if (authState.pincode.isNotEmpty) {
      _pincodeController.text = authState.pincode;
    }

    final int initialAmount = widget.amount ?? 0;
    _amountController = TextEditingController(
      text: initialAmount > 0 ? initialAmount.toString() : '',
    );

    // Refresh active memberships on appearance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardControllerProvider.notifier).loadDashboard();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _personNameController.dispose();
    _mobileController.dispose();
    _altMobileController.dispose();
    _address1Controller.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  /// Automatically detects patron GPS location and auto-populates pickup address
  Future<void> _fetchCurrentLocation() async {
    if (_isDetectingLocation) return;
    setState(() => _isDetectingLocation = true);

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are turned off. Please turn on GPS in your device settings.'),
            backgroundColor: Color(0xFF063B2C),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied. You can manually enter your pickup address.'),
              backgroundColor: Color(0xFF063B2C),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is permanently denied. You can manually type your address.'),
            backgroundColor: Color(0xFF063B2C),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      // Reverse geocode coordinates using OpenStreetMap Nominatim
      try {
        final Dio geoDio = Dio();
        final response = await geoDio.get<Map<String, dynamic>>(
          'https://nominatim.openstreetmap.org/reverse',
          queryParameters: <String, dynamic>{
            'format': 'json',
            'lat': position.latitude,
            'lon': position.longitude,
          },
          options: Options(headers: <String, String>{'User-Agent': 'SwastikKittyApp/1.0'}),
        );

        final addressData = response.data?['address'] as Map<String, dynamic>?;
        if (addressData != null) {
          final String road = addressData['road']?.toString() ??
              addressData['suburb']?.toString() ??
              addressData['neighbourhood']?.toString() ??
              '';
          final String city = addressData['city']?.toString() ??
              addressData['town']?.toString() ??
              addressData['state_district']?.toString() ??
              addressData['state']?.toString() ??
              '';
          final String postcode = addressData['postcode']?.toString() ?? '';

          if (road.isNotEmpty) _areaController.text = road;
          if (city.isNotEmpty) _cityController.text = city;
          if (postcode.isNotEmpty) _pincodeController.text = postcode;
          if (_address1Controller.text.isEmpty) {
            _address1Controller.text = 'Near $road';
          }
        }
      } catch (_) {
        if (_areaController.text.isEmpty) {
          _areaController.text = 'Near Coordinates (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location detected successfully (Lat: ${position.latitude.toStringAsFixed(3)}, Lon: ${position.longitude.toStringAsFixed(3)})'),
          backgroundColor: const Color(0xFF063B2C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not fetch GPS location: $e. You can type your address below.'),
          backgroundColor: const Color(0xFF063B2C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDetectingLocation = false);
    }
  }

  /// Opens pickup query in Google Maps so patron can verify/adjust location pin
  Future<void> _openGoogleMaps() async {
    final String query = <String>[
      _address1Controller.text.trim(),
      _areaController.text.trim(),
      _cityController.text.trim(),
      _pincodeController.text.trim(),
    ].where((String s) => s.isNotEmpty).join(', ');

    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query.isNotEmpty ? query : 'Swastik Jewellers')}',
    );

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to launch Google Maps.'),
          backgroundColor: Color(0xFF063B2C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final dashboardState = ref.read(dashboardControllerProvider);
    final DashboardSummaryEntity? scheme = dashboardState.selectedScheme ??
        (dashboardState.schemes.isNotEmpty ? dashboardState.schemes.first : dashboardState.data);

    final String membershipId = widget.membershipId?.isNotEmpty == true
        ? widget.membershipId!
        : (_selectedMembershipId ?? scheme?.membershipId ?? '');

    if (membershipId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Active Gold Savings Plan required to schedule cash pickup. Please enroll in a scheme first.'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'View Plans',
            textColor: Colors.white,
            onPressed: () => context.push(RoutePaths.offers),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final DioClient dio = ref.read(dioClientProvider);

      final String fullAddress = <String>[
        _address1Controller.text.trim(),
        _areaController.text.trim(),
        _cityController.text.trim(),
      ].where((String s) => s.isNotEmpty).join(', ');

      final int parsedAmount = int.tryParse(_amountController.text.trim()) ??
          widget.amount ??
          scheme?.nextInstallment?.amount ??
          scheme?.customMonthlyEmi ??
          5000;

      final int targetMonth = widget.monthFor ?? ((scheme?.monthsPaid ?? 0) + 1);

      final Map<String, dynamic> payload = <String, dynamic>{
        'membershipId': membershipId,
        'months': <int>[targetMonth],
        'amount': parsedAmount,
        'pickupAddress': fullAddress,
        'pickupPincode': _pincodeController.text.trim(),
        'preferredTimeSlot': '$_selectedDate - $_selectedTimeSlot',
        'contactPhone': _mobileController.text.trim(),
      };

      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/payments/cash-pickup-request',
        data: payload,
      );

      final dynamic data = response.data?['data'];
      final String returnedOtp = data?['verificationOtp']?.toString() ?? '1234';
      final String returnedReqId = data?['requestId']?.toString() ?? 'PCK-SW-0001';

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _generatedOtp = returnedOtp;
          _generatedRequestId = returnedReqId;
          _isScheduled = true;
        });

        // Invalidate dashboard controller so passbook and metrics refresh
        ref.invalidate(dashboardControllerProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pickup Scheduled! Verification OTP is $_generatedOtp'),
            backgroundColor: const Color(0xFF063B2C),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        String userError = 'Unable to schedule pickup. Please check your active gold plan.';
        if (e is DioException) {
          final resData = e.response?.data;
          if (resData is Map) {
            if (resData['message'] != null) {
              userError = resData['message'].toString();
            } else if (resData['error'] is Map && resData['error']['message'] != null) {
              userError = resData['error']['message'].toString();
            }
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userError),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _copyOtp() {
    Clipboard.setData(ClipboardData(text: _generatedOtp));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP $_generatedOtp copied to clipboard'),
        backgroundColor: const Color(0xFF063B2C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 16, top: 8, bottom: 4),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      if (_isScheduled) {
                        context.go(RoutePaths.offers);
                      } else if (context.canPop()) {
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
                    child: Center(
                      child: Text(
                        _isScheduled ? 'Cash Pickup Confirmed' : 'Doorstep Cash Pickup',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: _isScheduled ? _buildSuccessView() : _buildFormView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView() {
    final dashboardState = ref.watch(dashboardControllerProvider);
    final List<DashboardSummaryEntity> activeSchemes = dashboardState.schemes;
    final bool hasActiveMembership = widget.membershipId?.isNotEmpty == true ||
        activeSchemes.isNotEmpty ||
        (dashboardState.data?.membershipId?.isNotEmpty ?? false);

    final DashboardSummaryEntity? currentScheme = activeSchemes.isNotEmpty
        ? activeSchemes.firstWhere(
            (s) => s.membershipId == (_selectedMembershipId ?? widget.membershipId),
            orElse: () => activeSchemes.first,
          )
        : (dashboardState.selectedScheme ?? dashboardState.data);

    final String planDisplayName = widget.planTitle.isNotEmpty &&
            widget.planTitle != '11 Month Gold Plan' &&
            widget.planTitle != 'Gold Savings Plan'
        ? widget.planTitle
        : (currentScheme?.schemeName ?? 'Gold Savings Plan');

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!hasActiveMembership) ...<Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Row(
                    children: <Widget>[
                      Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No Active Gold Plan Enrolled',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Doorstep cash collection is exclusively available for paying monthly installments of an active gold plan. Please enroll in a plan first.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: Color(0xFF7F1D1D),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push(RoutePaths.offers),
                      icon: const Icon(Icons.explore_outlined, size: 16, color: Colors.white),
                      label: const Text(
                        'Explore & Enroll in Gold Plan',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF063B2C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (activeSchemes.length > 1) ...<Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEFE8DD)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'SELECT GOLD PLAN FOR CASH PICKUP',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF78716C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedMembershipId ?? activeSchemes.first.membershipId,
                    items: activeSchemes.map((s) {
                      final String tokenLabel = s.chitToken?.isNotEmpty == true ? ' (${s.chitToken})' : '';
                      final int emi = s.nextInstallment?.amount ?? s.customMonthlyEmi ?? 5000;
                      return DropdownMenuItem<String>(
                        value: s.membershipId,
                        child: Text(
                          '${s.schemeName}$tokenLabel - ₹$emi/mo',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1917),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedMembershipId = val;
                          final selected = activeSchemes.firstWhere((s) => s.membershipId == val);
                          final amt = selected.nextInstallment?.amount ?? selected.customMonthlyEmi ?? 5000;
                          _amountController.text = amt.toString();
                        });
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFAF7F2),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE7E5E4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE7E5E4)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Plan & Amount Preview Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Colors.white, Color(0xFFFAF5EC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEBE1D0)),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF063B2C),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                '💵',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  'PAYMENT FOR',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFA8A29E),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  planDisplayName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1C1917),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        const Text(
                          'Cash Amount',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            color: Color(0xFFA8A29E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${_amountController.text.isNotEmpty ? _amountController.text : (widget.amount?.toString() ?? '5,000')}',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF063B2C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFEFE8DD), height: 1),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.check_circle_rounded, color: Color(0xFF187A64), size: 15),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Free Doorstep Collection',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF187A64),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Verified Store Agent',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: Color(0xFFA8A29E),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Cash Amount to Hand Over
          _buildCardSection(
            title: 'CASH AMOUNT TO HAND OVER',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1917),
                  ),
                  decoration: const InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1917),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Color(0xFFE7E5E4)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Keep exact cash ready for a quick and smooth handover.',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    color: Color(0xFFA8A29E),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Handover Person Details
          _buildCardSection(
            title: 'CASH HANDOVER PERSON',
            child: Column(
              children: <Widget>[
                _buildInputField(
                  label: 'Name of person who will give cash *',
                  controller: _personNameController,
                  hint: 'e.g. Ramesh Kumar',
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  label: 'Mobile Number *',
                  controller: _mobileController,
                  hint: '9876543210',
                  keyboardType: TextInputType.phone,
                  prefixText: '+91 ',
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  label: 'Alternate Number (Optional)',
                  controller: _altMobileController,
                  hint: 'Secondary contact number',
                  keyboardType: TextInputType.phone,
                  isRequired: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Pickup Location
          _buildCardSection(
            title: 'PICKUP LOCATION',
            action: _isDetectingLocation
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF063B2C)),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Location Action Buttons Row
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isDetectingLocation ? null : _fetchCurrentLocation,
                        icon: _isDetectingLocation
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF063B2C)),
                              )
                            : const Icon(Icons.my_location_rounded, size: 16, color: Color(0xFF063B2C)),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _isDetectingLocation ? 'Locating...' : 'Fetch GPS',
                            maxLines: 1,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF063B2C),
                            ),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF063B2C)),
                          backgroundColor: const Color(0xFFE6F4F0).withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openGoogleMaps,
                        icon: const Icon(Icons.map_rounded, size: 16, color: Color(0xFFC88A35)),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Google Maps',
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFC88A35),
                            ),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFC88A35)),
                          backgroundColor: const Color(0xFFFAF5EC),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'Flat / House No. / Building Name *',
                  controller: _address1Controller,
                  hint: 'e.g. Flat 302, Royal Palms',
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  label: 'Area / Street / Landmark *',
                  controller: _areaController,
                  hint: 'e.g. MG Road',
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildInputField(
                        label: 'City *',
                        controller: _cityController,
                        hint: 'Mumbai',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInputField(
                        label: 'Pincode *',
                        controller: _pincodeController,
                        hint: '400001',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Pickup Time Window
          _buildCardSection(
            title: 'PICKUP TIME WINDOW',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _buildDateChip('Today (Express)', 'Today'),
                    const SizedBox(width: 10),
                    _buildDateChip('Tomorrow', 'Tomorrow'),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSlotOption('Morning (10:00 AM - 01:00 PM)', 'Available'),
                const SizedBox(height: 8),
                _buildSlotOption('Afternoon (01:00 PM - 05:00 PM)', 'Standard'),
                const SizedBox(height: 8),
                _buildSlotOption('Evening (05:00 PM - 08:00 PM)', 'Standard'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Store Security Guarantee
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4F0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC5E5DC)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF187A64),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Store Security Guarantee',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF063B2C),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'An OTP will be generated next. Only reveal that OTP when our store staff arrives and presents their official Shop Identity Badge.',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: Color(0xFF145344),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Submit CTA Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : (!hasActiveMembership
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Active Gold Savings Plan required to schedule cash pickup. Please enroll in a scheme first.'),
                              backgroundColor: const Color(0xFFDC2626),
                              behavior: SnackBarBehavior.floating,
                              action: SnackBarAction(
                                label: 'Explore Plans',
                                textColor: Colors.white,
                                onPressed: () => context.push(RoutePaths.offers),
                              ),
                            ),
                          );
                        }
                      : _handleSubmit),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasActiveMembership ? const Color(0xFF063B2C) : const Color(0xFF78716C),
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: const Color(0x33063B2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      hasActiveMembership ? 'Schedule Pickup & Get OTP' : 'Enroll in a Plan to Schedule Pickup',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 8),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFE6F4F0),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x4D187A64), width: 2),
          ),
          child: const Center(
            child: Icon(Icons.check_rounded, color: Color(0xFF063B2C), size: 36),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '● Pickup Scheduled & Confirmed',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF063B2C),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cash Pickup Requested!',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1C1917),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Our store executive has been assigned and will visit your location to collect the cash.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12.5,
            color: Color(0xFF57534E),
            height: 1.4,
          ),
        ),

        const SizedBox(height: 18),

        // OTP Display Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Colors.white, Color(0xFFFAF7F2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF063B2C), width: 2),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x1A063B2C),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              const Text(
                'PICKUP VERIFICATION OTP',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Color(0xFF063B2C),
                ),
              ),
              const SizedBox(height: 12),

              // Verification OTP digits row (4-digit patron code)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (int i = 0; i < _generatedOtp.length; i++) ...<Widget>[
                    _buildOtpBox(_generatedOtp[i]),
                    if (i < _generatedOtp.length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),

              const SizedBox(height: 14),

              // Warning Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Text(
                  'Tell this OTP to our shop executive in person when they arrive. Do not share on phone call.',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92400E),
                    height: 1.35,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Copy Button
              ElevatedButton.icon(
                onPressed: _copyOtp,
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy OTP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE6F4F0),
                  foregroundColor: const Color(0xFF063B2C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Assigned Executive Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEFE8DD)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFFAF3E8),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👨‍💼', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Rajesh Verma',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1917),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Official Executive ID: SJ-409',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11.5,
                        color: Color(0xFF57534E),
                      ),
                    ),
                    Text(
                      'Verified Jewellers Staff • Carrying Digital Scale',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF187A64),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Pickup Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEFE8DD)),
          ),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Pickup Summary',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFA8A29E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'REQ #$_generatedRequestId',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF57534E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Amount to Handover',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12.5,
                      color: Color(0xFF78716C),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${_amountController.text}',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF063B2C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Scheduled Time',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12.5,
                      color: Color(0xFF78716C),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '$_selectedDate • ${_selectedTimeSlot.split("(")[0].trim()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1917),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Action Buttons
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => context.go(RoutePaths.offers),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF063B2C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Done - Return to Home',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            onPressed: () => context.go(RoutePaths.dashboard),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1C1917),
              side: const BorderSide(color: Color(0xFFE7E5E4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(23),
              ),
            ),
            child: const Text(
              'View My Gold Plan',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildOtpBox(String digit) {
    return Container(
      width: 40,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4B886)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A063B2C),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF063B2C),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({required String title, required Widget child, Widget? action}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFE8DD)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Color(0xFF78716C),
                  ),
                ),
              ),
              if (action != null) ...<Widget>[
                const SizedBox(width: 8),
                action,
              ],
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF44403C),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1917),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFA8A29E)),
            prefixText: prefixText,
            prefixStyle: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1C1917)),
            filled: true,
            fillColor: const Color(0xFFFAF7F2).withValues(alpha: 0.6),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Color(0xFFE7E5E4)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Color(0xFFE7E5E4)),
            ),
          ),
          validator: isRequired ? (value) => value == null || value.trim().isEmpty ? 'Required' : null : null,
        ),
      ],
    );
  }

  Widget _buildDateChip(String label, String value) {
    final bool isSelected = _selectedDate == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDate = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF063B2C) : const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF063B2C) : const Color(0xFFE7E5E4),
            ),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF44403C),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlotOption(String slot, String status) {
    final bool isSelected = _selectedTimeSlot == slot;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeSlot = slot;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF7FAF9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF063B2C) : const Color(0xFFE7E5E4),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                slot,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: const Color(0xFF1C1917),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE6F4F0) : const Color(0xFFF5F5F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF187A64) : const Color(0xFFA8A29E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
