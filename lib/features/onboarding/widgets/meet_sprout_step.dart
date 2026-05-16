import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/shared/widgets/neuroot_widgets.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';

class MeetSproutStep extends StatelessWidget {
  final VoidCallback onNext;

  const MeetSproutStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Area: Mascot
        Expanded(
          flex: 5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glowing effect
              Positioned(
                top: 80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mascot Image
                  NeurootNetworkImage(
                    url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD5X5WACiOWYO6he6_oCUBjc0AC4XcNXuXzm08oIoKGdBeQZSwaUWxVak3GYkHjYq_2YPYJOf1syEcHSZtMPkxHhDliA1KtgGt35iXJIRqhdpBTrgX960Z0ZzdDiKpcVTe0K5wMT19wo7wmLaZ_ZDdebt__D0qf9tAzN3WDAaFBcSD0dP3KT79HhonbOFzA5Tm93ErPzAR8qAvCaIAa8erROaE4wdMJ325unTSQrnJuYlDdVxQCI2dqnYmeOt6Blq7MZ9wqP6dAHW8',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    errorIcon: Icons.eco,
                    placeholderColor: Colors.transparent,
                  ),
                  
                  // Name Card
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Container(
                      width: 240,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF0EBE3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sprout 🌱', style: AppTypography.titleMedium(color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text('Your study companion · Level 1', style: AppTypography.labelSmall(color: const Color(0xFF7F7662))),
                          const SizedBox(height: 12),
                          // XP Bar
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAE7E7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Bottom Area: Content
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Meet Sprout!', style: AppTypography.titleXL(color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Text(
                  'Sprout grows as you study, attend classes, and take care of yourself. No judgment — just gentle encouragement every day.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium(color: const Color(0xFF5A5A5A)),
                ),
                const SizedBox(height: 24),
                
                // Feature Pills
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildFeaturePill('🌱 Grows with you'),
                    _buildFeaturePill('✨ Never judges'),
                    _buildFeaturePill('🎯 Celebrates wins'),
                  ],
                ),
                const SizedBox(height: 32),

                // CTA
                NeurootButton(
                  label: "Let's Bloom! 🌱",
                  backgroundColor: AppColors.primaryContainer,
                  textColor: AppColors.textPrimary,
                  onTap: onNext,
                ),
                const SizedBox(height: 16),
                Text("Sprout can't wait to see you grow.", style: AppTypography.labelSmall(color: const Color(0xFF7F7662))),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturePill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(text, style: AppTypography.labelMedium(color: const Color(0xFF5A5A5A))),
    );
  }
}
