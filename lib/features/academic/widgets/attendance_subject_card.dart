import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

enum AttendanceRisk {
  safe,
  warning,
  danger
}

class AttendanceSubjectCard extends StatelessWidget {
  final String title;
  final String professor;
  final double percentage;
  final Color dotColor;
  final Color iconBgColor;
  final AttendanceRisk riskLevel;
  final int leavesLeft;
  final VoidCallback onTap;

  const AttendanceSubjectCard({
    super.key,
    required this.title,
    required this.professor,
    required this.percentage,
    required this.dotColor,
    required this.iconBgColor,
    required this.riskLevel,
    required this.leavesLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color getRiskColor() {
      switch (riskLevel) {
        case AttendanceRisk.safe:
          return AppColors.sageDark;
        case AttendanceRisk.warning:
          return AppColors.amber;
        case AttendanceRisk.danger:
          return const Color(0xFFE05C5C); // bloom-red
      }
    }

    Color getRiskBgColor() {
      switch (riskLevel) {
        case AttendanceRisk.safe:
          return const Color(0xFFEBF5EB); // bloom-sage-bg
        case AttendanceRisk.warning:
          return const Color(0xFFFFF3C4); // bloom-yellow-soft
        case AttendanceRisk.danger:
          return const Color(0xFFFFECEC); // bloom-red-bg
      }
    }

    String getRiskText() {
      switch (riskLevel) {
        case AttendanceRisk.safe:
          return 'Safe · can miss $leavesLeft more';
        case AttendanceRisk.warning:
          return 'Warning · can miss $leavesLeft';
        case AttendanceRisk.danger:
          return 'Danger · miss $leavesLeft more';
      }
    }

    final isDanger = riskLevel == AttendanceRisk.danger;
    final riskColor = getRiskColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDanger ? const Color(0xFFFFECEC) : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDanger ? const Color(0xFFE05C5C).withValues(alpha: 0.4) : const Color(0xFFF5EFE3),
            width: isDanger ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDanger ? AppColors.white : iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isDanger ? const Color(0xFFE05C5C) : dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTypography.titleSmall(color: isDanger ? const Color(0xFFE05C5C) : const Color(0xFF1B1C1C)).copyWith(fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              professor,
                              style: AppTypography.bodySmall(color: isDanger ? const Color(0xFF93000A) : const Color(0xFF4E4634)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: AppTypography.titleXL(color: riskColor).copyWith(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Progress Bar
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: isDanger ? Colors.white.withValues(alpha: 0.5) : const Color(0xFFE4E2E1), // surface-container-highest
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: riskColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDanger ? const Color(0xFFE05C5C) : getRiskBgColor(),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDanger) ...[
                        const Icon(Icons.warning, size: 12, color: AppColors.white),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        getRiskText(),
                        style: AppTypography.labelSmall(color: isDanger ? AppColors.white : riskColor).copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      isDanger ? 'Appeal' : 'Mark today',
                      style: AppTypography.labelSmall(color: isDanger ? const Color(0xFFE05C5C) : const Color(0xFF4E4634)),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: isDanger ? const Color(0xFFE05C5C) : const Color(0xFF4E4634),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
