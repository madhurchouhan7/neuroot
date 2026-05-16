import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/features/planning/providers/task_provider.dart';

class TodayPrioritiesCard extends ConsumerWidget {
  const TodayPrioritiesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(upcomingTasksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "TODAY'S PRIORITIES",
            style: AppTypography.labelSmall(color: const Color(0xFF7F7662))
                .copyWith(letterSpacing: 0.08, fontWeight: FontWeight.bold),
          ),
        ),
        if (tasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF0EBE3)),
            ),
            alignment: Alignment.center,
            child: Text(
              "No priorities right now! 🎉",
              style: AppTypography.bodyMedium(color: const Color(0xFFB0A898)),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF0EBE3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: tasks.map((t) {
                // Determine due badge
                final isToday = t.dueDate.year == DateTime.now().year &&
                                t.dueDate.month == DateTime.now().month &&
                                t.dueDate.day == DateTime.now().day;
                final isOverdue = t.dueDate.isBefore(DateTime.now()) && !isToday;
                
                String badgeText = isToday ? 'Due Today' : (isOverdue ? 'Overdue' : 'Upcoming');
                Color badgeColor = const Color(0xFF6D5400);
                Color badgeBg = const Color(0xFFFFF3C4);

                if (isOverdue) {
                  badgeColor = AppColors.amber;
                  badgeBg = const Color(0xFFFFF8E8);
                } else if (!isToday) {
                  badgeColor = const Color(0xFF5D4D8E);
                  badgeBg = const Color(0xFFF0ECFF);
                }

                return Padding(
                  padding: EdgeInsets.only(bottom: t == tasks.last ? 0 : 4.0),
                  child: _buildTaskRow(
                    title: t.title,
                    isDone: t.isCompleted,
                    badgeText: badgeText,
                    badgeColor: badgeColor,
                    badgeBg: badgeBg,
                    bgColor: AppColors.white,
                    onTap: () {
                      ref.read(taskNotifierProvider.notifier).toggleComplete(t.id, isCompleted: !t.isCompleted);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildTaskRow({
    required String title,
    required bool isDone,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFFEBF5EB) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? AppColors.sageDark : const Color(0xFFDCD9D9), // surface-dim
                  width: isDone ? 1 : 2,
                ),
              ),
              alignment: Alignment.center,
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: AppColors.sageDark)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyMedium(
                  color: isDone ? const Color(0xFFB0A898) : const Color(0xFF2B2B2B),
                ).copyWith(
                  fontWeight: isDone ? FontWeight.normal : FontWeight.w500,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                badgeText,
                style: AppTypography.labelSmall(color: badgeColor).copyWith(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
