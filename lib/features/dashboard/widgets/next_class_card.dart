import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/features/dashboard/providers/dashboard_provider.dart';
import 'package:neuroot/features/academic/providers/attendance_provider.dart';
import 'package:neuroot/core/models/timetable_entry_model.dart';

class NextClassCard extends ConsumerWidget {
  const NextClassCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(todayClassesProvider);
    final subjects = ref.watch(subjectsStreamProvider).asData?.value ?? [];

    TimetableEntry? nextClass;
    final now = TimeOfDay.now();
    for (var c in classes) {
      // Clean up legacy 12-hour formats just in case
      String t = c.startTime;
      if (t.toUpperCase().contains('AM') || t.toUpperCase().contains('PM')) {
        try {
          final parts = t.split(' ');
          final timeParts = parts[0].split(':');
          int h = int.parse(timeParts[0]);
          final m = int.parse(timeParts[1]);
          final isPm = parts[1].toUpperCase() == 'PM';
          if (isPm && h != 12) h += 12;
          if (!isPm && h == 12) h = 0;
          t = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
        } catch (_) {}
      }

      final parts = t.split(':');
      if (parts.length == 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        if (h > now.hour || (h == now.hour && m >= now.minute)) {
          nextClass = c;
          break;
        }
      }
    }

    if (nextClass == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'NEXT CLASS',
              style: AppTypography.labelSmall(color: const Color(0xFF7F7662))
                  .copyWith(letterSpacing: 0.08, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF0EBE3)),
            ),
            alignment: Alignment.center,
            child: Text(
              "No more classes today! 🥳",
              style: AppTypography.bodyMedium(color: const Color(0xFFB0A898)),
            ),
          ),
        ],
      );
    }

    // Use embedded code/color from timetable entry, fall back to subjects stream
    final relatedSubject = subjects.where((s) => s.id == nextClass?.subjectId).firstOrNull;
    final code = nextClass.subjectCode.isNotEmpty
        ? nextClass.subjectCode
        : (relatedSubject?.code ?? 'CLS');
    final name = nextClass.subjectName;
    final attPct = relatedSubject?.attendancePercentage.toStringAsFixed(0) ?? '--';

    Color subjectColor = AppColors.primaryContainer;
    try {
      final hex = nextClass.subjectColor.isNotEmpty
          ? nextClass.subjectColor
          : (relatedSubject?.color ?? '#A8D5BA');
      subjectColor = Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {}


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'NEXT CLASS',
            style: AppTypography.labelSmall(color: const Color(0xFF7F7662))
                .copyWith(letterSpacing: 0.08, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2B2B2B),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned(
                  right: -24,
                  top: -24,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: subjectColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: subjectColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          code,
                          style: AppTypography.titleSmall(color: const Color(0xFF2B2B2B)).copyWith(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: AppTypography.titleMedium(color: AppColors.white)),
                            const SizedBox(height: 2),
                            Text(
                              '${nextClass.room.isNotEmpty ? '${nextClass.room} · ' : ''}${nextClass.startTime}',
                              style: AppTypography.labelSmall(color: const Color(0xFF8B8070)).copyWith(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.sageDark.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.sageDark.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          '$attPct% ATT',
                          style: AppTypography.titleSmall(color: AppColors.sageDark).copyWith(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
