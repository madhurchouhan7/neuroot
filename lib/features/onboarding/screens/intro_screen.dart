import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/onboarding/widgets/welcome_step.dart';
import 'package:neuroot/features/onboarding/widgets/semester_setup_step.dart';
import 'package:neuroot/features/onboarding/widgets/timetable_builder_step.dart';
import 'package:neuroot/features/onboarding/widgets/meet_sprout_step.dart';
import 'package:neuroot/shared/widgets/neuroot_confetti.dart';

/// Pre-auth intro onboarding — 4 pages:
///   0. Welcome to Neuroot
///   1. Set up your semester  (functional, data stored in Riverpod)
///   2. Build your timetable  (functional, data stored in Riverpod)
///   3. Meet Sprout
/// Navigates to /landing on completion.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  static const int _totalPages = 4;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go('/landing');
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
      context.go('/landing');
    }
  }

  void _skip() => _showSkipConfirmationDialog();

  void _back() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: _back,
                    child: AnimatedOpacity(
                      opacity: _currentPage > 0 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.arrow_back,
                            color: AppColors.textPrimary, size: 22),
                      ),
                    ),
                  ),

                  // Progress dots
                  Row(
                    children: List.generate(_totalPages, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.amber
                              : const Color(0xFFD1C5AE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Skip button
                  GestureDetector(
                    onTap: _skip,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(
                        'Skip',
                        style: AppTypography.labelLarge(
                          color: const Color(0xFF7F7662),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Pages ────────────────────────────────────────────────────────
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
}
