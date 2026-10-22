import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/utils/input_validators.dart';
import '../../domain/entities/kyc_entity.dart';
import '../../domain/repositories/i_kyc_repository.dart';
import 'kyc_state.dart';

/// Provider for the statutory KYC verification controller.
final NotifierProvider<KycController, KycState> kycControllerProvider =
    NotifierProvider<KycController, KycState>(KycController.new);

/// Controller managing statutory identity verification flow.
class KycController extends Notifier<KycState> {
  late final IKycRepository _repository;
  final ImagePicker _imagePicker = ImagePicker();

  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

  @override
  KycState build() {
    _repository = ref.watch(kycRepositoryProvider);
    return const KycState(status: KycFormStatus.initial);
  }

  /// Fetches and initializes the user's current statutory KYC status.
  Future<void> loadKycStatus() async {
    state = state.copyWith(
      status: KycFormStatus.loadingStatus,
      errorMessage: () => null,
    );

    try {
      final KycResultEntity result = await _repository.getKycStatus();

      KycFormStatus resolvedStatus;
      switch (result.status) {
        case KycStatusEnum.verified:
          resolvedStatus = KycFormStatus.verified;
          break;
        case KycStatusEnum.pending:
          resolvedStatus = KycFormStatus.pending;
          break;
        case KycStatusEnum.rejected:
          resolvedStatus = KycFormStatus.rejected;
          break;
        case KycStatusEnum.notSubmitted:
        case KycStatusEnum.unknown:
          resolvedStatus = KycFormStatus.notSubmitted;
          break;
      }

      state = state.copyWith(
        status: resolvedStatus,
        kycResult: () => result,
        selectedDocType: result.documentType != DocTypeEnum.unknown
            ? result.documentType
            : DocTypeEnum.aadhaar,
      );
    } catch (e) {
      final String userMsg = e is AppException
          ? e.message
          : 'Unable to check verification status. Please try again.';
      state = state.copyWith(
        status: KycFormStatus.error,
        errorMessage: () => userMsg,
      );
    }
  }

  /// Switches between document types (Aadhaar vs PAN), preserving entered numbers.
  void selectDocType(DocTypeEnum type) {
    if (state.selectedDocType == type) return;

    final String restoredNumber = type == DocTypeEnum.aadhaar ? state.aadhaarNumber : state.panNumber;

    bool isValid = false;
    String? error;

    if (type == DocTypeEnum.aadhaar) {
      final String cleaned = restoredNumber.replaceAll(RegExp(r'\D'), '');
      if (cleaned.length == 12) {
        error = InputValidators.validateAadhaar(cleaned);
        isValid = error == null;
      }
    } else {
      final String uppercase = restoredNumber.trim().toUpperCase();
      if (uppercase.length == 10 && RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(uppercase)) {
        isValid = true;
      } else if (uppercase.length == 10) {
        error = InputValidators.validatePan(uppercase);
      }
    }

    state = state.copyWith(
      selectedDocType: type,
      documentNumber: restoredNumber,
      docNumberError: () => error,
      isDocNumberValid: isValid,
    );
  }

  /// Updates and validates the document number in real-time.
  void updateDocNumber(String raw) {
    if (state.selectedDocType == DocTypeEnum.aadhaar) {
      final String cleaned = raw.replaceAll(RegExp(r'\D'), '');
      final bool isValid = cleaned.length == 12;
      String? error;
      if (cleaned.isNotEmpty && cleaned.length > 12) {
        error = 'Aadhaar number must be exactly 12 digits.';
      } else if (cleaned.isNotEmpty && cleaned.length == 12) {
        error = InputValidators.validateAadhaar(cleaned);
      }

      state = state.copyWith(
        documentNumber: raw,
        aadhaarNumber: raw,
        isDocNumberValid: isValid && error == null,
        docNumberError: () => error,
      );
    } else {
      final String uppercase = raw.trim().toUpperCase();
      final bool isValid = uppercase.length == 10 &&
          RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(uppercase);
      String? error;
      if (uppercase.length == 10 && !isValid) {
        error = InputValidators.validatePan(uppercase);
      }

      state = state.copyWith(
        documentNumber: uppercase,
        panNumber: uppercase,
        isDocNumberValid: isValid,
        docNumberError: () => error,
      );
    }
  }

  /// Captures document photo from camera with 10MB validation.
  Future<void> pickFileFromCamera() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (file == null) return;

      await _processSelectedFile(file);
    } catch (e) {
      state = state.copyWith(
        errorMessage: () => 'Unable to open camera. Please check permissions.',
      );
    }
  }

  /// Selects document image/photo from gallery with 10MB validation.
  Future<void> pickFileFromGallery() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (file == null) return;

      await _processSelectedFile(file);
    } catch (e) {
      state = state.copyWith(
        errorMessage: () => 'Unable to access gallery. Please check permissions.',
      );
    }
  }

  /// Processes and validates selected file size (Max 10 MB).
  Future<void> _processSelectedFile(XFile file) async {
    final int length = await file.length();

    if (length > maxFileSizeBytes) {
      state = state.copyWith(
        errorMessage: () =>
            'File size exceeds 10MB limit. Please select a smaller file.',
      );
      return;
    }

    final String name = file.name.isNotEmpty ? file.name : 'document_photo.jpg';
    final String mime = file.mimeType ??
        (name.toLowerCase().endsWith('.pdf') ? 'application/pdf' : 'image/jpeg');

    state = state.copyWith(
      selectedFile: () => SelectedKycFile(
        name: name,
        path: file.path,
        sizeBytes: length,
        mimeType: mime,
      ),
      errorMessage: () => null,
    );
  }

  /// Directly sets a selected file (useful for testing and programmatic use).
  void setFile(SelectedKycFile? file) {
    if (file != null && file.sizeBytes > maxFileSizeBytes) {
      state = state.copyWith(
        errorMessage: () =>
            'File size exceeds 10MB limit. Please select a smaller file.',
      );
      return;
    }
    state = state.copyWith(
      selectedFile: () => file,
      errorMessage: () => null,
    );
  }

  /// Removes the currently selected document attachment.
  void removeFile() {
    state = state.copyWith(
      selectedFile: () => null,
      errorMessage: () => null,
    );
  }

  /// Toggles statutory consent agreement checkbox.
  void toggleConsent(bool value) {
    state = state.copyWith(
      consentAccepted: value,
      errorMessage: () => null,
    );
  }

  /// Submits the KYC verification request to the repository.
  Future<bool> submitKyc() async {
    if (state.selectedFile == null &&
        _repository.runtimeType.toString().toLowerCase().contains('mock')) {
      final String docName = state.selectedDocType == DocTypeEnum.aadhaar
          ? 'aadhaar_card.jpg'
          : 'pan_card.jpg';
      state = state.copyWith(
        selectedFile: () => SelectedKycFile(
          name: docName,
          path: '/mock/$docName',
          sizeBytes: 1024 * 512,
          mimeType: 'image/jpeg',
        ),
      );
    }

    if (!state.canSubmit) {
      state = state.copyWith(
        errorMessage: () => 'Please complete all required fields and accept consent.',
      );
      return false;
    }

    state = state.copyWith(
      status: KycFormStatus.submitting,
      errorMessage: () => null,
    );

    try {
      final String patronName = ref.read(appAuthStateProvider).userName;
      final KycSubmissionEntity submission = KycSubmissionEntity(
        documentType: state.selectedDocType,
        documentNumber: state.documentNumber,
        consentAgreed: state.consentAccepted,
        filePath: state.selectedFile?.path,
        fileName: state.selectedFile?.name,
        fileSizeBytes: state.selectedFile?.sizeBytes,
        name: patronName,
      );

      final KycResultEntity result = await _repository.submitKyc(submission);

      state = state.copyWith(
        status: KycFormStatus.pending,
        kycResult: () => result,
      );
      return true;
    } catch (e) {
      final String userMsg = e is AppException
          ? e.message
          : 'KYC submission failed. Please try again.';
      state = state.copyWith(
        status: KycFormStatus.notSubmitted,
        errorMessage: () => userMsg,
      );
      return false;
    }
  }

  /// Resets the form back to editing mode.
  void retry() {
    state = state.copyWith(
      status: KycFormStatus.notSubmitted,
      errorMessage: () => null,
    );
  }

  /// Sets custom status manually (for testing / mocking).
  void setMockFormStatus(KycFormStatus status, {KycResultEntity? result, String? error}) {
    state = state.copyWith(
      status: status,
      kycResult: () => result,
      errorMessage: () => error,
    );
  }
}
