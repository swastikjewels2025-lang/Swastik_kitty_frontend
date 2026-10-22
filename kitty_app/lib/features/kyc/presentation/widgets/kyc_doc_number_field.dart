import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/enums/app_enums.dart';

/// Custom formatter to insert space every 4 digits for Aadhaar: `1234 5678 9012`.
class AadhaarInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text == newValue.text) return newValue;

    final String text = newValue.text;
    final int selectionIndex = newValue.selection.end;

    // Count non-space characters before cursor in newValue
    int nonSpacesBeforeCursor = 0;
    for (int i = 0; i < selectionIndex && i < text.length; i++) {
      if (text[i] != ' ') {
        nonSpacesBeforeCursor++;
      }
    }

    final String digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    final StringBuffer buffer = StringBuffer();
    int newCursorPos = 0;
    int digitCount = 0;

    for (int i = 0; i < digitsOnly.length && i < 12; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
        if (digitCount < nonSpacesBeforeCursor) {
          newCursorPos++;
        }
      }
      buffer.write(digitsOnly[i]);
      digitCount++;
      if (digitCount <= nonSpacesBeforeCursor) {
        newCursorPos++;
      }
    }

    final String formatted = buffer.toString();
    newCursorPos = newCursorPos.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }
}

/// Formatter to convert text to uppercase.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Document number input field with live validation icons matching `kyc.html`.
class KycDocNumberField extends StatefulWidget {
  const KycDocNumberField({
    super.key,
    required this.docType,
    required this.controller,
    required this.onChanged,
    required this.isValid,
    this.errorText,
    this.enabled = true,
  });

  final DocTypeEnum docType;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isValid;
  final String? errorText;
  final bool enabled;

  @override
  State<KycDocNumberField> createState() => _KycDocNumberFieldState();
}

class _KycDocNumberFieldState extends State<KycDocNumberField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  static const Color _textPrimary = Color(0xFF0A221C);
  static const Color _textDim = Color(0xFF68726E);
  static const Color _danger = Color(0xFFEF4444);
  static const Color _success = Color(0xFF10B981);
  static const Color _inputBg = Color(0xFFFAF8F5);
  static const Color _inputBgFocus = Colors.white;
  static const Color _inputBorder = Color(0xFFEFE6DB);
  static const Color _focusBorder = Color(0xFF063B2C);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  bool _isComplete(bool isAadhaar, String text) {
    if (isAadhaar) {
      return text.replaceAll(' ', '').length >= 12;
    }
    return text.trim().length >= 10;
  }

  @override
  Widget build(BuildContext context) {
    final bool isAadhaar = widget.docType == DocTypeEnum.aadhaar;
    final String label = isAadhaar
        ? 'Aadhaar Number (12 Digits)'
        : 'PAN Card Number (10 Characters)';
    final String placeholder = isAadhaar ? 'XXXX XXXX XXXX' : 'ABCDE1234F';
    final String hint = isAadhaar ? '12 Digits' : '10 Characters';

    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final bool hasText = widget.controller.text.isNotEmpty;
    final bool isInvalid = hasError || (hasText && !widget.isValid && _isComplete(isAadhaar, widget.controller.text));

    Color borderColor = _inputBorder;
    Color bgColor = _inputBg;
    List<BoxShadow>? boxShadow;

    if (isInvalid) {
      borderColor = _danger;
      boxShadow = const <BoxShadow>[
        BoxShadow(
          color: Color(0x26EF4444),
          blurRadius: 6,
          spreadRadius: 2,
        ),
      ];
    } else if (_isFocused) {
      borderColor = _focusBorder;
      bgColor = _inputBgFocus;
      boxShadow = const <BoxShadow>[
        BoxShadow(
          color: Color(0x14063B2C),
          blurRadius: 6,
          spreadRadius: 2,
        ),
      ];
    } else if (widget.isValid) {
      borderColor = _success;
      boxShadow = const <BoxShadow>[
        BoxShadow(
          color: Color(0x2610B981),
          blurRadius: 6,
          spreadRadius: 1,
        ),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Field Label Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              hint,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: _textDim,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Input Field Container with right status icon
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: 1.2,
            ),
            boxShadow: boxShadow,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  keyboardType: isAadhaar
                      ? const TextInputType.numberWithOptions(signed: false, decimal: false)
                      : TextInputType.text,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  scrollPadding: const EdgeInsets.only(bottom: 120),
                  textCapitalization: isAadhaar
                      ? TextCapitalization.none
                      : TextCapitalization.characters,
                  inputFormatters: isAadhaar
                      ? <TextInputFormatter>[
                          AadhaarInputFormatter(),
                          LengthLimitingTextInputFormatter(14), // 12 digits + 2 spaces
                        ]
                      : <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                          UpperCaseTextFormatter(),
                          LengthLimitingTextInputFormatter(10),
                        ],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: isAadhaar ? 1.8 : 1.2,
                    color: _textPrimary,
                  ),
                  cursorColor: _focusBorder,
                  onChanged: widget.onChanged,
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: isAadhaar ? 1.8 : 1.2,
                      color: _textDim,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(
                      left: 16,
                      right: 12,
                      top: 14,
                      bottom: 14,
                    ),
                  ),
                ),
              ),

              // Validation Status Icons on the right
              if (widget.isValid) ...<Widget>[
                const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: _success,
                  ),
                ),
              ] else if (isInvalid) ...<Widget>[
                const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 20,
                    color: _danger,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Error message row
        if (hasError) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              widget.errorText!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: _danger,
                height: 1.3,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
