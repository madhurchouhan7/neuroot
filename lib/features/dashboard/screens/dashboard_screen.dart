import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/features/dashboard/providers/dashboard_provider.dart';
import 'package:neuroot/shared/widgets/neuroot_widgets.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/sprout_companion_card.dart';
import '../widgets/exam_week_banner.dart';
import '../widgets/mood_check_in_strip.dart';
import '../widgets/next_class_card.dart';
import '../widgets/today_priorities_card.dart';
import '../widgets/attendance_alert_card.dart';
import '../widgets/start_focus_button.dart';
import 'package:neuroot/features/academic/providers/attendance_provider.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/shared/widgets/ambient_motion.dart';
import 'package:neuroot/core/router/app_shell.dart';
import 'package:neuroot/features/focus/providers/focus_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(homeThemeStateProvider);
    final subjectsAsync = ref.watch(subjectsStreamProvider);

    return Scaffold(
      backgroundColor: themeState.backgroundColor,
      body: Stack(
        children: [
          // Gradient Background (Top Third)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: themeState.gradientColors,
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const DashboardHeader(),
                      const SizedBox(height: 20),

                      // Exam Week Banner (renders dynamically when an exam is close)
                      const ExamWeekBanner(),

                      const MoodCheckInStrip(),
                      const SizedBox(height: 20),

                      // Burnout Calming Card (renders dynamically if in burnout state)
                      const BurnoutCalmingCard(),

                      // Living Mascot Companion status widget
                      const SproutCompanionCard(),
                      const SizedBox(height: 20),

                      subjectsAsync.when(
                        loading: () => const SizedBox(
                          height: 200,
                          child: ShimmerListLoading(count: 2),
                        ),
                        error: (_, __) => const SizedBox(),
                        data: (subjects) {
                          if (subjects.isEmpty) {
                            return const _HomeEmptyStateWidget();
                          }
                          return Column(
                            children: [
                              const NextClassCard(),
                              const SizedBox(height: 20),

                              const TodayPrioritiesCard(),
                              const SizedBox(height: 20),

                              const AttendanceAlertCard(),
                              const SizedBox(height: 20),

                              const StartFocusButton(),
                            ],
                          );
                        },
                      ),

                      const SizedBox(
                        height: 40,
                      ), // Extra padding for bottom nav
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeEmptyStateWidget extends StatelessWidget {
  const _HomeEmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          NeurootNetworkImage(
            url:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCGAc2fsEi31o6PdDuRC1oBoT9gJ1hvP1bw2p3t1AxUd_f6t9fb9q4ONR5jhWot8mHDR8mCmFZK2jpkwleXbgbq6W_yf_0C9qakFGZo6fnJhEK3eb5ZJZASllQ7hsgMHUhwAOKDnDxH0DfvIWdTONSgtucV1ZmZ1VWz6KBx8KGqE6rty14jS_SzE4CVXuv_bGlNeM6f_DQRkitsZp7NYujmbxrzNT6mCG7OIBcf5wHJB6HGi7RAoLZ4OX21fReh4abVUaRgGve9pqk',
            height: 120,
            fit: BoxFit.contain,
            errorIcon: Icons.nature_people_outlined,
            placeholderColor: Colors.transparent,
          ),
          const SizedBox(height: 20),
          Text(
            'Your semester is waiting 🌱',
            style: AppTypography.titleSmall(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your subjects and timetable to\nunlock your full dashboard.',
            style: AppTypography.bodyMedium(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              context.push(
                '/settings/edit_semester',
              ); // User can edit semester from settings
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Set Up Semester →',
                style: AppTypography.buttonMedium(color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BurnoutCalmingCard extends ConsumerWidget {
  const BurnoutCalmingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBurnout = ref.watch(isBurnoutModeProvider);
    if (!isBurnout) return const SizedBox.shrink();

    return BreathingWidget(
      scaleTarget: 1.012,
      duration: const Duration(seconds: 4),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F1EE), // Softest soothing sage
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFCBE0D9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B8E7D).withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4E7E1),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🧘', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Burnout Calming Mode Active',
                        style: AppTypography.titleSmall(
                          color: const Color(0xFF2C4438),
                        ).copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Sprout detected high workload & fatigue signals',
                        style: AppTypography.labelSmall(
                          color: const Color(0xFF537466),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your focus times are softened and ambient focus sounds have been optimized for calming deep breaths. Take it easy today — progress is built on consistency, not exhaustion.',
              style: AppTypography.bodySmall(
                color: const Color(0xFF3B564A),
              ).copyWith(height: 1.45, fontSize: 12),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                ref.read(focusProvider.notifier).startBreak(isLong: false);
                ref.read(shellNavIndexProvider.notifier).setIndex(2);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B8E7D), // Sage Accent
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B8E7D).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Take a Soothing 5-Min Break →',
                  style: AppTypography.buttonMedium(
                    color: Colors.white,
                  ).copyWith(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
