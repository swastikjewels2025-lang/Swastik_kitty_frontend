import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/services/pdf_launcher_service.dart';
import '../../../home/presentation/providers/home_controller.dart';
import '../../../passbook/domain/entities/passbook_entry_entity.dart';
import '../../domain/entities/receipt_entity.dart';
import '../../domain/repositories/i_receipt_repository.dart';
import 'receipt_state.dart';

/// Riverpod Notifier handling receipt lifecycle, status reconciliation, and PDF opening.
class ReceiptController extends Notifier<ReceiptState> {
  late IReceiptRepository _receiptRepository;
  late IPdfLauncherService _pdfLauncherService;
  String? _receiptId;

  @override
  ReceiptState build() {
    _receiptRepository = ref.watch(receiptRepositoryProvider);
    _pdfLauncherService = ref.watch(pdfLauncherServiceProvider);
    return const ReceiptState.loading();
  }

  /// Initializes or re-initializes receipt state from passed parameters.
  Future<void> initialize({
    required String receiptId,
    PassbookEntryEntity? initialPassbookEntry,
    ReceiptEntity? initialReceipt,
  }) async {
    _receiptId = receiptId;

    if (initialReceipt != null) {
      _initWithReceipt(initialReceipt);
      return;
    }

    if (initialPassbookEntry != null) {
      _initWithPassbookEntry(initialPassbookEntry);
      return;
    }

    await loadReceipt(receiptId);
  }

  void _initWithReceipt(ReceiptEntity receipt) {
    if (receipt.pdfUrl != null && receipt.pdfUrl!.trim().isNotEmpty) {
      state = ReceiptState.available(receipt);
    } else {
      state = ReceiptState.generating(receipt);
    }
  }

  void _initWithPassbookEntry(PassbookEntryEntity entry) {
    final double goldGrams = entry.goldGrams ?? 0.702;
    final double goldRate = goldGrams > 0
        ? (entry.amount / goldGrams)
        : (ref.read(homeControllerProvider).data?.goldRate?.ratePerGram ?? 15268.00);

    final AppAuthState authState = ref.read(appAuthStateProvider);
    final String customerName = authState.userName.isNotEmpty
        ? authState.userName
        : 'Valued Patron';
    final String customerPhone = authState.userPhone.isNotEmpty
        ? authState.userPhone
        : '';

    final ReceiptEntity receipt = ReceiptEntity(
      receiptId: entry.transactionId ?? (_receiptId ?? 'REC-${entry.month}'),
      transactionId: entry.transactionId ?? 'TXN-SW-00${entry.month}',
      paymentOrderId: 'ORD-SW-00${entry.month}',
      membershipId: 'MEM-SW-042',
      customerName: customerName,
      customerPhone: customerPhone,
      schemeName: 'Swastik Suvarna Varsha (12 Months)',
      installmentNumber: entry.month,
      totalInstallments: 12,
      amount: entry.amount,
      goldRateAtPayment: goldRate,
      goldWeightCreditedGrams: goldGrams,
      paymentMethod: entry.paymentMethod ?? PaymentMethodEnum.online,
      paymentStatus: PaymentStatusEnum.success,
      paidAt: entry.paidAt ?? DateTime.now(),
      pdfUrl: entry.receiptUrl,
    );

    if (entry.receiptUrl != null && entry.receiptUrl!.trim().isNotEmpty) {
      state = ReceiptState.available(receipt);
    } else {
      state = ReceiptState.generating(receipt);
    }
  }

  /// Loads receipt metadata from the repository.
  Future<void> loadReceipt([String? id]) async {
    final String targetId = id ?? _receiptId ?? 'rec_10821';
    _receiptId = targetId;
    state = const ReceiptState.loading();

    try {
      final ReceiptEntity receipt = await _receiptRepository.getReceipt(targetId);
      if (receipt.pdfUrl != null && receipt.pdfUrl!.trim().isNotEmpty) {
        state = ReceiptState.available(receipt);
      } else {
        state = ReceiptState.generating(receipt);
      }
    } on AppException catch (e) {
      state = ReceiptState.error(e.message);
    } catch (_) {
      state = const ReceiptState.error(
        'Unable to load receipt. Please try again.',
      );
    }
  }

  /// Refreshes receipt data (used during async generation polling/retry).
  Future<void> refreshReceipt() async {
    final String? targetId = _receiptId ?? state.receipt?.receiptId;
    if (targetId == null) return;

    try {
      final ReceiptEntity receipt = await _receiptRepository.getReceipt(targetId);
      if (receipt.pdfUrl != null && receipt.pdfUrl!.trim().isNotEmpty) {
        state = ReceiptState.available(receipt);
      } else {
        state = ReceiptState.generating(receipt);
      }
    } catch (_) {
      // Retain existing state on background refresh error
    }
  }

  /// Launches the PDF via [IPdfLauncherService].
  Future<bool> openPdf() async {
    final String? pdfUrl = state.receipt?.pdfUrl;
    if (pdfUrl == null || pdfUrl.trim().isEmpty) {
      state = state.copyWith(
        errorMessage:
            'Receipt PDF is still generating. Please check back shortly.',
      );
      return false;
    }

    state = state.copyWith(isOpeningPdf: true);
    try {
      final bool success = await _pdfLauncherService.launchPdf(pdfUrl);
      state = state.copyWith(isOpeningPdf: false);
      return success;
    } on AppException catch (e) {
      state = state.copyWith(
        isOpeningPdf: false,
        errorMessage: e.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isOpeningPdf: false,
        errorMessage: 'Failed to launch PDF viewer.',
      );
      return false;
    }
  }
}

/// Riverpod provider for [ReceiptController].
final NotifierProvider<ReceiptController, ReceiptState>
    receiptControllerProvider =
    NotifierProvider<ReceiptController, ReceiptState>(
  ReceiptController.new,
);
