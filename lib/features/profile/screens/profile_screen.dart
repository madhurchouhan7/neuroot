import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/features/auth/providers/user_provider.dart';
import 'package:neuroot/features/academic/providers/attendance_provider.dart';
import 'package:neuroot/features/academic/providers/insights_provider.dart';
import 'package:neuroot/features/planning/providers/task_provider.dart';
import 'package:neuroot/core/models/attendance_record_model.dart';
import 'package:neuroot/features/settings/providers/settings_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userDocProvider);
    final user = userState.asData?.value;
    final settings = ref.watch(settingsProvider);

    void handleToggleCosmetic(String id) {
      final currentlyEquipped = user?.equippedCosmetic ?? '';
      final nextEquipped = currentlyEquipped == id ? '' : id;
      ref.read(userNotifierProvider.notifier).updateProfile({
        'equippedCosmetic': nextEquipped,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextEquipped.isNotEmpty
                ? 'Equipped cosmetic! Sprout looks cozy 🎓'
                : 'Unequipped cosmetic 🌱',
            style: AppTypography.bodyMedium(color: AppColors.white),
          ),
          backgroundColor: AppColors.sageDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }

    final level = user?.level ?? 1;
    final xp = user?.xp ?? 0;

    // Calculate level progress (Level 1 requires 500 XP, level 2 requires 1000 XP, etc. according to our provider logic)
    // Actually the user provider awards level based on: (xp ~/ 500) + 1. So each level is 500 XP.
    final currentLevelXP = xp % 500;
    final xpProgress = currentLevelXP / 500.0;

    final tasksList = ref.watch(tasksStreamProvider).asData?.value ?? [];
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final completedToday = tasksList.where((t) {
      if (!t.isCompleted || t.completedAt == null) return false;
      return t.completedAt!.isAfter(todayStart) &&
          t.completedAt!.isBefore(todayEnd);
    }).length;

    final monthRecords = ref.watch(monthAttendanceProvider).asData?.value ?? [];
    final todayAttendance = monthRecords.where((r) {
      return r.date.isAfter(todayStart) && r.date.isBefore(todayEnd);
    }).toList();

    final classesAttendedToday = todayAttendance
        .where((r) => r.status == AttendanceStatus.present)
        .length;
    final totalClassesToday = todayAttendance.length;

    // Generate dynamic message & companion state
    String bubbleMessage;
    String statusBadge;

    if (!settings.sproutAIEnabled) {
      bubbleMessage =
          '"Sprout\'s AI Coach is turned off. You need to turn it ON from Settings! 🤖🌱"';
      statusBadge = 'AI Coach Offline 📴';
    } else if (completedToday > 0 &&
        totalClassesToday > 0 &&
        classesAttendedToday == totalClassesToday) {
      bubbleMessage =
          '"You completed $completedToday task${completedToday == 1 ? "" : "s"} and attended all $totalClassesToday class${totalClassesToday == 1 ? "" : "es"} today! 🌟 Small progress still counts — I\'m proud of you."';
      statusBadge = 'Blooming & Active 🌟';
    } else if (completedToday > 0 && totalClassesToday == 0) {
      bubbleMessage =
          '"You completed $completedToday task${completedToday == 1 ? "" : "s"} today! 🌱 You\'re building amazing habits. Sprout is cheering you on!"';
      statusBadge = 'Blooming & Active 🌟';
    } else if (completedToday > 0 && classesAttendedToday < totalClassesToday) {
      bubbleMessage =
          '"You completed $completedToday task${completedToday == 1 ? "" : "s"} and made it to $classesAttendedToday/$totalClassesToday of your classes today. 🌸 Rest is part of the journey — let\'s grow step-by-step."';
      statusBadge = 'Blooming & Active 🌟';
    } else if (completedToday == 0 &&
        totalClassesToday > 0 &&
        classesAttendedToday == totalClassesToday) {
      bubbleMessage =
          '"You attended all $totalClassesToday class${totalClassesToday == 1 ? "" : "es"} today! 🎓 Showing up is half the battle. You did great today!"';
      statusBadge = 'Blooming & Active 🌟';
    } else if (completedToday == 0 &&
        totalClassesToday > 0 &&
        classesAttendedToday < totalClassesToday) {
      bubbleMessage =
          '"You made it to $classesAttendedToday/$totalClassesToday class${totalClassesToday == 1 ? "" : "es"} today. 🌼 Every day is a fresh page. Let\'s rest and try again tomorrow!"';
      statusBadge = 'Blooming & Active 🌟';
    } else {
      bubbleMessage =
          '"Hey there! Sprout is ready to grow with you today. 🌱 Try breaking down your tasks or checking in on your classes whenever you\'re ready!"';
      statusBadge = 'Dreaming & Growing 🌱';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F1), // bloom-cream
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading:
            const SizedBox.shrink(), // AppShell handles back if needed, but this is a root tab
        title: Text(
          'Sprout 🌱',
          style: AppTypography.titleMedium(
            color: const Color(0xFF2B2B2B),
          ).copyWith(fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_rounded,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // XP Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Level $level',
                        style: AppTypography.titleMedium(
                          color: const Color(0xFF2B2B2B),
                        ).copyWith(fontSize: 14),
                      ),
                      Text(
                        '$currentLevelXP / 500 XP',
                        style: AppTypography.bodySmall(
                          color: const Color(0xFF5A5A5A),
                        ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE0C8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: xpProgress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFF3C4),
                              AppColors.primaryContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Mascot Hero
                  Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      NeurootNetworkImage(
                        url:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuC0mprWCJNQy5UKdH9apf4yYSUDZlT_FwMfPtcISBk4yz3BRDYfqx18lIpWfrEslLXaLk-nfgzIIJl2tRRs1kSWh2_JaGxJCiM3DaRN7Kut9Izu-ATrgGH5lhSm8AuNppkGNTdcbnxBy5U9eyKlR4u1DSe6Rrng4iGusQXyC5RgH6gVagjrmlumwdRccez7tbXddMztMlpuQc79Lv2uwPidIqIFbmM74MFRK_f7EXIji2QJejM-wOxXkmJJ1ufpT9aN1MzoQ1ho_DM',
                        height: 200,
                        fit: BoxFit.contain,
                        errorIcon: Icons.eco,
                        placeholderColor: Colors.transparent,
                      ),
                      Positioned(
                        bottom: -16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF5EFE3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            statusBadge,
                            style: AppTypography.labelSmall(
                              color: const Color(0xFF1B1C1C),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Speech bubble
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: -10,
                        child: CustomPaint(
                          size: const Size(20, 10),
                          painter: _TrianglePainter(color: AppColors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFF5EFE3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          bubbleMessage,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium(
                            color: const Color(0xFF1B1C1C),
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Cosmetic Unlocks
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Cosmetic Unlocks',
                      style: AppTypography.titleMedium(
                        color: const Color(0xFF2B2B2B),
                      ).copyWith(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildCosmetic(
                        'scholar_hat',
                        '🎓',
                        'Scholar Hat',
                        (user?.level ?? 1) < 1,
                        (user?.equippedCosmetic ?? '') == 'scholar_hat',
                        () => handleToggleCosmetic('scholar_hat'),
                      ),
                      _buildCosmetic(
                        'sunny_room',
                        '☀️',
                        'Sunny Room',
                        (user?.level ?? 1) < 2,
                        (user?.equippedCosmetic ?? '') == 'sunny_room',
                        () => handleToggleCosmetic('sunny_room'),
                      ),
                      _buildCosmetic(
                        'night_mode',
                        '🌙',
                        'Night Mode',
                        (user?.level ?? 1) < 3,
                        (user?.equippedCosmetic ?? '') == 'night_mode',
                        () => handleToggleCosmetic('night_mode'),
                      ),
                      _buildCosmetic(
                        'gold_crown',
                        '👑',
                        'Gold Crown',
                        (user?.streak ?? 0) < 3,
                        (user?.equippedCosmetic ?? '') == 'gold_crown',
                        () => handleToggleCosmetic('gold_crown'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Milestones
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Milestones',
                      style: AppTypography.titleMedium(
                        color: const Color(0xFF2B2B2B),
                      ).copyWith(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildMilestone(
                    icon: '📅',
                    title: '7-Day Streak',
                    subtitle: (user?.streak ?? 0) >= 7
                        ? 'Completed!'
                        : '${user?.streak ?? 0} / 7 days',
                    isCompleted: (user?.streak ?? 0) >= 7,
                    progress: ((user?.streak ?? 0) / 7.0).clamp(0.0, 1.0),
                  ),
                  const SizedBox(height: 12),

                  // 10h Study Week Calculation
                  () {
                    final weeklyFocusHours = ref.watch(
                      weeklyFocusHoursProvider,
                    );
                    final totalWeeklyHours = weeklyFocusHours.fold<double>(
                      0.0,
                      (sum, val) => sum + val,
                    );
                    final isStudyGoalCompleted = totalWeeklyHours >= 10.0;
                    return _buildMilestone(
                      icon: '📚',
                      title: '10h Study Week',
                      subtitle: isStudyGoalCompleted
                          ? 'Completed!'
                          : '${totalWeeklyHours.toStringAsFixed(1)} / 10 hrs',
                      isCompleted: isStudyGoalCompleted,
                      progress: (totalWeeklyHours / 10.0).clamp(0.0, 1.0),
                    );
                  }(),
                  const SizedBox(height: 12),

                  // 75% Attendance Goal Calculation
                  () {
                    final overallAttendance = ref.watch(
                      overallAttendanceProvider,
                    );
                    final attendancePercentage = overallAttendance ?? 0.0;
                    final isAttendanceGoalCompleted =
                        attendancePercentage >= 75.0;
                    return _buildMilestone(
                      icon: '🌸',
                      title: '75% Attendance Goal',
                      subtitle: isAttendanceGoalCompleted
                          ? 'Completed! (${attendancePercentage.toStringAsFixed(1)}%)'
                          : (overallAttendance == null
                                ? 'No classes marked'
                                : '${attendancePercentage.toStringAsFixed(1)}% / 75%'),
                      isCompleted: isAttendanceGoalCompleted,
                      progress: (attendancePercentage / 75.0).clamp(0.0, 1.0),
                      isDisabled: overallAttendance == null,
                    );
                  }(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCosmetic(
    String id,
    String emoji,
    String title,
    bool isLocked,
    bool isEquipped,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isLocked
              ? AppColors.white.withValues(alpha: 0.5)
              : (isEquipped ? const Color(0xFFF0EBE3) : AppColors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked
                ? const Color(0xFFF5EFE3).withValues(alpha: 0.5)
                : (isEquipped
                      ? AppColors.primaryContainer
                      : const Color(0xFFF5EFE3)),
            width: isEquipped ? 2 : 1,
          ),
          boxShadow: isLocked
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            if (isLocked)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.lock, size: 16, color: Color(0xFF5A5A5A)),
              )
            else if (isEquipped)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  size: 18,
                  color: AppColors.sageDark,
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 28,
                      color: isLocked ? Colors.grey : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: AppTypography.bodySmall(
                      color: isLocked
                          ? const Color(0xFF5A5A5A)
                          : const Color(0xFF1B1C1C),
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (isEquipped) ...[
                    const SizedBox(height: 2),
                    Text(
                      'EQUIPPED',
                      style: AppTypography.labelSmall(
                        color: AppColors.sageDark,
                      ).copyWith(fontSize: 8, fontWeight: FontWeight.bold),
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

  Widget _buildMilestone({
    required String icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required double progress,
    bool isDisabled = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFFEBF5EB)
            : (isDisabled
                  ? AppColors.white.withValues(alpha: 0.5)
                  : AppColors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5EFE3)),
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.white : const Color(0xFFFFF9F1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: TextStyle(
                fontSize: 20,
                color: isDisabled ? Colors.grey : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMedium(
                        color: const Color(0xFF2C4E30),
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (!isCompleted)
                      Text(
                        subtitle,
                        style: AppTypography.labelSmall(
                          color: const Color(0xFF5A5A5A),
                        ).copyWith(fontSize: 10),
                      ),
                  ],
                ),
                if (isCompleted)
                  Text(
                    subtitle,
                    style: AppTypography.labelSmall(color: AppColors.sageDark),
                  ),
                if (!isCompleted && !isDisabled) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EFE3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
                if (isDisabled)
                  Text(
                    subtitle,
                    style: AppTypography.labelSmall(
                      color: const Color(0xFF5A5A5A),
                    ),
                  ),
              ],
            ),
          ),
          if (isCompleted) ...[
            const SizedBox(width: 12),
            const Icon(Icons.check_circle, color: AppColors.sageDark),
          ],
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
