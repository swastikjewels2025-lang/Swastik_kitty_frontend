import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mandatory statutory legal consent checkbox matching `kyc.html`.
class KycConsentCheckbox extends StatelessWidget {
  const KycConsentCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
    this.enabled = true,
  });

  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  static const Color _checkboxBg = Color(0xFFFAF8F5);
  static const Color _checkboxBorder = Color(0xFFD6CBC0);
  static const Color _textMuted = Color(0xFF68726E);
  static const Color _activeEmerald = Color(0xFF063B2C);
  static const Color _darkHighlight = Color(0xFF0A221C);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => onChanged(!isChecked) : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Custom 20x20 Checkbox Box
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(top: 2, right: 12),
                decoration: BoxDecoration(
                  color: isChecked ? _activeEmerald : _checkboxBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isChecked ? _activeEmerald : _checkboxBorder,
                    width: 1.5,
                  ),
                  boxShadow: isChecked
                      ? const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x1F063B2C),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: isChecked
                    ? const Center(
                        child: Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),

              // Consent Text
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.8,
                      height: 1.5,
                      color: _textMuted,
                    ),
                    children: const <TextSpan>[
                      TextSpan(text: 'I agree to '),
                      TextSpan(
                        text: 'Swastik CRM',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _darkHighlight,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' securely storing and verifying my identity documents in compliance with ',
                      ),
                      TextSpan(
                        text: 'RBI & PMLA',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _darkHighlight,
                        ),
                      ),
                      TextSpan(text: ' statutory regulations.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
