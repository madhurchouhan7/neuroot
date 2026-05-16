import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/user_provider.dart';
import '../providers/focus_provider.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focus = ref.watch(focusProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1A16), // bloom-night
      body: SafeArea(
        child: focus.phase == FocusPhase.idle
            ? _IdleState(ref: ref, focus: focus)
            : _ActiveState(ref: ref, focus: focus),
      ),
    );
  }
}

class _IdleState extends StatelessWidget {
  final WidgetRef ref;
  final FocusState focus;

  const _IdleState({required this.ref, required this.focus});

  @override
  Widget build(BuildContext context) {
    // Basic idle state mapped to dark theme
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('FOCUS MODE', style: AppTypography.labelSmall(color: const Color(0xFF6B6560)).copyWith(letterSpacing: 1.5, fontSize: 11)),
              const Icon(Icons.settings, color: Color(0xFF6B6560), size: 20),
            ],
          ),
          const Spacer(),
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: Color(0xFF272420), // night card
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('🌱', style: TextStyle(fontSize: 72)),
          ),
          const SizedBox(height: 24),
          Text(
            'Ready to focus?',
            style: AppTypography.titleXL(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Sprout will study beside you.',
            style: AppTypography.bodyMedium(color: const Color(0xFF6B6560)),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => ref.read(focusProvider.notifier).startFocus(),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'Start Session',
                style: AppTypography.titleMedium(color: const Color(0xFF1C1A16)).copyWith(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ActiveState extends StatelessWidget {
  final WidgetRef ref;
  final FocusState focus;

  const _ActiveState({required this.ref, required this.focus});

  @override
  Widget build(BuildContext context) {
    final isBreak = focus.phase == FocusPhase.breakTime;
    final isCompleted = focus.phase == FocusPhase.completed;

    if (isCompleted) {
      return _CompletedState(ref: ref, focus: focus);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => ref.read(focusProvider.notifier).reset(),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back, color: Color(0xFF6B6560), size: 18),
                    const SizedBox(width: 4),
                    Text('Exit', style: AppTypography.bodySmall(color: const Color(0xFF6B6560))),
                  ],
                ),
              ),
              Text(
                'FOCUS MODE',
                style: AppTypography.labelSmall(color: const Color(0xFF6B6560)).copyWith(letterSpacing: 1.5, fontSize: 11),
              ),
              const Icon(Icons.settings, color: Color(0xFF6B6560), size: 20),
            ],
          ),
          
          const Spacer(),
          
          Text(
            isBreak ? 'BREAK TIME' : 'SPROUT IS FOCUSED!',
            style: AppTypography.labelSmall(color: const Color(0xFF6B6560)).copyWith(letterSpacing: 1.5, fontSize: 11),
          ),
          const SizedBox(height: 8),
          
          // Sprout image with glow
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: isBreak ? AppColors.sageDark : AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isBreak ? AppColors.sageDark : AppColors.primaryContainer).withValues(alpha: 0.2),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                ),
                NeurootNetworkImage(
                  url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBXNerXP1G6X3A4IkM1-sZgIDU5pg_S9Mqid8sIA3oJQngA4P3lp9fiM8n8UPRxAa5Pu58pUIZDfdD0Dh6v84a9mtjuHMHMUdNzPLD73L4GzSjQ77sKanNmqkLILdcft4TFhXw5NnjUj52B8uOnuADfelGENWzX68vuzHh8RGZB8FWU-d12LSgvPUrkTowzuWqowSQtA4VIexr0VF5QUfh27OnxE9mInIqSy-c2kd-pskjBvPetgDWdQ3_c7sfHG9LnmiWe1jgT53o',
                  fit: BoxFit.contain,
                  errorIcon: Icons.eco,
                  placeholderColor: Colors.transparent,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          Text(
            isBreak ? 'RESTING' : 'STUDYING',
            style: AppTypography.labelSmall(color: const Color(0xFF6B6560)).copyWith(letterSpacing: 1.5, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            focus.taskName ?? 'Focus Session',
            style: AppTypography.titleMedium(color: AppColors.white).copyWith(fontSize: 20),
          ),
          
          const SizedBox(height: 32),
          
          // Timer Circle
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: focus.progress,
                    strokeWidth: 6,
                    backgroundColor: const Color(0xFF2A2620),
                    color: isBreak ? AppColors.sageDark : AppColors.primaryContainer,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      focus.formattedTime,
                      style: GoogleFonts.sora(fontSize: 44, fontWeight: FontWeight.w800, color: AppColors.white, letterSpacing: -1),
                    ),
                    Text(
                      isBreak ? 'BREAK' : 'FOCUS',
                      style: AppTypography.labelSmall(color: const Color(0xFF6B6560)).copyWith(letterSpacing: 1.5, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(Icons.replay, () => ref.read(focusProvider.notifier).reset(), false),
              const SizedBox(width: 24),
              _buildControlButton(Icons.pause, () => ref.read(focusProvider.notifier).pause(), true),
              const SizedBox(width: 24),
              _buildControlButton(Icons.skip_next, () {
                if (isBreak) {
                  ref.read(focusProvider.notifier).startFocus();
                } else {
                  ref.read(focusProvider.notifier).startBreak();
                }
              }, false),
            ],
          ),
          
          const Spacer(),
          
          // Stats Row
          Row(
            children: [
              Expanded(child: _buildStatCard('${focus.completedSessions}', 'SESSIONS')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('${((focus.completedSessions * focus.totalSeconds) / 3600).toStringAsFixed(1)}h', 'DEEP WORK')),
              const SizedBox(width: 12),
              Expanded(child: Consumer(
                builder: (context, ref, child) {
                  final user = ref.watch(userDocProvider).asData?.value;
                  return _buildStatCard('${user?.streak ?? 0}', 'DAY STREAK');
                },
              )),
            ],
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap, bool isPrimary) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isPrimary ? 64 : 48,
        height: isPrimary ? 64 : 48,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryContainer : const Color(0xFF2A2620),
          shape: BoxShape.circle,
          boxShadow: isPrimary ? [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: isPrimary ? const Color(0xFF1C1A16) : AppColors.white,
          size: isPrimary ? 32 : 24,
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF272420),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF302D29)),
      ),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.white)),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.labelSmall(color: const Color(0xFF6B6560)).copyWith(letterSpacing: 1.5, fontSize: 10)),
        ],
      ),
    );
  }
}

class _CompletedState extends StatelessWidget {
  final WidgetRef ref;
  final FocusState focus;

  const _CompletedState({required this.ref, required this.focus});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 24),
          Text(
            'Session Complete!',
            style: AppTypography.titleXL(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You focused for ${focus.totalSeconds ~/ 60} minutes.',
            style: AppTypography.bodyMedium(color: const Color(0xFF6B6560)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () => ref.read(focusProvider.notifier).startBreak(),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.sageDark,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                'Take a 5 min Break ☕',
                style: AppTypography.titleMedium(color: AppColors.white).copyWith(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => ref.read(focusProvider.notifier).reset(),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF6B6560)),
              ),
              alignment: Alignment.center,
              child: Text(
                'End Session',
                style: AppTypography.titleMedium(color: const Color(0xFF6B6560)).copyWith(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
