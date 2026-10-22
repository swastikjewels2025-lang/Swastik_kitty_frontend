/// Pure domain entity representing live bullion gold ticker rates.
///
/// Preserves exact 3-decimal precision according to backend contract.
class LiveGoldRateEntity {
  const LiveGoldRateEntity({
    required this.ratePerGram, // 3-decimal precision (e.g. 7120.500)
    required this.purity, // e.g. "24K (999)"
    required this.purityFraction, // 0.999
    required this.currency,
    required this.change24h, // e.g. +45.250
    required this.changePct, // e.g. +0.64
    required this.isUp,
    required this.updatedAt,
    this.silverRatePerGram,
    this.rate22k,
    this.rate18k,
    this.rate14k,
  });

  final double ratePerGram;
  final String purity;
  final double purityFraction;
  final String currency;
  final double change24h;
  final double changePct;
  final bool isUp;
  final DateTime updatedAt;
  final double? silverRatePerGram;
  final double? rate22k;
  final double? rate18k;
  final double? rate14k;

  /// Benchmark 24K rate per gram.
  double get rate24k => ratePerGram;

  /// Effective 22K rate per gram (explicit backend value or standard 22/24 fraction).
  double get effectiveRate22k => rate22k ?? (ratePerGram * (22.0 / 24.0));

  /// Effective 18K rate per gram (explicit backend value or standard 18/24 fraction).
  double get effectiveRate18k => rate18k ?? (ratePerGram * (18.0 / 24.0));

  /// Effective 14K rate per gram (explicit backend value or standard 14/24 fraction).
  double get effectiveRate14k => rate14k ?? (ratePerGram * (14.0 / 24.0));
}
