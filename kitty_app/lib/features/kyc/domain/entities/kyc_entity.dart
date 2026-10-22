import '../../../../core/enums/app_enums.dart';

/// Represents a validated local file selected for KYC upload.
class SelectedKycFile {
  const SelectedKycFile({
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.mimeType,
  });

  final String name;
  final String path;
  final int sizeBytes;
  final String mimeType;

  bool get isImage =>
      mimeType.startsWith('image/') ||
      name.toLowerCase().endsWith('.jpg') ||
      name.toLowerCase().endsWith('.jpeg') ||
      name.toLowerCase().endsWith('.png') ||
      name.toLowerCase().endsWith('.webp');

  bool get isPdf =>
      mimeType == 'application/pdf' || name.toLowerCase().endsWith('.pdf');

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Request parameters for submitting statutory identity verification.
class KycSubmissionEntity {
  const KycSubmissionEntity({
    required this.documentType,
    required this.documentNumber,
    required this.consentAgreed,
    this.filePath,
    this.fileName,
    this.fileSizeBytes,
    this.name,
  });

  final DocTypeEnum documentType;
  final String documentNumber;
  final bool consentAgreed;
  final String? filePath;
  final String? fileName;
  final int? fileSizeBytes;
  final String? name;
}

/// Confirmation result of submitted KYC.
class KycResultEntity {
  const KycResultEntity({
    required this.referenceId,
    required this.status,
    required this.documentType,
    required this.documentNumberMasked,
    this.documentUrl,
    this.submittedAt,
    this.rejectionReason,
  });

  final String referenceId;
  final KycStatusEnum status;
  final DocTypeEnum documentType;
  final String documentNumberMasked;
  final String? documentUrl;
  final DateTime? submittedAt;
  final String? rejectionReason;
}
