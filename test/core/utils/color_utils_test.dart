import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purenote/core/utils/color_utils.dart';

void main() {
  group('ColorUtils.fromArgb / toArgb roundtrip', () {
    test('roundtrips a known color value', () {
      const argb = 0xFF42A5F5;
      final color = ColorUtils.fromArgb(argb);
      expect(color, isA<Color>());
      expect(ColorUtils.toArgb(color), argb);
    });

    test('roundtrips pure black', () {
      const argb = 0xFF000000;
      final color = ColorUtils.fromArgb(argb);
      expect(ColorUtils.toArgb(color), argb);
    });

    test('roundtrips pure white', () {
      const argb = 0xFFFFFFFF;
      final color = ColorUtils.fromArgb(argb);
      expect(ColorUtils.toArgb(color), argb);
    });

    test('roundtrips a color with low alpha', () {
      const argb = 0x33FF0000;
      final color = ColorUtils.fromArgb(argb);
      expect(ColorUtils.toArgb(color), argb);
    });
  });

  group('ColorUtils.isLight', () {
    test('returns true for a light color', () {
      expect(ColorUtils.isLight(Colors.white), isTrue);
    });

    test('returns false for a dark color', () {
      expect(ColorUtils.isLight(Colors.black), isFalse);
    });

    test('returns true for a light yellow', () {
      expect(ColorUtils.isLight(Color(0xFFFFEE58)), isTrue);
    });

    test('returns false for a dark blue', () {
      expect(ColorUtils.isLight(Color(0xFF1A237E)), isFalse);
    });
  });
}
