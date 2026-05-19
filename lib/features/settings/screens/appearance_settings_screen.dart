import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/settings/providers/settings_provider.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final currentTheme = s.themeMode;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => context.pop(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF8B8070), size: 14),
                const SizedBox(width: 4),
                Text('Settings', style: AppTypography.bodyMedium(color: const Color(0xFF8B8070)).copyWith(fontWeight: FontWeight.w500, fontSize: 13)),
              ],
            ),
          ),
        ),
        title: Text('Appearance', style: AppTypography.titleSmall(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Theme Selection Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF0E8DC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('App theme', style: AppTypography.titleSmall(color: AppColors.textPrimary).copyWith(fontSize: 15)),
                    const SizedBox(height: 16),
                    
                    _ThemePreviewCard(
                      title: 'Light',
                      sub: 'Warm cream, yellow accents, natural feel',
                      isSelected: currentTheme == AppThemeMode.light,
                      onTap: () {
                        ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.light);
                        _showToast(context, 'Theme switched to Light ☀️');
                      },
                      previewColor: const Color(0xFFFFF9F1),
                      borderColor: const Color(0xFFF0EBE3),
                    ),
                    const SizedBox(height: 12),
                    
                    _ThemePreviewCard(
                      title: 'Dark',
                      sub: 'Deep charcoal, cozy amber glow, night mode',
                      isSelected: currentTheme == AppThemeMode.dark,
                      onTap: () {
                        ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.dark);
                        _showToast(context, 'Theme switched to Dark 🌙');
                      },
                      previewColor: AppColors.nightBg,
                      borderColor: AppColors.nightCard,
                    ),
                    const SizedBox(height: 12),
                    
                    _ThemePreviewCard(
                      title: 'Auto (follows system)',
                      sub: 'Switches based on your phone\'s dark mode setting',
                      isSelected: currentTheme == AppThemeMode.system,
                      onTap: () {
                        ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.system);
                        _showToast(context, 'Theme set to Auto 🌗');
                      },
                      previewColor: const Color(0xFFE0D8CE),
                      borderColor: const Color(0xFFD1C5AE),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Dynamic UI Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF0E8DC)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Time-based dynamic UI', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                              Text('Bloom adjusts colors by time of day', style: AppTypography.bodySmall(color: const Color(0xFF8B8070)).copyWith(fontSize: 12)),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: true,
                          onChanged: (v) {},
                          activeThumbColor: AppColors.amber,
                          activeTrackColor: AppColors.amber.withValues(alpha: 0.25),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _DynamicPill('6AM–11AM', const [Color(0xFFFFDFB3), Color(0xFFFFC085)], const Color(0xFFB35900)),
                        _DynamicPill('12PM–5PM', const [Color(0xFFFFF9F1), Color(0xFFF0E8DC)], const Color(0xFF8B8070)),
                        _DynamicPill('6PM–9PM', const [Color(0xFFF6C945), Color(0xFFD4A017)], const Color(0xFF5A4000)),
                        _DynamicPill('9PM+', const [Color(0xFF2B2B2B), Color(0xFF1C1C1C)], const Color(0xFFC8C0B8)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Premium Themes
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF0E8DC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Premium Themes', style: AppTypography.titleSmall(color: AppColors.textPrimary).copyWith(fontSize: 15)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3D8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Bloom Pro ✨', style: AppTypography.labelSmall(color: const Color(0xFFC4900A))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Unlock aesthetic themes with Bloom Pro', style: AppTypography.bodySmall(color: const Color(0xFF8B8070)).copyWith(fontSize: 12)),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(child: _PremiumThemeCard(
                          title: 'Dark Academia', 
                          bg: const Color(0xFF3B2F2F), 
                          textColor: Colors.white,
                          isSelected: currentTheme == AppThemeMode.darkAcademia,
                          onTap: () {
                            ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.darkAcademia);
                            _showToast(context, 'Theme switched to Dark Academia 🕰️');
                          },
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _PremiumThemeCard(
                          title: 'Sakura Spring', 
                          bg: const Color(0xFFFFE4E1), 
                          textColor: const Color(0xFFC71585),
                          isSelected: currentTheme == AppThemeMode.sakuraSpring,
                          onTap: () {
                            ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.sakuraSpring);
                            _showToast(context, 'Theme switched to Sakura Spring 🌸');
                          },
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _PremiumThemeCard(
                          title: 'Midnight Focus', 
                          bg: const Color(0xFF191970), 
                          textColor: const Color(0xFFE6E6FA),
                          isSelected: false,
                          onTap: () {},
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _PremiumThemeCard(
                          title: 'Cozy Café', 
                          bg: const Color(0xFF8B4513), 
                          textColor: const Color(0xFFFFDEAD),
                          isSelected: false,
                          onTap: () {},
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.amber,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {},
                        child: Text('More themes coming soon →', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showToast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTypography.bodyMedium(color: AppColors.white)),
        backgroundColor: AppColors.sageDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  final String title;
  final String sub;
  final bool isSelected;
  final VoidCallback onTap;
  final Color previewColor;
  final Color borderColor;

  const _ThemePreviewCard({
    required this.title,
    required this.sub,
    required this.isSelected,
    required this.onTap,
    required this.previewColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : const Color(0xFFFAF5F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : const Color(0xFFF0E8DC),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60, height: 80,
              decoration: BoxDecoration(
                color: previewColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Container(height: 10, margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.circular(2))),
                  Container(height: 6, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.circular(2))),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(sub, style: AppTypography.bodySmall(color: const Color(0xFF8B8070)).copyWith(fontSize: 12)),
                  if (isSelected) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF5EB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Currently active', style: AppTypography.labelSmall(color: const Color(0xFF2A8052)).copyWith(fontWeight: FontWeight.w600, fontSize: 10)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DynamicPill extends StatelessWidget {
  final String label;
  final List<Color> gradient;
  final Color textColor;
  const _DynamicPill(this.label, this.gradient, this.textColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66, height: 26,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(100),
      ),
      alignment: Alignment.center,
      child: Text(label, style: AppTypography.labelSmall(color: textColor).copyWith(fontWeight: FontWeight.w600, fontSize: 9)),
    );
  }
}

class _PremiumThemeCard extends StatelessWidget {
  final String title;
  final Color bg;
  final Color textColor;
  final bool isSelected;
  final VoidCallback onTap;
  const _PremiumThemeCard({
    required this.title, 
    required this.bg, 
    required this.textColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: AppColors.textPrimary, width: 2) : null,
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(title, style: AppTypography.bodyMedium(color: textColor).copyWith(fontWeight: FontWeight.w600, fontSize: 12)),
            ),
            if (isSelected)
              const Align(
                alignment: Alignment.topRight,
                child: Icon(Icons.check_circle, size: 16, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
