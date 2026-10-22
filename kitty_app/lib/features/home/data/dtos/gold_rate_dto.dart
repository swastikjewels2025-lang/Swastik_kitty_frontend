/// Live Gold Rate Data Transfer Object adhering to Frozen Backend Contract v1.0.
class LiveGoldRateDto {
  const LiveGoldRateDto({
    required this.ratePerGram,
    required this.purity,
    required this.purityFraction,
    required this.currency,
    required this.change24h,
    required this.changePct,
    required this.isUp,
    required this.updatedAt,
    this.rate24k,
    this.rate22k,
    this.benchmark,
    this.silverRatePerGram,
  });

  factory LiveGoldRateDto.fromJson(Map<String, dynamic> json) {
    // Backend provides rate24k and rateChangePct; mock fixtures provide ratePerGram and changePct
    final double? rawRate24k = (json['rate24k'] as num?)?.toDouble();
    final double? rawRate22k = (json['rate22k'] as num?)?.toDouble();
    final double? rawRateChangePct = (json['rateChangePct'] as num?)?.toDouble();
    final double? rawSilverRate = (json['silverRatePerGram'] as num?)?.toDouble() ??
        (json['silverRate'] as num?)?.toDouble() ??
        (json['rateSilver'] as num?)?.toDouble();

    final double ratePerGram = rawRate24k ??
        (json['ratePerGram'] as num?)?.toDouble() ??
        0.0;
    final double changePct = rawRateChangePct ??
        (json['changePct'] as num?)?.toDouble() ??
        0.0;
    final double change24h = (json['change24h'] as num?)?.toDouble() ?? 0.0;
    final bool isUp = json['isUp'] as bool? ?? (changePct >= 0);

    return LiveGoldRateDto(
      ratePerGram: ratePerGram,
      purity: json['purity'] as String? ?? '24K (999)',
      purityFraction: (json['purityFraction'] as num?)?.toDouble() ?? 0.999,
      currency: json['currency'] as String? ?? 'INR',
      change24h: change24h,
      changePct: changePct,
      isUp: isUp,
      updatedAt: json['updatedAt'] as String? ?? '',
      rate24k: rawRate24k,
      rate22k: rawRate22k,
      benchmark: json['benchmark'] as String?,
      silverRatePerGram: rawSilverRate,
    );
  }

  final double ratePerGram;
  final String purity;
  final double purityFraction;
  final String currency;
  final double change24h;
  final double changePct;
  final bool isUp;
  final String updatedAt;
  final double? rate24k;
  final double? rate22k;
  final String? benchmark;
  final double? silverRatePerGram;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'ratePerGram': ratePerGram,
        'purity': purity,
        'purityFraction': purityFraction,
        'currency': currency,
        'change24h': change24h,
        'changePct': changePct,
        'isUp': isUp,
        'updatedAt': updatedAt,
        if (rate24k != null) 'rate24k': rate24k,
        if (rate22k != null) 'rate22k': rate22k,
        if (benchmark != null) 'benchmark': benchmark,
      };
}
