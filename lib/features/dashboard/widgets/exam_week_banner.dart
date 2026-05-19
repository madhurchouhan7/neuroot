import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/dashboard/providers/dashboard_provider.dart';
import 'package:intl/intl.dart';

import 'package:neuroot/features/planning/screens/task_detail_screen.dart';

class ExamWeekBanner extends ConsumerWidget {
  const ExamWeekBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExamWeek = ref.watch(isExamWeekProvider);
    final nextExam = ref.watch(nextUpcomingExamProvider);

    if (!isExamWeek) return const SizedBox.shrink();

    final title = nextExam?.title ?? "Upcoming Exam";
    final dueDate = nextExam?.dueDate;

    String countdown = "";
    if (dueDate != null) {
      final difference = dueDate.difference(DateTime.now());
      if (difference.isNegative) {
        countdown = "Overdue! 🌱";
      } else if (difference.inDays >= 1) {
        countdown =
            "${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} left!";
      } else if (difference.inHours >= 1) {
        countdown =
            "${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} left!";
      } else {
        countdown = "${difference.inMinutes} mins left!";
      }
    }

    final formattedDate = dueDate != null
        ? DateFormat('EEE, MMM d @ h:mm a').format(dueDate)
        : "";

    return GestureDetector(
      onTap: () {
        if (nextExam != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskDetailScreen(task: nextExam)),
          );
        } else {
          context.push('/planner');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF805AD5), // Purple 600
              Color(0xFFB794F4), // Purple 400
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF805AD5).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Sprout with glasses icon container
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🤓', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),

            // Countdown detail
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9D8FD), // Light purple badge
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'EXAM WEEK MODE',
                          style: AppTypography.labelSmall(
                            color: const Color(0xFF553C9A),
                          ).copyWith(fontWeight: FontWeight.bold, fontSize: 9),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (countdown.isNotEmpty)
                        Text(
                          countdown,
                          style: AppTypography.labelSmall(
                            color: Colors.white,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: AppTypography.titleMedium(
                      color: Colors.white,
                    ).copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (formattedDate.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: AppTypography.bodySmall(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
