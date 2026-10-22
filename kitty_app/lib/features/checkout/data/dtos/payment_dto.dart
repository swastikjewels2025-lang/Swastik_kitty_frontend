/// Request DTO for initiating GoKwik payment order.
class PaymentInitiateRequestDto {
  const PaymentInitiateRequestDto({
    required this.membershipId,
    required this.monthFor,
    required this.paymentMethod,
  });

  final String membershipId;
  final int monthFor;
  final String paymentMethod;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'membershipId': membershipId,
        'monthFor': monthFor,
        'paymentMethod': paymentMethod,
      };
}

/// Response DTO for initiated GoKwik payment order.
class PaymentInitiateResponseDto {
  const PaymentInitiateResponseDto({
    required this.orderId,
    required this.paymentId,
    required this.amount,
    required this.currency,
    this.merchantKey,
  });

  factory PaymentInitiateResponseDto.fromJson(Map<String, dynamic> json) {
    return PaymentInitiateResponseDto(
      orderId: json['orderId'] as String? ?? '',
      paymentId: json['paymentId'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      merchantKey: json['merchantKey'] as String?,
    );
  }

  final String orderId;
  final String paymentId;
  final int amount; // Whole integer rupees
  final String currency;
  final String? merchantKey;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'orderId': orderId,
        'paymentId': paymentId,
        'amount': amount,
        'currency': currency,
        if (merchantKey != null) 'merchantKey': merchantKey,
      };
}

/// Response DTO for payment verification polling status.
class PaymentStatusResponseDto {
  const PaymentStatusResponseDto({
    required this.orderId,
    required this.status,
    this.transactionId,
    this.receiptUrl,
    required this.totalPaidAmount,
    required this.monthsPaid,
  });

  factory PaymentStatusResponseDto.fromJson(Map<String, dynamic> json) {
    return PaymentStatusResponseDto(
      orderId: json['orderId'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      transactionId: json['transactionId'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      totalPaidAmount: json['totalPaidAmount'] as int? ?? 0,
      monthsPaid: json['monthsPaid'] as int? ?? 0,
    );
  }

  final String orderId;
  final String status;
  final String? transactionId;
  final String? receiptUrl;
  final int totalPaidAmount;
  final int monthsPaid;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'orderId': orderId,
        'status': status,
        if (transactionId != null) 'transactionId': transactionId,
        if (receiptUrl != null) 'receiptUrl': receiptUrl,
        'totalPaidAmount': totalPaidAmount,
        'monthsPaid': monthsPaid,
      };
}
