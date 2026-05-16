import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import '../providers/insights_provider.dart';

class AttendanceSummaryWidget extends ConsumerWidget {
  const AttendanceSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceData = ref.watch(weeklyAttendanceProvider);
    
    // Average attendance
    final totalPercent = attendanceData.isEmpty 
        ? 0.0 
        : attendanceData.map((e) => e['percentage'] as double).reduce((a, b) => a + b) / attendanceData.length;

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
        children: [
          Text(
            'Attendance',
            style: AppTypography.titleMedium(color: const Color(0xFF5A5A5A)).copyWith(fontSize: 15),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  color: const Color(0xFFE4E2E1),
                ),
                if (attendanceData.isEmpty)
                  CircularProgressIndicator(
                    value: 0.0,
                    strokeWidth: 8,
                    color: AppColors.primaryContainer,
                  )
                else
                  // Simple representation: stack of the first few subjects
                  ...attendanceData.take(4).toList().asMap().entries.map((entry) {
                    final i = entry.key;
                    final data = entry.value;
                    final val = data['percentage'] as double;
                    final colorHex = data['colorHex'] as String;
                    final color = Color(int.parse(colorHex.replaceAll('#', '0xFF')));
                    return CircularProgressIndicator(
                      value: val * (1.0 - (i * 0.15)), // Stagger them
                      strokeWidth: 8,
                      color: color,
                    );
                  }),
                
                Text(
                  '${(totalPercent * 100).toInt()}%',
                  style: AppTypography.titleXL(color: const Color(0xFF5A5A5A)).copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
