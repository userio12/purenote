import 'package:flutter/material.dart';

class ColorUtils {
  ColorUtils._();

  static Color fromArgb(int value) => Color(value);

  static int toArgb(Color color) => color.toARGB32();

  static Color withAlpha(Color color, double alpha) =>
      color.withValues(alpha: alpha);

  static bool isLight(Color color) => color.computeLuminance() > 0.5;
}
