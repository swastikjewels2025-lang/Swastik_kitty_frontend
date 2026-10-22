import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/enums/app_enums.dart';

/// Document selector tab widget matching `kyc.html` / `kyc.css`.
class KycDocTabs extends StatelessWidget {
  const KycDocTabs({
    super.key,
    required this.selectedDocType,
    required this.onDocTypeChanged,
    this.enabled = true,
  });

  final DocTypeEnum selectedDocType;
  final ValueChanged<DocTypeEnum> onDocTypeChanged;
  final bool enabled;

  static const Color _tabGroupBg = Color(0xFFF3EDE4);
  static const Color _tabBorder = Color(0xFFEFE6DB);
  static const Color _textMuted = Color(0xFF68726E);
  static const Color _activeBg = Color(0xFF063B2C);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'SELECT DOCUMENT TYPE',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0A221C),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _tabGroupBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _tabBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _buildTab(
                  type: DocTypeEnum.aadhaar,
                  label: 'Aadhaar Card',
                  icon: Icons.badge_outlined,
                  isSelected: selectedDocType == DocTypeEnum.aadhaar,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildTab(
                  type: DocTypeEnum.pan,
                  label: 'PAN Card',
                  icon: Icons.credit_card_outlined,
                  isSelected: selectedDocType == DocTypeEnum.pan,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab({
    required DocTypeEnum type,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => onDocTypeChanged(type) : null,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? _activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x1F063B2C),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : _textMuted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : _textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
