import 'package:flutter_test/flutter_test.dart';
import 'package:i_account/utils/date.dart';

void main() {
  group('Date Utility Tests', () {
    test('formatDate should format date correctly', () {
      final date = DateTime(2023, 5, 15);
      expect(formatDate(date), equals('2023-05-15'));
      expect(formatDate(date, showLen: 2), equals('2023-05'));
      expect(formatDate(date, showLen: 1), equals('2023'));
      expect(formatDate(date, gap: '/'), equals('2023/05/15'));
    });

    test('formatDateLeft should format date correctly', () {
      final date = DateTime(2023, 5, 15);
      expect(formatDateLeft(date), equals('05-15'));
      expect(formatDateLeft(date, showLen: 2), equals('05-15'));
      expect(formatDateLeft(date, showLen: 1), equals('15'));
      expect(formatDateLeft(date, gap: '/'), equals('05/15'));
    });

    test('getWeeksOfMonth should return correct weeks', () {
      final date = DateTime(2023, 5, 15);
      final weeks = getWeeksOfMonth(date);
      expect(weeks, isNotEmpty);
      // Check that all weeks belong to the same month
      for (final week in weeks) {
        expect(week.$3, greaterThan(0));
      }
    });

    test('getMonthlyRanges should return correct ranges', () {
      final date = DateTime(2023, 5, 15);
      final ranges = getMonthlyRanges(date);
      expect(ranges.length, equals(5)); // Jan to May
      expect(ranges.first.$3, equals(1)); // January
      expect(ranges.last.$3, equals(5)); // May
    });

    test('getYearlyRanges should return correct ranges', () {
      final date = DateTime(2023, 5, 15);
      final ranges = getYearlyRanges(date);
      expect(ranges, isNotEmpty);
      expect(ranges.last.$3, equals(2023));
    });
  });
}