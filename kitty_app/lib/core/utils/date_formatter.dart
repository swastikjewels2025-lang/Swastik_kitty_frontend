import 'package:intl/intl.dart';

/// Centralized Date and Time formatter converting UTC timestamps to Indian Standard Time (IST).
abstract final class DateFormatter {
  /// Indian Standard Time offset (+05:30).
  static const Duration istOffset = Duration(hours: 5, minutes: 30);

  static final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _displayDateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _shortMonthYearFormat = DateFormat('MMM yyyy');
  static final DateFormat _isoDateFormat = DateFormat('yyyy-MM-dd');

  /// Convert a [DateTime] to IST timezone.
  static DateTime toIst(DateTime dateTime) {
    if (dateTime.isUtc) {
      return dateTime.add(istOffset);
    }
    return dateTime.toUtc().add(istOffset);
  }

  /// Formats UTC [DateTime] to IST display string (e.g. `15 Sep 2026`).
  static String formatUtcToIst(DateTime? utcDateTime) {
    if (utcDateTime == null) return '—';
    final DateTime ist = toIst(utcDateTime);
    return _displayDateFormat.format(ist);
  }

  /// Formats UTC [DateTime] to IST with time (e.g. `15 Sep 2026, 06:30 PM`).
  static String formatUtcToIstWithTime(DateTime? utcDateTime) {
    if (utcDateTime == null) return '—';
    final DateTime ist = toIst(utcDateTime);
    return _displayDateTimeFormat.format(ist);
  }

  /// Formats ISO 8601 string to localized IST display date (e.g. `15 Sep 2026`).
  static String formatIsoToDisplay(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) return '—';
    try {
      final DateTime parsed = DateTime.parse(isoString);
      return formatUtcToIst(parsed);
    } catch (_) {
      return isoString;
    }
  }

  /// Formats ISO 8601 string to localized IST date and time (e.g. `15 Sep 2026, 06:30 PM`).
  static String formatIsoToDisplayWithTime(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) return '—';
    try {
      final DateTime parsed = DateTime.parse(isoString);
      return formatUtcToIstWithTime(parsed);
    } catch (_) {
      return isoString;
    }
  }

  /// Formats [DateTime] to month and year (e.g. `September 2026`).
  static String formatMonthYear(DateTime? dateTime) {
    if (dateTime == null) return '—';
    return _monthYearFormat.format(dateTime);
  }

  /// Formats [DateTime] to short month and year (e.g. `Sep 2026`).
  static String formatShortMonthYear(DateTime? dateTime) {
    if (dateTime == null) return '—';
    return _shortMonthYearFormat.format(dateTime);
  }

  /// Formats [DateTime] to standard `yyyy-MM-dd`.
  static String formatIsoDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _isoDateFormat.format(dateTime);
  }
}
