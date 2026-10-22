/// Passbook Ledger Entry Data Transfer Object.
class PassbookEntryDto {
  const PassbookEntryDto({
    required this.month,
    required this.label,
    required this.amount,
    required this.status,
    this.paidAt,
    this.dueDate,
    this.paymentMethod,
    this.transactionId,
    this.goldGrams,
    this.receiptUrl,
    this.bonusNote,
    this.monthName,
  });

  factory PassbookEntryDto.fromJson(Map<String, dynamic> json) {
    return PassbookEntryDto(
      month: json['month'] as int? ?? 1,
      label: json['label'] as String? ?? 'Month ${json['month']}',
      amount: json['amount'] as int? ?? 0,
      status: json['status'] as String? ?? 'UPCOMING',
      paidAt: json['paidAt'] as String?,
      dueDate: json['dueDate'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
      goldGrams: (json['goldGrams'] as num?)?.toDouble(),
      receiptUrl: json['receiptUrl'] as String?,
      bonusNote: json['bonusNote'] as String?,
      monthName: json['monthName'] as String?,
    );
  }

  final int month;
  final String label;
  final int amount; // Whole integer rupees
  final String status;
  final String? paidAt;
  final String? dueDate;
  final String? paymentMethod;
  final String? transactionId;
  final double? goldGrams;
  final String? receiptUrl;
  final String? bonusNote;
  final String? monthName;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'month': month,
        'label': label,
        'amount': amount,
        'status': status,
        if (paidAt != null) 'paidAt': paidAt,
        if (dueDate != null) 'dueDate': dueDate,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (transactionId != null) 'transactionId': transactionId,
        if (goldGrams != null) 'goldGrams': goldGrams,
        if (receiptUrl != null) 'receiptUrl': receiptUrl,
        if (bonusNote != null) 'bonusNote': bonusNote,
        if (monthName != null) 'monthName': monthName,
      };
}
