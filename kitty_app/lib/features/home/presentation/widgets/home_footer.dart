import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Clean luxury footer at the bottom of the Home page matching Screenshot 2.
///
/// Features:
/// - Clean navigation links row: About Us, Contact Us, Privacy Policy, Terms of Use, Disclaimer
/// - Subtle divider line
/// - Copyright notice
class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.border16),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.deepForestCharcoal,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.deepForestCharcoal,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryEmerald,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Column(
        children: <Widget>[
          // 1. Navigation Links Row / Wrap
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 18,
            runSpacing: 10,
            children: <Widget>[
              _FooterLink(
                label: 'About Us',
                onTap: () => _showInfoDialog(
                  context,
                  'About Us',
                  'Swastik Jewellers offers 100% BIS Hallmarked fine jewellery and digital gold schemes with guaranteed transparency, sovereign assay certification, and customer trust.',
                ),
              ),
              _FooterLink(
                label: 'Contact Us',
                onTap: () => _showInfoDialog(
                  context,
                  'Contact Us',
                  'Concierge Helpline: +91 98765 43210\nEmail: support@swastikjewel.in\nShowroom: 108 Swastik Heritage Towers, Main Ring Road, New Delhi, India.',
                ),
              ),
              _FooterLink(
                label: 'Privacy Policy',
                onTap: () => _showInfoDialog(
                  context,
                  'Privacy Policy',
                  'Your personal information and KYC documents are protected under encrypted bank-grade protocols and statutory privacy guidelines.',
                ),
              ),
              _FooterLink(
                label: 'Terms of Use',
                onTap: () => _showInfoDialog(
                  context,
                  'Terms of Use',
                  'All gold scheme transactions, booking allocations, and redemptions are governed by Swastik Jewellers standard customer agreements.',
                ),
              ),
              _FooterLink(
                label: 'Disclaimer',
                onTap: () => _showInfoDialog(
                  context,
                  'Disclaimer',
                  'Gold and bullion rates are updated daily based on national bullion market prices and may vary based on local statutory taxes and purity.',
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 2. Subtle Divider
          Container(
            height: 1,
            color: const Color(0xFFECE7DE),
            width: double.infinity,
          ),

          const SizedBox(height: 16),

          // 3. Copyright Notice
          Text(
            '© 2026 Gold Calculator India · All rights reserved',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.mutedSlateGray,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.border8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.deepForestCharcoal,
          ),
        ),
      ),
    );
  }
}
