import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

/// Generic settings tile supporting tap navigation, toggles, or custom trailing widgets.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool destructive;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = destructive ? const Color(0xFFBA1A1A) : AppColors.textPrimary;
    final iconActualColor = destructive ? const Color(0xFFBA1A1A) : iconColor;
    final bgActual = destructive ? const Color(0xFFFFDAD6) : iconBg;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: bgActual,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconActualColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMedium(color: titleColor).copyWith(fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(subtitle!, style: AppTypography.bodySmall(color: AppColors.textMuted)),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!
            else if (showChevron)
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
