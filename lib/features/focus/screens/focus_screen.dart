import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/user_provider.dart';
import '../providers/focus_provider.dart';
import '../../../shared/widgets/bounce_button.dart';
import '../../../shared/widgets/ambient_motion.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  @override
  Widget build(BuildContext context) {
    final focus = ref.watch(focusProvider);

    // Enter immersive mode if focusing, exit if idle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focus.phase != FocusPhase.idle) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });

    return Scaffold(
      backgroundColor: focus.phase == FocusPhase.idle
          ? const Color(0xFF272420)
          : const Color(0xFF14120F),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: focus.phase == FocusPhase.idle
              ? _IdleState(key: const ValueKey('idle'), ref: ref, focus: focus)
              : _ActiveState(
                  key: const ValueKey('active'),
                  ref: ref,
                  focus: focus,
                ),
        ),
      ),
    );
  }
}

class _IdleState extends StatelessWidget {
  final WidgetRef ref;
  final FocusState focus;

  const _IdleState({
    required this.ref,
    required this.focus,
    required ValueKey<String> key,
  });

  @override
  Widget build(BuildContext context) {
    // Basic idle state mapped to dark theme
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FOCUS MODE',
                      style: AppTypography.labelSmall(
                        color: const Color(0xFF6B6560),
                      ).copyWith(letterSpacing: 1.5, fontSize: 11),
                    ),
                    const Icon(
                      Icons.settings,
                      color: Color(0xFF6B6560),
                      size: 20,
                    ),
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
                  style: AppTypography.bodyMedium(
                    color: const Color(0xFF6B6560),
                  ),
                ),
                const SizedBox(height: 32),

                // Ambient Sound Selector
                _AmbientSoundSelector(focus: focus, ref: ref),
                const SizedBox(height: 16),

                // Deep Focus Toggle
                _DeepFocusToggle(focus: focus, ref: ref),

                const Spacer(),
                GlowPulseWidget(
                  glowColor: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  child: BounceButton(
                    onTap: () => ref.read(focusProvider.notifier).startFocus(),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryContainer.withValues(
                              alpha: 0.2,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Start Session',
                        style: AppTypography.titleMedium(
                          color: const Color(0xFF1C1A16),
                        ).copyWith(fontSize: 16),
                      ),
                    ),
                  ),
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

class _ActiveState extends StatelessWidget {
  final WidgetRef ref;
  final FocusState focus;

  const _ActiveState({
    required this.ref,
    required this.focus,
    required ValueKey<String> key,
  });

  @override
  Widget build(BuildContext context) {
    final isBreak = focus.phase == FocusPhase.breakTime;
    final isCompleted = focus.phase == FocusPhase.completed;

    if (isCompleted) {
      return _CompletedState(ref: ref, focus: focus);
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BounceButton(
                      onTap: () => ref.read(focusProvider.notifier).reset(),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF6B6560),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Exit',
                            style: AppTypography.bodySmall(
                              color: const Color(0xFF6B6560),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'FOCUS MODE',
                      style: AppTypography.labelSmall(
                        color: const Color(0xFF6B6560),
                      ).copyWith(letterSpacing: 1.5, fontSize: 11),
                    ),
                    const Icon(
                      Icons.settings,
                      color: Color(0xFF6B6560),
                      size: 20,
                    ),
                  ],
                ),

                const Spacer(),

                Text(
                  isBreak ? 'BREAK TIME' : 'SPROUT IS FOCUSED!',
                  style: AppTypography.labelSmall(
                    color: const Color(0xFF6B6560),
                  ).copyWith(letterSpacing: 1.5, fontSize: 11),
                ),
                const SizedBox(height: 8),

                // Sprout image with glow
                BreathingWidget(
                  duration: const Duration(seconds: 4),
                  child: SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: isBreak
                                ? const Color(0xFFFFB703) // Warm amber for break
                                : AppColors.primaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isBreak
                                            ? const Color(0xFFFFB703)
                                            : AppColors.primaryContainer)
                                        .withValues(alpha: 0.2),
                                blurRadius: 40,
                              ),
                            ],
                          ),
                        ),
                        isBreak
                            ? Transform.scale(
                                scaleX: 1.3,
                                scaleY: 0.85,
                                child: NeurootNetworkImage(
                                  url:
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBXNerXP1G6X3A4IkM1-sZgIDU5pg_S9Mqid8sIA3oJQngA4P3lp9fiM8n8UPRxAa5Pu58pUIZDfdD0Dh6v84a9mtjuHMHMUdNzPLD73L4GzSjQ77sKanNmqkLILdcft4TFhXw5NnjUj52B8uOnuADfelGENWzX68vuzHh8RGZB8FWU-d12LSgvPUrkTowzuWqowSQtA4VIexr0VF5QUfh27OnxE9mInIqSy-c2kd-pskjBvPetgDWdQ3_c7sfHG9LnmiWe1jgT53o',
                                  fit: BoxFit.contain,
                                  errorIcon: Icons.eco,
                                  placeholderColor: Colors.transparent,
                                ),
                              )
                            : NeurootNetworkImage(
                                url:
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBXNerXP1G6X3A4IkM1-sZgIDU5pg_S9Mqid8sIA3oJQngA4P3lp9fiM8n8UPRxAa5Pu58pUIZDfdD0Dh6v84a9mtjuHMHMUdNzPLD73L4GzSjQ77sKanNmqkLILdcft4TFhXw5NnjUj52B8uOnuADfelGENWzX68vuzHh8RGZB8FWU-d12LSgvPUrkTowzuWqowSQtA4VIexr0VF5QUfh27OnxE9mInIqSy-c2kd-pskjBvPetgDWdQ3_c7sfHG9LnmiWe1jgT53o',
                                fit: BoxFit.contain,
                                errorIcon: Icons.eco,
                                placeholderColor: Colors.transparent,
                              ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  isBreak ? 'RESTING' : 'STUDYING',
                  style: AppTypography.labelSmall(
                    color: const Color(0xFF6B6560),
                  ).copyWith(letterSpacing: 1.5, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  focus.taskName ?? 'Focus Session',
                  style: AppTypography.titleMedium(
                    color: AppColors.white,
                  ).copyWith(fontSize: 20),
                ),

                const SizedBox(height: 32),

                // Timer Circle
                BreathingWidget(
                  duration: const Duration(seconds: 5),
                  scaleTarget: 1.02,
                  child: SizedBox(
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
                            color: isBreak
                                ? const Color(0xFFFFB703) // Warm amber
                                : AppColors.primaryContainer,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              focus.formattedTime,
                              style: GoogleFonts.sora(
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              isBreak ? 'BREAK' : 'FOCUS',
                              style: AppTypography.labelSmall(
                                color: const Color(0xFF6B6560),
                              ).copyWith(letterSpacing: 1.5, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(
                      Icons.replay,
                      () => ref.read(focusProvider.notifier).reset(),
                      false,
                    ),
                    const SizedBox(width: 24),
                    _buildControlButton(
                      focus.isPaused ? Icons.play_arrow : Icons.pause,
                      () {
                        if (focus.isPaused) {
                          ref.read(focusProvider.notifier).resume();
                        } else {
                          ref.read(focusProvider.notifier).pause();
                        }
                      },
                      true,
                    ),
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
                    Expanded(
                      child: _buildStatCard(
                        '${focus.completedSessions}',
                        'SESSIONS',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '${((focus.completedSessions * focus.totalSeconds) / 3600).toStringAsFixed(1)}h',
                        'DEEP WORK',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final user = ref.watch(userDocProvider).asData?.value;
                          return _buildStatCard(
                            '${user?.streak ?? 0}',
                            'DAY STREAK',
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(
    IconData icon,
    VoidCallback onTap,
    bool isPrimary,
  ) {
    return BounceButton(
      onTap: onTap,
      child: Container(
        width: isPrimary ? 64 : 48,
        height: isPrimary ? 64 : 48,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primaryContainer
              : const Color(0xFF2A2620),
          shape: BoxShape.circle,
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
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
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall(
              color: const Color(0xFF6B6560),
            ).copyWith(letterSpacing: 1.5, fontSize: 10),
          ),
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
    final user = ref.watch(userDocProvider).asData?.value;
    final xpEarned = focus.totalSeconds ~/ 60; // 1 XP per minute focused
    
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text('🏆', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 24),
                Text(
                  'Focus Complete!',
                  style: AppTypography.titleXL(color: AppColors.white).copyWith(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'You focused deeply for ${focus.totalSeconds ~/ 60} minutes.\nGreat job staying on track.',
                  style: AppTypography.bodyMedium(
                    color: const Color(0xFF8B857F),
                  ).copyWith(height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Achievements Dashboard
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF272420),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF38342F)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB703).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.bolt_rounded, color: Color(0xFFFFB703), size: 24),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'XP Earned',
                                style: AppTypography.titleMedium(color: AppColors.white),
                              ),
                            ],
                          ),
                          Text(
                            '+$xpEarned XP',
                            style: AppTypography.titleMedium(color: const Color(0xFFFFB703))
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: Color(0xFF38342F), height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF8A65).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF8A65), size: 24),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Current Streak',
                                style: AppTypography.titleMedium(color: AppColors.white),
                              ),
                            ],
                          ),
                          Text(
                            '${user?.streak ?? 1} Days',
                            style: AppTypography.titleMedium(color: const Color(0xFFFF8A65))
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                BounceButton(
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
                      style: AppTypography.titleMedium(
                        color: AppColors.white,
                      ).copyWith(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                BounceButton(
                  onTap: () {
                    // In a real app we'd dispatch XP update here, e.g. ref.read(userDocProvider.notifier).addXp(xpEarned);
                    ref.read(focusProvider.notifier).reset();
                  },
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF272420),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF38342F)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Claim & End Session',
                      style: AppTypography.titleMedium(
                        color: AppColors.white,
                      ).copyWith(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Toggles & Selectors ──────────────────────────────────────────────────

class _DeepFocusToggle extends StatelessWidget {
  final FocusState focus;
  final WidgetRef ref;

  const _DeepFocusToggle({required this.focus, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1A16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38342F)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                focus.isDeepFocus ? Icons.do_not_disturb_on : Icons.do_not_disturb_off,
                color: focus.isDeepFocus ? const Color(0xFFFF8A65) : const Color(0xFF6B6560),
                size: 20,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deep Focus Mode',
                    style: AppTypography.titleMedium(color: AppColors.white).copyWith(fontSize: 14),
                  ),
                  Text(
                    'Keeps screen on & mutes alerts',
                    style: AppTypography.labelSmall(color: const Color(0xFF6B6560)).copyWith(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: focus.isDeepFocus,
            activeColor: const Color(0xFFFF8A65),
            activeTrackColor: const Color(0xFFFF8A65).withValues(alpha: 0.2),
            inactiveThumbColor: const Color(0xFF6B6560),
            inactiveTrackColor: const Color(0xFF272420),
            onChanged: (val) {
              ref.read(focusProvider.notifier).toggleDeepFocus();
              if (val) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Deep Focus ON: Please put your phone on silent mode! 🤫'),
                    backgroundColor: const Color(0xFFFF8A65),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _AmbientSoundSelector extends StatelessWidget {
  final FocusState focus;
  final WidgetRef ref;

  const _AmbientSoundSelector({required this.focus, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AMBIENT SOUND',
          style: AppTypography.labelSmall(color: const Color(0xFF6B6560))
              .copyWith(letterSpacing: 1.5, fontSize: 11),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SoundOption(
              icon: Icons.volume_off_rounded,
              label: 'None',
              isSelected: focus.ambientSound == AmbientSound.none,
              onTap: () => ref.read(focusProvider.notifier).setAmbientSound(AmbientSound.none),
            ),
            _SoundOption(
              icon: Icons.water_drop_rounded,
              label: 'Rain',
              isSelected: focus.ambientSound == AmbientSound.rain,
              onTap: () => ref.read(focusProvider.notifier).setAmbientSound(AmbientSound.rain),
            ),
            _SoundOption(
              icon: Icons.forest_rounded,
              label: 'Forest',
              isSelected: focus.ambientSound == AmbientSound.forest,
              onTap: () => ref.read(focusProvider.notifier).setAmbientSound(AmbientSound.forest),
            ),
            _SoundOption(
              icon: Icons.local_fire_department_rounded,
              label: 'Fire',
              isSelected: focus.ambientSound == AmbientSound.fire,
              onTap: () => ref.read(focusProvider.notifier).setAmbientSound(AmbientSound.fire),
            ),
          ],
        ),
      ],
    );
  }
}

class _SoundOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SoundOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primaryContainer : const Color(0xFF6B6560);
    final bgColor = isSelected ? AppColors.primaryContainer.withValues(alpha: 0.1) : const Color(0xFF1C1A16);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.3) : const Color(0xFF38342F),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.labelSmall(color: color).copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

