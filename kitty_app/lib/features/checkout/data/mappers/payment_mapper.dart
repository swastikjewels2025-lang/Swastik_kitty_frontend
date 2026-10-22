import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/payment_order_entity.dart';
import '../dtos/payment_dto.dart';

/// Mapper between Payment DTOs and Domain Entities.
abstract final class PaymentMapper {
  static PaymentOrderEntity toOrderEntity(PaymentInitiateResponseDto dto) {
    return PaymentOrderEntity(
      orderId: dto.orderId,
      paymentId: dto.paymentId,
      amount: dto.amount, // Whole integer rupees preserved
      currency: dto.currency,
      merchantKey: dto.merchantKey,
    );
  }

  static PaymentStatusEntity toStatusEntity(PaymentStatusResponseDto dto) {
    return PaymentStatusEntity(
      orderId: dto.orderId,
      status: PaymentStatusEnum.fromString(dto.status),
      transactionId: dto.transactionId,
      receiptUrl: dto.receiptUrl,
      totalPaidAmount: dto.totalPaidAmount, // Whole integer rupees preserved
      monthsPaid: dto.monthsPaid,
    );
  }
}
