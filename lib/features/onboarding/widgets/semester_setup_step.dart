import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/shared/widgets/neuroot_widgets.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';

class SemesterSetupStep extends StatelessWidget {
  final VoidCallback onNext;

  const SemesterSetupStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  // Header Section
                  Center(
                    child: NeurootNetworkImage(
                      url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBkgJVMoaR_-QpCUz412ZSDt4ReD_578rnJOcYb8zClZg5eZGgtZ0H4ghYACDV1qSs3zX6X0pcID2HZBosYoXp7VOcPs6BzYbAxUt68R7HkLl-GuF2dUYw37N6KmLZ06wS9r8fdDXPB1_b-yu6ajukdE-yR3jLepK6Sp2E88lHojp3nS-ORacSBesxBAFwl1JV4hG1_M-HlLiKn6fzH70e21v0D267lkor3oJxHj-v5mwciL_XILaUGZzxW4zs5r1kI3aJvf72wzLQ',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      errorIcon: Icons.school_rounded,
                      placeholderColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Set up your semester',
                      style: AppTypography.titleXL(color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Takes under 2 minutes. We promise.',
                      style: AppTypography.bodyMedium(color: const Color(0xFF4E4634)),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Semester Name
                  Text('Semester Name', style: AppTypography.labelLarge(color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  _buildInput('Sem 4 · 2025–26', Icons.check_circle, AppColors.sageDark, const Color(0xFFEBF5EB)),
                  const SizedBox(height: 20),

                  // Dates Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start Date', style: AppTypography.labelLarge(color: AppColors.textPrimary)),
                            const SizedBox(height: 8),
                            _buildInput('Jan 06, 2026', Icons.calendar_today, AppColors.sageDark, Colors.transparent),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('End Date', style: AppTypography.labelLarge(color: AppColors.textPrimary)),
                            const SizedBox(height: 8),
                            _buildInput('May 20, 2026', Icons.calendar_today, AppColors.sageDark, Colors.transparent),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Attendance Threshold
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Target Attendance', style: AppTypography.labelLarge(color: AppColors.textPrimary)),
                      Text('Most require 75%', style: AppTypography.labelSmall(color: const Color(0xFF4E4634))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildAttendanceOption('75%', isSelected: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildAttendanceOption('80%', isSelected: false)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildAttendanceOption('85%', isSelected: false)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Subjects
                  Text('Subjects', style: AppTypography.labelLarge(color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSubjectChip('DSA', const Color(0xFFFF8A65), const Color(0xFFFFECEC)),
                      _buildSubjectChip('CN', AppColors.tertiary, AppColors.lavenderSurface),
                      _buildSubjectChip('OS', AppColors.sageDark, AppColors.sageSurface),
                      _buildSubjectChip('EMFT', AppColors.amber, AppColors.energyLight),
                      _buildSubjectChip('DBMS', const Color(0xFFBA1A1A), const Color(0xFFFFDAD6)),
                      // Add Subject Button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD1C5AE), width: 1.5, style: BorderStyle.solid), // Flutter doesn't have dashed border built-in easily without package
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, size: 16, color: Color(0xFF4E4634)),
                            const SizedBox(width: 4),
                            Text('Add Subject', style: AppTypography.labelMedium(color: const Color(0xFF4E4634))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Fixed Bottom
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              children: [
                NeurootButton(
                  label: 'Continue',
                  backgroundColor: AppColors.primaryContainer,
                  textColor: AppColors.textPrimary,
                  icon: const Icon(Icons.arrow_forward, size: 20, color: AppColors.textPrimary),
                  onTap: onNext,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('✦', style: TextStyle(color: AppColors.amber, fontSize: 14)),
                    const SizedBox(width: 4),
                    Text('You can edit these anytime', style: AppTypography.labelSmall(color: const Color(0xFF4E4634))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String hint, IconData icon, Color iconColor, Color iconBg) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0EBE3), width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(hint, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceOption(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryContainer : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.primaryContainer : const Color(0xFFF0EBE3),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTypography.labelLarge(
          color: isSelected ? AppColors.textPrimary : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSubjectChip(String label, Color dotColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: dotColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.labelMedium(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
