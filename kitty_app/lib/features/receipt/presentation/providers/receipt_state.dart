import '../../domain/entities/receipt_entity.dart';

/// Presentation status states for Digital Receipt experience.
enum ReceiptStatus {
  initial,
  loading,
  available,
  generating,
  error,
}

/// Immutable state container for the Digital Receipt screen / modal.
class ReceiptState {
  const ReceiptState({
    required this.status,
    this.receipt,
    this.errorMessage,
    this.isOpeningPdf = false,
  });

  const ReceiptState.initial()
      : status = ReceiptStatus.initial,
        receipt = null,
        errorMessage = null,
        isOpeningPdf = false;

  const ReceiptState.loading()
      : status = ReceiptStatus.loading,
        receipt = null,
        errorMessage = null,
        isOpeningPdf = false;

  const ReceiptState.available(this.receipt)
      : status = ReceiptStatus.available,
        errorMessage = null,
        isOpeningPdf = false;

  const ReceiptState.generating(this.receipt)
      : status = ReceiptStatus.generating,
        errorMessage = null,
        isOpeningPdf = false;

  const ReceiptState.error(String message)
      : status = ReceiptStatus.error,
        receipt = null,
        errorMessage = message,
        isOpeningPdf = false;

  final ReceiptStatus status;
  final ReceiptEntity? receipt;
  final String? errorMessage;
  final bool isOpeningPdf;

  bool get isLoading => status == ReceiptStatus.loading;
  bool get hasError => status == ReceiptStatus.error;

  /// Whether the receipt details are known, but PDF URL is not yet generated.
  bool get isGenerating =>
      status == ReceiptStatus.generating ||
      (receipt != null && (receipt!.pdfUrl == null || receipt!.pdfUrl!.trim().isEmpty));

  /// Whether the receipt is fully generated and ready for viewing/downloading.
  bool get isAvailable =>
      status == ReceiptStatus.available &&
      receipt != null &&
      receipt!.pdfUrl != null &&
      receipt!.pdfUrl!.trim().isNotEmpty;

  ReceiptState copyWith({
    ReceiptStatus? status,
    ReceiptEntity? receipt,
    String? errorMessage,
    bool? isOpeningPdf,
  }) {
    return ReceiptState(
      status: status ?? this.status,
      receipt: receipt ?? this.receipt,
      errorMessage: errorMessage ?? this.errorMessage,
      isOpeningPdf: isOpeningPdf ?? this.isOpeningPdf,
    );
  }
}
