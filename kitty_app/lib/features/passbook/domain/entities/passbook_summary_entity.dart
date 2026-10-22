/// Pure domain entity representing summary metrics for customer's passbook ledger.
class PassbookSummaryEntity {
  const PassbookSummaryEntity({
    required this.chitToken,
    required this.schemeName,
    required this.totalMonths,
    required this.monthsPaid,
    required this.monthlyEmi,
    required this.totalPaid,
    required this.accumulatedGoldGrams,
    this.isPreJoin = false,
  });

  /// Canonical chit token (e.g. "#SW-042").
  final String chitToken;

  /// Human-readable scheme name.
  final String schemeName;

  /// Scheme tenure in months (e.g. 12).
  final int totalMonths;

  /// Number of completed installments (e.g. 8).
  final int monthsPaid;

  /// Base monthly installment in integer rupees (e.g. 5000).
  final int monthlyEmi;

  /// Total amount contributed in integer rupees (e.g. 40000).
  final int totalPaid;

  /// Total 24K pure gold accumulated in grams with 3-decimal precision (e.g. 5.482).
  final double accumulatedGoldGrams;

  /// Whether the patron enrolled via a late-join / PRE_JOIN state.
  final bool isPreJoin;

  /// Remaining unpaid installments count.
  int get remainingMonths => (totalMonths - monthsPaid).clamp(0, totalMonths);
}
