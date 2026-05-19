import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_theme.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/shared/widgets/bounce_button.dart';
import 'package:neuroot/shared/widgets/ambient_motion.dart';
import 'package:shimmer/shimmer.dart';

// ─── NeurootCard ──────────────────────────────────────────────────────────────
/// The primary surface container. Soft shadow, rounded corners, no borders.
class NeurootCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double radius;

  const NeurootCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.onTap,
    this.radius = AppTheme.radiusCard,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        color ?? (isDark ? AppColors.nightCard : AppColors.warmWhite);

    return BounceButton(
      onTap: onTap,
      scaleFactor: 0.98,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppTheme.spacingMD),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: isDark ? null : AppColors.softShadow,
        ),
        child: child,
      ),
    );
  }
}

// ─── NeurootButton ────────────────────────────────────────────────────────────
/// Primary action button — sage green pill style.
class NeurootButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSmall;
  final bool isLoading;

  const NeurootButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isSmall = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.sage;
    final fg = textColor ?? AppColors.white;
    return BounceButton(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        height: isSmall ? 44.0 : 56.0,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          boxShadow: [
            BoxShadow(
              color: bg.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              ),
            ] else ...[
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(
                label,
                style:
                    (isSmall
                            ? AppTypography.buttonMedium
                            : AppTypography.buttonLarge)
                        .call(color: fg),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── NeurootSecondaryButton ────────────────────────────────────────────────────
class NeurootSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget? icon;

  const NeurootSecondaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return BounceButton(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.sageSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(color: AppColors.sage.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Text(
              label,
              style: AppTypography.buttonMedium(color: AppColors.sageDark),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SproutSpeechBubble ────────────────────────────────────────────────────────
/// Sprout's dialog bubble — warm, friendly, Nunito Bold text.
class SproutSpeechBubble extends StatelessWidget {
  final String message;
  final Color? backgroundColor;

  const SproutSpeechBubble({
    super.key,
    required this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.sageSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(color: AppColors.sage.withValues(alpha: 0.3)),
      ),
      child: Text(message, style: AppTypography.mascotSpeech()),
    );
  }
}

// ─── SectionHeader ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: AppTypography.titleSmall()),
        const Spacer(),
        if (actionLabel != null)
          BounceButton(
            onTap: onAction,
            scaleFactor: 0.95,
            child: Text(
              actionLabel!,
              style: AppTypography.labelMedium(color: AppColors.sageDark),
            ),
          ),
      ],
    );
  }
}

// ─── StatusChip ────────────────────────────────────────────────────────────────
/// A small pill chip for status indicators (attendance %, mood, etc.)
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final Widget? leading;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 4)],
          Text(
            label,
            style: AppTypography.labelSmall(
              color: textColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ProgressRing ─────────────────────────────────────────────────────────────
/// Circular progress indicator — used for attendance %, focus %, etc.
class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;
  final Widget? center;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 8,
    required this.color,
    this.backgroundColor = AppColors.softGrey,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          ?center,
        ],
      ),
    );
  }
}

// ─── NeurootTextField ─────────────────────────────────────────────────────────
class NeurootTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;

  const NeurootTextField({
    super.key,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      style: AppTypography.bodyMedium(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// ─── EmptyState ───────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BreathingWidget(
              scaleTarget: 1.05,
              child: Text(emoji, style: const TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            Text(
              title,
              style: AppTypography.titleMedium(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Text(
              message,
              style: AppTypography.bodyMedium(),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTheme.spacingLG),
              SizedBox(
                width: 200,
                child: NeurootButton(label: actionLabel!, onTap: onAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Shimmer Elements ─────────────────────────────────────────────────────────

/// A simple custom shimmer box mapped to Neuroot's warm aesthetic.
class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEEDDCC).withValues(alpha: 0.5),
      highlightColor: const Color(0xFFFAF6F0),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer effect designed for lists.
class ShimmerListLoading extends StatelessWidget {
  final int count;
  const ShimmerListLoading({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Shimmer.fromColors(
            baseColor: const Color(0xFFEEDDCC).withValues(alpha: 0.5),
            highlightColor: const Color(0xFFFAF6F0),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 90,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer effect designed for full cards.
class ShimmerCardLoading extends StatelessWidget {
  final double height;
  final double borderRadius;
  const ShimmerCardLoading({
    super.key,
    this.height = 140.0,
    this.borderRadius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEEDDCC).withValues(alpha: 0.5),
      highlightColor: const Color(0xFFFAF6F0),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
