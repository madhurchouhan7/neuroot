import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/features/onboarding/providers/onboarding_provider.dart';
import 'package:neuroot/shared/widgets/neuroot_confetti.dart';

import '../widgets/welcome_step.dart';
import '../widgets/semester_setup_step.dart';
import '../widgets/timetable_builder_step.dart';
import '../widgets/meet_sprout_step.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_currentPage < 2) {
      // Steps 0–2: just advance the page
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else if (_currentPage == 2) {
      // Step 3 (TimetableBuilder → MeetSprout):
      // Save semester data to Firestore before showing final step
      final ok = await ref.read(onboardingProvider.notifier).createSemester();
      if (ok && mounted) {
        _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      } else if (!ok && mounted) {
        final err = ref.read(onboardingProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? "Couldn't save. Try again 🌱"),
            backgroundColor: AppColors.dangerSoftRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } else {
      // Final step (MeetSprout): mark onboarding complete → router redirects
      await ref.read(onboardingProvider.notifier).completeOnboarding();
      if (mounted) context.go('/home');
    }
  }

  Future<void> _showSkipConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF9F7F1), // Warm cream
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Text('⚠️ ', style: TextStyle(fontSize: 22)),
              Text(
                'Skip Setup?',
                style: TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            "Skipping setup means Sprout won't have your class schedule or semester boundaries to automatically track your attendance, calculate study wins, or tailor milestones.\n\nYou can set this up later in Settings, but doing it now unlocks Sprout's companion powers! Skip anyway? 🌱",
            style: TextStyle(color: Color(0xFF5A5A5A), height: 1.4),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Go Back',
                style: TextStyle(color: AppColors.sageDark, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFECEC), // Warm warning light-red
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Skip Setup',
                style: TextStyle(color: Color(0xFFE05C5C), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await ref.read(onboardingProvider.notifier).completeOnboarding();
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar for semester + timetable steps
            if (_currentPage == 1 || _currentPage == 2)
              _buildTopBar(),

            Expanded(
              child: Stack(
                children: [
                  PageView(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      WelcomeStep(onNext: _next),
                      SemesterSetupStep(onNext: _next),
                      TimetableBuilderStep(onNext: _next),
                      MeetSproutStep(onNext: _next),
                    ],
                  ),
                  if (_currentPage == 3)
                    const IgnorePointer(
                      child: NeurootConfetti(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (_currentPage > 0) {
                _pageCtrl.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back,
                  color: AppColors.textPrimary, size: 20),
            ),
          ),

          // Progress Dots
          Row(
            children: List.generate(4, (i) {
              final isActive = _currentPage == i;
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryContainer
                        : const Color(0xFFD1C5AE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),

          // Skip → marks onboarding complete
          GestureDetector(
            onTap: _showSkipConfirmationDialog,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Color(0xFF4E4634),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
