import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/auth/providers/auth_provider.dart';
import 'package:neuroot/shared/widgets/neuroot_widgets.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    // Show error snackbar if Google sign-in fails
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.errorMessage!,
              style: AppTypography.bodyMedium(color: AppColors.white),
            ),
            backgroundColor: AppColors.sageDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: Stack(
        children: [
          // Subtle top gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFECEC).withValues(alpha: 0.6),
                    AppColors.warmCream.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      // Upper Half: Illustration
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: NeurootNetworkImage(
                            url:
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuBtqCJ0D9j0iHPKOkOCN8o0ljXWRLEPE52Qd6bN0p6q31ukIr6EQxib9kf1bmcmDNuy64Xm8hA4gAUOEKhqUjRt_fPLPb5feo705OU5a2lCZ4EdFjKOKAKGohEDv05xrSSrB5JBsDe2xlbwHqRoACGdXEkNjwAlmlE0CCog26ilEXoEKaehgGgWfHXUZ4mxtQvj5fKEYzf4XvUcC_tsXupWCsY3cSsB9zn0Bp8OxE6M__tyy9e9wnHWTc6rxi1z4Gh7WL_sdYdkl6Q',
                            fit: BoxFit.contain,
                            errorIcon: Icons.eco,
                            placeholderColor: Colors.transparent,
                          ),
                        ),
                      ),

                      // Lower Half: Content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Branding
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.eco,
                                  color: AppColors.primaryContainer,
                                  size: 36,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'neuroot',
                                  style: AppTypography.titleXL(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your cozy study companion',
                              style: AppTypography.mascotSpeech(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Track attendance, plan exams, and study without burning out — all in one place.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMedium(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Get Started
                            NeurootButton(
                              label: "Get Started!",
                              backgroundColor: AppColors.primaryContainer,
                              textColor: AppColors.textPrimary,
                              icon: const Icon(
                                Icons.arrow_forward,
                                size: 20,
                                color: AppColors.textPrimary,
                              ),
                              onTap: isLoading
                                  ? null
                                  : () => context.push('/signup'),
                            ),
                            const SizedBox(height: 12),

                            // Google Button
                            GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () => ref
                                        .read(authNotifierProvider.notifier)
                                        .signInWithGoogle(),
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isLoading
                                      ? AppColors.softGrey
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE8E0D4),
                                    width: 1.5,
                                  ),
                                ),
                                child: isLoading
                                    ? const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.sageDark,
                                          ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          NeurootNetworkImage(
                                            url:
                                                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                            width: 24,
                                            height: 24,
                                            fit: BoxFit.contain,
                                            errorIcon: Icons.g_mobiledata,
                                            placeholderColor:
                                                Colors.transparent,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Continue with Google',
                                            style: AppTypography.buttonMedium(
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Sign In Link
                            GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () => context.push('/signin'),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RichText(
                                  text: TextSpan(
                                    style: AppTypography.bodyMedium(
                                      color: AppColors.textSecondary,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Already have an account? ',
                                      ),
                                      TextSpan(
                                        text: 'Sign in',
                                        style: AppTypography.bodyMedium(
                                          color: AppColors.textPrimary,
                                        ).copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                            Text(
                              'By continuing, you agree to our Terms & Privacy Policy.',
                              style: AppTypography.labelSmall(
                                color: const Color(0xFFC8C0B8),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
