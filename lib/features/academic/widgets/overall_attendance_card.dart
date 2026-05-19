import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

class OverallAttendanceCard extends StatelessWidget {
  final double percentage;
  final int safeLeaves;
  final int threshold;
  final bool hasData;

  const OverallAttendanceCard({
    super.key,
    required this.percentage,
    required this.safeLeaves,
    this.threshold = 75,
    this.hasData = true,
  });

  @override
  Widget build(BuildContext context) {
    final isSafe = percentage >= threshold;
    final isWarning = percentage >= (threshold - 3) && percentage < threshold;

    final Color statusColor = isSafe
        ? AppColors.sageDark
        : isWarning
        ? AppColors.amber
        : const Color(0xFFE05C5C);
    final Color statusBg = isSafe
        ? AppColors.sageDark.withValues(alpha: 0.2)
        : isWarning
        ? AppColors.amber.withValues(alpha: 0.2)
        : const Color(0xFFE05C5C).withValues(alpha: 0.2);
    final String statusLabel = isSafe
        ? 'Safe Zone ✅'
        : isWarning
        ? 'Warning Zone ⚠️'
        : 'Danger Zone 🚨';

    final String safeLeavesText;
    if (!hasData) {
      safeLeavesText = 'Mark some classes to start tracking';
    } else if (safeLeaves > 0) {
      safeLeavesText =
          'You can miss $safeLeaves more class${safeLeaves == 1 ? '' : 'es'}';
    } else if (safeLeaves == 0) {
      safeLeavesText = 'Attend every class to stay safe 🌱';
    } else {
      final need = safeLeaves.abs();
      safeLeavesText =
          'Attend $need more class${need == 1 ? '' : 'es'} to recover';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background flair
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasData ? '${percentage.toStringAsFixed(1)}%' : '--.--% ',
                      style: AppTypography.titleXL(
                        color: AppColors.white,
                      ).copyWith(fontSize: 52, height: 1, letterSpacing: -1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Overall Attendance',
                      style: AppTypography.bodySmall(
                        color: const Color(0xFF8B8070),
                      ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: hasData
                            ? statusBg
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '●',
                            style: TextStyle(
                              fontSize: 8,
                              color: hasData
                                  ? statusColor
                                  : const Color(0xFF8B8070),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              hasData ? statusLabel : 'No data yet',
                              style: AppTypography.labelSmall(
                                color: hasData
                                    ? statusColor
                                    : const Color(0xFF8B8070),
                              ).copyWith(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      safeLeavesText,
                      style: AppTypography.bodySmall(
                        color: const Color(0xFFD1C5AE),
                      ).copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Threshold Ring
              Column(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: hasData
                                ? (percentage / 100).clamp(0.0, 1.0)
                                : 0,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.1,
                            ),
                            color: hasData
                                ? statusColor
                                : const Color(0xFF8B8070),
                          ),
                        ),
                        Text(
                          '$threshold%',
                          style: AppTypography.titleMedium(
                            color: AppColors.white,
                          ).copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'THRESHOLD',
                    style: AppTypography.labelSmall(
                      color: const Color(0xFF8B8070),
                    ).copyWith(fontSize: 11, letterSpacing: 1),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
