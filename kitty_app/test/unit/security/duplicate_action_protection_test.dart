import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/checkout/data/repositories/mock_payment_repository.dart';
import 'package:kitty_app/features/checkout/presentation/providers/payment_controller.dart';
import 'package:kitty_app/features/kyc/data/repositories/mock_kyc_repository.dart';
import 'package:kitty_app/features/kyc/presentation/providers/kyc_controller.dart';
import 'package:kitty_app/features/kyc/presentation/providers/kyc_state.dart';
import 'package:kitty_app/features/notifications/data/repositories/mock_notification_repository.dart';
import 'package:kitty_app/features/notifications/presentation/providers/notifications_controller.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/features/checkout/domain/entities/payment_order_entity.dart';
import 'package:kitty_app/features/payment_gateway/data/mock_payment_gateway_launcher.dart';
import 'package:kitty_app/features/payment_gateway/domain/gateway_result.dart';
import 'package:kitty_app/features/payment_gateway/presentation/providers/gateway_providers.dart';

void main() {
  group('Phase 15 - Duplicate Action Protection Suite', () {
    final MockEngineConfig instantConfig =
        MockEngineConfig(latency: MockLatency.instant);

    test('1. Payment: isBusy prevents double initiation and duplicate payment orders',
        () async {
      final mockRepo = _SpyPaymentRepository(engineConfig: instantConfig);
      final mockLauncher = _SpyGatewayLauncher(
        forcedResult: const GatewayResult.completed(message: 'Test completed'),
      );

      final container = ProviderContainer(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(mockRepo),
          paymentGatewayLauncherProvider.overrideWithValue(mockLauncher),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(paymentControllerProvider.notifier);

      // First initiation
      final firstCall = controller.initiateAndPay(_DummyContext());
      // Immediate second call while busy
      final secondCall = controller.initiateAndPay(_DummyContext());

      await Future.wait([firstCall, secondCall]);

      // Exactly ONE initiation and gateway launch occurred
      expect(mockRepo.initiateCalls, equals(1));
      expect(mockLauncher.launchCalls, equals(1));
    });

    test('2. KYC: submitting status prevents duplicate form submission', () {
      final mockRepo = MockKycRepository(engineConfig: instantConfig);
      final container = ProviderContainer(
        overrides: [
          kycRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(kycControllerProvider.notifier);
      controller.setMockFormStatus(KycFormStatus.submitting);

      // canSubmit must be false while submitting
      expect(container.read(kycControllerProvider).canSubmit, isFalse);
    });

    test('3. Notifications: unreadCount == 0 or isMarkingAllAsRead guards markAllAsRead',
        () async {
      final mockRepo = MockNotificationRepository(engineConfig: instantConfig);
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(notificationsControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      await controller.loadNotifications();

      expect(container.read(notificationsControllerProvider).unreadCount, greaterThan(0));

      // Mark all read
      await controller.markAllAsRead();
      expect(container.read(notificationsControllerProvider).unreadCount, equals(0));

      // Subsequent call when unread == 0 is safe no-op
      await controller.markAllAsRead();
      expect(container.read(notificationsControllerProvider).unreadCount, equals(0));
    });
  });
}

class _DummyContext extends Fake implements BuildContext {
  @override
  bool get mounted => true;
}

class _SpyPaymentRepository extends MockPaymentRepository {
  _SpyPaymentRepository({super.engineConfig});
  int initiateCalls = 0;

  @override
  Future<PaymentOrderEntity> initiatePayment({
    required String membershipId,
    required int monthFor,
    int monthsCount = 1,
    PaymentMethodEnum paymentMethod = PaymentMethodEnum.online,
  }) async {
    initiateCalls++;
    return super.initiatePayment(
      membershipId: membershipId,
      monthFor: monthFor,
      monthsCount: monthsCount,
      paymentMethod: paymentMethod,
    );
  }
}

class _SpyGatewayLauncher extends MockPaymentGatewayLauncher {
  _SpyGatewayLauncher({super.forcedResult});
  int launchCalls = 0;

  @override
  Future<GatewayResult> launchGateway({
    required BuildContext context,
    required PaymentOrderEntity order,
  }) async {
    launchCalls++;
    return super.launchGateway(context: context, order: order);
  }
}

