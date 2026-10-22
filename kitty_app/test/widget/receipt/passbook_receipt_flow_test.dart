import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/core/routing/route_names.dart';
import 'package:kitty_app/core/routing/route_paths.dart';
import 'package:kitty_app/core/services/pdf_launcher_service.dart';
import 'package:kitty_app/features/passbook/data/repositories/mock_passbook_repository.dart';
import 'package:kitty_app/features/passbook/domain/entities/passbook_entry_entity.dart';
import 'package:kitty_app/features/passbook/presentation/screens/passbook_screen.dart';
import 'package:kitty_app/features/receipt/data/repositories/mock_receipt_repository.dart';
import 'package:kitty_app/features/receipt/presentation/screens/receipt_screen.dart';

class _FakePdfLauncherService implements IPdfLauncherService {
  @override
  bool isValidPdfUrl(String? url) => true;

  @override
  Future<bool> launchPdf(String url) async => true;
}

void main() {
  group('Passbook to Receipt Navigation Flow Tests (Phase 13)', () {
    late MockEngineConfig mockEngine;
    late MockReceiptRepository mockReceiptRepo;
    late MockPassbookRepository mockPassbookRepo;

    setUp(() {
      mockEngine = MockEngineConfig(latency: MockLatency.instant);
      mockReceiptRepo = MockReceiptRepository(engineConfig: mockEngine);
      mockPassbookRepo = MockPassbookRepository(engineConfig: mockEngine);
    });

    testWidgets('Tapping Receipt button in Passbook navigates to Receipt modal',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final router = GoRouter(
        initialLocation: RoutePaths.passbook,
        routes: [
          GoRoute(
            path: RoutePaths.passbook,
            name: AppRoute.passbook.name,
            builder: (context, state) => const PassbookScreen(),
          ),
          GoRoute(
            path: RoutePaths.receipt,
            name: AppRoute.receipt.name,
            builder: (context, state) {
              final receiptId = state.pathParameters['id'] ?? 'REC-UNKNOWN';
              return ReceiptScreen(
                receiptId: receiptId,
                passbookEntry: state.extra as PassbookEntryEntity?,
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            passbookRepositoryProvider.overrideWithValue(mockPassbookRepo),
            receiptRepositoryProvider.overrideWithValue(mockReceiptRepo),
            pdfLauncherServiceProvider.overrideWithValue(_FakePdfLauncherService()),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Receipt button in Table View (Month 1 is PAID)
      final receiptBtn = find.widgetWithText(OutlinedButton, 'Receipt').first;
      expect(receiptBtn, findsOneWidget);

      await tester.tap(receiptBtn);
      await tester.pumpAndSettle();

      // Verify Receipt Screen is presented
      expect(find.text('Official Gold Scheme Receipt'), findsOneWidget);
      expect(find.text('PAYMENT CONFIRMED'), findsOneWidget);

      // Verify Done button pops back to Passbook
      final doneBtn = find.byKey(const Key('btn_receipt_done'));
      expect(doneBtn, findsOneWidget);

      await tester.tap(doneBtn);
      await tester.pumpAndSettle();

      // Back on Passbook Screen
      expect(find.text('Passbook Ledger'), findsOneWidget);
    });
  });
}
