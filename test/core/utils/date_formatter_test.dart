import 'package:flutter_test/flutter_test.dart';
import 'package:purenote/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter.formatRelative', () {
    test('returns "Just now" for a timestamp less than 60 seconds ago', () {
      final now = DateTime.now();
      final epochMs = now.millisecondsSinceEpoch - 30 * 1000;
      expect(DateFormatter.formatRelative(epochMs), 'Just now');
    });

    test('returns "Just now" for a timestamp of 0 seconds ago', () {
      final now = DateTime.now();
      expect(DateFormatter.formatRelative(now.millisecondsSinceEpoch), 'Just now');
    });

    test('returns "Just now" when less than 1 hour (no minutes granularity)', () {
      final now = DateTime.now();
      final epochMs = now.millisecondsSinceEpoch - 5 * 60 * 1000;
      expect(DateFormatter.formatRelative(epochMs), 'Just now');
    });

    test('returns hours ago when less than 1 day', () {
      final now = DateTime.now();
      final epochMs = now.millisecondsSinceEpoch - 3 * 60 * 60 * 1000;
      expect(DateFormatter.formatRelative(epochMs), '3h ago');
    });

    test('returns "Yesterday" for exactly 1 day ago', () {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      expect(DateFormatter.formatRelative(yesterday.millisecondsSinceEpoch), 'Yesterday');
    });

    test('returns days ago for less than 7 days', () {
      final now = DateTime.now();
      final daysAgo = DateTime(now.year, now.month, now.day - 4);
      expect(DateFormatter.formatRelative(daysAgo.millisecondsSinceEpoch), '4d ago');
    });

    test('returns month and day for older dates in the same year', () {
      final now = DateTime.now();
      final oldDate = DateTime(now.year, 3, 15);
      expect(DateFormatter.formatRelative(oldDate.millisecondsSinceEpoch), 'Mar 15');
    });

    test('returns full date for dates in a different year', () {
      final date = DateTime(2023, 12, 25);
      expect(DateFormatter.formatRelative(date.millisecondsSinceEpoch), 'Dec 25, 2023');
    });
  });

  group('DateFormatter.formatFull', () {
    test('formats a known timestamp correctly', () {
      final dt = DateTime(2024, 6, 15, 9, 5);
      expect(DateFormatter.formatFull(dt), 'Jun 15, 2024 09:05');
    });

    test('pads single-digit hour and minute with zeros', () {
      final dt = DateTime(2024, 1, 1, 3, 7);
      expect(DateFormatter.formatFull(dt), 'Jan 1, 2024 03:07');
    });

    test('handles midnight', () {
      final dt = DateTime(2024, 12, 31);
      expect(DateFormatter.formatFull(dt), 'Dec 31, 2024 00:00');
    });
  });
}
