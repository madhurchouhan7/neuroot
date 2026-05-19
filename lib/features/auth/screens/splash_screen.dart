import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
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
                // Mascot Card
                Container(
                  width: 208,
                  height: 208,
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEEDDCC).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Image.asset(
                    'assets/mascot/image.png',
                    fit: BoxFit.contain,
                  ),
                ),

                // App Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'bl',
                      style: AppTypography.titleXL(
                        color: AppColors.textPrimary,
                      ).copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Gold leaf outline logo
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: const Color(0xFFF5C542),
                          width: 3.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.eco,
                        color: Color(0xFFF5C542),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'm',
                      style: AppTypography.titleXL(
                        color: AppColors.textPrimary,
                      ).copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Tagline
                Text(
                  'your cozy study companion',
                  style: AppTypography.supportiveMedium(
                    color: const Color(0xFF7F7662),
                  ).copyWith(
                    fontSize: 14,
                    letterSpacing: 0.5,
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
                  color: const Color(0xFFECEAE5),
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
                          color: const Color(0xFFF5C542),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF5C542).withValues(
                                alpha: 0.4,
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
