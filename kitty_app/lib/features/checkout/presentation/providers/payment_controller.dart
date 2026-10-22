import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_controller.dart';
import '../../../home/presentation/providers/home_controller.dart';
import '../../../passbook/presentation/providers/passbook_controller.dart';
import '../../../payment_gateway/domain/gateway_result.dart';
import '../../../payment_gateway/domain/i_payment_gateway_launcher.dart';
import '../../../payment_gateway/presentation/providers/gateway_providers.dart';
import '../../domain/entities/payment_order_entity.dart';
import '../../domain/repositories/i_payment_repository.dart';
import 'payment_state.dart';

/// Riverpod provider for [PaymentController].
final NotifierProvider<PaymentController, PaymentState> paymentControllerProvider =
    NotifierProvider<PaymentController, PaymentState>(PaymentController.new);

/// Controller managing payment checkout initiation, gateway coordination,
/// status polling loop, terminal state reconciliation, and provider invalidation.
class PaymentController extends Notifier<PaymentState> {
  late IPaymentRepository _paymentRepository;
  late IPaymentGatewayLauncher _gatewayLauncher;

  bool _isDisposed = false;
  Completer<void>? _activePollingCompleter;

  /// Configurable polling duration between requests (default 2 seconds).
  Duration pollingInterval = const Duration(seconds: 2);

  @override
  PaymentState build() {
    _paymentRepository = ref.watch(paymentRepositoryProvider);
    _gatewayLauncher = ref.watch(paymentGatewayLauncherProvider);

    ref.onDispose(() {
      _isDisposed = true;
      _activePollingCompleter?.complete();
    });

    // Auto-detect instant testing latency to keep test suites fast and synchronous
    try {
      final mockEngine = ref.watch(mockEngineConfigProvider);
      if (mockEngine.latency.duration == Duration.zero) {
        pollingInterval = Duration.zero;
      }
    } catch (_) {
      // Production or standalone testing without mock engine provider
    }

    return const PaymentState();
  }

  /// Sets custom installment parameters (e.g. from passbook pay action).
  void setInstallmentContext({
    required String membershipId,
    required String chitToken,
    required int monthFor,
    required int amount,
    int totalDurationMonths = 12,
  }) {
    if (state.isBusy) return;
    final int remaining =
        (totalDurationMonths - monthFor + 1).clamp(1, totalDurationMonths);
    state = state.copyWith(
      membershipId: membershipId,
      chitToken: chitToken,
      monthFor: monthFor,
      startMonth: monthFor,
      amount: amount,
      monthlyInstallment: amount,
      selectedMonthsCount: 1,
      totalDurationMonths: totalDurationMonths,
      remainingMonthsCount: remaining,
    );
  }

  /// Selects the number of installment months to pay (1, 2, 3, or remaining).
  bool selectMonthsCount(int count) {
    if (state.isBusy) return false;
    final int maxAllowed = state.remainingMonthsCount;
    if (count < 1 || count > maxAllowed) {
      state = state.copyWith(
        errorMessage: 'Invalid month selection. Remaining months: $maxAllowed.',
      );
      return false;
    }

    final int newTotal = count * state.monthlyInstallment;
    state = state.copyWith(
      selectedMonthsCount: count,
      amount: newTotal,
      clearError: true,
    );
    return true;
  }

  /// Selects all remaining months in the active tenure.
  void selectAllRemainingMonths() {
    selectMonthsCount(state.remainingMonthsCount);
  }

  /// Selects specific payment channel (UPI, NetBanking, Card, Pick Cash).
  void selectPaymentChannel(PaymentChannel channel) {
    if (state.isBusy) return;
    state = state.copyWith(
      selectedChannel: channel,
      selectedMethod: channel.methodEnum,
      clearError: true,
    );
  }

  /// Selects payment method (ONLINE, CASH) with channel synchronization.
  void selectPaymentMethod(PaymentMethodEnum method) {
    if (state.isBusy) return;
    final PaymentChannel channel = method == PaymentMethodEnum.cash
        ? PaymentChannel.pickCash
        : (state.selectedChannel == PaymentChannel.pickCash
            ? PaymentChannel.upi
            : state.selectedChannel);
    state = state.copyWith(
      selectedMethod: method,
      selectedChannel: channel,
      clearError: true,
    );
  }

  /// Initiates payment and manages the entire gateway and polling lifecycle.
  ///
  /// Protected against duplicate initiation and double-taps.
  Future<void> initiateAndPay(BuildContext context) async {
    // 1. Duplicate Initiation Protection
    if (state.isBusy) {
      return;
    }

    state = state.copyWith(
      status: PaymentUiStatus.initiating,
      clearError: true,
    );

    PaymentOrderEntity order;
    try {
      // 2. Initiate Payment with backend repository
      order = await _paymentRepository.initiatePayment(
        membershipId: state.membershipId,
        monthFor: state.monthFor,
        monthsCount: state.selectedMonthsCount,
        paymentMethod: state.selectedMethod,
      );

      if (_isDisposed) return;
      state = state.copyWith(
        order: order,
        status: PaymentUiStatus.awaitingGateway,
      );
    } on AppException catch (e) {
      if (_isDisposed) return;
      state = state.copyWith(
        status: PaymentUiStatus.error,
        errorMessage: e.message,
      );
      return;
    } catch (_) {
      if (_isDisposed) return;
      state = state.copyWith(
        status: PaymentUiStatus.error,
        errorMessage: 'Unable to initiate payment session. Please check your connection and try again.',
      );
      return;
    }

    // 3. Launch Payment Gateway Interface
    if (!context.mounted) return;
    GatewayResult gatewayResult;
    try {
      gatewayResult = await _gatewayLauncher.launchGateway(
        context: context,
        order: order,
      );
    } catch (_) {
      if (_isDisposed) return;
      state = state.copyWith(
        status: PaymentUiStatus.error,
        errorMessage: 'Payment gateway encountered an unexpected launch error.',
      );
      return;
    }

    if (_isDisposed) return;

    // 4. Handle Gateway return
    if (gatewayResult.isCancelled) {
      state = state.copyWith(
        status: PaymentUiStatus.cancelled,
        errorMessage: gatewayResult.message ?? 'Payment cancelled by user.',
      );
      return;
    }

    // 5. Begin Reconciliation Polling Loop
    // Even if gateway reported failed or completed, the BACKEND remains the
    // authoritative source of truth. We poll the backend status.
    await startPolling(order.orderId);
  }

  /// Executes status polling loop against backend repository.
  Future<void> startPolling(String orderId) async {
    if (_isDisposed) return;

    state = state.copyWith(
      status: PaymentUiStatus.polling,
      pollCount: 0,
      pollingMessage: 'Verifying payment with bank...',
    );

    const int maxAttempts = 5;
    for (int i = 1; i <= maxAttempts; i++) {
      if (_isDisposed) return;

      // Update dynamic status message
      final String message = _getDynamicPollingMessage(i);
      state = state.copyWith(
        pollCount: i,
        pollingMessage: message,
      );

      try {
        final PaymentStatusEntity statusEntity =
            await _paymentRepository.getPaymentStatus(orderId);

        if (_isDisposed) return;

        // Terminal State: SUCCESS
        if (statusEntity.isSuccess) {
          state = state.copyWith(
            status: PaymentUiStatus.success,
            statusEntity: statusEntity,
          );

          // Invalidate data providers so that Dashboard, Passbook, and Home
          // refetch the newly updated records from their repositories.
          _invalidateDataProviders();
          return;
        }

        // Terminal State: FAILED
        if (statusEntity.isFailed) {
          state = state.copyWith(
            status: PaymentUiStatus.failed,
            statusEntity: statusEntity,
            errorMessage: 'Payment was declined by your bank or transaction expired.',
          );
          return;
        }

        // Terminal State: CANCELLED
        if (statusEntity.status == PaymentStatusEnum.cancelled) {
          state = state.copyWith(
            status: PaymentUiStatus.cancelled,
            statusEntity: statusEntity,
            errorMessage: 'Payment was cancelled before completion.',
          );
          return;
        }

        // Defensive: If unknown status is received, treat safely as pending
        // and do not mark as success
      } on AppException catch (e) {
        if (_isDisposed) return;
        // If last poll failed with network error, set error state
        if (i == maxAttempts) {
          state = state.copyWith(
            status: PaymentUiStatus.error,
            errorMessage: e.message,
          );
          return;
        }
      } catch (_) {
        if (_isDisposed) return;
        if (i == maxAttempts) {
          state = state.copyWith(
            status: PaymentUiStatus.error,
            errorMessage: 'Reconciliation timed out due to connection error.',
          );
          return;
        }
      }

      // Wait between polls if not last attempt
      if (i < maxAttempts) {
        await Future<void>.delayed(pollingInterval);
      }
    }

    if (_isDisposed) return;

    // 6. Polling reached maximum attempts (Timeout)
    state = state.copyWith(
      status: PaymentUiStatus.timeout,
      errorMessage: 'Payment status is taking longer than expected. We will update your passbook once confirmed.',
    );
  }

  /// Retries payment initiation after a failure or cancellation.
  Future<void> retry(BuildContext context) async {
    if (state.isBusy) return;
    state = state.copyWith(
      status: PaymentUiStatus.initial,
      clearError: true,
      pollCount: 0,
    );
    await initiateAndPay(context);
  }

  /// Resets state back to initial.
  void reset() {
    if (state.isBusy) return;
    state = state.copyWith(
      status: PaymentUiStatus.initial,
      clearError: true,
      pollCount: 0,
    );
  }

  String _getDynamicPollingMessage(int pollIndex) {
    switch (pollIndex) {
      case 1:
        return 'Verifying payment with bank...';
      case 2:
        return 'Confirming gateway authorization...';
      case 3:
        return 'Reconciling gold allocation with Swastik Vault...';
      case 4:
        return 'Updating official chit ledger...';
      case 5:
      default:
        return 'Finalizing transaction verification...';
    }
  }

  /// Invalidates related feature providers upon verified payment success.
  void _invalidateDataProviders() {
    ref.invalidate(dashboardControllerProvider);
    ref.invalidate(passbookControllerProvider);
    ref.invalidate(homeControllerProvider);
  }
}
