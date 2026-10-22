import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_constants.dart';

/// Centralized safe URL launcher utility for external platforms (Instagram, Website catalog).
abstract final class UrlLauncherHelper {
  /// Safely launches the official Swastik Jewels Instagram profile.
  ///
  /// Attempts the primary official URL via [LaunchMode.externalApplication]
  /// to open the native Instagram app if installed. If unavailable, falls back
  /// to web URL. Displays a contextual error message if all attempts fail.
  static Future<bool> launchInstagram(BuildContext context) async {
    await HapticFeedback.lightImpact();

    // Prefer native Instagram app deep link if installed
    final Uri appUri = Uri.parse('instagram://user?username=swastikjewels_bynitingupta');
    final Uri webUri = Uri.parse(AppConstants.officialInstagramUrl);

    try {
      if (await canLaunchUrl(appUri)) {
        final bool appLaunched = await launchUrl(
          appUri,
          mode: LaunchMode.externalApplication,
        );
        if (appLaunched) return true;
      }
    } catch (_) {}

    try {
      final bool webLaunched = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
      if (webLaunched) return true;
    } catch (_) {}

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open Instagram profile.'),
          backgroundColor: Color(0xFF063B2C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return false;
  }

  /// Safely launches the official showroom jewellery web catalog.
  static Future<bool> launchJewelleryCatalog(BuildContext context) async {
    await HapticFeedback.lightImpact();

    final Uri websiteUri = Uri.parse(AppConstants.jewelleryCatalogUrl);
    try {
      final bool launched = await launchUrl(
        websiteUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
    } catch (_) {}

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open Swastik Jewellers website.'),
          backgroundColor: Color(0xFF063B2C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return false;
  }
}
