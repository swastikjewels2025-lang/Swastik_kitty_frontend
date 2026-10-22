import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/features/checkout/domain/entities/payment_order_entity.dart';
import 'package:kitty_app/features/payment_gateway/data/mock_payment_gateway_launcher.dart';
import 'package:kitty_app/features/payment_gateway/domain/gateway_result.dart';

void main() {
  group('MockPaymentGatewayLauncher & GatewayResult Unit Tests', () {
    const testOrder = PaymentOrderEntity(
      orderId: 'gokwik_ord_test_01',
      paymentId: 'pay_test_01',
      amount: 5000,
      currency: 'INR',
      merchantKey: 'mock_mid',
    );

    test('GatewayResult getters evaluate correctly across all variants', () {
      const completed = GatewayResult.completed(message: 'Success');
      expect(completed.isCompleted, isTrue);
      expect(completed.isCancelled, isFalse);
      expect(completed.isFailed, isFalse);
      expect(completed.isPending, isFalse);

      const cancelled = GatewayResult.cancelled(message: 'Cancelled');
      expect(cancelled.isCompleted, isFalse);
      expect(cancelled.isCancelled, isTrue);

      const failed = GatewayResult.failed(message: 'Failed');
      expect(failed.isFailed, isTrue);

      const pending = GatewayResult.pending(message: 'Pending');
      expect(pending.isPending, isTrue);
    });

    testWidgets('MockPaymentGatewayLauncher returns forcedResult immediately', (WidgetTester tester) async {
      final launcher = MockPaymentGatewayLauncher(
        forcedResult: const GatewayResult.completed(message: 'Forced success'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () async {
                  final result = await launcher.launchGateway(
                    context: context,
                    order: testOrder,
                  );
                  expect(result.isCompleted, isTrue);
                  expect(result.message, 'Forced success');
                },
                child: const Text('Launch'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Launch'));
      await tester.pumpAndSettle();

      expect(launcher.hasLaunched, isTrue);
      expect(launcher.lastOrder?.orderId, 'gokwik_ord_test_01');
      expect(launcher.lastOrder?.amount, 5000);
    });
  });
}
