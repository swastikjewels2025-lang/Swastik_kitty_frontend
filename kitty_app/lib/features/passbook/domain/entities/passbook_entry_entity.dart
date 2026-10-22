import '../../../../core/enums/app_enums.dart';

/// Pure domain entity representing an installment record in the passbook ledger.
class PassbookEntryEntity {
  const PassbookEntryEntity({
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

  final int month;
  final String label;
  final int amount; // Whole integer Rupees (e.g. 5000)
  final InstallmentStatusEnum status;
  final DateTime? paidAt;
  final DateTime? dueDate;
  final PaymentMethodEnum? paymentMethod;
  final String? transactionId;
  final double? goldGrams; // 3 Decimals precision (e.g. 0.702)
  final String? receiptUrl;
  final String? bonusNote;
  final String? monthName;

  bool get isPaid => status == InstallmentStatusEnum.paid;
  bool get isCurrent => status == InstallmentStatusEnum.current;
  bool get isBonus => status == InstallmentStatusEnum.bonus;
  bool get isPreJoin => status == InstallmentStatusEnum.preJoin;
}
