import 'package:flutter/material.dart';

/// Neuroot Design System — Color Palette
/// Based on "Cozy Productivity" philosophy.
/// Soft, warm, emotionally safe. No corporate blues, no harsh neons.
class AppColors {
  AppColors._();

  // ─── Brand Background ───────────────────────────────────────────────────────
  static const Color warmCream = Color(0xFFF8F5F0);      // Main scaffold bg
  static const Color warmWhite = Color(0xFFFFFDF8);      // Card surfaces
  static const Color softGrey = Color(0xFFECEAE5);       // Dividers, borders
  static const Color creamDark = Color(0xFFF0EBE3);      // Secondary surfaces

  // ─── Primary — Sage Green ───────────────────────────────────────────────────
  static const Color sage = Color(0xFFA8D5BA);           // Primary brand color
  static const Color sageDark = Color(0xFF6BAF8B);       // Active / selected
  static const Color sageSurface = Color(0xFFEAF4EE);    // Tinted bg surface
  static const Color sageDeep = Color(0xFF3D8A65);       // Icon fills

  // ─── Accent — Warm Gold / Energy ────────────────────────────────────────────
  static const Color energy = Color(0xFFFFB703);          // CTAs, highlights
  static const Color energyLight = Color(0xFFFFF0C4);     // Tinted CTA bg
  static const Color primaryContainer = Color(0xFFF6C945);
  static const Color amber = Color(0xFFF5A623);

  // ─── Accent — Lavender / Gen Z ──────────────────────────────────────────────
  static const Color lavender = Color(0xFFCDB4DB);        // Emotional accent
  static const Color lavenderSurface = Color(0xFFF3EEFA); // Tinted bg
  static const Color tertiary = Color(0xFF645495);

  // ─── Accent — Peach / Warmth ────────────────────────────────────────────────
  static const Color peach = Color(0xFFFFD6A5);           // Warm warmth
  static const Color peachSurface = Color(0xFFFFF3E6);    // Tinted bg

  // ─── Accent — Sky Blue / Focus ──────────────────────────────────────────────
  static const Color focusBlue = Color(0xFF7CB9E8);       // Focus sessions
  static const Color focusBlueSurface = Color(0xFFE8F4FD); // Focus bg tint

  // ─── Semantic ───────────────────────────────────────────────────────────────
  static const Color successMint = Color(0xFF95D5B2);     // Safe attendance
  static const Color dangerSoftRed = Color(0xFFE5989B);   // Soft danger (not harsh)
  static const Color dangerSurface = Color(0xFFFCECED);   // Danger bg tint
  static const Color warningAmber = Color(0xFFF4A261);    // Medium alert

  // ─── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2B2B2B);     // Main text
  static const Color textSecondary = Color(0xFF6B6B6B);   // Secondary text
  static const Color textMuted = Color(0xFF9B9B9B);       // Placeholder / hint
  static const Color textOnDark = Color(0xFFF8F5F0);      // Text on dark bg

  // ─── Dark Mode ──────────────────────────────────────────────────────────────
  static const Color nightBg = Color(0xFF161616);
  static const Color nightCard = Color(0xFF222222);
  static const Color nightCardHover = Color(0xFF2A2A2A);
  static const Color nightBorder = Color(0xFF333333);

  // ─── Utility ────────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;

  // ─── Soft Shadows ───────────────────────────────────────────────────────────
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF2B2B2B).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF2B2B2B).withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: const Color(0xFF2B2B2B).withValues(alpha: 0.12),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];
}

/// Semantic color extensions per mood / context
class MoodColors {
  MoodColors._();
  static const Color happy = Color(0xFFFFD6A5);
  static const Color happySurface = Color(0xFFFFF3E6);
  static const Color focused = Color(0xFF7CB9E8);
  static const Color focusedSurface = Color(0xFFE8F4FD);
  static const Color overwhelmed = Color(0xFFE5989B);
  static const Color overwhelmedSurface = Color(0xFFFCECED);
  static const Color burnedOut = Color(0xFFCDB4DB);
  static const Color burnedOutSurface = Color(0xFFF3EEFA);
  static const Color calm = Color(0xFFA8D5BA);
  static const Color calmSurface = Color(0xFFEAF4EE);
  static const Color anxious = Color(0xFFF4A261);
  static const Color anxiousSurface = Color(0xFFFEF0E7);
}

