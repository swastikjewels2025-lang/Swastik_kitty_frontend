import '../../../../core/enums/app_enums.dart';

/// Pure domain entity representing an initiated payment order.
class PaymentOrderEntity {
  const PaymentOrderEntity({
    required this.orderId,
    required this.paymentId,
    required this.amount, // Whole integer Rupees
    required this.currency,
    this.merchantKey,
  });

  final String orderId;
  final String paymentId;
  final int amount;
  final String currency;
  final String? merchantKey;
}

/// Pure domain entity representing payment reconciliation status.
class PaymentStatusEntity {
  const PaymentStatusEntity({
    required this.orderId,
    required this.status,
    this.transactionId,
    this.receiptUrl,
    required this.totalPaidAmount,
    required this.monthsPaid,
  });

  final String orderId;
  final PaymentStatusEnum status;
  final String? transactionId;
  final String? receiptUrl;
  final int totalPaidAmount; // Whole integer Rupees
  final int monthsPaid;

  bool get isSuccess => status == PaymentStatusEnum.success;
  bool get isPending => status == PaymentStatusEnum.pending;
  bool get isFailed => status == PaymentStatusEnum.failed;
}
