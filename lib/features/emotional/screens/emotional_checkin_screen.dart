import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/neuroot_widgets.dart';
import '../providers/mood_provider.dart';

class EmotionalCheckinScreen extends ConsumerStatefulWidget {
  final VoidCallback? onDone;
  const EmotionalCheckinScreen({super.key, this.onDone});

  @override
  ConsumerState<EmotionalCheckinScreen> createState() =>
      _EmotionalCheckinScreenState();
}

class _EmotionalCheckinScreenState
    extends ConsumerState<EmotionalCheckinScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  static const _moods = [
    _MoodOption(
      mood: UserMood.happy,
      emoji: '😊',
      label: 'Happy',
      color: MoodColors.happySurface,
      activeColor: MoodColors.happy,
    ),
    _MoodOption(
      mood: UserMood.focused,
      emoji: '🎯',
      label: 'Focused',
      color: MoodColors.focusedSurface,
      activeColor: MoodColors.focused,
    ),
    _MoodOption(
      mood: UserMood.calm,
      emoji: '🍵',
      label: 'Calm',
      color: MoodColors.calmSurface,
      activeColor: MoodColors.calm,
    ),
    _MoodOption(
      mood: UserMood.anxious,
      emoji: '🌀',
      label: 'Anxious',
      color: MoodColors.anxiousSurface,
      activeColor: MoodColors.anxious,
    ),
    _MoodOption(
      mood: UserMood.overwhelmed,
      emoji: '🌧️',
      label: 'Overwhelmed',
      color: MoodColors.overwhelmedSurface,
      activeColor: MoodColors.overwhelmed,
    ),
    _MoodOption(
      mood: UserMood.burnedOut,
      emoji: '🔋',
      label: 'Burned Out',
      color: MoodColors.burnedOutSurface,
      activeColor: MoodColors.burnedOut,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(moodNotifierProvider);

    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: AppColors.warmCream,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Sprout + Greeting header ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                  child: Column(
                    children: [
                      // Sprout mascot
                      _AnimatedSprout(mood: selected),
                      const SizedBox(height: 24),
                      Text(
                        'How are you feeling today?',
                        style: AppTypography.titleXL(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Take a breath. No wrong answers here 🌱',
                        style: AppTypography.supportiveMedium(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // ── Mood grid ──────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: _moods
                      .map((m) => _MoodCard(
                            option: m,
                            isSelected: selected == m.mood,
                            onTap: () => ref
                                .read(moodNotifierProvider.notifier)
                                .setMood(m.mood),
                          ))
                      .toList(),
                ),
              ),

              // ── Sprout reaction ────────────────────────────────────────
              if (selected != UserMood.none)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: SproutSpeechBubble(
                      message: _getSproutResponse(selected),
                      backgroundColor: _getMoodSurface(selected),
                    ),
                  ),
                ),

              // ── Continue button ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: AnimatedOpacity(
                    opacity: selected != UserMood.none ? 1.0 : 0.4,
                    duration: AppTheme.durationMedium,
                    child: NeurootButton(
                      label: selected != UserMood.none
                          ? 'Let\'s go 🌱'
                          : 'Pick how you feel',
                      onTap: selected != UserMood.none
                          ? () => widget.onDone?.call()
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSproutResponse(UserMood mood) {
    switch (mood) {
      case UserMood.happy:
        return 'Love the energy! Let\'s make the most of today ✨';
      case UserMood.focused:
        return 'You\'re in the zone! A focus session will feel great 🎯';
      case UserMood.calm:
        return 'Calm and steady — the best state for deep work 🍵';
      case UserMood.anxious:
        return 'That\'s okay. Let\'s break today into tiny, easy steps 🌿';
      case UserMood.overwhelmed:
        return 'Take it one breath at a time. We\'ll figure it out together 💛';
      case UserMood.burnedOut:
        return 'Rest is part of growing. Even one small thing today counts 🌱';
      default:
        return '';
    }
  }

  Color _getMoodSurface(UserMood mood) {
    switch (mood) {
      case UserMood.happy:
        return MoodColors.happySurface;
      case UserMood.focused:
        return MoodColors.focusedSurface;
      case UserMood.calm:
        return MoodColors.calmSurface;
      case UserMood.anxious:
        return MoodColors.anxiousSurface;
      case UserMood.overwhelmed:
        return MoodColors.overwhelmedSurface;
      case UserMood.burnedOut:
        return MoodColors.burnedOutSurface;
      default:
        return AppColors.sageSurface;
    }
  }
}

// ─── Animated Sprout ──────────────────────────────────────────────────────────
class _AnimatedSprout extends StatefulWidget {
  final UserMood mood;
  const _AnimatedSprout({required this.mood});

  @override
  State<_AnimatedSprout> createState() => _AnimatedSproutState();
}

class _AnimatedSproutState extends State<_AnimatedSprout>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _getEmoji(UserMood mood) {
    switch (mood) {
      case UserMood.happy:
        return '🌟';
      case UserMood.focused:
        return '🎯';
      case UserMood.calm:
        return '😌';
      case UserMood.anxious:
        return '😰';
      case UserMood.overwhelmed:
        return '😮';
      case UserMood.burnedOut:
        return '😴';
      default:
        return '🌱';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _float.value),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.sageSurface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.sage.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: AppTheme.durationMedium,
              child: Text(
                _getEmoji(widget.mood),
                key: ValueKey(widget.mood),
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Mood Card ────────────────────────────────────────────────────────────────
class _MoodOption {
  final UserMood mood;
  final String emoji;
  final String label;
  final Color color;
  final Color activeColor;

  const _MoodOption({
    required this.mood,
    required this.emoji,
    required this.label,
    required this.color,
    required this.activeColor,
  });
}

class _MoodCard extends StatelessWidget {
  final _MoodOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationMedium,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected ? option.activeColor : option.color,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: isSelected
              ? Border.all(color: option.activeColor, width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: option.activeColor.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: AppTheme.durationMedium,
              child: Text(option.emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 10),
            Text(
              option.label,
              style: AppTypography.labelLarge(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

