import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/models/attendance_record_model.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/academic/providers/attendance_provider.dart';

class AttendanceHeatmap extends ConsumerWidget {
  const AttendanceHeatmap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(monthAttendanceProvider);

    return recordsAsync.when(
      loading: () => Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator(color: AppColors.sageDark)),
      ),
      error: (e, _) => const SizedBox.shrink(),
      data: (records) => _HeatmapContent(records: records),
    );
  }
}

class _HeatmapContent extends StatelessWidget {
  final List<AttendanceRecord> records;
  const _HeatmapContent({required this.records});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    // Build a map of day → status for quick lookup
    final Map<int, AttendanceStatus> dayStatusMap = {};
    for (final r in records) {
      if (r.date.year == year && r.date.month == month) {
        // If multiple records on same day, prefer present > absent > cancelled
        final existing = dayStatusMap[r.date.day];
        if (existing == null || r.status == AttendanceStatus.present) {
          dayStatusMap[r.date.day] = r.status;
        }
      }
    }

    // Build calendar grid: find first weekday of month
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // weekday: Mon=1 ... Sun=7, we want Mon offset=0
    final startOffset = (firstDay.weekday - 1) % 7;

    // Total cells = offset + daysInMonth, padded to full weeks
    final totalCells = startOffset + daysInMonth;
    final totalRows = (totalCells / 7).ceil();

    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${monthNames[month - 1]} $year",
                style: AppTypography.titleMedium(color: const Color(0xFF1B1C1C))
                    .copyWith(fontSize: 16),
              ),
              Text(
                '${records.length} records',
                style: AppTypography.bodySmall(color: AppColors.textSecondary)
                    .copyWith(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _DayLabel('M'), _DayLabel('T'), _DayLabel('W'), _DayLabel('T'),
              _DayLabel('F'), _DayLabel('S', dim: true), _DayLabel('S', dim: true),
            ],
          ),
          const SizedBox(height: 8),

          // Calendar rows
          ...List.generate(totalRows, (rowIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (colIndex) {
                  final cellIndex = rowIndex * 7 + colIndex;
                  final dayNumber = cellIndex - startOffset + 1;

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    // Empty cell (before/after month)
                    return const _HeatmapCell(type: _CellType.none);
                  }

                  final isToday = dayNumber == now.day;
                  final isFuture = dayNumber > now.day;
                  final status = dayStatusMap[dayNumber];

                  if (isToday) return const _HeatmapCell(type: _CellType.today);
                  if (isFuture) return const _HeatmapCell(type: _CellType.future);

                  if (status == null) {
                    // Past day with no record
                    return const _HeatmapCell(type: _CellType.noRecord);
                  }

                  switch (status) {
                    case AttendanceStatus.present:
                      return const _HeatmapCell(type: _CellType.present);
                    case AttendanceStatus.absent:
                      return const _HeatmapCell(type: _CellType.absent);
                    case AttendanceStatus.cancelled:
                      return const _HeatmapCell(type: _CellType.cancelled);
                  }
                }),
              ),
            );
          }),

          const SizedBox(height: 8),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegend(AppColors.sageDark.withValues(alpha: 0.85), 'Present'),
              _buildLegend(const Color(0xFFE05C5C).withValues(alpha: 0.75), 'Absent'),
              _buildLegend(const Color(0xFFEAE7E7), 'Cancelled',
                  border: const Color(0xFFD1C5AE)),
              _buildLegend(const Color(0xFFD9D9D9), 'No record'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label, {Color? border}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: border != null ? Border.all(color: border) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall(color: const Color(0xFF4E4634))
              .copyWith(fontSize: 10),
        ),
      ],
    );
  }
}

// ─── Cell types ───────────────────────────────────────────────────────────────
enum _CellType { present, absent, cancelled, today, future, noRecord, none }

class _DayLabel extends StatelessWidget {
  final String label;
  final bool dim;
  const _DayLabel(this.label, {this.dim = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.labelSmall(color: const Color(0xFF4E4634)).copyWith(
          fontSize: 10,
          color: dim
              ? const Color(0xFF4E4634).withValues(alpha: 0.45)
              : const Color(0xFF4E4634),
        ),
      ),
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  final _CellType type;
  const _HeatmapCell({required this.type});

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.transparent;
    Border? border;
    Widget? child;

    switch (type) {
      case _CellType.present:
        bgColor = AppColors.sageDark.withValues(alpha: 0.85);
        break;
      case _CellType.absent:
        bgColor = const Color(0xFFE05C5C).withValues(alpha: 0.75);
        break;
      case _CellType.cancelled:
        bgColor = const Color(0xFFEAE7E7);
        border = Border.all(color: const Color(0xFFD1C5AE));
        child = const Center(
          child: Text('C', style: TextStyle(fontSize: 8, color: Color(0xFF4E4634))),
        );
        break;
      case _CellType.today:
        bgColor = AppColors.white;
        border = Border.all(color: AppColors.primaryContainer, width: 2);
        child = Center(
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        );
        break;
      case _CellType.future:
        border = Border.all(color: const Color(0xFFD1C5AE).withValues(alpha: 0.35));
        break;
      case _CellType.noRecord:
        bgColor = const Color(0xFFD9D9D9).withValues(alpha: 0.6);
        break;
      case _CellType.none:
        bgColor = Colors.transparent;
        break;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: border,
      ),
      child: child,
    );
  }
}
