import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../buttons/kitty_secondary_button.dart';

/// KYC & Document upload dropzone foundation for Kitty App.
///
/// Implements the media capture dropzone matching `kyc.html` / `kyc.css`.
/// Supports empty state with upload triggers, and selected file preview mode.
class KittyDropzone extends StatelessWidget {
  const KittyDropzone({
    super.key,
    this.title = 'Upload Document',
    this.subtitle = 'Supports JPG, PNG, PDF (Max 10MB)',
    this.selectedFileName,
    this.selectedFileSize,
    this.previewWidget,
    this.onTakePhoto,
    this.onChooseFile,
    this.onRemoveFile,
    this.isLoading = false,
    this.isDarkSurface = true,
  });

  /// Main label.
  final String title;

  /// Helper format and size note.
  final String subtitle;

  /// Name of the currently selected file (if any).
  final String? selectedFileName;

  /// Formatted size of selected file (e.g. "2.4 MB").
  final String? selectedFileSize;

  /// Optional custom preview thumbnail widget.
  final Widget? previewWidget;

  /// Camera trigger callback.
  final VoidCallback? onTakePhoto;

  /// Gallery / file picker callback.
  final VoidCallback? onChooseFile;

  /// Remove selected file callback.
  final VoidCallback? onRemoveFile;

  /// Whether upload is actively in progress.
  final bool isLoading;

  /// Surface mode.
  final bool isDarkSurface;

  bool get hasFile => selectedFileName != null && selectedFileName!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDarkSurface
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

    final Color subColor = isDarkSurface
        ? AppColors.emeraldTextSubtle
        : AppColors.textSecondaryMuted;

    final Color bgColor = isDarkSurface
        ? const Color(0xD8041913)
        : AppColors.surfaceCardBg;

    final Color borderColor = isDarkSurface
        ? AppColors.goldBorder
        : AppColors.surfaceCardBorder;

    if (hasFile) {
      return Container(
        padding: AppSpacing.all16,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.border14,
          border: Border.all(
            color: AppColors.goldPrimary,
            width: 1.2,
          ),
        ),
        child: Row(
          children: <Widget>[
            if (previewWidget != null)
              previewWidget!
            else
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.goldSubtle,
                  borderRadius: AppRadius.border10,
                ),
                child: const Center(
                  child: Icon(
                    Icons.description_outlined,
                    color: AppColors.goldPrimary,
                    size: 24,
                  ),
                ),
              ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    selectedFileName!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (selectedFileSize != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      selectedFileSize!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: subColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onRemoveFile != null && !isLoading)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.statusErrorText,
                onPressed: onRemoveFile,
                tooltip: 'Remove document',
              ),
          ],
        ),
      );
    }

    return Container(
      padding: AppSpacing.all20,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.border14,
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.goldSubtle,
            ),
            child: const Center(
              child: Icon(
                Icons.cloud_upload_outlined,
                size: 26,
                color: AppColors.goldPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: subColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space16),
          Wrap(
            spacing: AppSpacing.space8,
            runSpacing: AppSpacing.space8,
            alignment: WrapAlignment.center,
            children: <Widget>[
              if (onTakePhoto != null)
                KittySecondaryButton(
                  label: 'Take Photo',
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  onPressed: onTakePhoto,
                  isDarkSurface: isDarkSurface,
                ),
              if (onChooseFile != null)
                KittySecondaryButton(
                  label: 'Choose File',
                  icon: const Icon(Icons.folder_open_outlined, size: 16),
                  onPressed: onChooseFile,
                  isDarkSurface: isDarkSurface,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
