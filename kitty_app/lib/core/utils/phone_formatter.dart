/// Helper utility for formatting and sanitizing Indian mobile phone numbers.
abstract final class PhoneFormatter {
  /// Cleans raw input to a standard 10-digit Indian mobile number.
  /// Strips `+91`, leading `0`, spaces, dashes, parentheses.
  /// - `+91 98765-43210` -> `9876543210`
  /// - `09876543210` -> `9876543210`
  static String clean(String? rawPhone) {
    if (rawPhone == null) return '';
    String digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0') && digits.length == 11) {
      digits = digits.substring(1);
    }
    return digits;
  }

  /// Formats 10-digit phone number with 5-5 grouping:
  /// - `9876543210` -> `98765 43210`
  static String format5x5(String? phone) {
    final String cleaned = clean(phone);
    if (cleaned.length != 10) return cleaned;
    return '${cleaned.substring(0, 5)} ${cleaned.substring(5)}';
  }

  /// Formats with standard Indian country code:
  /// - `9876543210` -> `+91 98765 43210`
  static String formatWithCountryCode(String? phone) {
    final String formatted = format5x5(phone);
    if (formatted.isEmpty) return '';
    return '+91 $formatted';
  }

  /// Masks mobile number for privacy on passbook/receipt previews:
  /// - `9876543210` -> `98765 •••••` or `••••••3210`
  static String maskMiddle(String? phone) {
    final String cleaned = clean(phone);
    if (cleaned.length != 10) return cleaned;
    return '${cleaned.substring(0, 2)}••••••${cleaned.substring(8)}';
  }
}
