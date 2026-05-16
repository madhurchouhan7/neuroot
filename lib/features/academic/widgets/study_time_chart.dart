import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import '../providers/insights_provider.dart';
import 'package:intl/intl.dart';

class StudyTimeChart extends ConsumerWidget {
  const StudyTimeChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoursData = ref.watch(weeklyFocusHoursProvider);
    final maxHours = hoursData.isEmpty ? 1.0 : (hoursData.reduce((a, b) => a > b ? a : b)).clamp(1.0, double.infinity);
    
    // Labels for the last 7 days including today
    final now = DateTime.now();
    final labels = List.generate(7, (i) => DateFormat('E').format(now.subtract(Duration(days: 6 - i))).substring(0, 1));
    
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Study Time',
                style: AppTypography.titleMedium(color: const Color(0xFF5A5A5A)).copyWith(fontSize: 18),
              ),
              const Icon(Icons.more_horiz, color: Color(0xFFDCD9D9)),
            ],
          ),
          const SizedBox(height: 24),
          
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final val = hoursData.isEmpty ? 0.0 : hoursData[index];
                final isToday = index == 6;
                return _buildBar(labels[index], val / maxHours, isToday, popupLabel: isToday ? '${val.toStringAsFixed(1)}h' : null);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double heightFactor, bool isActive, {bool isMissed = false, String? popupLabel}) {
    final barColor = isActive ? AppColors.primaryContainer : const Color(0xFFA8CFA8);
    
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (popupLabel != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1A16), // night
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                popupLabel,
                style: AppTypography.labelSmall(color: AppColors.white).copyWith(fontSize: 10),
              ),
            ),
          if (isMissed)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text('🌱', style: TextStyle(fontSize: 10)),
            ),
            
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: constraints.maxHeight * heightFactor,
                    decoration: BoxDecoration(
                      color: isMissed ? barColor.withValues(alpha: 0.5) : barColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(alpha: 0.4),
                          blurRadius: 15,
                        ),
                      ] : null,
                    ),
                  );
                }
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.labelSmall(color: const Color(0xFF5A5A5A)).copyWith(
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? const Color(0xFF5A5A5A) : const Color(0xFF5A5A5A).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
