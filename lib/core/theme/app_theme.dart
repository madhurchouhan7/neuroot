import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  // ─── Border Radius Constants ─────────────────────────────────────────────────
  static const double radiusSm = 12.0;
  static const double radiusMd = 20.0;
  static const double radiusLg = 28.0;
  static const double radiusCard = 24.0;
  static const double radiusSheet = 32.0;
  static const double radiusPill = 100.0;

  // ─── Spacing Constants ───────────────────────────────────────────────────────
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  static const double screenPadding = 20.0;

  // ─── Animation Durations ─────────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  // ─── Light Theme ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.warmCream,
      textTheme: AppTypography.textTheme,

      colorScheme: const ColorScheme.light(
        primary: AppColors.sage,
        secondary: AppColors.energy,
        tertiary: AppColors.lavender,
        surface: AppColors.warmCream,
        surfaceContainerHighest: AppColors.warmWhite,
        error: AppColors.dangerSoftRed,
        onPrimary: AppColors.white,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.white,
        outline: AppColors.softGrey,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.warmCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        centerTitle: false,
        titleTextStyle: AppTypography.titleMedium(),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      cardTheme: CardThemeData(
        color: AppColors.warmWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sage,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          textStyle: AppTypography.buttonLarge(color: AppColors.white),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.sage,
          side: const BorderSide(color: AppColors.sage, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          textStyle: AppTypography.buttonMedium(color: AppColors.sage),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.sageDark,
          textStyle: AppTypography.buttonMedium(color: AppColors.sageDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.warmWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.softGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.softGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.sage, width: 2),
        ),
        hintStyle: AppTypography.bodyMedium(color: AppColors.textMuted),
        labelStyle: AppTypography.bodyMedium(color: AppColors.textSecondary),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.warmWhite,
        selectedItemColor: AppColors.sageDark,
        unselectedItemColor: AppColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.softGrey,
        thickness: 1,
        space: 0,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.sageSurface,
        selectedColor: AppColors.sage,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: AppTypography.labelMedium(),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
    );
  }

  // ─── Dark Theme ──────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.nightBg,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.textOnDark,
        displayColor: AppColors.textOnDark,
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.sage,
        secondary: AppColors.energy,
        tertiary: AppColors.lavender,
        surface: AppColors.nightBg,
        surfaceContainerHighest: AppColors.nightCard,
        error: AppColors.dangerSoftRed,
        onPrimary: AppColors.white,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textOnDark,
        onError: AppColors.white,
        outline: AppColors.nightBorder,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.nightBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        centerTitle: false,
        titleTextStyle: AppTypography.titleMedium(color: AppColors.textOnDark),
        iconTheme: const IconThemeData(color: AppColors.textOnDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.nightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
      ),
    );
  }
}

