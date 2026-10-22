import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/widgets/dialogs/edit_profile_dialog.dart';
import '../../../live_rates/presentation/providers/live_rate_controller.dart';
import '../../../live_rates/presentation/providers/live_rate_state.dart';

/// Helper function to display the approved `dddd/menu.html` hamburger menu
/// as a modal sheet with backdrop blur from anywhere in the app.
Future<void> openKittyMenu(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.60),
    useSafeArea: true,
    builder: (BuildContext ctx) => const KittyMenuSheet(),
  );
}

/// Native Flutter reproduction of `dddd/menu.html` (Profile & Gold Services).
///
/// Features:
/// 1. Rich Pine Emerald Header (#063B2C) with luxury decorative glow effects.
/// 2. Golden Gradient Avatar (135° #ECCF96 -> #D4A95B -> #9E742A) with user initial.
/// 3. Patron profile info (Name, Mobile, "Edit Profile" link).
/// 4. Settings & Close buttons.
/// 5. Curved Ivory Sheet (rounded-t-[32px]) containing 7 exact options:
///    - My Gold Plans (-> My Plan / Dashboard)
///    - My Bookings (-> My Orders & Bookings)
///    - Live Gold Rate (-> Live Rate screen with pulsing LIVE badge)
///    - Gold Coins (-> New Gold Coins page)
///    - Gold Calculator (-> Dedicated Calculator page)
///    - KYC Details (-> KYC screen with Verified badge)
///    - Logout (-> Confirmation dialog)
/// 6. Interactive "Edit Profile" modal dialog with Name, Surname, Mobile number.
/// 7. Logout Confirmation modal dialog.
class KittyMenuSheet extends ConsumerStatefulWidget {
  const KittyMenuSheet({super.key});

  @override
  ConsumerState<KittyMenuSheet> createState() => _KittyMenuSheetState();
}

class _KittyMenuSheetState extends ConsumerState<KittyMenuSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  static const Color _pineDark = Color(0xFF063B2C);
  static const Color _pineLight = Color(0xFF0B4D3B);
  static const Color _surfaceBg = Color(0xFFFFFFFF);
  static const Color _dividerColor = Color(0xFFF4EFE6);
  static const Color _textDark = Color(0xFF1A2120);
  static const Color _textMuted = Color(0xFF6E7876);
  static const Color _goldBase = Color(0xFFCBA258);
  static const Color _goldLight = Color(0xFFE8CA89);
  static const Color _itemBg = Color(0xFFFAF6EE);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openEditProfileDialog(BuildContext context, AppAuthState authState) {
    showEditProfileDialog(context, authState: authState);
  }

  void _openLogoutConfirmDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      builder: (BuildContext ctx) => _LogoutConfirmDialog(
        onConfirm: () async {
          Navigator.of(ctx).pop(); // Close dialog
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(); // Close menu
          }
          await ref.read(appAuthStateProvider.notifier).logout();
          if (context.mounted) {
            context.go(RoutePaths.login);
          }
        },
      ),
    );
  }

  void _navigate(String routePath) {
    HapticFeedback.selectionClick();
    final GoRouter router = GoRouter.of(context);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    if (routePath == RoutePaths.liveRates ||
        routePath == RoutePaths.coinRates ||
        routePath == RoutePaths.orders ||
        routePath == RoutePaths.kyc ||
        routePath == RoutePaths.settings ||
        routePath == RoutePaths.passbook) {
      router.push(routePath);
    } else {
      router.go(routePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppAuthState authState = ref.watch(appAuthStateProvider);
    final LiveRateState rateState = ref.watch(liveRateControllerProvider);

    final double gold24k = rateState.data?.rate24k ?? 7485.0;
    final String formattedGold24k = NumberFormat('#,##,###').format(gold24k.round());

    final String displayName = authState.userName.trim().isNotEmpty
        ? authState.userName.trim()
        : 'Mahak Garg';
    final String displayPhone = authState.userPhone.trim().isNotEmpty
        ? authState.userPhone.trim()
        : '+91 98765 43210';
    final String initialLetter = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'M';

    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.94,
      ),
      decoration: const BoxDecoration(
        color: _pineDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // =================================================================
            // 1. RICH EMERALD PROFILE HEADER
            // =================================================================
            Container(
              color: _pineDark,
              child: Stack(
                children: <Widget>[
                  // Decorative Blur Glows matching menu.html lines 109-110
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _pineLight.withValues(alpha: 0.35),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 60,
                    bottom: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _goldBase.withValues(alpha: 0.12),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: const SizedBox.shrink(),
                      ),
                    ),
                  ),

                  // Header Content Row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Top Drag Pill + Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.30),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                // Settings Gear Icon
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _navigate(RoutePaths.settings),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.10),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.15),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.settings_outlined,
                                          color: Colors.white,
                                          size: 19,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Close Button (X)
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => Navigator.of(context).pop(),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.10),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.15),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Avatar + User Details
                        Row(
                          children: <Widget>[
                            // Golden Gradient Avatar (matching menu.html .gold-gradient-avatar)
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: <Color>[
                                    Color(0xFFECCF96),
                                    Color(0xFFD4A95B),
                                    Color(0xFF9E742A),
                                  ],
                                  stops: <double>[0.0, 0.45, 1.0],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 2.0,
                                ),
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  initialLetter,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 27,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: const <Shadow>[
                                      Shadow(
                                        color: Color(0x40000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Profile Details & Edit Profile Action
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    displayName,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    displayPhone,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withValues(alpha: 0.82),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () => _openEditProfileDialog(context, authState),
                                    borderRadius: BorderRadius.circular(4),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            'Edit Profile',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: _goldLight,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(
                                            Icons.chevron_right_rounded,
                                            size: 15,
                                            color: _goldLight,
                                          ),
                                        ],
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
                  ),
                ],
              ),
            ),

            // =================================================================
            // 2. ROUNDED WHITE/IVORY BODY SHEET (matching menu.html rounded-t-[32px])
            // =================================================================
            Flexible(
              child: Container(
                decoration: const BoxDecoration(
                  color: _surfaceBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                  child: Column(
                    children: <Widget>[
                      // 1. My Gold Plans
                      _buildMenuItem(
                        iconWidget: const Icon(
                          Icons.assignment_outlined,
                          size: 21,
                          color: _textDark,
                        ),
                        iconBg: _itemBg,
                        title: 'My Gold Plans',
                        subtitle: '1 Active Plan',
                        onTap: () => _navigate(RoutePaths.dashboard),
                      ),

                      // 2. My Bookings
                      _buildMenuItem(
                        iconWidget: const Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: _textDark,
                        ),
                        iconBg: _itemBg,
                        title: 'My Bookings',
                        subtitle: 'View your jewellery bookings',
                        onTap: () => _navigate(RoutePaths.orders),
                      ),

                      // 3. Live Gold Rate (With Live Ticker Badge)
                      _buildMenuItem(
                        iconWidget: const Icon(
                          Icons.trending_up_rounded,
                          size: 22,
                          color: Color(0xFFB45309), // amber-700
                        ),
                        iconBg: const Color(0xFFFEF3C7), // amber-50
                        title: 'Live Gold Rate',
                        titleBadge: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) => Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF059669).withValues(
                                      alpha: _pulseAnimation.value,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF065F46),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        subtitle: '24K: ₹$formattedGold24k/g (+0.42%)',
                        onTap: () => _navigate(RoutePaths.liveRates),
                      ),

                      // 4. Gold Coins (Bullion & Mint)
                      _buildMenuItem(
                        iconWidget: const Icon(
                          Icons.monetization_on_outlined,
                          size: 22,
                          color: Color(0xFFB87A1E),
                        ),
                        iconBg: const Color(0xFFFFF6E5),
                        title: 'Gold Coins',
                        subtitle: '24K 999 certified coins & bars',
                        onTap: () => _navigate(RoutePaths.coinRates),
                      ),

                      // 5. Gold Calculator (Interactive Valuation)
                      _buildMenuItem(
                        iconWidget: const Icon(
                          Icons.calculate_outlined,
                          size: 22,
                          color: Color(0xFF065F46), // emerald-800
                        ),
                        iconBg: const Color(0xFFECFDF5), // emerald-50
                        title: 'Gold Calculator',
                        subtitle: 'Calculate rate, making & GST',
                        onTap: () => _navigate(RoutePaths.calculator),
                      ),

                      // Doorstep Cash Pickup
                      _buildMenuItem(
                        iconWidget: const Icon(
                          Icons.local_shipping_outlined,
                          size: 22,
                          color: Color(0xFF063B2C),
                        ),
                        iconBg: const Color(0xFFE8F5E9),
                        title: 'Doorstep Cash Pickup',
                        titleBadge: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFDE68A),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            'FREE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFB45309),
                            ),
                          ),
                        ),
                        subtitle: 'Cash collection from your home',
                        onTap: () => _navigate(RoutePaths.cashPickup),
                      ),

                      // 6. KYC Details
                      _buildMenuItem(
                        iconWidget: const Icon(
                          Icons.badge_outlined,
                          size: 21,
                          color: _textDark,
                        ),
                        iconBg: _itemBg,
                        title: 'KYC Details',
                        titleBadge: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFA7F3D0),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            authState.isKycVerified ? 'Verified' : 'Pending',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ),
                        subtitle: 'Manage your account verification',
                        onTap: () => _navigate(RoutePaths.kyc),
                      ),

                      // 7. Logout Action
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _openLogoutConfirmDialog(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.logout_rounded,
                                        size: 21,
                                        color: Color(0xFFE04F43),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    'Logout',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFE04F43),
                                      letterSpacing: 0.2,
                                    ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required Widget iconWidget,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? titleBadge,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _dividerColor, width: 1.0),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.black.withValues(alpha: 0.03),
          highlightColor: Colors.black.withValues(alpha: 0.02),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
            child: Row(
              children: <Widget>[
                // Icon Box
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: iconWidget),
                ),

                const SizedBox(width: 14),

                // Labels
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (titleBadge != null) ...<Widget>[
                            const SizedBox(width: 8),
                            titleBadge,
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Chevron
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0xFFA8B2B0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Edit Profile Dialog matching `menu.html` aesthetic and Requirement 6.
class _EditProfileDialog extends ConsumerStatefulWidget {
  const _EditProfileDialog({required this.authState});

  final AppAuthState authState;

  @override
  ConsumerState<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<_EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _phoneController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final List<String> parts = widget.authState.userName.trim().split(' ');
    final String firstName = parts.isNotEmpty ? parts.first : '';
    final String surname = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    _nameController = TextEditingController(text: firstName);
    _surnameController = TextEditingController(text: surname);
    _phoneController = TextEditingController(text: widget.authState.userPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final String name = _nameController.text.trim();
    final String surname = _surnameController.text.trim();
    final String phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final String fullName = surname.isNotEmpty ? '$name $surname' : name;

    await ref.read(appAuthStateProvider.notifier).updateProfile(
      userName: fullName,
      userPhone: phone,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF063B2C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Title & Subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Edit Profile',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A2120),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF6E7876)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Update your personal information below',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6E7876),
              ),
            ),

            const SizedBox(height: 18),

            // Name Field
            _buildField(
              label: 'First Name',
              controller: _nameController,
              hint: 'Enter your name',
            ),

            const SizedBox(height: 12),

            // Surname Field
            _buildField(
              label: 'Surname',
              controller: _surnameController,
              hint: 'Enter your surname',
            ),

            const SizedBox(height: 12),

            // Mobile Number Field
            _buildField(
              label: 'Mobile Number',
              controller: _phoneController,
              hint: '+91 98765 43210',
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 22),

            // Actions Row
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A2120),
                      side: const BorderSide(color: Color(0xFFEFE7DA)),
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
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF063B2C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save Changes',
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A2120),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2120),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: const Color(0xFFA8B2B0),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
            ),
          ),
        ),
      ],
    );
  }
}

/// Logout Confirmation Dialog strictly matching `menu.html` lines 518-538.
class _LogoutConfirmDialog extends StatelessWidget {
  const _LogoutConfirmDialog({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Red Circular Logout Icon
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFE04F43),
                  size: 24,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Heading
            Text(
              'Log Out?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2120),
              ),
            ),

            const SizedBox(height: 6),

            // Subtitle
            Text(
              'Are you sure you want to sign out from your gold account?',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6E7876),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 22),

            // Buttons Row
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A2120),
                      side: const BorderSide(color: Color(0xFFEFE7DA)),
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
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE04F43),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Log Out',
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
}
