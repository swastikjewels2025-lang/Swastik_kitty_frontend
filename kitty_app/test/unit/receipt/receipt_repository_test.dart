import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/errors/app_exception.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/features/receipt/data/repositories/mock_receipt_repository.dart';
import 'package:kitty_app/features/receipt/data/repositories/receipt_repository_impl.dart';
import 'package:kitty_app/features/receipt/domain/entities/receipt_entity.dart';

void main() {
  group('Receipt Repository & Mock States Unit Tests (Phase 13)', () {
    late MockEngineConfig mockEngine;
    late MockReceiptRepository mockRepo;
    late ReceiptRepositoryImpl implRepo;

    setUp(() {
      mockEngine = MockEngineConfig(latency: MockLatency.instant);
      mockRepo = MockReceiptRepository(engineConfig: mockEngine);
      implRepo = ReceiptRepositoryImpl();
    });

    test('1. Receipt Available: returns safe mock PDF url and details', () async {
      final ReceiptEntity receipt = await mockRepo.getReceipt('rec_10821');

      expect(receipt.receiptId, equals('rec_10821'));
      expect(receipt.pdfUrl, isNotNull);
      expect(receipt.pdfUrl, contains('rec_10821.pdf'));
      expect(receipt.pdfUrl, startsWith('https://'));
      expect(receipt.amount, equals(5000));
      expect(receipt.goldWeightCreditedGrams, equals(0.327));
      expect(receipt.goldRateAtPayment, equals(15268.000));
    });

    test('2. Receipt Generating: returns null pdfUrl when generating', () async {
      mockRepo.forcedState = MockReceiptState.generating;
      final ReceiptEntity receipt = await mockRepo.getReceipt('rec_gen_01');

      expect(receipt.pdfUrl, isNull);

      // Also via special ID
      mockRepo.forcedState = null;
      final ReceiptEntity receiptById = await mockRepo.getReceipt('generating');
      expect(receiptById.pdfUrl, isNull);
    });

    test('3. Receipt Error: throws ServerException', () async {
      mockRepo.forcedState = MockReceiptState.error;
      await expectLater(
        mockRepo.getReceipt('rec_err_01'),
        throwsA(isA<ServerException>()),
      );

      mockRepo.forcedState = null;
      await expectLater(
        mockRepo.getReceipt('error'),
        throwsA(isA<ServerException>()),
      );
    });

    test('4. Receipt Invalid URL: provides malformed link for error handling tests', () async {
      mockRepo.forcedState = MockReceiptState.invalidUrl;
      final ReceiptEntity receipt = await mockRepo.getReceipt('rec_bad_01');

      expect(receipt.pdfUrl, equals('invalid_protocol://bad-receipt-link'));
    });

    test('5. ReceiptRepositoryImpl resolves locally without remote /api/v1/receipts endpoint', () async {
      // Verifies no HTTP call is triggered to nonexistent /api/v1/receipts
      final ReceiptEntity receipt = await implRepo.getReceipt('rec_10821');

      expect(receipt.receiptId, equals('rec_10821'));
      expect(receipt.amount, equals(5000));
      expect(receipt.customerName, equals('Rihan Saifi'));
    });
  });
}
