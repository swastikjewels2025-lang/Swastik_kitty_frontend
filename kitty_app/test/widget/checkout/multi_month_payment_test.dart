import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/checkout/data/repositories/mock_payment_repository.dart';
import 'package:kitty_app/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:kitty_app/features/checkout/presentation/widgets/payment_checkout_modal.dart';
import 'package:kitty_app/features/checkout/presentation/widgets/payment_result_view.dart';
import 'package:kitty_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:kitty_app/features/payment_gateway/data/mock_payment_gateway_launcher.dart';
import 'package:kitty_app/features/payment_gateway/domain/gateway_result.dart';
import 'package:kitty_app/features/payment_gateway/presentation/providers/gateway_providers.dart';

void main() {
  group('Multi-Month Installment Payment Engine Tests (Phase 9)', () {
    late MockEngineConfig engineConfig;
    late MockPaymentRepository mockPaymentRepo;
    late MockPaymentGatewayLauncher mockLauncher;

    setUp(() {
      engineConfig = MockEngineConfig(latency: MockLatency.instant);
      mockPaymentRepo = MockPaymentRepository(engineConfig: engineConfig);
      mockLauncher = MockPaymentGatewayLauncher(
        forcedResult: const GatewayResult.completed(message: 'Simulated success'),
      );
    });

    Widget createTestWidget({
      List<dynamic> overrides = const <dynamic>[],
      CheckoutArgs? args,
    }) {
      return ProviderScope(
        overrides: [
          mockEngineConfigProvider.overrideWithValue(engineConfig),
          dashboardRepositoryProvider.overrideWithValue(
            MockDashboardRepository(engineConfig: engineConfig),
          ),
          paymentRepositoryProvider.overrideWithValue(mockPaymentRepo),
          paymentGatewayLauncherProvider.overrideWithValue(mockLauncher),
          ...overrides.cast(),
        ],
        child: MaterialApp(
          home: CheckoutScreen(args: args),
        ),
      );
    }

    testWidgets('1. Displays multi-month selection pills with 1 Month selected by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(PaymentCheckoutModal), findsOneWidget);
      expect(find.text('SELECT INSTALLMENT MONTHS'), findsOneWidget);
      expect(find.byKey(const Key('month_pill_1')), findsOneWidget);
      expect(find.byKey(const Key('month_pill_2')), findsOneWidget);
      expect(find.byKey(const Key('month_pill_3')), findsOneWidget);
      expect(find.text('1 Month'), findsOneWidget);
      expect(find.text('2 Months'), findsOneWidget);
      expect(find.text('3 Months'), findsOneWidget);
      expect(find.text('Confirm & Pay ₹5,000'), findsOneWidget);
    });

    testWidgets('2. Selecting 2 Months dynamically updates payable amount to ₹10,000',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap 2 Months pill
      await tester.tap(find.byKey(const Key('month_pill_2')));
      await tester.pumpAndSettle();

      // Amount should double to ₹10,000
      expect(find.byKey(const Key('checkout_modal_amount_text')), findsOneWidget);
      expect(find.text('₹10,000'), findsOneWidget);
      expect(find.text('Confirm & Pay ₹10,000'), findsOneWidget);
      expect(find.textContaining('Paying Months 9, 10 (2 × ₹5,000)'), findsOneWidget);
    });

    testWidgets('3. Selecting 3 Months dynamically updates payable amount to ₹15,000',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap 3 Months pill
      await tester.tap(find.byKey(const Key('month_pill_3')));
      await tester.pumpAndSettle();

      // Amount should triple to ₹15,000
      expect(find.text('₹15,000'), findsOneWidget);
      expect(find.text('Confirm & Pay ₹15,000'), findsOneWidget);
      expect(find.textContaining('Paying Months 9, 10, 11 (3 × ₹5,000)'), findsOneWidget);
    });

    testWidgets('4. Boundary validation: When only 2 months remain, 3 months pill is disabled',
        (WidgetTester tester) async {
      // Month 11 in a 12-month tenure leaves only 2 months (11, 12)
      const customArgs = CheckoutArgs(
        membershipId: 'mem_tenure_test',
        chitToken: '#SW-099',
        monthFor: 11,
        amount: 5000,
      );

      await tester.pumpWidget(createTestWidget(args: customArgs));
      await tester.pumpAndSettle();

      // Tap disabled 3 Months pill
      await tester.tap(find.byKey(const Key('month_pill_3')));
      await tester.pumpAndSettle();

      // Amount should remain 1 month (₹5,000), not change to 3 months
      expect(find.text('Confirm & Pay ₹5,000'), findsOneWidget);
    });

    testWidgets('5. Multi-month payment execution transitions to success with reconciled amount',
        (WidgetTester tester) async {
      mockPaymentRepo.configurePolling(
        finalStatus: PaymentStatusEnum.success,
        requiredPolls: 1,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Select 2 Months (₹10,000)
      await tester.tap(find.byKey(const Key('month_pill_2')));
      await tester.pumpAndSettle();

      // Tap confirm and pay
      await tester.ensureVisible(find.byKey(const Key('btn_confirm_payment')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn_confirm_payment')));
      await tester.pumpAndSettle();

      // Reconciles successfully to PaymentResultView
      expect(find.byType(PaymentResultView), findsOneWidget);
      expect(find.byKey(const Key('payment_success_check_icon')), findsOneWidget);
      expect(find.text('₹10,000'), findsOneWidget);
    });

    testWidgets('6. Payment failure handles retry flow gracefully',
        (WidgetTester tester) async {
      mockPaymentRepo.configurePolling(
        finalStatus: PaymentStatusEnum.failed,
        requiredPolls: 1,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Confirm & Pay
      await tester.ensureVisible(find.byKey(const Key('btn_confirm_payment')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn_confirm_payment')));
      await tester.pumpAndSettle();

      // Failure view is rendered
      expect(find.byType(PaymentResultView), findsOneWidget);
      expect(find.text('Payment Could Not Be Completed'), findsOneWidget);
      expect(find.byKey(const Key('btn_payment_retry')), findsOneWidget);

      // Tap Retry - re-initiates and succeeds when gateway recovers
      mockPaymentRepo.configurePolling(
        finalStatus: PaymentStatusEnum.success,
        requiredPolls: 1,
      );
      await tester.tap(find.byKey(const Key('btn_payment_retry')));
      await tester.pumpAndSettle();

      expect(find.byType(PaymentResultView), findsOneWidget);
      expect(find.byKey(const Key('payment_success_check_icon')), findsOneWidget);
      expect(find.text('Installment Paid Successfully'), findsOneWidget);
    });

    testWidgets('7. Gateway cancellation transitions to cancelled state',
        (WidgetTester tester) async {
      mockLauncher = MockPaymentGatewayLauncher(
        forcedResult: const GatewayResult.cancelled(message: 'User cancelled payment'),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Confirm & Pay
      await tester.ensureVisible(find.byKey(const Key('btn_confirm_payment')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn_confirm_payment')));
      await tester.pumpAndSettle();

      expect(find.byType(PaymentResultView), findsOneWidget);
      expect(find.text('Payment Cancelled'), findsOneWidget);
    });
  });
}
