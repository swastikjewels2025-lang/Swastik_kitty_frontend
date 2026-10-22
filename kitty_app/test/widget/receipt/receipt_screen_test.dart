import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/core/services/pdf_launcher_service.dart';
import 'package:kitty_app/features/passbook/domain/entities/passbook_entry_entity.dart';
import 'package:kitty_app/features/receipt/data/repositories/mock_receipt_repository.dart';
import 'package:kitty_app/features/receipt/presentation/screens/receipt_screen.dart';
import 'package:kitty_app/shared/widgets/buttons/kitty_primary_button.dart';

class _MockPdfLauncherService implements IPdfLauncherService {
  String? lastLaunchedUrl;

  @override
  bool isValidPdfUrl(String? url) => url != null && url.startsWith('https://');

  @override
  Future<bool> launchPdf(String url) async {
    lastLaunchedUrl = url;
    return true;
  }
}

void main() {
  group('ReceiptScreen Widget Tests (Phase 13)', () {
    late MockEngineConfig mockEngine;
    late MockReceiptRepository mockRepo;
    late _MockPdfLauncherService mockPdfLauncher;

    setUp(() {
      mockEngine = MockEngineConfig(latency: MockLatency.instant);
      mockRepo = MockReceiptRepository(engineConfig: mockEngine);
      mockPdfLauncher = _MockPdfLauncherService();
    });

    Widget createTestWidget({
      required String receiptId,
      PassbookEntryEntity? passbookEntry,
    }) {
      return ProviderScope(
        overrides: [
          receiptRepositoryProvider.overrideWithValue(mockRepo),
          pdfLauncherServiceProvider.overrideWithValue(mockPdfLauncher),
        ],
        child: MaterialApp(
          home: ReceiptScreen(
            receiptId: receiptId,
            passbookEntry: passbookEntry,
          ),
        ),
      );
    }

    testWidgets('1. Paid passbook item with receiptUrl renders complete receipt and launches PDF',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      const entry = PassbookEntryEntity(
        month: 9,
        label: 'Month 9',
        amount: 5000,
        status: InstallmentStatusEnum.paid,
        transactionId: 'TXN-SW-84920',
        goldGrams: 0.668,
        receiptUrl: 'https://res.cloudinary.com/swastik-test/rec_84920.pdf',
      );

      await tester.pumpWidget(
        createTestWidget(receiptId: 'TXN-SW-84920', passbookEntry: entry),
      );
      await tester.pumpAndSettle();

      // Verify Header and Title
      expect(find.text('Official Gold Scheme Receipt'), findsOneWidget);
      expect(find.text('Swastik Jewellers Tax & Gold Passbook Invoice'), findsOneWidget);

      // Verify Transaction and Status
      expect(find.text('TXN-SW-84920'), findsOneWidget);
      expect(find.text('PAYMENT CONFIRMED'), findsOneWidget);
      expect(find.text('Receipt for Month 9'), findsOneWidget);

      // Verify Line Items
      expect(find.text('Chit Token Number:'), findsOneWidget);
      expect(find.text('#SW-042'), findsOneWidget);
      expect(find.text('+0.668 grams'), findsOneWidget);
      expect(find.text('Statutory GST (3% Bullion):'), findsOneWidget);
      expect(find.text('₹0.00 (Covered by Jeweler)'), findsOneWidget);
      expect(find.text('Total Amount Paid:'), findsOneWidget);
      expect(find.text('₹5,000.00'), findsOneWidget);

      // Verify Disclaimer
      expect(
        find.textContaining('audited under BIS 999 Hallmark certification'),
        findsOneWidget,
      );

      // Verify "View / Download PDF" button is present and tap triggers launcher
      final pdfButton = find.byKey(const Key('btn_view_receipt_pdf'));
      expect(pdfButton, findsOneWidget);

      await tester.tap(pdfButton);
      await tester.pumpAndSettle();

      expect(mockPdfLauncher.lastLaunchedUrl, equals('https://res.cloudinary.com/swastik-test/rec_84920.pdf'));
    });

    testWidgets('2. Paid passbook item with null receiptUrl renders Generating Receipt state',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      const entry = PassbookEntryEntity(
        month: 10,
        label: 'Month 10',
        amount: 5000,
        status: InstallmentStatusEnum.paid,
        transactionId: 'TXN-SW-99001',
        goldGrams: 0.700,
        receiptUrl: null, // Asynchronously generating
      );

      await tester.pumpWidget(
        createTestWidget(receiptId: 'TXN-SW-99001', passbookEntry: entry),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Generating state elements
      expect(find.byKey(const Key('receipt_generating_banner')), findsOneWidget);
      expect(find.text('Generating Official Tax PDF...'), findsOneWidget);
      expect(find.byKey(const Key('btn_receipt_refresh')), findsOneWidget);
      expect(find.byKey(const Key('btn_view_receipt_pdf_disabled')), findsOneWidget);
      expect(find.text('Check Status'), findsOneWidget);

      // Verify NO PDF viewer is opened
      expect(mockPdfLauncher.lastLaunchedUrl, isNull);
    });

    testWidgets('3. Loading state displays shimmer placeholders',
        (WidgetTester tester) async {
      mockEngine = MockEngineConfig(latency: MockLatency.slow);
      mockRepo = MockReceiptRepository(engineConfig: mockEngine);

      await tester.pumpWidget(createTestWidget(receiptId: 'rec_slow'));
      await tester.pump(const Duration(milliseconds: 50));

      // In flight, receipt modal is not yet rendered
      expect(find.text('Official Gold Scheme Receipt'), findsNothing);
      // Wait for completion
      await tester.pumpAndSettle();
    });

    testWidgets('4. Error state renders error view with retry action',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      mockRepo.forcedState = MockReceiptState.error;

      await tester.pumpWidget(createTestWidget(receiptId: 'rec_error'));
      await tester.pumpAndSettle();

      expect(find.text('Receipt Unavailable'), findsOneWidget);
      expect(find.widgetWithText(KittyPrimaryButton, 'RETRY LOAD'), findsOneWidget);

      // Now recover and tap Retry
      mockRepo.forcedState = MockReceiptState.available;
      await tester.tap(find.widgetWithText(KittyPrimaryButton, 'RETRY LOAD'));
      await tester.pumpAndSettle();

      expect(find.text('Official Gold Scheme Receipt'), findsOneWidget);
      expect(find.text('PAYMENT CONFIRMED'), findsOneWidget);
    });

    testWidgets('5. Close and Done buttons exist and can be tapped',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(createTestWidget(receiptId: 'rec_10821'));
      await tester.pumpAndSettle();

      final closeButton = find.byKey(const Key('receipt_close_btn'));
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      final doneButton = find.byKey(const Key('btn_receipt_done'));
      expect(doneButton, findsOneWidget);
      await tester.tap(doneButton);
      await tester.pumpAndSettle();
    });
  });
}
