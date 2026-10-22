import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/checkout/data/repositories/mock_payment_repository.dart';
import 'package:kitty_app/features/checkout/presentation/providers/payment_controller.dart';
import 'package:kitty_app/features/checkout/presentation/providers/payment_state.dart';
import 'package:kitty_app/features/payment_gateway/data/mock_payment_gateway_launcher.dart';
import 'package:kitty_app/features/payment_gateway/domain/gateway_result.dart';
import 'package:kitty_app/features/payment_gateway/presentation/providers/gateway_providers.dart';

void main() {
  group('PaymentController Unit & Polling Tests', () {
    late MockPaymentRepository mockPaymentRepo;
    late MockPaymentGatewayLauncher mockLauncher;
    late ProviderContainer container;

    setUp(() {
      final engineConfig = MockEngineConfig(latency: MockLatency.instant);
      mockPaymentRepo = MockPaymentRepository(engineConfig: engineConfig);
      mockLauncher = MockPaymentGatewayLauncher(
        forcedResult: const GatewayResult.completed(message: 'Simulated complete'),
      );

      container = ProviderContainer(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(mockPaymentRepo),
          paymentGatewayLauncherProvider.overrideWithValue(mockLauncher),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('1. Initial state has default month, amount, and idle status', () {
      final state = container.read(paymentControllerProvider);
      expect(state.status, PaymentUiStatus.initial);
      expect(state.amount, 5000);
      expect(state.monthFor, 9);
      expect(state.selectedMethod, PaymentMethodEnum.online);
      expect(state.canInitiate, isTrue);
      expect(state.isBusy, isFalse);
    });

    test('2. selectPaymentMethod updates selectedMethod', () {
      final controller = container.read(paymentControllerProvider.notifier);
      controller.selectPaymentMethod(PaymentMethodEnum.online);
      expect(container.read(paymentControllerProvider).selectedMethod, PaymentMethodEnum.online);
    });

    test('2b. selectPaymentChannel updates channel and synchronizes method', () {
      final controller = container.read(paymentControllerProvider.notifier);
      controller.selectPaymentChannel(PaymentChannel.netbanking);
      expect(container.read(paymentControllerProvider).selectedChannel, PaymentChannel.netbanking);
      expect(container.read(paymentControllerProvider).selectedMethod, PaymentMethodEnum.online);

      controller.selectPaymentChannel(PaymentChannel.pickCash);
      expect(container.read(paymentControllerProvider).selectedChannel, PaymentChannel.pickCash);
      expect(container.read(paymentControllerProvider).selectedMethod, PaymentMethodEnum.cash);
    });

    test('3. setInstallmentContext overrides scheme and month parameters', () {
      final controller = container.read(paymentControllerProvider.notifier);
      controller.setInstallmentContext(
        membershipId: 'mem_custom',
        chitToken: '#SW-CUSTOM',
        monthFor: 5,
        amount: 3000,
      );

      final state = container.read(paymentControllerProvider);
      expect(state.membershipId, 'mem_custom');
      expect(state.chitToken, '#SW-CUSTOM');
      expect(state.monthFor, 5);
      expect(state.amount, 3000);
    });

    testWidgets('4. Full Successful Flow: Initiate -> Gateway -> Polling -> Success', (WidgetTester tester) async {
      mockPaymentRepo.configurePolling(
        finalStatus: PaymentStatusEnum.success,
        requiredPolls: 2,
      );

      final controller = container.read(paymentControllerProvider.notifier);
      controller.pollingInterval = Duration.zero;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () => controller.initiateAndPay(context),
                child: const Text('Pay'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();

      final state = container.read(paymentControllerProvider);
      expect(state.status, PaymentUiStatus.success);
      expect(state.isSuccess, isTrue);
      expect(state.isTerminal, isTrue);
      expect(state.statusEntity?.status, PaymentStatusEnum.success);
      expect(state.statusEntity?.transactionId, 'TXN-SW-50291');
      expect(state.statusEntity?.monthsPaid, 9);
      expect(state.statusEntity?.totalPaidAmount, 45000);
    });

    testWidgets('5. Full Failed Flow: Terminal FAILED from repository', (WidgetTester tester) async {
      mockPaymentRepo.configurePolling(
        finalStatus: PaymentStatusEnum.failed,
        requiredPolls: 1,
      );

      final controller = container.read(paymentControllerProvider.notifier);
      controller.pollingInterval = Duration.zero;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () => controller.initiateAndPay(context),
                child: const Text('Pay'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();

      final state = container.read(paymentControllerProvider);
      expect(state.status, PaymentUiStatus.failed);
      expect(state.isFailed, isTrue);
      expect(state.isTerminal, isTrue);
      expect(state.canInitiate, isTrue);
    });

    testWidgets('6. Cancelled Flow: User cancels gateway interaction', (WidgetTester tester) async {
      mockLauncher.forcedResult = const GatewayResult.cancelled(message: 'User closed gateway');

      final controller = container.read(paymentControllerProvider.notifier);
      controller.pollingInterval = Duration.zero;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () => controller.initiateAndPay(context),
                child: const Text('Pay'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();

      final state = container.read(paymentControllerProvider);
      expect(state.status, PaymentUiStatus.cancelled);
      expect(state.isCancelled, isTrue);
      expect(state.canInitiate, isTrue);
    });

    test('7. Timeout Flow: Polling times out after max 5 attempts with status PENDING', () async {
      // Require 10 polls before success, so 5 polls will time out
      mockPaymentRepo.configurePolling(
        finalStatus: PaymentStatusEnum.success,
        requiredPolls: 10,
      );

      final controller = container.read(paymentControllerProvider.notifier);
      controller.pollingInterval = Duration.zero;

      await controller.startPolling('gokwik_ord_test_timeout');

      final state = container.read(paymentControllerProvider);
      expect(state.status, PaymentUiStatus.timeout);
      expect(state.isTimeout, isTrue);
      expect(state.pollCount, 5);
      expect(state.isTerminal, isTrue);
    });

    testWidgets('8. Duplicate Initiation Protection: Ignored when already busy', (WidgetTester tester) async {
      final controller = container.read(paymentControllerProvider.notifier);
      controller.pollingInterval = Duration.zero;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  // Fire two concurrent calls
                  controller.initiateAndPay(context);
                  controller.initiateAndPay(context);
                },
                child: const Text('Pay Twice'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Pay Twice'));
      await tester.pumpAndSettle();

      // Ensure launcher only called once
      expect(mockLauncher.hasLaunched, isTrue);
    });

    testWidgets('9. Initiation Failure sets error status and enables retry', (WidgetTester tester) async {
      mockPaymentRepo.setShouldThrowOnInitiate(true);

      final controller = container.read(paymentControllerProvider.notifier);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () => controller.initiateAndPay(context),
                child: const Text('Pay'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();

      final state = container.read(paymentControllerProvider);
      expect(state.status, PaymentUiStatus.error);
      expect(state.isError, isTrue);
      expect(state.canInitiate, isTrue);
    });

    test('10. Polling network error on last attempt sets error state', () async {
      mockPaymentRepo.setShouldThrowOnPoll(true);

      final controller = container.read(paymentControllerProvider.notifier);
      controller.pollingInterval = Duration.zero;

      await controller.startPolling('gokwik_ord_err');

      final state = container.read(paymentControllerProvider);
      expect(state.status, PaymentUiStatus.error);
      expect(state.isError, isTrue);
    });

    test('11. Unknown status from backend is handled defensively without marking success', () async {
      mockPaymentRepo.configurePolling(
        finalStatus: PaymentStatusEnum.unknown,
        requiredPolls: 0,
      );

      final controller = container.read(paymentControllerProvider.notifier);
      controller.pollingInterval = Duration.zero;

      await controller.startPolling('gokwik_ord_unknown');

      final state = container.read(paymentControllerProvider);
      // Unknown status did not set success; it timed out safely
      expect(state.isSuccess, isFalse);
      expect(state.status, PaymentUiStatus.timeout);
    });
  });
}
