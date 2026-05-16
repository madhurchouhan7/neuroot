import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/models/mood_log_model.dart';
import 'package:neuroot/features/dashboard/providers/dashboard_provider.dart';

class MoodCheckInStrip extends ConsumerWidget {
  const MoodCheckInStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMood = ref.watch(todayMoodProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0EBE3)), // cream-dark
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'How are you feeling?',
            style: AppTypography.bodyMedium(color: const Color(0xFF2B2B2B)).copyWith(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              _buildEmojiBtn('😊', currentMood == MoodType.happy, () => _setMood(ref, MoodType.happy)),
              const SizedBox(width: 8),
              _buildEmojiBtn('😐', currentMood == MoodType.calm, () => _setMood(ref, MoodType.calm)),
              const SizedBox(width: 8),
              _buildEmojiBtn('😔', currentMood == MoodType.tired, () => _setMood(ref, MoodType.tired)),
              const SizedBox(width: 8),
              _buildEmojiBtn('😵', currentMood == MoodType.overwhelmed, () => _setMood(ref, MoodType.overwhelmed)),
            ],
          ),
        ],
      ),
    );
  }

  void _setMood(WidgetRef ref, MoodType mood) {
    ref.read(todayMoodProvider.notifier).setMood(mood);
  }

  Widget _buildEmojiBtn(String emoji, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryContainer : const Color(0xFFF6F3F2), // surface-container-low
        shape: BoxShape.circle,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Transform.scale(
        scale: isSelected ? 1.1 : 1.0,
        child: Text(emoji, style: const TextStyle(fontSize: 18)),
      ),
      ),
    );
  }
}
