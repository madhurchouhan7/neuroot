import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/settings/providers/settings_provider.dart';

/// Appearance section — Light / Dark / Auto theme selector.
class AppearanceCard extends ConsumerWidget {
  const AppearanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(settingsProvider).themeMode;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EBE3)),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          _ThemeOption(
            label: 'Light',
            icon: Icons.wb_sunny_rounded,
            preview: const _LightPreview(),
            isSelected: current == AppThemeMode.light,
            onTap: () => ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.light),
          ),
          const SizedBox(width: 12),
          _ThemeOption(
            label: 'Dark',
            icon: Icons.nightlight_round,
            preview: const _DarkPreview(),
            isSelected: current == AppThemeMode.dark,
            onTap: () => ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.dark),
          ),
          const SizedBox(width: 12),
          _ThemeOption(
            label: 'Auto',
            icon: Icons.brightness_auto_rounded,
            preview: const _AutoPreview(),
            isSelected: current == AppThemeMode.system,
            onTap: () => ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.system),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget preview;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.preview,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.amber : const Color(0xFFF0EBE3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(height: 56, child: preview),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.labelMedium(
                    color: isSelected ? AppColors.amber : AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LightPreview extends StatelessWidget {
  const _LightPreview();
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFFFF9F1),
    child: Column(children: [
      Container(height: 12, color: AppColors.white, margin: const EdgeInsets.all(4)),
      Container(height: 6, color: AppColors.warmCream, margin: const EdgeInsets.symmetric(horizontal: 4)),
      Container(height: 6, color: AppColors.warmCream, margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2)),
    ]),
  );
}

class _DarkPreview extends StatelessWidget {
  const _DarkPreview();
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.nightBg,
    child: Column(children: [
      Container(height: 12, color: AppColors.nightCard, margin: const EdgeInsets.all(4)),
      Container(height: 6, color: AppColors.nightCardHover, margin: const EdgeInsets.symmetric(horizontal: 4)),
      Container(height: 6, color: AppColors.nightCardHover, margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2)),
    ]),
  );
}

class _AutoPreview extends StatelessWidget {
  const _AutoPreview();
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFFFFF9F1), AppColors.nightBg]),
    ),
    child: Column(children: [
      Container(height: 12, color: Colors.white30, margin: const EdgeInsets.all(4)),
      Container(height: 6, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 4)),
    ]),
  );
}
