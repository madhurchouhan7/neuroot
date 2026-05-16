import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

class ExamCountdownCard extends StatelessWidget {
  const ExamCountdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF5B4BE8), // brand-purple
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UPCOMING EXAM',
                  style: AppTypography.labelSmall(color: Colors.white.withValues(alpha: 0.5))
                      .copyWith(letterSpacing: 0.8, fontSize: 10),
                ),
                const SizedBox(height: 4),
                Text(
                  'Computer Networks',
                  style: AppTypography.titleMedium(color: AppColors.white)
                      .copyWith(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  'Friday, 16 May · Hall B',
                  style: AppTypography.bodySmall(color: Colors.white.withValues(alpha: 0.8))
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  'Prof. Gupta · 3 hrs duration',
                  style: AppTypography.bodySmall(color: Colors.white.withValues(alpha: 0.6))
                      .copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '2',
                style: AppTypography.titleXL(color: AppColors.white)
                    .copyWith(fontSize: 56, fontWeight: FontWeight.w800, height: 1),
              ),
              Text(
                'DAYS LEFT',
                style: AppTypography.labelSmall(color: Colors.white.withValues(alpha: 0.6))
                    .copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
