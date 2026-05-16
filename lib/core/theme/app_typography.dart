import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Neuroot Typography System
/// Sora → Headlines (soft, expressive)
/// Nunito → Body & mascot speech (friendly, warm)
/// Inter → Numbers, analytics (precise, readable)
class AppTypography {
  AppTypography._();

  // ─── Display ─────────────────────────────────────────────────────────────────
  static TextStyle displayHero({Color color = AppColors.textPrimary}) =>
      GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle displayLarge({Color color = AppColors.textPrimary}) =>
      GoogleFonts.sora(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.3,
        color: color,
      );

  // ─── Titles ──────────────────────────────────────────────────────────────────
  static TextStyle titleXL({Color color = AppColors.textPrimary}) =>
      GoogleFonts.sora(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle titleLarge({Color color = AppColors.textPrimary}) =>
      GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: color,
      );

  static TextStyle titleMedium({Color color = AppColors.textPrimary}) =>
      GoogleFonts.sora(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  static TextStyle titleSmall({Color color = AppColors.textPrimary}) =>
      GoogleFonts.sora(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  // ─── Body ─────────────────────────────────────────────────────────────────────
  static TextStyle bodyLarge({Color color = AppColors.textSecondary}) =>
      GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: color,
      );

  static TextStyle bodyMedium({Color color = AppColors.textSecondary}) =>
      GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodySmall({Color color = AppColors.textMuted}) =>
      GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color,
      );

  // ─── Support / Emotional ───────────────────────────────────────────────────────
  static TextStyle supportiveLarge({Color color = AppColors.textSecondary}) =>
      GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.6,
        color: color,
      );

  static TextStyle supportiveMedium({Color color = AppColors.textSecondary}) =>
      GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: color,
      );

  static TextStyle mascotSpeech({Color color = AppColors.textPrimary}) =>
      GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: color,
      );

  // ─── Labels / Chips ───────────────────────────────────────────────────────────
  static TextStyle labelLarge({Color color = AppColors.textPrimary}) =>
      GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.0,
        color: color,
      );

  static TextStyle labelMedium({Color color = AppColors.textSecondary}) =>
      GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.0,
        color: color,
      );

  static TextStyle labelSmall({Color color = AppColors.textMuted}) =>
      GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.0,
        letterSpacing: 0.8,
        color: color,
      );

  // ─── Numbers / Analytics (Inter) ─────────────────────────────────────────────
  static TextStyle statHero({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: color,
      );

  static TextStyle statLarge({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: color,
      );

  static TextStyle statMedium({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.0,
        color: color,
      );

  static TextStyle statSmall({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.0,
        color: color,
      );

  // ─── Button Text ─────────────────────────────────────────────────────────────
  static TextStyle buttonLarge({Color color = AppColors.textPrimary}) =>
      GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: color,
      );

  static TextStyle buttonMedium({Color color = AppColors.textPrimary}) =>
      GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: color,
      );

  // ─── ThemeData TextTheme (for MaterialApp) ────────────────────────────────────
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayHero(),
    displayMedium: displayLarge(),
    displaySmall: titleXL(),
    headlineLarge: titleLarge(),
    headlineMedium: titleMedium(),
    headlineSmall: titleSmall(),
    bodyLarge: bodyLarge(),
    bodyMedium: bodyMedium(),
    bodySmall: bodySmall(),
    labelLarge: labelLarge(),
    labelMedium: labelMedium(),
    labelSmall: labelSmall(),
  );
}

