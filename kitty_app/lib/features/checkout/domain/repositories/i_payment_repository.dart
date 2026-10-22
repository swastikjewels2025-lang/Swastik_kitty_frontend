import '../../../../core/enums/app_enums.dart';
import '../entities/payment_order_entity.dart';

/// Pure domain repository interface for installment payments and reconciliation.
abstract interface class IPaymentRepository {
  /// Initiates payment order on GoKwik gateway.
  Future<PaymentOrderEntity> initiatePayment({
    required String membershipId,
    required int monthFor,
    int monthsCount = 1,
    PaymentMethodEnum paymentMethod = PaymentMethodEnum.online,
  });

  /// Polls / checks payment verification status.
  Future<PaymentStatusEntity> getPaymentStatus(String orderId);
}
