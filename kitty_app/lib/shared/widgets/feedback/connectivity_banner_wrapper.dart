import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/providers/core_providers.dart';

/// Lightweight global connectivity banner wrapper.
///
/// Overlays an animated status banner when the device loses network connectivity,
/// and momentarily confirms "Back online" when connection is restored.
///
/// Preserves the underlying screen, active inputs, and navigation completely stable.
class ConnectivityBannerWrapper extends ConsumerStatefulWidget {
  const ConnectivityBannerWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<ConnectivityBannerWrapper> createState() =>
      _ConnectivityBannerWrapperState();
}

class _ConnectivityBannerWrapperState
    extends ConsumerState<ConnectivityBannerWrapper> {
  bool? _wasOffline;
  bool _showRestoredBanner = false;
  Timer? _restoredTimer;

  @override
  void dispose() {
    _restoredTimer?.cancel();
    super.dispose();
  }

  void _onConnectivityChanged(bool isOnline) {
    if (!isOnline) {
      _wasOffline = true;
      _restoredTimer?.cancel();
      if (_showRestoredBanner) {
        setState(() {
          _showRestoredBanner = false;
        });
      }
    } else {
      if (_wasOffline == true) {
        setState(() {
          _showRestoredBanner = true;
        });
        _restoredTimer?.cancel();
        _restoredTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showRestoredBanner = false;
              _wasOffline = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(connectivityStatusProvider, (previous, next) {
      next.whenData((bool isOnline) {
        _onConnectivityChanged(isOnline);
      });
    });

    final AsyncValue<bool> connectivityState =
        ref.watch(connectivityStatusProvider);
    final bool isOffline = connectivityState.asData?.value == false;

    return Stack(
      children: <Widget>[
        // Active Application Screen (Stable & Preserved)
        widget.child,

        // Animated Offline / Back Online Banner Strip
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: child,
                );
              },
              child: isOffline
                  ? _buildOfflineBanner()
                  : (_showRestoredBanner
                      ? _buildRestoredBanner()
                      : const SizedBox.shrink()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      key: const Key('connectivity_offline_banner'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF7F1D1D), // Refined deep red / amber
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.space8),
            Text(
              'No internet connection',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoredBanner() {
    return Container(
      key: const Key('connectivity_online_banner'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF047857), // Pure emerald green
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.wifi_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.space8),
            Text(
              'Back online',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
