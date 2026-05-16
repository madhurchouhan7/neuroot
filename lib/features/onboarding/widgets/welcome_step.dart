import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/shared/widgets/neuroot_widgets.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';

class WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;

  const WelcomeStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Area: Illustration & Particles
        Expanded(
          flex: 4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Particles and stars
              Positioned(
                top: 50, left: 60,
                child: Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.2), shape: BoxShape.circle)),
              ),
              Positioned(
                top: 100, right: 40,
                child: Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.2), shape: BoxShape.circle)),
              ),
              Positioned(
                bottom: 80, left: 80,
                child: Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.2), shape: BoxShape.circle)),
              ),
              Positioned(
                top: 80, right: 80,
                child: Icon(Icons.star_border, size: 16, color: AppColors.amber.withValues(alpha: 0.3)),
              ),
              Positioned(
                bottom: 100, right: 100,
                child: Icon(Icons.star_border, size: 20, color: AppColors.amber.withValues(alpha: 0.3)),
              ),
              Positioned(
                top: 150, left: 50,
                child: Icon(Icons.psychology_alt, size: 14, color: AppColors.amber.withValues(alpha: 0.3)),
              ),

              // Mascot Image
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: NeurootNetworkImage(
                  url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB_DiJg5h25zXN_SAGdi9bOxBpVY8Su1Y7-ztl4_TRphYcFcNUDz94HZCOQA6zYAkhXpkYGlI84myWU1HLaybM7EobLdwNnz01Zz27WeWGc0ngQuKs2WMvC981Isg4sjIt2s7LBCSMIUMPZCW1jnBqx4-rJUs6LetUa_cHE_qmqJ8qsPqkUwFzMlV1ulKFJxc2b9Q5KmTPvllKxp_9CV1DuN6Hphxs7VfFpnpzLFGgdaHtcVL0fbMOz1iNSDYDQ9I-PAgtdQuj9UIo',
                  fit: BoxFit.contain,
                  errorIcon: Icons.eco,
                  placeholderColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),

        // Middle Area: Content
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome to Bloom 🌱', style: AppTypography.titleXL(color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                Text(
                  "Your cozy study companion. We'll help you stay on top of classes, assignments, and your own well-being — without the stress.",
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium(color: const Color(0xFF7F7662)),
                ),
              ],
            ),
          ),
        ),

        // Bottom Area: Actions
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                NeurootButton(
                  label: "Let's Get Started",
                  backgroundColor: AppColors.primaryContainer,
                  textColor: AppColors.textPrimary,
                  icon: const Icon(Icons.arrow_forward, size: 20, color: AppColors.textPrimary),
                  onTap: onNext,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Swipe to continue ', style: AppTypography.labelSmall(color: const Color(0xFFD1C5AE))),
                    const Icon(Icons.arrow_forward, size: 14, color: Color(0xFFD1C5AE)),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
