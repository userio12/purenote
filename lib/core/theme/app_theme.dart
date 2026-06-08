import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purenote/core/theme/app_colors.dart';
import 'package:purenote/core/theme/app_spacing.dart';
import 'package:purenote/core/theme/app_shapes.dart';
import 'package:purenote/core/theme/app_shadows.dart';

class AppTheme {
  AppTheme._();

  static const _seedColor = Color(0xFF7C3AED);

  static const List<int> noteColors = AppColors.noteColorValues;

  static ThemeData light() {
    final appColors = AppColors.light();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ).copyWith(
      surface: appColors.surface,
      onSurface: appColors.textPrimary,
    );

    final interTextTheme = GoogleFonts.interTextTheme();
    final loraTextTheme = GoogleFonts.loraTextTheme();

    final textTheme = interTextTheme.copyWith(
      displayLarge: interTextTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      displayMedium: interTextTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      displaySmall: interTextTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: interTextTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: interTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: interTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: interTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleMedium: interTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleSmall: interTextTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: loraTextTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: loraTextTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
      ),
      bodySmall: loraTextTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w400,
      ),
      labelLarge: interTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      labelMedium: interTextTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      labelSmall: interTextTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: [appColors],
      appBarTheme: AppBarTheme(
        backgroundColor: appColors.surface.withValues(alpha: 0.85),
        foregroundColor: appColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: appColors.surfaceElevated,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.md,
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: appColors.surface.withValues(alpha: 0.80),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: appColors.accentPrimary,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? appColors.accentPrimary : appColors.textTertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: isSelected ? appColors.accentPrimary : appColors.textTertiary,
          );
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.xlTop,
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: appColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.lg,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: appColors.surface,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: appColors.textPrimary,
        ),
        actionTextColor: appColors.accentPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.md,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: appColors.accentPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.lg,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appColors.surfaceOverlay,
        border: OutlineInputBorder(
          borderRadius: AppShapes.sm,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppShapes.sm,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppShapes.sm,
          borderSide: BorderSide(
            color: appColors.accentPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppShapes.sm,
          borderSide: BorderSide(
            color: appColors.accentDanger,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppShapes.sm,
          borderSide: BorderSide(
            color: appColors.accentDanger,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: appColors.surfaceOverlay,
        selectedColor: appColors.accentPrimary,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.sm,
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: appColors.surfaceElevated,
          borderRadius: AppShapes.sm,
          boxShadow: AppShadows.sm,
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: appColors.textPrimary,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: appColors.accentPrimary,
        inactiveTrackColor: appColors.surfaceOverlay,
        thumbColor: appColors.accentPrimary,
        overlayColor: appColors.accentPrimary.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return appColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return appColors.accentPrimary;
          }
          return appColors.surfaceOverlay;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: appColors.border,
        thickness: 1,
        space: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: appColors.surface,
        elevation: 2,
        shadowColor: appColors.border,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.sm,
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: appColors.textPrimary,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: appColors.textSecondary,
        ),
        iconColor: appColors.textSecondary,
      ),
    );
  }

  static ThemeData dark() {
    final appColors = AppColors.dark();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ).copyWith(
      surface: appColors.surface,
      onSurface: appColors.textPrimary,
    );

    final interTextTheme = GoogleFonts.interTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );
    final loraTextTheme = GoogleFonts.loraTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );

    final textTheme = interTextTheme.copyWith(
      displayLarge: interTextTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: appColors.textPrimary,
      ),
      displayMedium: interTextTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: appColors.textPrimary,
      ),
      displaySmall: interTextTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: appColors.textPrimary,
      ),
      headlineLarge: interTextTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: appColors.textPrimary,
      ),
      headlineMedium: interTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: appColors.textPrimary,
      ),
      headlineSmall: interTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: appColors.textPrimary,
      ),
      titleLarge: interTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: appColors.textPrimary,
      ),
      titleMedium: interTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: appColors.textPrimary,
      ),
      titleSmall: interTextTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: appColors.textPrimary,
      ),
      bodyLarge: loraTextTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
        color: appColors.textPrimary,
      ),
      bodyMedium: loraTextTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
        color: appColors.textPrimary,
      ),
      bodySmall: loraTextTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w400,
        color: appColors.textSecondary,
      ),
      labelLarge: interTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: appColors.textSecondary,
      ),
      labelMedium: interTextTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: appColors.textSecondary,
      ),
      labelSmall: interTextTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        color: appColors.textTertiary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: [appColors],
      appBarTheme: AppBarTheme(
        backgroundColor: appColors.surface.withValues(alpha: 0.85),
        foregroundColor: appColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: appColors.surfaceElevated,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.md,
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: appColors.surface.withValues(alpha: 0.80),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: appColors.accentPrimary,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? appColors.accentPrimary : appColors.textTertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: isSelected ? appColors.accentPrimary : appColors.textTertiary,
          );
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.xlTop,
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: appColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.lg,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: appColors.surface,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: appColors.textPrimary,
        ),
        actionTextColor: appColors.accentPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.md,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: appColors.accentPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.lg,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appColors.surfaceOverlay,
        border: OutlineInputBorder(
          borderRadius: AppShapes.sm,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppShapes.sm,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppShapes.sm,
          borderSide: BorderSide(
            color: appColors.accentPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppShapes.sm,
          borderSide: BorderSide(
            color: appColors.accentDanger,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppShapes.sm,
          borderSide: BorderSide(
            color: appColors.accentDanger,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: appColors.surfaceOverlay,
        selectedColor: appColors.accentPrimary,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.sm,
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: appColors.surfaceElevated,
          borderRadius: AppShapes.sm,
          boxShadow: AppShadows.sm,
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: appColors.textPrimary,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: appColors.accentPrimary,
        inactiveTrackColor: appColors.surfaceOverlay,
        thumbColor: appColors.accentPrimary,
        overlayColor: appColors.accentPrimary.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return appColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return appColors.accentPrimary;
          }
          return appColors.surfaceOverlay;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: appColors.border,
        thickness: 1,
        space: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: appColors.surface,
        elevation: 2,
        shadowColor: appColors.border,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.sm,
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: appColors.textPrimary,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: appColors.textSecondary,
        ),
        iconColor: appColors.textSecondary,
      ),
    );
  }
}
