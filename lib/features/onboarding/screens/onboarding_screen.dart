import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/features/onboarding/providers/onboarding_provider.dart';

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
              child: PageView(
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
            onTap: () async {
              await ref
                  .read(onboardingProvider.notifier)
                  .completeOnboarding();
              if (mounted) context.go('/home');
            },
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
