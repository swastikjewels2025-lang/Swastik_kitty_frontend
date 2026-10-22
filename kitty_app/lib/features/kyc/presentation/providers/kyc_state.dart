import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/kyc_entity.dart';

/// Form and lifecycle status of the KYC verification process.
enum KycFormStatus {
  initial,
  loadingStatus,
  notSubmitted,
  submitting,
  pending,
  verified,
  rejected,
  error,
}

/// Immutable state container for statutory KYC compliance.
class KycState {
  const KycState({
    this.status = KycFormStatus.initial,
    this.selectedDocType = DocTypeEnum.aadhaar,
    this.documentNumber = '',
    this.aadhaarNumber = '',
    this.panNumber = '',
    this.selectedFile,
    this.consentAccepted = false,
    this.kycResult,
    this.errorMessage,
    this.docNumberError,
    this.isDocNumberValid = false,
  });

  final KycFormStatus status;
  final DocTypeEnum selectedDocType;
  final String documentNumber;
  final String aadhaarNumber;
  final String panNumber;
  final SelectedKycFile? selectedFile;
  final bool consentAccepted;
  final KycResultEntity? kycResult;
  final String? errorMessage;
  final String? docNumberError;
  final bool isDocNumberValid;

  /// Whether the user can submit the KYC form.
  bool get canSubmit =>
      isDocNumberValid &&
      selectedFile != null &&
      consentAccepted &&
      status != KycFormStatus.submitting;

  bool get isLoading =>
      status == KycFormStatus.loadingStatus ||
      status == KycFormStatus.submitting;

  KycState copyWith({
    KycFormStatus? status,
    DocTypeEnum? selectedDocType,
    String? documentNumber,
    String? aadhaarNumber,
    String? panNumber,
    SelectedKycFile? Function()? selectedFile,
    bool? consentAccepted,
    KycResultEntity? Function()? kycResult,
    String? Function()? errorMessage,
    String? Function()? docNumberError,
    bool? isDocNumberValid,
  }) {
    return KycState(
      status: status ?? this.status,
      selectedDocType: selectedDocType ?? this.selectedDocType,
      documentNumber: documentNumber ?? this.documentNumber,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      panNumber: panNumber ?? this.panNumber,
      selectedFile:
          selectedFile != null ? selectedFile() : this.selectedFile,
      consentAccepted: consentAccepted ?? this.consentAccepted,
      kycResult: kycResult != null ? kycResult() : this.kycResult,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
      docNumberError:
          docNumberError != null ? docNumberError() : this.docNumberError,
      isDocNumberValid: isDocNumberValid ?? this.isDocNumberValid,
    );
  }
}
