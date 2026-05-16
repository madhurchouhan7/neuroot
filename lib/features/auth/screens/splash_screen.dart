import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';
import 'dart:math' as math;

/// Splash screen — shows the brand animation only.
/// Navigation is driven entirely by the GoRouter auth redirect, NOT a Timer.
/// The router will redirect as soon as authStateProvider emits a value.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingCtrl;

  @override
  void initState() {
    super.initState();
    _loadingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    // ✅ No Timer.delayed here — router's redirect handles navigation
  }

  @override
  void dispose() {
    _loadingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: Stack(
        children: [
          // ── Background Particles ───────────────────────────────────────────
          _buildParticle(Icons.eco_outlined, 24, 0.15, 0.2, 15 * math.pi / 180),
          _buildParticle(
            Icons.circle_outlined,
            16,
            0.25,
            0.85,
            -20 * math.pi / 180,
          ),
          _buildParticle(Icons.eco_outlined, 20, 0.6, 0.1, 45 * math.pi / 180),
          _buildParticle(
            Icons.circle_outlined,
            12,
            0.75,
            0.75,
            10 * math.pi / 180,
          ),
          _buildParticle(Icons.eco_outlined, 18, 0.4, 0.8, -45 * math.pi / 180),
          _buildParticle(Icons.eco_outlined, 22, 0.85, 0.4, 30 * math.pi / 180),

          // ── Main Content ─────────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mascot circle
                Container(
                  width: 192,
                  height: 192,
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textSecondary.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: NeurootNetworkImage(
                    url:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBpenh9mGN5KX_c-iZXTTC0dK5E7y6K4xiPoSAoY_OuLc9JTwzkVgJN2ONpe-u7c7eBdTvlwu_GYs6t3n74Efqlgc_3LlmIsoqo9gDDG0SWUrGxnIPzgGUiUdyPUle5gO8sYjI8NIbDQAB4IrnevgwTqrP1EpuGbb1E1thQqP6LCA22lp7Ho7qPtHn2sIJ83rpthikwQ0BsnSHx-enf0ko9i6v7oPDhZ8l4QopTeY_xwDvY4ETc_F91wb7GN58rfJlTdZFJkvYSXmg',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                    errorIcon: Icons.eco,
                    placeholderColor: Colors.transparent,
                  ),
                ),

                // App Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'neur',
                      style: AppTypography.titleXL(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        Icons.eco,
                        color: AppColors.primaryContainer,
                        size: 32,
                      ),
                    ),
                    Text(
                      'ot',
                      style: AppTypography.titleXL(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Tagline
                Text(
                  'your cozy study companion',
                  style: AppTypography.supportiveMedium(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),

          // ── Loading Bar ──────────────────────────────────────────────────
          Positioned(
            bottom: 64,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 192,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.softGrey,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: AnimatedBuilder(
                  animation: _loadingCtrl,
                  builder: (context, child) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 192 * (0.1 + (_loadingCtrl.value * 0.8)),
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryContainer.withValues(
                                alpha: 0.6,
                              ),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticle(
    IconData icon,
    double size,
    double topFrac,
    double leftFrac,
    double rotation,
  ) {
    return Positioned(
      top: MediaQuery.of(context).size.height * topFrac,
      left: MediaQuery.of(context).size.width * leftFrac,
      child: Opacity(
        opacity: 0.1,
        child: Transform.rotate(
          angle: rotation,
          child: Icon(icon, size: size, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
