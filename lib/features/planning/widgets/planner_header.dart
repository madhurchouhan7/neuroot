import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

class PlannerHeader extends StatelessWidget {
  const PlannerHeader({super.key});

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent, // or bloom-cream-dark on hover
                ),
                child: const Icon(Icons.menu, color: AppColors.primaryContainer),
              ),
              Text(
                'Planner',
                style: AppTypography.titleMedium(color: AppColors.primaryContainer)
                    .copyWith(fontSize: 20),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: const Icon(Icons.calendar_today_outlined, color: AppColors.primaryContainer),
              ),
            ],
          ),
        ),
        
        // Filter Tabs Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildTab('All', true),
              const SizedBox(width: 8),
              _buildTab('Assignments', false),
              const SizedBox(width: 8),
              _buildTab('Exams', false),
              const SizedBox(width: 8),
              _buildTab('Labs', false),
              const SizedBox(width: 8),
              _buildTab('Recurring', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2B2B2B) : const Color(0xFFF5F0FF), // brand-dark or brand-purple-light
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? const Color(0xFF2B2B2B) : const Color(0xFFE8E0F0),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall(
          color: isSelected ? AppColors.white : const Color(0xFF8B8070),
        ).copyWith(fontSize: 11),
      ),
    );
  }
}
