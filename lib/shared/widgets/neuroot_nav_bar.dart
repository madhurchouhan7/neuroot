import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';  
import 'package:neuroot/core/theme/app_theme.dart';
import 'package:neuroot/core/theme/app_typography.dart';

/// Neuroot Bottom Navigation Bar
/// Cozy, softly elevated, icon + label style.
class NeurootNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const NeurootNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.cottage_rounded, label: 'Home'),
    _NavItem(icon: Icons.edit_calendar_rounded, label: 'Planner'),
    _NavItem(icon: Icons.local_florist_rounded, label: 'Focus'),
    _NavItem(icon: Icons.backpack_rounded, label: 'Academic'),
    _NavItem(icon: Icons.face_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.nightCard : AppColors.warmWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (i) => _NavTile(
                item: _items[i],
                isSelected: currentIndex == i,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppTheme.durationMedium,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.sageSurface
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: isSelected
                  ? AppColors.sageDark
                  : (isDark ? AppColors.textMuted : AppColors.textMuted),
            ),
            AnimatedSize(
              duration: AppTheme.durationMedium,
              curve: Curves.easeOutCubic,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        item.label,
                        style: AppTypography.labelMedium(color: AppColors.sageDark),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

