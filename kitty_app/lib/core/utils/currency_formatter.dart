import 'package:intl/intl.dart';

/// Bank-grade Indian Rupee currency formatter strictly operating on integer rupees.
///
/// Follows Frozen Backend Contract v1.0:
/// - Pure integer rupees (no floating point, no fractional paise).
/// - Indian numbering format (e.g. `₹5,000`, `₹1,05,000`, `₹60,000`).
abstract final class CurrencyFormatter {
  static final NumberFormat _formatterWithSymbol = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _formatterWithoutSymbol = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: 0,
  );

  /// Formats integer rupees with `₹` symbol and Indian comma grouping:
  /// - `5000` -> `₹5,000`
  /// - `105000` -> `₹1,05,000`
  /// - `0` -> `₹0`
  static String formatRupees(int? amount) {
    if (amount == null) return '₹0';
    return _formatterWithSymbol.format(amount).trim();
  }

  /// Formats integer rupees without currency symbol:
  /// - `5000` -> `5,000`
  /// - `105000` -> `1,05,000`
  static String formatWithoutSymbol(int? amount) {
    if (amount == null) return '0';
    return _formatterWithoutSymbol.format(amount).trim();
  }

  /// Parses a string representation of rupee amount safely to integer rupees.
  /// Strips symbols (`₹`), commas, spaces.
  /// - `₹1,05,000` -> `105000`
  /// - `5000` -> `5000`
  static int parseRupees(String? value) {
    if (value == null) return 0;
    final String clean = value.replaceAll(RegExp(r'[^\d-]'), '');
    if (clean.isEmpty || clean == '-') return 0;
    return int.tryParse(clean) ?? 0;
  }
}
