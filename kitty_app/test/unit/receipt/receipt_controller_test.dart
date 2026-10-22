import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/errors/app_exception.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/core/services/pdf_launcher_service.dart';
import 'package:kitty_app/features/passbook/domain/entities/passbook_entry_entity.dart';
import 'package:kitty_app/features/receipt/data/repositories/mock_receipt_repository.dart';
import 'package:kitty_app/features/receipt/presentation/providers/receipt_controller.dart';
import 'package:kitty_app/features/receipt/presentation/providers/receipt_state.dart';

class _FakePdfLauncherService implements IPdfLauncherService {
  String? lastLaunchedUrl;
  bool shouldSucceed = true;

  @override
  bool isValidPdfUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    return url.startsWith('https://') || url.startsWith('http://');
  }

  @override
  Future<bool> launchPdf(String url) async {
    if (!isValidPdfUrl(url)) {
      throw const ValidationException('Invalid receipt URL provided.');
    }
    if (!shouldSucceed) {
      throw const ServerException('Failed to open PDF.');
    }
    lastLaunchedUrl = url;
    return true;
  }
}

void main() {
  group('ReceiptController Unit Tests (Phase 13)', () {
    late MockEngineConfig mockEngine;
    late MockReceiptRepository mockRepo;
    late _FakePdfLauncherService fakePdfLauncher;

    setUp(() {
      mockEngine = MockEngineConfig(latency: MockLatency.instant);
      mockRepo = MockReceiptRepository(engineConfig: mockEngine);
      fakePdfLauncher = _FakePdfLauncherService();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          receiptRepositoryProvider.overrideWithValue(mockRepo),
          pdfLauncherServiceProvider.overrideWithValue(fakePdfLauncher),
        ],
      );
    }

    test('Initial load with available receipt sets status to available', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(receiptControllerProvider.notifier);
      await notifier.initialize(receiptId: 'rec_10821');

      final state = container.read(receiptControllerProvider);
      expect(state.status, equals(ReceiptStatus.available));
      expect(state.isAvailable, isTrue);
      expect(state.isGenerating, isFalse);
      expect(state.receipt?.amount, equals(5000));
    });

    test('Initial load with generating receipt sets status to generating', () async {
      mockRepo.forcedState = MockReceiptState.generating;
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(receiptControllerProvider.notifier);
      await notifier.initialize(receiptId: 'rec_gen');

      final state = container.read(receiptControllerProvider);
      expect(state.status, equals(ReceiptStatus.generating));
      expect(state.isGenerating, isTrue);
      expect(state.isAvailable, isFalse);
    });

    test('Initial load with error sets status to error and allows retry', () async {
      mockRepo.forcedState = MockReceiptState.error;
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(receiptControllerProvider.notifier);
      await notifier.initialize(receiptId: 'rec_err');

      expect(container.read(receiptControllerProvider).status, equals(ReceiptStatus.error));
      expect(container.read(receiptControllerProvider).hasError, isTrue);

      // Now recover and retry
      mockRepo.forcedState = MockReceiptState.available;
      await notifier.loadReceipt('rec_err');

      expect(container.read(receiptControllerProvider).status, equals(ReceiptStatus.available));
      expect(container.read(receiptControllerProvider).hasError, isFalse);
    });

    test('Initializing from PassbookEntryEntity with receiptUrl sets available immediately', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      const entry = PassbookEntryEntity(
        month: 1,
        label: 'Month 1',
        amount: 5000,
        status: InstallmentStatusEnum.paid,
        transactionId: 'TXN-001',
        goldGrams: 0.702,
        receiptUrl: 'https://res.cloudinary.com/swastik-test/rec_001.pdf',
      );

      final notifier = container.read(receiptControllerProvider.notifier);
      await notifier.initialize(
        receiptId: 'TXN-001',
        initialPassbookEntry: entry,
      );

      final state = container.read(receiptControllerProvider);
      expect(state.status, equals(ReceiptStatus.available));
      expect(state.receipt?.transactionId, equals('TXN-001'));
      expect(state.receipt?.amount, equals(5000));
    });

    test('Initializing from PassbookEntryEntity with null receiptUrl sets generating', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      const entry = PassbookEntryEntity(
        month: 2,
        label: 'Month 2',
        amount: 5000,
        status: InstallmentStatusEnum.paid,
        transactionId: 'TXN-002',
        goldGrams: 0.702,
        receiptUrl: null, // Asynchronously generating
      );

      final notifier = container.read(receiptControllerProvider.notifier);
      await notifier.initialize(
        receiptId: 'TXN-002',
        initialPassbookEntry: entry,
      );

      final state = container.read(receiptControllerProvider);
      expect(state.status, equals(ReceiptStatus.generating));
      expect(state.isGenerating, isTrue);
    });

    test('openPdf launches PDF when url is available', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(receiptControllerProvider.notifier);
      await notifier.initialize(receiptId: 'rec_10821');

      final bool success = await notifier.openPdf();
      expect(success, isTrue);
      expect(fakePdfLauncher.lastLaunchedUrl, contains('rec_10821.pdf'));
    });

    test('openPdf fails gracefully when url is null in generating state', () async {
      mockRepo.forcedState = MockReceiptState.generating;
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(receiptControllerProvider.notifier);
      await notifier.initialize(receiptId: 'rec_gen');

      final bool success = await notifier.openPdf();
      expect(success, isFalse);
      expect(container.read(receiptControllerProvider).errorMessage, isNotNull);
      expect(fakePdfLauncher.lastLaunchedUrl, isNull);
    });
  });
}
