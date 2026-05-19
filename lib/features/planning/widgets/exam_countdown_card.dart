import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/models/task_model.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/planning/providers/task_provider.dart';

class ExamCountdownCard extends ConsumerWidget {
  const ExamCountdownCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksStreamProvider).asData?.value ?? [];
    final upcomingExams = tasks
        .where((t) => t.type == TaskType.exam && !t.isCompleted && t.dueDate.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    if (upcomingExams.isEmpty) {
      return const SizedBox.shrink(); // Hide if no upcoming exams
    }

    final nextExam = upcomingExams.first;
    final daysLeft = nextExam.dueDate.difference(DateTime.now()).inDays;
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dateStr = '${days[nextExam.dueDate.weekday - 1]}, ${nextExam.dueDate.day} ${months[nextExam.dueDate.month - 1]}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF5B4BE8), // brand-purple
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UPCOMING EXAM',
                  style: AppTypography.labelSmall(color: Colors.white.withValues(alpha: 0.5))
                      .copyWith(letterSpacing: 0.8, fontSize: 10),
                ),
                const SizedBox(height: 4),
                Text(
                  nextExam.title,
                  style: AppTypography.titleMedium(color: AppColors.white)
                      .copyWith(fontSize: 20),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: AppTypography.bodySmall(color: Colors.white.withValues(alpha: 0.8))
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                ),
                if (nextExam.notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    nextExam.notes,
                    style: AppTypography.bodySmall(color: Colors.white.withValues(alpha: 0.6))
                        .copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '$daysLeft',
                style: AppTypography.titleXL(color: AppColors.white)
                    .copyWith(fontSize: 56, fontWeight: FontWeight.w800, height: 1),
              ),
              Text(
                daysLeft == 1 ? 'DAY LEFT' : 'DAYS LEFT',
                style: AppTypography.labelSmall(color: Colors.white.withValues(alpha: 0.6))
                    .copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
