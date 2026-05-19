import 'dart:async';

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
import '../../planning/providers/task_provider.dart';
import '../../settings/providers/settings_provider.dart';

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
          : (focus.phase == FocusPhase.breakTime
                ? const Color(0xFF2E1C0C)
                : const Color(0xFF14120F)),
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

class _ActiveState extends ConsumerStatefulWidget {
  final FocusState focus;

  const _ActiveState({
    required this.focus,
    required ValueKey<String> key,
    required WidgetRef ref,
  });

  @override
  ConsumerState<_ActiveState> createState() => _ActiveStateState();
}

class _ActiveStateState extends ConsumerState<_ActiveState> {
  Timer? _inactivityTimer;
  bool _showNudge = false;

  @override
  void initState() {
    super.initState();
    _resetInactivityTimer();
  }

  @override
  void didUpdateWidget(covariant _ActiveState oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset inactivity timer if pause/break states change
    if (oldWidget.focus.isPaused != widget.focus.isPaused ||
        oldWidget.focus.phase != widget.focus.phase) {
      _resetInactivityTimer();
    }
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    // Do not nudge if paused or if in break mode
    if (widget.focus.isPaused || widget.focus.phase == FocusPhase.breakTime) {
      if (_showNudge) {
        setState(() => _showNudge = false);
      }
      return;
    }

    _inactivityTimer = Timer(const Duration(seconds: 20), () {
      if (mounted &&
          !widget.focus.isPaused &&
          widget.focus.phase == FocusPhase.focusing) {
        setState(() => _showNudge = true);
        HapticFeedback.vibrate();
      }
    });
  }

  void _handleUserInteraction() {
    if (_showNudge) {
      setState(() => _showNudge = false);
    }
    _resetInactivityTimer();
  }

  Future<void> _handleExit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF272420),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Text('🍂 ', style: TextStyle(fontSize: 22)),
              Text(
                'Abandon Session?',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            "Leaving focus mode mid-session will forfeit this timer's progress and Sprout will stop studying. Abandon anyway? 🌱",
            style: TextStyle(color: Color(0xFFB5AFA8), height: 1.4),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Keep Focusing',
                style: TextStyle(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFECEC),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Abandon',
                style: TextStyle(
                  color: Color(0xFFE05C5C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      ref.read(focusProvider.notifier).reset();
    }
  }

  Future<void> _handleRestart() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF272420),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Text('🔄 ', style: TextStyle(fontSize: 22)),
              Text(
                'Restart Session?',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            "This will reset the focus timer back to the beginning. Your current session progress will be lost. Restart anyway?",
            style: TextStyle(color: Color(0xFFB5AFA8), height: 1.4),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFFB5AFA8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Restart',
                style: TextStyle(
                  color: Color(0xFF1C1A16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      ref.read(focusProvider.notifier).startFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBreak = widget.focus.phase == FocusPhase.breakTime;
    final isCompleted = widget.focus.phase == FocusPhase.completed;

    if (isCompleted) {
      return _CompletedState(focus: widget.focus);
    }

    final cardBgColor = isBreak
        ? const Color(0xFF452C16)
        : const Color(0xFF272420);
    final cardBorderColor = isBreak
        ? const Color(0xFF5D3F23)
        : const Color(0xFF302D29);
    final progressColor = isBreak
        ? const Color(0xFFFF9E00)
        : AppColors.primaryContainer;

    return Listener(
      onPointerDown: (_) => _handleUserInteraction(),
      child: Stack(
        children: [
          CustomScrollView(
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
                            onTap: _handleExit,
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
                        isBreak ? '☕ BREAK TIME' : 'SPROUT IS FOCUSED!',
                        style: AppTypography.labelSmall(
                          color: isBreak
                              ? const Color(0xFFFFB703)
                              : const Color(0xFF6B6560),
                        ).copyWith(letterSpacing: 1.5, fontSize: 11),
                      ),
                      const SizedBox(height: 8),

                      // Sprout image with dynamic break animation
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
                                      ? const Color(0xFFFFB703)
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
                                  ? _SwayingBreakSprout(
                                      child: Transform.scale(
                                        scaleX: 1.3,
                                        scaleY: 0.85,
                                        child: const NeurootNetworkImage(
                                          url:
                                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBXNerXP1G6X3A4IkM1-sZgIDU5pg_S9Mqid8sIA3oJQngA4P3lp9fiM8n8UPRxAa5Pu58pUIZDfdD0Dh6v84a9mtjuHMHMUdNzPLD73L4GzSjQ77sKanNmqkLILdcft4TFhXw5NnjUj52B8uOnuADfelGENWzX68vuzHh8RGZB8FWU-d12LSgvPUrkTowzuWqowSQtA4VIexr0VF5QUfh27OnxE9mInIqSy-c2kd-pskjBvPetgDWdQ3_c7sfHG9LnmiWe1jgT53o',
                                          fit: BoxFit.contain,
                                          errorIcon: Icons.eco,
                                          placeholderColor: Colors.transparent,
                                        ),
                                      ),
                                    )
                                  : const NeurootNetworkImage(
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
                        widget.focus.taskName ?? 'Focus Session',
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
                                  value: widget.focus.progress,
                                  strokeWidth: 6,
                                  backgroundColor: isBreak
                                      ? const Color(0xFF382312)
                                      : const Color(0xFF2A2620),
                                  color: progressColor,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.focus.formattedTime,
                                    style: GoogleFonts.sora(
                                      fontSize: 44,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.white,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  Text(
                                    isBreak ? 'BREAK' : 'FOCUS',
                                    style:
                                        AppTypography.labelSmall(
                                          color: isBreak
                                              ? const Color(0xFFFFB703)
                                              : const Color(0xFF6B6560),
                                        ).copyWith(
                                          letterSpacing: 1.5,
                                          fontSize: 11,
                                        ),
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
                            _handleRestart,
                            false,
                            isBreak: isBreak,
                          ),
                          const SizedBox(width: 24),
                          _buildControlButton(
                            widget.focus.isPaused
                                ? Icons.play_arrow
                                : Icons.pause,
                            () {
                              if (widget.focus.isPaused) {
                                ref.read(focusProvider.notifier).resume();
                              } else {
                                ref.read(focusProvider.notifier).pause();
                              }
                            },
                            true,
                            isBreak: isBreak,
                          ),
                          const SizedBox(width: 24),
                          _buildControlButton(
                            Icons.skip_next,
                            () {
                              if (isBreak) {
                                ref.read(focusProvider.notifier).startFocus();
                              } else {
                                ref.read(focusProvider.notifier).startBreak();
                              }
                            },
                            false,
                            isBreak: isBreak,
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              '${widget.focus.completedSessions}',
                              'SESSIONS',
                              cardBgColor: cardBgColor,
                              cardBorderColor: cardBorderColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              '${((widget.focus.completedSessions * widget.focus.totalSeconds) / 3600).toStringAsFixed(1)}h',
                              'DEEP WORK',
                              cardBgColor: cardBgColor,
                              cardBorderColor: cardBorderColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Consumer(
                              builder: (context, ref, child) {
                                final user = ref
                                    .watch(userDocProvider)
                                    .asData
                                    ?.value;
                                return _buildStatCard(
                                  '${user?.streak ?? 0}',
                                  'DAY STREAK',
                                  cardBgColor: cardBgColor,
                                  cardBorderColor: cardBorderColor,
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
          ),

          // Distraction Nudge Overlay
          if (_showNudge)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.85),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📱🌱', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 24),
                    Text(
                      "Sprout notices you've drifted!",
                      style: AppTypography.titleMedium(color: AppColors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Keep your hands off the screen and eyes on the prize to earn your Focus XP! Sprout is study-buddy waiting for you. 🌱",
                      style: AppTypography.bodyMedium(
                        color: const Color(0xFFB5AFA8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    BounceButton(
                      onTap: () {
                        setState(() {
                          _showNudge = false;
                        });
                        _resetInactivityTimer();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "I'm Focusing! 🏃‍♂️",
                          style: AppTypography.buttonMedium(
                            color: const Color(0xFF1C1A16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon,
    VoidCallback onTap,
    bool isPrimary, {
    required bool isBreak,
  }) {
    final activeColor = isBreak
        ? const Color(0xFFFFB703)
        : AppColors.primaryContainer;
    return BounceButton(
      onTap: onTap,
      child: Container(
        width: isPrimary ? 64 : 48,
        height: isPrimary ? 64 : 48,
        decoration: BoxDecoration(
          color: isPrimary
              ? activeColor
              : (isBreak ? const Color(0xFF452C16) : const Color(0xFF2A2620)),
          shape: BoxShape.circle,
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
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

  Widget _buildStatCard(
    String value,
    String label, {
    required Color cardBgColor,
    required Color cardBorderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor),
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

class _CompletedState extends ConsumerStatefulWidget {
  final FocusState focus;

  const _CompletedState({required this.focus});

  @override
  ConsumerState<_CompletedState> createState() => _CompletedStateState();
}

class _CompletedStateState extends ConsumerState<_CompletedState> {
  String? _selectedTaskId;
  bool _markAsCompleted = false;
  bool _isClaiming = false;

  Future<void> _onClaim() async {
    setState(() => _isClaiming = true);
    try {
      // 1. Save focus session persistence & award basic focus XP
      await ref
          .read(focusSessionProvider.notifier)
          .saveSession(
            durationMinutes: widget.focus.totalSeconds ~/ 60,
            sessionsCompleted: 1,
            linkedTaskId: _selectedTaskId,
          );

      // 2. Mark linked task completed if toggled
      if (_selectedTaskId != null && _markAsCompleted) {
        await ref
            .read(taskNotifierProvider.notifier)
            .toggleComplete(_selectedTaskId!, isCompleted: true);
      }

      // 3. Reset focus provider state
      ref.read(focusProvider.notifier).reset();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error claiming session: $e')));
    } finally {
      if (mounted) setState(() => _isClaiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userDocProvider).asData?.value;
    final xpEarned = widget.focus.totalSeconds ~/ 60; // 1 XP per minute focused
    final tasksAsync = ref.watch(tasksStreamProvider);

    final tasks = tasksAsync.asData?.value ?? [];
    final incompleteTasks = tasks.where((t) => !t.isCompleted).toList();

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
                  style: AppTypography.titleXL(
                    color: AppColors.white,
                  ).copyWith(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'You focused deeply for ${widget.focus.totalSeconds ~/ 60} minutes.\nGreat job staying on track.',
                  style: AppTypography.bodyMedium(
                    color: const Color(0xFF8B857F),
                  ).copyWith(height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Achievements Card (Streak milestones + XP)
                Container(
                  padding: const EdgeInsets.all(20),
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
                                  color: const Color(
                                    0xFFFFB703,
                                  ).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: Color(0xFFFFB703),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'XP Earned',
                                style: AppTypography.titleMedium(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '+$xpEarned XP',
                            style: AppTypography.titleMedium(
                              color: const Color(0xFFFFB703),
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
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
                                  color: const Color(
                                    0xFFFF8A65,
                                  ).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Color(0xFFFF8A65),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Current Streak',
                                style: AppTypography.titleMedium(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${user?.streak ?? 1} Days',
                            style: AppTypography.titleMedium(
                              color: const Color(0xFFFF8A65),
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Custom Task Status Linkage Section
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1A16),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF38342F)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LINK TO A TASK 🌱',
                        style: AppTypography.labelSmall(
                          color: const Color(0xFF6B6560),
                        ).copyWith(letterSpacing: 1.2, fontSize: 10),
                      ),
                      const SizedBox(height: 12),
                      incompleteTasks.isEmpty
                          ? Text(
                              'No active tasks. Just claim your XP!',
                              style: AppTypography.bodySmall(
                                color: const Color(0xFF8B857F),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF272420),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF38342F),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedTaskId,
                                  hint: Text(
                                    'Select a task you focused on',
                                    style: AppTypography.bodyMedium(
                                      color: const Color(0xFF6B6560),
                                    ),
                                  ),
                                  dropdownColor: const Color(0xFF272420),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color(0xFF6B6560),
                                  ),
                                  isExpanded: true,
                                  items: incompleteTasks.map((t) {
                                    return DropdownMenuItem<String>(
                                      value: t.id,
                                      child: Text(
                                        t.title,
                                        style: AppTypography.bodyMedium(
                                          color: AppColors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedTaskId = val;
                                      if (val == null) _markAsCompleted = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                      if (_selectedTaskId != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mark task as completed (+10 XP)',
                              style: AppTypography.bodyMedium(
                                color: AppColors.white,
                              ),
                            ),
                            Switch(
                              value: _markAsCompleted,
                              activeColor: AppColors.primaryContainer,
                              activeTrackColor: AppColors.primaryContainer
                                  .withValues(alpha: 0.2),
                              inactiveThumbColor: const Color(0xFF6B6560),
                              inactiveTrackColor: const Color(0xFF272420),
                              onChanged: (val) {
                                setState(() => _markAsCompleted = val);
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const Spacer(),

                _isClaiming
                    ? const CircularProgressIndicator(
                        color: AppColors.primaryContainer,
                      )
                    : Column(
                        children: [
                          BounceButton(
                            onTap: () =>
                                ref.read(focusProvider.notifier).startBreak(),
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
                          const SizedBox(height: 12),
                          BounceButton(
                            onTap: _onClaim,
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFF272420),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF38342F),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _selectedTaskId != null
                                    ? 'Claim & Link Session'
                                    : 'Claim & End Session',
                                style: AppTypography.titleMedium(
                                  color: AppColors.white,
                                ).copyWith(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SwayingBreakSprout extends StatefulWidget {
  final Widget child;
  const _SwayingBreakSprout({required this.child});

  @override
  State<_SwayingBreakSprout> createState() => _SwayingBreakSproutState();
}

class _SwayingBreakSproutState extends State<_SwayingBreakSprout>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _translationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _translationAnimation = Tween<double>(
      begin: -4.0,
      end: 4.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _translationAnimation.value),
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: widget.child,
          ),
        );
      },
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
    final settings = ref.watch(settingsProvider);

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
                focus.isDeepFocus
                    ? Icons.do_not_disturb_on
                    : Icons.do_not_disturb_off,
                color: focus.isDeepFocus
                    ? const Color(0xFFFF8A65)
                    : const Color(0xFF6B6560),
                size: 20,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deep Focus Mode',
                    style: AppTypography.titleMedium(
                      color: AppColors.white,
                    ).copyWith(fontSize: 14),
                  ),
                  Text(
                    'Keeps screen on & mutes alerts',
                    style: AppTypography.labelSmall(
                      color: const Color(0xFF6B6560),
                    ).copyWith(fontSize: 10),
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
              if (!settings.notificationsEnabled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Notifications are turned off. You need to turn it ON from Settings! 🔔',
                    ),
                    backgroundColor: const Color(0xFFFF8A65),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                return;
              }
              ref.read(focusProvider.notifier).toggleDeepFocus();
              if (val) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Deep Focus ON: Please put your phone on silent mode! 🤫',
                    ),
                    backgroundColor: const Color(0xFFFF8A65),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
    final settings = ref.watch(settingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AMBIENT SOUND',
          style: AppTypography.labelSmall(
            color: const Color(0xFF6B6560),
          ).copyWith(letterSpacing: 1.5, fontSize: 11),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SoundOption(
              icon: Icons.volume_off_rounded,
              label: 'None',
              isSelected: focus.ambientSound == AmbientSound.none,
              onTap: () => ref
                  .read(focusProvider.notifier)
                  .setAmbientSound(AmbientSound.none),
            ),
            _SoundOption(
              icon: Icons.water_drop_rounded,
              label: 'Rain',
              isSelected: focus.ambientSound == AmbientSound.rain,
              onTap: () {
                if (!settings.focusSoundsEnabled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Focus sounds are turned off. You need to turn it ON from Settings! 🎧',
                      ),
                      backgroundColor: const Color(0xFFFF8A65),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  return;
                }
                ref
                    .read(focusProvider.notifier)
                    .setAmbientSound(AmbientSound.rain);
              },
            ),
            _SoundOption(
              icon: Icons.forest_rounded,
              label: 'Forest',
              isSelected: focus.ambientSound == AmbientSound.forest,
              onTap: () {
                if (!settings.focusSoundsEnabled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Focus sounds are turned off. You need to turn it ON from Settings! 🎧',
                      ),
                      backgroundColor: const Color(0xFFFF8A65),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  return;
                }
                ref
                    .read(focusProvider.notifier)
                    .setAmbientSound(AmbientSound.forest);
              },
            ),
            _SoundOption(
              icon: Icons.local_fire_department_rounded,
              label: 'Fire',
              isSelected: focus.ambientSound == AmbientSound.fire,
              onTap: () {
                if (!settings.focusSoundsEnabled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Focus sounds are turned off. You need to turn it ON from Settings! 🎧',
                      ),
                      backgroundColor: const Color(0xFFFF8A65),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  return;
                }
                ref
                    .read(focusProvider.notifier)
                    .setAmbientSound(AmbientSound.fire);
              },
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
    final color = isSelected
        ? AppColors.primaryContainer
        : const Color(0xFF6B6560);
    final bgColor = isSelected
        ? AppColors.primaryContainer.withValues(alpha: 0.1)
        : const Color(0xFF1C1A16);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryContainer.withValues(alpha: 0.3)
                : const Color(0xFF38342F),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.labelSmall(
                color: color,
              ).copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
