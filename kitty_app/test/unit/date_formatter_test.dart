import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter (UTC to IST)', () {
    test('converts UTC timestamp to IST (+05:30) correctly', () {
      final DateTime utcDate = DateTime.utc(2026, 9, 15, 13, 0); // 13:00 UTC = 18:30 IST
      final String formatted = DateFormatter.formatUtcToIst(utcDate);
      expect(formatted, equals('15 Sep 2026'));
    });

    test('formats UTC timestamp with time in IST', () {
      final DateTime utcDate = DateTime.utc(2026, 9, 15, 13, 0);
      final String formatted = DateFormatter.formatUtcToIstWithTime(utcDate);
      expect(formatted, equals('15 Sep 2026, 06:30 PM'));
    });

    test('parses ISO string and formats to display date', () {
      const String iso = '2026-09-15T13:00:00.000Z';
      expect(DateFormatter.formatIsoToDisplay(iso), equals('15 Sep 2026'));
      expect(DateFormatter.formatIsoToDisplayWithTime(iso), equals('15 Sep 2026, 06:30 PM'));
    });

    test('formats month and year', () {
      final DateTime date = DateTime(2026, 9, 15);
      expect(DateFormatter.formatMonthYear(date), equals('September 2026'));
      expect(DateFormatter.formatShortMonthYear(date), equals('Sep 2026'));
    });

    test('handles null safely', () {
      expect(DateFormatter.formatUtcToIst(null), equals('—'));
      expect(DateFormatter.formatIsoToDisplay(null), equals('—'));
      expect(DateFormatter.formatMonthYear(null), equals('—'));
    });
  });
}
