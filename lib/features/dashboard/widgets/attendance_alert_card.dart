import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/features/academic/providers/attendance_provider.dart';

class AttendanceAlertCard extends ConsumerWidget {
  const AttendanceAlertCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dangerSubjects = ref.watch(dangerSubjectsProvider);

    if (dangerSubjects.isEmpty) {
      return const SizedBox.shrink(); // Hide if no alerts
    }

    // Just show the most critical one (lowest percentage)
    final criticalSubject = dangerSubjects.reduce((curr, next) => 
        curr.attendancePercentage < next.attendancePercentage ? curr : next);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8), // warning-surface
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE8B0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.amber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${criticalSubject.code.isNotEmpty ? criticalSubject.code : criticalSubject.name} attendance at ${criticalSubject.attendancePercentage.toStringAsFixed(0)}%',
                  style: AppTypography.bodyMedium(color: const Color(0xFF2B2B2B))
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cannot miss any more classes',
                  style: AppTypography.bodyMedium(color: const Color(0xFF4E4634))
                      .copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
