import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/shared/widgets/neuroot_widgets.dart';

class TimetableBuilderStep extends StatelessWidget {
  final VoidCallback onNext;

  const TimetableBuilderStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text('Build your timetable', style: AppTypography.titleXL(color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text('Add your weekly classes. Color-code by subject.', style: AppTypography.bodyMedium(color: const Color(0xFF4E4634))),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              
              // Day Tabs
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildDayTab('Mon', true),
                    const SizedBox(width: 8),
                    _buildDayTab('Tue', false),
                    const SizedBox(width: 8),
                    _buildDayTab('Wed', false),
                    const SizedBox(width: 8),
                    _buildDayTab('Thu', false),
                    const SizedBox(width: 8),
                    _buildDayTab('Fri', false),
                    const SizedBox(width: 8),
                    _buildDayTab('Sat', false),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Class Cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildClassCard(
                      title: 'Data Structures',
                      time: '9:00 AM – 10:30 AM',
                      room: 'Room 204',
                      prof: 'Prof. Sharma',
                      code: 'DSA',
                      color: const Color(0xFFFF8A65),
                      bgColor: const Color(0xFFFFF0E6),
                    ),
                    const SizedBox(height: 12),
                    _buildClassCard(
                      title: 'Computer Networks',
                      time: '11:00 AM – 12:30 PM',
                      room: 'Room 108',
                      prof: 'Prof. Gupta',
                      code: 'CN',
                      color: AppColors.tertiary,
                      bgColor: const Color(0xFFE8DDFF),
                    ),
                    const SizedBox(height: 12),
                    // Add Class Button
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.warmCream,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFD1C5AE), width: 1.5, style: BorderStyle.solid), // Fallback for dashed
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '+ Add class for Monday',
                        style: AppTypography.labelLarge(color: const Color(0xFF7F7662)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom CTA
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: NeurootButton(
            label: 'Continue',
            backgroundColor: AppColors.primaryContainer,
            textColor: AppColors.textPrimary,
            icon: const Icon(Icons.arrow_forward, size: 20, color: AppColors.textPrimary),
            onTap: onNext,
          ),
        ),
      ],
    );
  }

  Widget _buildDayTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryContainer : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? AppColors.primaryContainer : const Color(0xFFF0EBE3),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTypography.labelLarge(
          color: isSelected ? AppColors.textPrimary : const Color(0xFF4E4634),
        ),
      ),
    );
  }

  Widget _buildClassCard({
    required String title,
    required String time,
    required String room,
    required String prof,
    required String code,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0EBE3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTypography.labelLarge(color: AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.schedule, size: 14, color: Color(0xFF4E4634)),
                                const SizedBox(width: 6),
                                Text(time, style: AppTypography.labelSmall(color: const Color(0xFF4E4634))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF7F7662)),
                                const SizedBox(width: 4),
                                Text(room, style: AppTypography.labelSmall(color: const Color(0xFF7F7662))),
                                const SizedBox(width: 12),
                                const Icon(Icons.person_outline, size: 14, color: Color(0xFF7F7662)),
                                const SizedBox(width: 4),
                                Text(prof, style: AppTypography.labelSmall(color: const Color(0xFF7F7662))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          code,
                          style: AppTypography.labelSmall(color: color).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
