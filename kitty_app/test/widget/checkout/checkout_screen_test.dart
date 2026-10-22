import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/checkout/data/repositories/mock_payment_repository.dart';
import 'package:kitty_app/features/checkout/presentation/providers/payment_state.dart';
import 'package:kitty_app/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:kitty_app/features/checkout/presentation/widgets/payment_checkout_modal.dart';
import 'package:kitty_app/features/checkout/presentation/widgets/payment_processing_view.dart';
import 'package:kitty_app/features/checkout/presentation/widgets/payment_result_view.dart';
import 'package:kitty_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:kitty_app/features/payment_gateway/data/mock_payment_gateway_launcher.dart';
import 'package:kitty_app/features/payment_gateway/domain/gateway_result.dart';
import 'package:kitty_app/features/payment_gateway/presentation/providers/gateway_providers.dart';

void main() {
  group('CheckoutScreen Widget Test Suite', () {
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

    testWidgets('1. Fully renders initial Payment Checkout Modal with correct Rupee amount', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(PaymentCheckoutModal), findsOneWidget);
      expect(find.byKey(const Key('checkout_modal_title')), findsOneWidget);
      expect(find.text('Pay Kitty Installment'), findsOneWidget);
      expect(find.byKey(const Key('checkout_modal_amount_text')), findsOneWidget);
      expect(find.text('₹5,000'), findsOneWidget);
      expect(find.text('SELECT PAYMENT METHOD'), findsOneWidget);
      expect(find.byKey(const Key('checkout_method_upi')), findsOneWidget);
      expect(find.byKey(const Key('btn_confirm_payment')), findsOneWidget);
      expect(find.text('Confirm & Pay ₹5,000'), findsOneWidget);
    });

    testWidgets('2. Custom CheckoutArgs are correctly reflected in modal', (WidgetTester tester) async {
      const customArgs = CheckoutArgs(
        membershipId: 'mem_custom_88',
        chitToken: '#SW-GOLD-88',
        monthFor: 4,
        amount: 10000,
      );

      await tester.pumpWidget(createTestWidget(args: customArgs));
      await tester.pumpAndSettle();

      expect(find.text('Month 4 Installment (#SW-GOLD-88)'), findsOneWidget);
      expect(find.text('₹10,000'), findsOneWidget);
      expect(find.text('Confirm & Pay ₹10,000'), findsOneWidget);
    });

    testWidgets('3. Tapping Confirm & Pay initiates flow and transitions to Success', (WidgetTester tester) async {
      mockPaymentRepo.configurePolling(
        finalStatus: PaymentStatusEnum.success,
        requiredPolls: 1,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap confirm & pay
      await tester.ensureVisible(find.byKey(const Key('btn_confirm_payment')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn_confirm_payment')));
      await tester.pumpAndSettle();

      // Successfully transitioned to result view
      expect(find.byType(PaymentResultView), findsOneWidget);
      expect(find.byKey(const Key('payment_success_check_icon')), findsOneWidget);
      expect(find.text('PAYMENT CONFIRMED'), findsOneWidget);
      expect(find.text('Installment Paid Successfully'), findsOneWidget);
      expect(find.byKey(const Key('btn_payment_view_passbook')), findsOneWidget);
      expect(find.byKey(const Key('btn_payment_back_dashboard')), findsOneWidget);
    });

    testWidgets('3b. Payment Method Selection: switching channels updates selection state and CTA', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially UPI is selected
      expect(find.text('Confirm & Pay ₹5,000'), findsOneWidget);

      // Select Net Banking
      await tester.ensureVisible(find.byKey(const Key('checkout_method_netbanking')));
      await tester.tap(find.byKey(const Key('checkout_method_netbanking')));
      await tester.pumpAndSettle();

      // Select Debit / Credit Card
      await tester.ensureVisible(find.byKey(const Key('checkout_method_card')));
      await tester.tap(find.byKey(const Key('checkout_method_card')));
      await tester.pumpAndSettle();

      // Select Pick Cash
      await tester.ensureVisible(find.byKey(const Key('checkout_method_pick_cash')));
      await tester.tap(find.byKey(const Key('checkout_method_pick_cash')));
      await tester.pumpAndSettle();

      // Button updates to reflect cash pickup
      expect(find.text('Proceed with Cash Pickup'), findsOneWidget);
    });

    testWidgets('4. Polling state renders PaymentProcessingView', (WidgetTester tester) async {
      const state = PaymentState(
        status: PaymentUiStatus.polling,
        pollCount: 2,
        amount: 5000,
        pollingMessage: 'Confirming gateway authorization...',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaymentProcessingView(state: state),
          ),
        ),
      );

      expect(find.byType(PaymentProcessingView), findsOneWidget);
      expect(find.text('RECONCILIATION STEP 2/5'), findsOneWidget);
      expect(find.text('Confirming gateway authorization...'), findsOneWidget);
      expect(find.text('Please do not close this window'), findsOneWidget);
    });

    testWidgets('5. Failed state renders Failure UI with Try Again button', (WidgetTester tester) async {
      const state = PaymentState(
        status: PaymentUiStatus.failed,
        amount: 5000,
        errorMessage: 'Bank declined transaction.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentResultView(
              state: state,
              onRetry: () {},
              onViewPassbook: () {},
              onReturnToDashboard: () {},
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('payment_failed_icon')), findsOneWidget);
      expect(find.text('Payment Could Not Be Completed'), findsOneWidget);
      expect(find.text('Bank declined transaction.'), findsOneWidget);
      expect(find.byKey(const Key('btn_payment_retry')), findsOneWidget);
      expect(find.byKey(const Key('btn_payment_dismiss')), findsOneWidget);
    });

    testWidgets('6. Cancelled state renders Cancelled UI', (WidgetTester tester) async {
      const state = PaymentState(
        status: PaymentUiStatus.cancelled,
        amount: 5000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentResultView(
              state: state,
              onRetry: () {},
              onViewPassbook: () {},
              onReturnToDashboard: () {},
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('payment_cancelled_icon')), findsOneWidget);
      expect(find.text('Payment Cancelled'), findsOneWidget);
      expect(find.byKey(const Key('btn_payment_cancelled_retry')), findsOneWidget);
    });

    testWidgets('7. Timeout state renders Timeout UI with Check Status action', (WidgetTester tester) async {
      const state = PaymentState(
        status: PaymentUiStatus.timeout,
        amount: 5000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentResultView(
              state: state,
              onRetry: () {},
              onViewPassbook: () {},
              onReturnToDashboard: () {},
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('payment_timeout_icon')), findsOneWidget);
      expect(find.text('Payment Under Bank Verification'), findsOneWidget);
      expect(find.byKey(const Key('btn_payment_check_status')), findsOneWidget);
      expect(find.byKey(const Key('btn_payment_timeout_passbook')), findsOneWidget);
    });
  });
}
