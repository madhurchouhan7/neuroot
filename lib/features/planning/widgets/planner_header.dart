import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

class PlannerHeader extends StatelessWidget {
  final VoidCallback? onCalendarTap;

  const PlannerHeader({super.key, this.onCalendarTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top App Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40), // Placeholder to center the title
              Text(
                'Planner',
                style: AppTypography.titleMedium(
                  color: AppColors.primaryContainer,
                ).copyWith(fontSize: 20),
              ),
              GestureDetector(
                onTap: onCalendarTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
