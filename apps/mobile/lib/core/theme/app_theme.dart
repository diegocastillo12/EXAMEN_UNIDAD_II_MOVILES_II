import 'app_typography.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const fontFamily = 'sans-serif';
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.ink,
      onPrimary: AppColors.background,
      primaryContainer: AppColors.divider,
      onPrimaryContainer: AppColors.ink,
      primaryFixed: AppColors.surface,
      primaryFixedDim: AppColors.divider,
      onPrimaryFixed: AppColors.ink,
      onPrimaryFixedVariant: AppColors.secondary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.background,
      secondaryContainer: AppColors.surface,
      onSecondaryContainer: AppColors.ink,
      secondaryFixed: AppColors.surface,
      secondaryFixedDim: AppColors.divider,
      onSecondaryFixed: AppColors.ink,
      onSecondaryFixedVariant: AppColors.secondary,
      tertiary: AppColors.secondary,
      onTertiary: AppColors.background,
      tertiaryContainer: AppColors.surface,
      onTertiaryContainer: AppColors.ink,
      tertiaryFixed: AppColors.surface,
      tertiaryFixedDim: AppColors.divider,
      onTertiaryFixed: AppColors.ink,
      onTertiaryFixedVariant: AppColors.secondary,
      error: AppColors.error,
      onError: AppColors.background,
      errorContainer: Color(0xFFF9ECEE),
      onErrorContainer: AppColors.error,
      surface: AppColors.background,
      onSurface: AppColors.ink,
      surfaceDim: AppColors.divider,
      surfaceBright: AppColors.background,
      surfaceContainerLowest: AppColors.background,
      surfaceContainerLow: AppColors.surface,
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.surface,
      surfaceContainerHighest: AppColors.divider,
      onSurfaceVariant: AppColors.secondary,
      outline: AppColors.secondary,
      outlineVariant: AppColors.divider,
      shadow: AppColors.ink,
      scrim: AppColors.ink,
      inverseSurface: AppColors.ink,
      onInverseSurface: AppColors.background,
      inversePrimary: AppColors.divider,
      surfaceTint: Colors.transparent,
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTheme.fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        displaySmall: AppTypography.primaryTitle,
        headlineMedium: AppTypography.primaryTitle,
        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: AppColors.ink,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: AppColors.secondary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppColors.secondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.45,
          color: AppColors.secondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 76,
        titleTextStyle: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 19,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: AppColors.ink,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF111111),
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 60),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

abstract final class AppColors {
  static const background = Colors.white;
  static const ink = Color(0xFF111111);
  static const secondary = Color(0xFF6E6E73);
  static const divider = Color(0xFFE5E5EA);
  static const surface = Color(0xFFF5F5F7);
  static const error = Color(0xFFB53F48);
}
