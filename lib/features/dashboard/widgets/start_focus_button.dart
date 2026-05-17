import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

import 'package:neuroot/shared/widgets/bounce_button.dart';
import 'package:neuroot/shared/widgets/ambient_motion.dart';
class StartFocusButton extends StatelessWidget {
  const StartFocusButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlowPulseWidget(
      glowColor: AppColors.sage,
      borderRadius: BorderRadius.circular(18),
      child: BounceButton(
        onTap: () {
          // TODO: Start focus session
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF2B2B2B),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer, color: AppColors.primaryContainer, size: 20),
              const SizedBox(width: 8),
              Text(
                'Start Focus Session',
                style: AppTypography.titleSmall(color: AppColors.white).copyWith(fontSize: 16),
              ),
              const SizedBox(width: 8),
              const Text('🌱', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
