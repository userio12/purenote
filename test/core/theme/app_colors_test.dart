import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purenote/core/theme/app_colors.dart';

void main() {
  group('AppColors.noteColorValues', () {
    test('has exactly 12 entries', () {
      expect(AppColors.noteColorValues.length, 12);
    });

    test('all values are valid 32-bit ARGB colors', () {
      for (final v in AppColors.noteColorValues) {
        expect(v, inInclusiveRange(0x00000000, 0xFFFFFFFF));
      }
    });
  });

  group('AppColors.noteColor', () {
    test('returns Color for a non-null int value', () {
      final color = AppColors.noteColor(0xFFEF5350);
      expect(color, isA<Color>());
      expect(color!.toARGB32(), 0xFFEF5350);
    });

    test('returns null for null input', () {
      expect(AppColors.noteColor(null), isNull);
    });
  });

  group('AppColors.luminance', () {
    test('returns a value between 0 and 1 for each note color', () {
      for (final v in AppColors.noteColorValues) {
        final l = AppColors.luminance(v);
        expect(l, inInclusiveRange(0.0, 1.0));
      }
    });

    test('white has luminance near 1', () {
      expect(AppColors.luminance(0xFFFFFFFF), closeTo(1.0, 0.01));
    });

    test('black has luminance near 0', () {
      expect(AppColors.luminance(0xFF000000), closeTo(0.0, 0.01));
    });
  });

  group('AppColors.isLight', () {
    test('returns true for a light color (yellow)', () {
      expect(AppColors.isLight(0xFFFFEE58), isTrue);
    });

    test('returns false for a dark color (indigo 900)', () {
      expect(AppColors.isLight(0xFF1A237E), isFalse);
    });

    test('returns expected value for each note color', () {
      for (final v in AppColors.noteColorValues) {
        final light = AppColors.luminance(v) > 0.5;
        expect(AppColors.isLight(v), light);
      }
    });
  });
}
