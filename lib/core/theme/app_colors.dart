import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceOverlay,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accentPrimary,
    required this.accentPrimaryLight,
    required this.accentSecondary,
    required this.accentWarm,
    required this.accentSuccess,
    required this.accentDanger,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceOverlay;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accentPrimary;
  final Color accentPrimaryLight;
  final Color accentSecondary;
  final Color accentWarm;
  final Color accentSuccess;
  final Color accentDanger;

  static const noteColorValues = [
    0xFFEF4444, // Red
    0xFFF97316, // Orange
    0xFFF59E0B, // Amber
    0xFF10B981, // Emerald
    0xFF06B6D4, // Cyan
    0xFF3B82F6, // Blue
    0xFF6366F1, // Indigo
    0xFF8B5CF6, // Violet
    0xFFA855F7, // Purple
    0xFFEC4899, // Pink
    0xFF64748B, // Slate
    0xFF78716C, // Stone
  ];

  static Color noteColor(int index) => Color(noteColorValues[index]);

  static double luminance(int argb) => Color(argb).computeLuminance();

  static bool isLight(int argb) => luminance(argb) > 0.5;

  factory AppColors.light() => const AppColors(
        background: Color(0xFFF8F9FA),
        surface: Color(0xFFFFFFFF),
        surfaceElevated: Color(0xFFFFFFFF),
        surfaceOverlay: Color(0xFFF1F3F5),
        border: Color(0xFFDEE2E6),
        textPrimary: Color(0xFF212529),
        textSecondary: Color(0xFF495057),
        textTertiary: Color(0xFF868E96),
        accentPrimary: Color(0xFF7C3AED),
        accentPrimaryLight: Color(0xFFA78BFA),
        accentSecondary: Color(0xFF06B6D4),
        accentWarm: Color(0xFFF59E0B),
        accentSuccess: Color(0xFF10B981),
        accentDanger: Color(0xFFEF4444),
      );

  factory AppColors.dark() => const AppColors(
        background: Color(0xFF0D1117),
        surface: Color(0xFF161B22),
        surfaceElevated: Color(0xFF1C2128),
        surfaceOverlay: Color(0xFF21262D),
        border: Color(0xFF30363D),
        textPrimary: Color(0xFFE6EDF3),
        textSecondary: Color(0xFF8B949E),
        textTertiary: Color(0xFF6E7681),
        accentPrimary: Color(0xFF7C3AED),
        accentPrimaryLight: Color(0xFFA78BFA),
        accentSecondary: Color(0xFF06B6D4),
        accentWarm: Color(0xFFF59E0B),
        accentSuccess: Color(0xFF10B981),
        accentDanger: Color(0xFFEF4444),
      );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceOverlay,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accentPrimary,
    Color? accentPrimaryLight,
    Color? accentSecondary,
    Color? accentWarm,
    Color? accentSuccess,
    Color? accentDanger,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accentPrimary: accentPrimary ?? this.accentPrimary,
      accentPrimaryLight: accentPrimaryLight ?? this.accentPrimaryLight,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      accentWarm: accentWarm ?? this.accentWarm,
      accentSuccess: accentSuccess ?? this.accentSuccess,
      accentDanger: accentDanger ?? this.accentDanger,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceOverlay: Color.lerp(surfaceOverlay, other.surfaceOverlay, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accentPrimary: Color.lerp(accentPrimary, other.accentPrimary, t)!,
      accentPrimaryLight:
          Color.lerp(accentPrimaryLight, other.accentPrimaryLight, t)!,
      accentSecondary:
          Color.lerp(accentSecondary, other.accentSecondary, t)!,
      accentWarm: Color.lerp(accentWarm, other.accentWarm, t)!,
      accentSuccess: Color.lerp(accentSuccess, other.accentSuccess, t)!,
      accentDanger: Color.lerp(accentDanger, other.accentDanger, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppColors &&
          runtimeType == other.runtimeType &&
          background == other.background &&
          surface == other.surface &&
          surfaceElevated == other.surfaceElevated &&
          surfaceOverlay == other.surfaceOverlay &&
          border == other.border &&
          textPrimary == other.textPrimary &&
          textSecondary == other.textSecondary &&
          textTertiary == other.textTertiary &&
          accentPrimary == other.accentPrimary &&
          accentPrimaryLight == other.accentPrimaryLight &&
          accentSecondary == other.accentSecondary &&
          accentWarm == other.accentWarm &&
          accentSuccess == other.accentSuccess &&
          accentDanger == other.accentDanger;

  @override
  int get hashCode => Object.hash(
        background,
        surface,
        surfaceElevated,
        surfaceOverlay,
        border,
        textPrimary,
        textSecondary,
        textTertiary,
        accentPrimary,
        accentPrimaryLight,
        accentSecondary,
        accentWarm,
        accentSuccess,
        accentDanger,
      );
}
