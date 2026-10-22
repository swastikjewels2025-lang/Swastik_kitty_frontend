import '../../../../core/enums/app_enums.dart';

/// Data Transfer Object for payment receipt.
class ReceiptDto {
  const ReceiptDto({
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

  factory ReceiptDto.fromJson(Map<String, dynamic> json) {
    return ReceiptDto(
      receiptId: json['receiptId'] as String? ?? json['receipt_id'] as String? ?? '',
      transactionId: json['transactionId'] as String? ?? json['transaction_id'] as String? ?? '',
      paymentOrderId: json['paymentOrderId'] as String? ?? json['payment_order_id'] as String? ?? '',
      membershipId: json['membershipId'] as String? ?? json['membership_id'] as String? ?? '',
      customerName: json['patronName'] as String? ?? json['customer_name'] as String? ?? json['customerName'] as String? ?? '',
      customerPhone: json['phone'] as String? ?? json['customer_phone'] as String? ?? json['customerPhone'] as String? ?? '',
      schemeName: json['schemeName'] as String? ?? json['scheme_name'] as String? ?? '',
      installmentNumber: (json['monthNumber'] as num? ?? json['installment_number'] as num? ?? json['installmentNumber'] as num? ?? 1).toInt(),
      totalInstallments: (json['total_installments'] as num? ?? json['totalInstallments'] as num? ?? 12).toInt(),
      amount: (json['amount'] as num? ?? 0).toInt(),
      goldRateAtPayment: (json['goldRatePerGram'] as num? ?? json['gold_rate_at_payment'] as num? ?? json['goldRateAtPayment'] as num? ?? 0.0).toDouble(),
      goldWeightCreditedGrams: (json['goldGramsAllocated'] as num? ?? json['gold_weight_credited_grams'] as num? ?? json['goldWeightCreditedGrams'] as num? ?? 0.0).toDouble(),
      paymentMethod: PaymentMethodEnum.fromString(json['paymentMethod'] as String? ?? json['payment_method'] as String?),
      paymentStatus: PaymentStatusEnum.fromString(json['paymentStatus'] as String? ?? json['payment_status'] as String? ?? 'SUCCESS'),
      paidAt: json['paidAt'] as String? ?? json['paid_at'] as String? ?? '',
      pdfUrl: json['receiptUrl'] as String? ?? json['pdfUrl'] as String? ?? json['pdf_url'] as String?,
    );
  }

  final String receiptId;
  final String transactionId;
  final String paymentOrderId;
  final String membershipId;
  final String customerName;
  final String customerPhone;
  final String schemeName;
  final int installmentNumber;
  final int totalInstallments;
  final int amount;
  final double goldRateAtPayment;
  final double goldWeightCreditedGrams;
  final PaymentMethodEnum paymentMethod;
  final PaymentStatusEnum paymentStatus;
  final String paidAt;
  final String? pdfUrl;

  Map<String, dynamic> toJson() {
    return {
      'receiptId': receiptId,
      'transactionId': transactionId,
      'paymentOrderId': paymentOrderId,
      'membershipId': membershipId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'schemeName': schemeName,
      'installmentNumber': installmentNumber,
      'totalInstallments': totalInstallments,
      'amount': amount,
      'goldRateAtPayment': goldRateAtPayment,
      'goldWeightCreditedGrams': goldWeightCreditedGrams,
      'paymentMethod': paymentMethod.toJson(),
      'paymentStatus': paymentStatus.toJson(),
      'paidAt': paidAt,
      if (pdfUrl != null) 'pdfUrl': pdfUrl,
    };
  }
}
