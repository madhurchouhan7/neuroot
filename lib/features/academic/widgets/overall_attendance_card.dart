import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

class OverallAttendanceCard extends StatelessWidget {
  final double percentage;
  final int safeLeaves;
  
  const OverallAttendanceCard({
    super.key,
    required this.percentage,
    required this.safeLeaves,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B), // dark background
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
          // Background circle flair
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: AppTypography.titleXL(color: AppColors.white).copyWith(fontSize: 52, height: 1, letterSpacing: -1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Overall Attendance',
                    style: AppTypography.bodySmall(color: const Color(0xFF8B8070)).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  
                  // Safe Zone Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.sageDark.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('●', style: TextStyle(fontSize: 8, color: AppColors.sageDark)),
                        const SizedBox(width: 4),
                        Text(
                          'Safe Zone',
                          style: AppTypography.labelSmall(color: AppColors.sageDark).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: AppTypography.bodySmall(color: const Color(0xFFD1C5AE)),
                      children: [
                        const TextSpan(text: 'You can miss '),
                        TextSpan(text: '$safeLeaves more', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
                        const TextSpan(text: ' classes this month'),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Threshold Circle
              Column(
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: 0.75, // 75% threshold fixed
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          color: AppColors.sageDark,
                        ),
                        Text(
                          '75%',
                          style: AppTypography.titleMedium(color: AppColors.white).copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'THRESHOLD',
                    style: AppTypography.labelSmall(color: const Color(0xFF8B8070)).copyWith(fontSize: 11, letterSpacing: 1),
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
