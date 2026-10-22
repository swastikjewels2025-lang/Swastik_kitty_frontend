import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/routing/route_paths.dart';
import '../providers/auth_controller.dart';

/// User Details & Nominee Registration Screen for post-login onboarding.
///
/// Multi-step progressive flow:
/// - Step 1 of 3: Personal Details (First Name, Last Name, Phone, Email)
/// - Step 2 of 3: Address & Birth Date (DOB, Residential Address, City, Pincode) - Skippable!
/// - Step 3 of 3: Nominee Details (Nominee Name, Relationship, Nominee Phone)
///
/// Features:
/// - Light cream background #FAF7F2, Deep Emerald #063B2C & Royal Gold #C88A35.
/// - Uncramped, responsive City & Pincode layout with single-line labels and 6-digit validation.
/// - Step 2 (Address/DOB) is skippable via top bar button or secondary action.
/// - Step 3 (Nominee) is also skippable.
/// - Persists all details to AuthState and Backend MongoDB.
/// - Directly navigates to KYC Screen.
class RegisterProfileScreen extends ConsumerStatefulWidget {
  const RegisterProfileScreen({super.key});

  @override
  ConsumerState<RegisterProfileScreen> createState() =>
      _RegisterProfileScreenState();
}

class _RegisterProfileScreenState
    extends ConsumerState<RegisterProfileScreen> {
  final GlobalKey<FormState> _step1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step2FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step3FormKey = GlobalKey<FormState>();

  int _currentStep = 1; // 1 = Personal Details, 2 = Address & DOB, 3 = Nominee Details

  // Step 1 Controllers (Personal Details)
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;

  // Step 2 Controllers (Address & DOB)
  late final TextEditingController _dobController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _pincodeController;

  // Step 3 Controllers (Nominee Details)
  late final TextEditingController _nomineeNameController;
  late final TextEditingController _nomineePhoneController;
  String _selectedRelationship = 'Spouse';

  bool _isSubmitting = false;

  static const List<String> _relationshipOptions = <String>[
    'Spouse',
    'Father',
    'Mother',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final AppAuthState appAuth = ref.read(appAuthStateProvider);
    final AuthFlowState authFlow = ref.read(authControllerProvider);

    // Only prefill real names, never dummy fallback placeholders
    final String rawName = appAuth.userName.isNotEmpty
        ? appAuth.userName
        : (authFlow.authSession?.user.name ?? '');
    final String initialName = (rawName.isNotEmpty &&
            rawName != 'Patron' &&
            rawName != 'Rihan' &&
            rawName != 'Google Patron')
        ? rawName
        : '';

    String initialFirstName = '';
    String initialLastName = '';
    if (initialName.isNotEmpty) {
      final List<String> parts = initialName.trim().split(RegExp(r'\s+'));
      initialFirstName = parts.first;
      if (parts.length > 1) {
        initialLastName = parts.sublist(1).join(' ');
      }
    }

    // Only prefill real emails, never dummy placeholders
    final String rawEmail = appAuth.userEmail.isNotEmpty
        ? appAuth.userEmail
        : (authFlow.authSession?.user.email ?? '');
    final String initialEmail =
        (rawEmail.isNotEmpty && rawEmail != 'rihan@swastikjewel.com')
            ? rawEmail
            : '';

    final String initialMobile = appAuth.userPhone.isNotEmpty
        ? appAuth.userPhone
        : (authFlow.phone.isNotEmpty
            ? '${authFlow.countryCode} ${authFlow.phone}'.trim()
            : (authFlow.authSession?.user.phone ?? ''));

    final String initialDob =
        appAuth.userDob.isNotEmpty ? appAuth.userDob : '';
    final String initialAddress =
        appAuth.address.isNotEmpty ? appAuth.address : '';
    final String initialCity = appAuth.city.isNotEmpty ? appAuth.city : '';
    final String initialPincode =
        appAuth.pincode.isNotEmpty ? appAuth.pincode : '';

    final String initialNomName =
        appAuth.nomineeName.isNotEmpty ? appAuth.nomineeName : '';
    final String initialNomPhone =
        appAuth.nomineePhone.isNotEmpty ? appAuth.nomineePhone : '';
    if (appAuth.nomineeRelation.isNotEmpty &&
        _relationshipOptions.contains(appAuth.nomineeRelation)) {
      _selectedRelationship = appAuth.nomineeRelation;
    }

    _firstNameController = TextEditingController(text: initialFirstName);
    _lastNameController = TextEditingController(text: initialLastName);
    _mobileController = TextEditingController(text: initialMobile);
    _emailController = TextEditingController(text: initialEmail);

    _dobController = TextEditingController(text: initialDob);
    _addressController = TextEditingController(text: initialAddress);
    _cityController = TextEditingController(text: initialCity);
    _pincodeController = TextEditingController(text: initialPincode);

    _nomineeNameController = TextEditingController(text: initialNomName);
    _nomineePhoneController = TextEditingController(text: initialNomPhone);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _nomineeNameController.dispose();
    _nomineePhoneController.dispose();
    super.dispose();
  }

  String get _fullName {
    final String first = _firstNameController.text.trim();
    final String last = _lastNameController.text.trim();
    if (first.isEmpty) return last;
    if (last.isEmpty) return first;
    return '$first $last';
  }

  Future<void> _selectDateOfBirth() async {
    await HapticFeedback.selectionClick();
    DateTime initial = DateTime(1998, 1, 1);
    try {
      final List<String> parts = _dobController.text.split('/');
      if (parts.length == 3) {
        final int d = int.parse(parts[0]);
        final int m = int.parse(parts[1]);
        final int y = int.parse(parts[2]);
        initial = DateTime(y, m, d);
      }
    } catch (_) {}

    if (!mounted) return;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      helpText: 'Select Date of Birth (18+ required)',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF063B2C),
              onPrimary: Colors.white,
              onSurface: Color(0xFF101915),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _handleNextToStep2() {
    if (!_step1FormKey.currentState!.validate()) return;

    // Persist progress to local auth state
    ref.read(appAuthStateProvider.notifier).updateProfile(
          userName: _fullName,
          userEmail: _emailController.text.trim(),
          userPhone: _mobileController.text.trim(),
        );

    setState(() {
      _currentStep = 2;
    });
  }

  void _handleNextToNominee() {
    // If any address or DOB is entered, validate format
    final String dob = _dobController.text.trim();
    final String address = _addressController.text.trim();
    final String city = _cityController.text.trim();
    final String pincode = _pincodeController.text.trim();

    final bool hasEnteredAny =
        dob.isNotEmpty || address.isNotEmpty || city.isNotEmpty || pincode.isNotEmpty;
    if (hasEnteredAny) {
      if (!_step2FormKey.currentState!.validate()) return;
    }

    // Persist progress to local auth state
    ref.read(appAuthStateProvider.notifier).updateProfile(
          userName: _fullName,
          userDob: dob,
          address: address,
          city: city,
          pincode: pincode,
        );

    setState(() {
      _currentStep = 3;
    });
  }

  void _handleSkipStep2() {
    setState(() {
      _currentStep = 3;
    });
  }

  Future<void> _handleSubmitAll({bool skipNominee = false}) async {
    if (!skipNominee) {
      if (!_step3FormKey.currentState!.validate()) return;
    }

    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final String name = _fullName;
    final String email = _emailController.text.trim();
    final String phone = _mobileController.text.trim();
    final String dob = _dobController.text.trim();
    final String address = _addressController.text.trim();
    final String city = _cityController.text.trim();
    final String pincode = _pincodeController.text.trim();

    final String nomineeName = skipNominee ? '' : _nomineeNameController.text.trim();
    final String nomineePhone = skipNominee ? '' : _nomineePhoneController.text.trim();
    final String nomineeRelation = skipNominee ? '' : _selectedRelationship;

    // 1. Persist updated user & nominee details into global auth state and secure storage
    await ref.read(appAuthStateProvider.notifier).updateProfile(
          userName: name,
          userEmail: email,
          userPhone: phone,
          userDob: dob,
          address: address,
          city: city,
          pincode: pincode,
          nomineeName: nomineeName,
          nomineeRelation: nomineeRelation,
          nomineePhone: nomineePhone,
          isOnboarded: true,
        );

    // Also update session in authController if active
    try {
      final AuthController authController = ref.read(authControllerProvider.notifier);
      final AuthFlowState currentFlow = ref.read(authControllerProvider);
      if (currentFlow.authSession != null) {
        final updatedUser = currentFlow.authSession!.user.copyWith(
          name: name,
          email: email,
          phone: phone,
          address: address,
          city: city,
          pincode: pincode,
          nomineeName: nomineeName,
          nomineeRelationship: nomineeRelation,
          nomineePhone: nomineePhone,
        );
        final updatedSession = currentFlow.authSession!.copyWith(user: updatedUser);
        authController.updateSession(updatedSession);
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      // 2. Navigate directly to KYC per statutory requirement
      await context.push(RoutePaths.kyc);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 1,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        if (_currentStep == 3) {
          setState(() => _currentStep = 2);
        } else if (_currentStep == 2) {
          setState(() => _currentStep = 1);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF7F2),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              // Top Navigation Bar
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 12, bottom: 4, right: 16),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        if (_currentStep == 3) {
                          setState(() => _currentStep = 2);
                        } else if (_currentStep == 2) {
                          setState(() => _currentStep = 1);
                        } else if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RoutePaths.login);
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF101915),
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    if (_currentStep == 2)
                      TextButton(
                        key: const Key('btn_skip_step2'),
                        onPressed: _handleSkipStep2,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFC88A35),
                          ),
                        ),
                      ),
                    if (_currentStep == 3)
                      TextButton(
                        key: const Key('btn_skip_step3'),
                        onPressed: () => _handleSubmitAll(skipNominee: true),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFC88A35),
                          ),
                        ),
                      ),
                    if (_currentStep > 1) const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF3E8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEFE6DB)),
                      ),
                      child: Text(
                        'Step $_currentStep of 3',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC88A35),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Form Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _currentStep == 1
                      ? _buildPersonalStep()
                      : (_currentStep == 2
                          ? _buildAddressStep()
                          : _buildNomineeStep()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Step 1: First Name, Last Name, Phone Number, Email Address
  Widget _buildPersonalStep() {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 8),

          // Screen Title
          Center(
            child: Text(
              'User Details',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B1F19),
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Enter your personal details to begin\nyour gold investment journey.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF636D69),
                height: 1.45,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Field 1: First Name Card
          _buildFieldCard(
            fieldKey: const Key('input_profile_name'),
            icon: Icons.person_outline_rounded,
            label: 'First Name',
            controller: _firstNameController,
            keyboardType: TextInputType.name,
            hintText: 'Enter your first name',
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your first name';
              }
              if (value.trim().length < 2) {
                return 'First name must be at least 2 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Field 2: Last Name Card
          _buildFieldCard(
            fieldKey: const Key('input_profile_last_name'),
            icon: Icons.badge_outlined,
            label: 'Last Name',
            controller: _lastNameController,
            keyboardType: TextInputType.name,
            hintText: 'Enter your last name',
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Field 3: Phone Number Card
          _buildFieldCard(
            fieldKey: const Key('input_profile_phone'),
            icon: Icons.phone_android_rounded,
            label: 'Phone Number',
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            hintText: '+91 98765 43210',
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              final String digits = value.replaceAll(RegExp(r'\D'), '');
              if (digits.length < 10) {
                return 'Please enter a valid 10-digit mobile number';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Field 4: Email Address Card
          _buildFieldCard(
            fieldKey: const Key('input_profile_email'),
            icon: Icons.mail_outline_rounded,
            label: 'Email Address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            hintText: 'name@example.com',
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email address';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),

          const SizedBox(height: 28),

          // NEXT CTA Button
          SizedBox(
            height: 54,
            child: ElevatedButton(
              key: const Key('btn_profile_submit'),
              onPressed: _handleNextToStep2,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF063B2C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'NEXT: ADDRESS & BIRTH DATE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  /// Step 2: Date of Birth & Address (Skippable)
  Widget _buildAddressStep() {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 8),

          // Screen Title
          Center(
            child: Text(
              'Address & Birth Date',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B1F19),
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Provide your residential address and birth date for vault delivery and statutory records.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF636D69),
                height: 1.45,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Field 1: Date of Birth Card
          _buildFieldCard(
            fieldKey: const Key('input_profile_dob'),
            icon: Icons.calendar_today_rounded,
            label: 'Date of Birth (DD/MM/YYYY)',
            controller: _dobController,
            keyboardType: TextInputType.datetime,
            hintText: 'DD/MM/YYYY',
            suffixIcon: IconButton(
              icon: const Icon(Icons.date_range_rounded,
                  color: Color(0xFF063B2C)),
              onPressed: _selectDateOfBirth,
            ),
            onTap: _selectDateOfBirth,
            readOnly: true,
            validator: (String? value) {
              if (value != null && value.trim().isNotEmpty) {
                final List<String> parts = value.trim().split('/');
                if (parts.length != 3) {
                  return 'Use DD/MM/YYYY format';
                }
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Field 2: Residential Address Card
          _buildFieldCard(
            fieldKey: const Key('input_profile_address'),
            icon: Icons.home_outlined,
            label: 'Residential Address (House / Flat / Street)',
            controller: _addressController,
            keyboardType: TextInputType.streetAddress,
            hintText: 'e.g. Flat 302, Royal Palms Residency, MG Road',
            validator: (String? value) {
              if (value != null &&
                  value.trim().isNotEmpty &&
                  value.trim().length < 5) {
                return 'Address must be at least 5 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Field 3 & 4: City & Pincode Row (Equal 1:1 Flex, Compact, Single-line Labels, 6-digit Pincode)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _buildFieldCard(
                  fieldKey: const Key('input_profile_city'),
                  icon: Icons.location_city_rounded,
                  label: 'City',
                  controller: _cityController,
                  keyboardType: TextInputType.text,
                  hintText: 'e.g. Mumbai',
                  compact: true,
                  validator: (String? value) {
                    if (value != null &&
                        value.trim().isNotEmpty &&
                        value.trim().length < 2) {
                      return 'Min 2 chars';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFieldCard(
                  fieldKey: const Key('input_profile_pincode'),
                  icon: Icons.pin_drop_outlined,
                  label: 'Pincode',
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  hintText: '400001',
                  compact: true,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (String? value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final String clean =
                          value.replaceAll(RegExp(r'\D'), '');
                      if (clean.length != 6) {
                        return 'Must be 6 digits';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // NEXT CTA Button
          SizedBox(
            height: 54,
            child: ElevatedButton(
              key: const Key('btn_address_next'),
              onPressed: _handleNextToNominee,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF063B2C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'NEXT: NOMINEE DETAILS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Secondary Skip Button
          Center(
            child: TextButton(
              key: const Key('btn_skip_step2_bottom'),
              onPressed: _handleSkipStep2,
              child: Text(
                'Skip this step for now',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC88A35),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Step 3: Nominee Details
  Widget _buildNomineeStep() {
    return Form(
      key: _step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 8),

          Center(
            child: Text(
              'Nominee Details',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B1F19),
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Assign a legal nominee for your gold savings scheme\nbenefits and statutory gold inheritance.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF636D69),
                height: 1.45,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Nominee Name
          _buildFieldCard(
            fieldKey: const Key('input_nominee_name'),
            icon: Icons.person_add_alt_1_rounded,
            label: 'Nominee Full Name',
            controller: _nomineeNameController,
            keyboardType: TextInputType.name,
            hintText: 'Enter nominee name',
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter nominee full name';
              }
              if (value.trim().length < 2) {
                return 'Nominee name must be at least 2 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Nominee Relationship Dropdown
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEFE8DE)),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.people_alt_outlined,
                      color: Color(0xFFC88A35), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Relationship with Patron',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7A8682),
                        ),
                      ),
                      const SizedBox(height: 2),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRelationship,
                          isDense: true,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF063B2C)),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF101915),
                          ),
                          items: _relationshipOptions.map((String rel) {
                            return DropdownMenuItem<String>(
                              value: rel,
                              child: Text(rel),
                            );
                          }).toList(),
                          onChanged: (String? val) {
                            if (val != null) {
                              setState(() => _selectedRelationship = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Nominee Mobile Number
          _buildFieldCard(
            fieldKey: const Key('input_nominee_phone'),
            icon: Icons.phone_android_rounded,
            label: 'Nominee Mobile Number',
            controller: _nomineePhoneController,
            keyboardType: TextInputType.phone,
            hintText: '10-digit mobile number',
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter nominee phone number';
              }
              final String digits = value.replaceAll(RegExp(r'\D'), '');
              if (digits.length < 10) {
                return 'Please enter a valid 10-digit mobile number';
              }
              return null;
            },
          ),

          const SizedBox(height: 18),

          // Compliance & Security Guarantee Note
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
                const Icon(Icons.shield_outlined,
                    color: Color(0xFF063B2C), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Nominee protection: In the event of unforeseen circumstances, all accumulated gold weight and scheme maturity benefits will be disbursed to the registered nominee per legal guidelines.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.0,
                      color: const Color(0xFF145344),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Submit & Proceed CTA Button
          SizedBox(
            height: 54,
            child: ElevatedButton(
              key: const Key('btn_nominee_submit'),
              onPressed: _isSubmitting
                  ? null
                  : () => _handleSubmitAll(skipNominee: false),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF063B2C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'CONFIRM & PROCEED TO KYC',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // Secondary Skip Nominee Button
          Center(
            child: TextButton(
              key: const Key('btn_skip_step3_bottom'),
              onPressed: _isSubmitting
                  ? null
                  : () => _handleSubmitAll(skipNominee: true),
              child: Text(
                'Skip nominee for now',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC88A35),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFieldCard({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required FormFieldValidator<String> validator,
    String? hintText,
    Widget? suffixIcon,
    VoidCallback? onTap,
    bool readOnly = false,
    bool compact = false,
    List<TextInputFormatter>? inputFormatters,
    Key? fieldKey,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFE8DE)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 12 : 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: compact ? 34 : 42,
            height: compact ? 34 : 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF5EB),
              borderRadius: BorderRadius.circular(compact ? 10 : 12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFC88A35),
              size: compact ? 17 : 20,
            ),
          ),
          SizedBox(width: compact ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: compact ? 12.0 : 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7A8682),
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  key: fieldKey,
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  validator: validator,
                  readOnly: readOnly,
                  onTap: onTap,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: compact ? 14.5 : 15.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF101915),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: hintText,
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: compact ? 13.0 : 14.0,
                      color: const Color(0xFFA8A29E),
                      fontWeight: FontWeight.w400,
                    ),
                    contentPadding: const EdgeInsets.only(top: 2, bottom: 2),
                    border: InputBorder.none,
                    errorStyle: const TextStyle(fontSize: 11, height: 1.1),
                  ),
                ),
              ],
            ),
          ),
          ?suffixIcon,
        ],
      ),
    );
  }
}
