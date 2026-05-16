import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:intl/intl.dart';
import '../providers/insights_provider.dart';
import '../../planning/providers/task_provider.dart';

class WeeklyWrapCard extends ConsumerWidget {
  const WeeklyWrapCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Focus
    final hoursData = ref.watch(weeklyFocusHoursProvider);
    final totalFocusHours = hoursData.isEmpty ? 0.0 : hoursData.reduce((a, b) => a + b);

    // 2. Attendance
    final attendanceData = ref.watch(weeklyAttendanceProvider);
    final totalPercent = attendanceData.isEmpty 
        ? 0.0 
        : attendanceData.map((e) => e['percentage'] as double).reduce((a, b) => a + b) / attendanceData.length;

    // 3. Tasks
    final tasks = ref.watch(tasksStreamProvider).asData?.value ?? [];
    // Just count how many are completed in the last week (mocked via total complete for simplicity right now)
    final completedTasks = tasks.where((t) => t.isCompleted).length;

    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 6));
    final dateRangeStr = '${DateFormat('MMM d').format(weekStart)}–${DateFormat('d, yyyy').format(now)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B), // bloom-night-card
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background amber flair
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: AppColors.warningAmber.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.warningAmber.withValues(alpha: 0.1), blurRadius: 40, spreadRadius: 20),
                ],
              ),
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Sprout's Weekly Wrap",
                    style: AppTypography.titleMedium(color: AppColors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text('🌿', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Week of $dateRangeStr',
                style: AppTypography.bodySmall(color: const Color(0xFF8B8070)).copyWith(fontSize: 12),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat('Focus', '${totalFocusHours.toStringAsFixed(1)}h', AppColors.primaryContainer),
                  _buildStat('Attend', '${(totalPercent * 100).toInt()}%', const Color(0xFFC5EDC4)), // secondary-container
                  _buildStat('Tasks', '$completedTasks', const Color(0xFFD5C6FF)), // tertiary-container
                ],
              ),
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF272420), // deeper night
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3A3A3A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEBF5EB),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text('🌱', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '"You studied 2 more hours than last week. That\'s growth 🌱"',
                        style: AppTypography.bodyMedium(color: AppColors.white.withValues(alpha: 0.7)).copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelSmall(color: const Color(0xFF8B8070)).copyWith(letterSpacing: 1),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleXL(color: valueColor).copyWith(fontSize: 28),
        ),
      ],
    );
  }
}
