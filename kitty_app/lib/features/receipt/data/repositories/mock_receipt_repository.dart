import 'dart:convert';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/mock/mock_engine_config.dart';
import '../../../../core/mock/mock_fixtures.dart';
import '../../domain/entities/receipt_entity.dart';
import '../../domain/repositories/i_receipt_repository.dart';
import '../mappers/receipt_mapper.dart';
import '../models/receipt_dto.dart';

/// Supported mock state variants for Digital Receipts (Phase 13).
enum MockReceiptState {
  available,
  generating,
  error,
  invalidUrl,
}

/// Mock implementation of [IReceiptRepository].
///
/// Supports all 5 required Phase 13 verification states:
/// 1. Available (valid safe mock PDF URL)
/// 2. Generating (pdfUrl == null)
/// 3. Loading (simulated network latency via [MockEngineConfig])
/// 4. Error (throws [ServerException] / [NetworkException])
/// 5. Invalid URL (malformed URI)
class MockReceiptRepository implements IReceiptRepository {
  MockReceiptRepository({
    MockEngineConfig? engineConfig,
    this.forcedState,
  }) : _engineConfig = engineConfig ?? MockEngineConfig();

  final MockEngineConfig _engineConfig;
  MockReceiptState? forcedState;

  @override
  Future<ReceiptEntity> getReceipt(String receiptId) async {
    await _engineConfig.simulateResponse();

    // Check forced mock state or receiptId triggers
    final bool isError = forcedState == MockReceiptState.error ||
        receiptId == 'error' ||
        _engineConfig.failureMode != MockFailureMode.none;
    if (isError) {
      throw const ServerException(
        'Unable to retrieve receipt record. Please try again.',
      );
    }

    final data = Map<String, dynamic>.from(
      MockFixtures.digitalReceiptJson['data'] as Map<String, dynamic>? ?? {},
    );
    data['receiptId'] = receiptId;

    final bool isGenerating = forcedState == MockReceiptState.generating ||
        receiptId == 'generating';
    final bool isInvalid = forcedState == MockReceiptState.invalidUrl ||
        receiptId == 'invalid_url';

    if (isGenerating) {
      data['pdfUrl'] = null;
      data['receiptUrl'] = null;
    } else if (isInvalid) {
      data['pdfUrl'] = 'invalid_protocol://bad-receipt-link';
      data['receiptUrl'] = 'invalid_protocol://bad-receipt-link';
    } else {
      // Safe test/mock URL (not real production Cloudinary)
      data['pdfUrl'] = 'https://res.cloudinary.com/swastik-test/image/upload/receipts/$receiptId.pdf';
      data['receiptUrl'] = data['pdfUrl'];
    }

    return ReceiptMapper.toEntity(ReceiptDto.fromJson(data));
  }

  @override
  Future<ReceiptEntity> getReceiptByTransactionId(String transactionId) async {
    await _engineConfig.simulateResponse();

    final bool isError = forcedState == MockReceiptState.error ||
        transactionId == 'error' ||
        _engineConfig.failureMode != MockFailureMode.none;
    if (isError) {
      throw const ServerException(
        'Unable to retrieve transaction receipt. Please try again.',
      );
    }

    final data = Map<String, dynamic>.from(
      MockFixtures.digitalReceiptJson['data'] as Map<String, dynamic>? ?? {},
    );
    data['transactionId'] = transactionId;

    if (forcedState == MockReceiptState.generating || transactionId == 'generating') {
      data['pdfUrl'] = null;
      data['receiptUrl'] = null;
    }

    return ReceiptMapper.toEntity(ReceiptDto.fromJson(data));
  }

  @override
  Future<List<int>> downloadReceiptPdf(String receiptId) async {
    await _engineConfig.simulateResponse();
    if (forcedState == MockReceiptState.error ||
        _engineConfig.failureMode != MockFailureMode.none) {
      throw const ServerException('Failed to download PDF stream.');
    }
    return utf8.encode('%PDF-1.4 Mock Receipt for $receiptId\n%%EOF');
  }
}
