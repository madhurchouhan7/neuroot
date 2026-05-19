import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/onboarding/providers/onboarding_provider.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';

/// Post-auth screen that auto-saves the data collected during [IntroScreen]
/// (semester, subjects, timetable) to Firestore, then navigates to /home.
///
/// Shown when user is authenticated but onboardingComplete == false.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  @override
  void initState() {
    super.initState();
    // Kick off the save as soon as the screen mounts.
    WidgetsBinding.instance.addPostFrameCallback((_) => _save());
  }

  Future<void> _save() async {
    final ok = await ref.read(onboardingProvider.notifier).createSemester();
    if (!mounted) return;
    if (ok) {
      await ref.read(onboardingProvider.notifier).completeOnboarding();
      if (mounted) context.go('/home');
    }
    // On failure the error snackbar is shown below via ref.listen
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    // Show error snackbar if save fails
    ref.listen<OnboardingState>(onboardingProvider, (_, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!,
                style: AppTypography.bodyMedium(color: AppColors.white)),
            backgroundColor: AppColors.dangerSoftRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppColors.white,
              onPressed: _save,
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeurootNetworkImage(
                url:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuD5X5WACiOWYO6he6_oCUBjc0AC4XcNXuXzm08oIoKGdBeQZSwaUWxVak3GYkHjYq_2YPYJOf1syEcHSZtMPkxHhDliA1KtgGt35iXJIRqhdpBTrgX960Z0ZzdDiKpcVTe0K5wMT19wo7wmLaZ_ZDdebt__D0qf9tAzN3WDAaFBcSD0dP3KT79HhonbOFzA5Tm93ErPzAR8qAvCaIAa8erROaE4wdMJ325unTSQrnJuYlDdVxQCI2dqnYmeOt6Blq7MZ9wqP6dAHW8',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorIcon: Icons.eco,
                placeholderColor: Colors.transparent,
              ),
              const SizedBox(height: 24),
              Text(
                state.isLoading
                    ? 'Setting up your account…'
                    : 'Almost there! 🌱',
                style: AppTypography.titleMedium(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                'We\'re saving your semester, subjects, and timetable.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(color: const Color(0xFF7F7662)),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                color: AppColors.amber,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
