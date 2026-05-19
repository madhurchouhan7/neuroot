import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/auth/providers/user_provider.dart';
import 'package:neuroot/features/dashboard/providers/dashboard_provider.dart';
import 'package:neuroot/shared/widgets/ambient_motion.dart';

class SproutCompanionCard extends ConsumerWidget {
  const SproutCompanionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(homeThemeStateProvider);
    final userState = ref.watch(userDocProvider);
    
    final user = userState.asData?.value;
    final level = user?.level ?? 1;
    final xp = user?.xp ?? 0;
    final streak = user?.streak ?? 0;
    
    final double xpProgress = (xp % 100) / 100.0;
    final xpRequired = 100;
    final xpCurrent = xp % 100;

    return BreathingWidget(
      scaleTarget: 1.015,
      duration: const Duration(seconds: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeState.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: themeState.accentColor.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeState.accentColor.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated Sprout Emoji avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: themeState.accentColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      themeState.sproutEmoji,
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Sprout status speech bubble
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: themeState.accentColor.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      themeState.sproutStatusText,
                      style: AppTypography.bodyMedium(
                        color: themeState.isDark ? AppColors.textSecondary : const Color(0xFF4A4A4A),
                      ).copyWith(fontSize: 13, height: 1.35),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Level & XP Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Lv $level',
                      style: AppTypography.labelLarge(
                        color: themeState.textColor,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB703).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Text('🔥 ', style: TextStyle(fontSize: 10)),
                          Text(
                            '$streak day streak',
                            style: AppTypography.labelSmall(
                              color: const Color(0xFFD08700),
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  '$xpCurrent/$xpRequired XP',
                  style: AppTypography.labelSmall(
                    color: themeState.isDark ? AppColors.textSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // XP Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    color: themeState.isDark ? Colors.grey[800] : const Color(0xFFECEAE5),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 8,
                    width: MediaQuery.of(context).size.width * 0.7 * xpProgress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeState.accentColor.withValues(alpha: 0.7),
                          themeState.accentColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
