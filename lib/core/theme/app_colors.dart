import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const List<int> noteColorValues = [
    0xFFEF5350,
    0xFFAB47BC,
    0xFF5C6BC0,
    0xFF42A5F5,
    0xFF26C6DA,
    0xFF66BB6A,
    0xFF9CCC65,
    0xFFFFEE58,
    0xFFFFA726,
    0xFF8D6E63,
    0xFF78909C,
    0xFFEC407A,
  ];

  static final List<Color> noteColors =
      noteColorValues.map((v) => Color(v)).toList();

  static Color? noteColor(int? colorValue) {
    return colorValue != null ? Color(colorValue) : null;
  }

  static double luminance(int colorValue) {
    return Color(colorValue).computeLuminance();
  }

  static bool isLight(int colorValue) {
    return luminance(colorValue) > 0.5;
  }
}
