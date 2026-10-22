import '../../../../core/enums/app_enums.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/mock/mock_engine_config.dart';
import '../../../../core/mock/mock_fixtures.dart';
import '../../domain/entities/payment_order_entity.dart';
import '../../domain/repositories/i_payment_repository.dart';
import '../dtos/payment_dto.dart';
import '../mappers/payment_mapper.dart';

/// Mock implementation of [IPaymentRepository] with state transition polling support.
class MockPaymentRepository implements IPaymentRepository {
  MockPaymentRepository({MockEngineConfig? engineConfig})
      : _engineConfig = engineConfig ?? MockEngineConfig.instance;

  final MockEngineConfig _engineConfig;
  final Map<String, int> _pollCounts = <String, int>{};
  PaymentStatusEnum _forcedFinalStatus = PaymentStatusEnum.success;
  int _requiredPollsBeforeSuccess = 2;
  bool _shouldThrowOnInitiate = false;
  bool _shouldThrowOnPoll = false;

  /// Configures polling behavior for testing.
  void configurePolling({
    PaymentStatusEnum finalStatus = PaymentStatusEnum.success,
    int requiredPolls = 2,
  }) {
    _forcedFinalStatus = finalStatus;
    _requiredPollsBeforeSuccess = requiredPolls;
  }

  /// Forces throwing exception on initiate.
  void setShouldThrowOnInitiate(bool shouldThrow) {
    _shouldThrowOnInitiate = shouldThrow;
  }

  /// Forces throwing exception on poll.
  void setShouldThrowOnPoll(bool shouldThrow) {
    _shouldThrowOnPoll = shouldThrow;
  }

  /// Resets poll count and configuration.
  void reset() {
    _pollCounts.clear();
    _forcedFinalStatus = PaymentStatusEnum.success;
    _requiredPollsBeforeSuccess = 2;
    _shouldThrowOnInitiate = false;
    _shouldThrowOnPoll = false;
  }

  @override
  Future<PaymentOrderEntity> initiatePayment({
    required String membershipId,
    required int monthFor,
    int monthsCount = 1,
    PaymentMethodEnum paymentMethod = PaymentMethodEnum.online,
  }) async {
    await _engineConfig.simulate();

    if (_shouldThrowOnInitiate) {
      throw const NetworkException('Failed to initiate payment gateway order.');
    }

    final PaymentInitiateResponseDto dto =
        PaymentInitiateResponseDto.fromJson(
      MockFixtures.paymentInitiateSuccessJson['data'] as Map<String, dynamic>,
    );

    _pollCounts[dto.orderId] = 0;

    final PaymentOrderEntity baseOrder = PaymentMapper.toOrderEntity(dto);
    return PaymentOrderEntity(
      orderId: baseOrder.orderId,
      paymentId: baseOrder.paymentId,
      amount: baseOrder.amount * monthsCount,
      currency: baseOrder.currency,
      merchantKey: baseOrder.merchantKey,
    );
  }

  @override
  Future<PaymentStatusEntity> getPaymentStatus(String orderId) async {
    await _engineConfig.simulate();

    if (_shouldThrowOnPoll) {
      throw const NetworkException('Network error during status verification poll.');
    }

    final int currentPoll = (_pollCounts[orderId] ?? 0) + 1;
    _pollCounts[orderId] = currentPoll;

    // Simulate PENDING on initial polls, transitioning to final status
    if (currentPoll <= _requiredPollsBeforeSuccess) {
      final PaymentStatusResponseDto pendingDto =
          PaymentStatusResponseDto.fromJson(
        MockFixtures.paymentStatusPendingJson['data'] as Map<String, dynamic>,
      );
      return PaymentMapper.toStatusEntity(pendingDto);
    }

    if (_forcedFinalStatus == PaymentStatusEnum.failed) {
      final PaymentStatusResponseDto failedDto =
          PaymentStatusResponseDto.fromJson(
        MockFixtures.paymentStatusFailedJson['data'] as Map<String, dynamic>,
      );
      return PaymentMapper.toStatusEntity(failedDto);
    }

    if (_forcedFinalStatus == PaymentStatusEnum.cancelled) {
      final PaymentStatusResponseDto cancelledDto =
          PaymentStatusResponseDto.fromJson(
        MockFixtures.paymentStatusCancelledJson['data'] as Map<String, dynamic>,
      );
      return PaymentMapper.toStatusEntity(cancelledDto);
    }

    if (_forcedFinalStatus == PaymentStatusEnum.unknown) {
      const PaymentStatusResponseDto unknownDto = PaymentStatusResponseDto(
        orderId: 'gokwik_ord_771829',
        status: 'UNRECOGNIZED_STATUS_FOR_TEST',
        totalPaidAmount: 40000,
        monthsPaid: 8,
      );
      return PaymentMapper.toStatusEntity(unknownDto);
    }

    final PaymentStatusResponseDto successDto =
        PaymentStatusResponseDto.fromJson(
      MockFixtures.paymentStatusSuccessJson['data'] as Map<String, dynamic>,
    );
    return PaymentMapper.toStatusEntity(successDto);
  }
}

