import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/features/auth/providers/auth_provider.dart';
import 'package:neuroot/features/auth/providers/user_provider.dart';
import 'package:neuroot/features/academic/providers/attendance_provider.dart';
import 'package:neuroot/features/academic/providers/insights_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userDocProvider);
    final user = userState.asData?.value;

    Future<void> handleSignOut() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.white,
          title: Text(
            'Sign Out',
            style: AppTypography.titleMedium(color: const Color(0xFF2B2B2B)),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: AppTypography.bodyMedium(color: const Color(0xFF5A5A5A)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: AppTypography.bodyMedium(
                  color: AppColors.primaryContainer,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Sign Out',
                style: AppTypography.bodyMedium(
                  color: Colors.red,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      if (confirm == true) {
        ref.read(authNotifierProvider.notifier).signOut();
      }
    }

    final level = user?.level ?? 1;
    final xp = user?.xp ?? 0;

    // Calculate level progress (Level 1 requires 500 XP, level 2 requires 1000 XP, etc. according to our provider logic)
    // Actually the user provider awards level based on: (xp ~/ 500) + 1. So each level is 500 XP.
    final currentLevelXP = xp % 500;
    final xpProgress = currentLevelXP / 500.0;

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
            icon: const Icon(Icons.settings_rounded, color: AppColors.textSecondary),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primaryContainer),
            onPressed: handleSignOut,
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
                            'Happy & Growing ✨',
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
                          '"You completed 3 tasks and attended all classes today! 🌟 Small progress still counts — I\'m proud of you."',
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
                      _buildCosmetic('🎓', 'Scholar Hat', false),
                      _buildCosmetic('☀️', 'Sunny Room', false),
                      _buildCosmetic('🌙', 'Night Mode', true),
                      _buildCosmetic('👑', 'Gold Crown', true),
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
                    final weeklyFocusHours = ref.watch(weeklyFocusHoursProvider);
                    final totalWeeklyHours = weeklyFocusHours.fold<double>(0.0, (sum, val) => sum + val);
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
                    final overallAttendance = ref.watch(overallAttendanceProvider);
                    final attendancePercentage = overallAttendance ?? 0.0;
                    final isAttendanceGoalCompleted = attendancePercentage >= 75.0;
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

                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: handleSignOut,
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: Text(
                        'Sign Out',
                        style: AppTypography.bodyMedium(
                          color: Colors.redAccent,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFF5EFE3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: AppColors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCosmetic(String emoji, String title, bool isLocked) {
    return Container(
      decoration: BoxDecoration(
        color: isLocked
            ? AppColors.white.withValues(alpha: 0.5)
            : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? const Color(0xFFF5EFE3).withValues(alpha: 0.5)
              : const Color(0xFFF5EFE3),
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
              ],
            ),
          ),
        ],
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
