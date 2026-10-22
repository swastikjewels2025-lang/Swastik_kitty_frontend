import '../../../../core/enums/app_enums.dart';

/// Domain entity representing a transaction receipt / payment acknowledgment.
class ReceiptEntity {
  const ReceiptEntity({
    required this.receiptId,
    required this.transactionId,
    required this.paymentOrderId,
    required this.membershipId,
    required this.customerName,
    required this.customerPhone,
    required this.schemeName,
    required this.installmentNumber,
    required this.totalInstallments,
    required this.amount,
    required this.goldRateAtPayment,
    required this.goldWeightCreditedGrams,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paidAt,
    this.pdfUrl,
  });

  final String receiptId;
  final String transactionId;
  final String paymentOrderId;
  final String membershipId;
  final String customerName;
  final String customerPhone;
  final String schemeName;
  final int installmentNumber;
  final int totalInstallments;
  /// Whole integer rupees
  final int amount;
  /// 3 decimal precision
  final double goldRateAtPayment;
  /// 3 decimal precision
  final double goldWeightCreditedGrams;
  final PaymentMethodEnum paymentMethod;
  final PaymentStatusEnum paymentStatus;
  final DateTime paidAt;
  final String? pdfUrl;
}
