import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/academic/providers/insights_provider.dart';
import 'package:intl/intl.dart';

class MoodTrendChart extends ConsumerWidget {
  const MoodTrendChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodLogs = ref.watch(moodTrendProvider).asData?.value ?? [];

    if (moodLogs.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort by date ascending for the chart
    final sortedLogs = List.of(moodLogs)..sort((a, b) => a.date.compareTo(b.date));

    final spots = sortedLogs.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.energy.toDouble());
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF5EFE3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Energy Trends',
            style: AppTypography.titleMedium(color: const Color(0xFF5A5A5A)).copyWith(fontSize: 18),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: 1,
                maxY: 5,
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedLogs.length) return const SizedBox.shrink();
                        final date = sortedLogs[index].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('E').format(date).substring(0, 1),
                            style: AppTypography.labelSmall(color: const Color(0xFF5A5A5A)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primaryContainer,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
