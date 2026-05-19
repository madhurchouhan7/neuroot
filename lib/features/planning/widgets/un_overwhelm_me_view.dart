import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/planning/providers/task_provider.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';
import 'package:go_router/go_router.dart';

class UnOverwhelmMeView extends ConsumerWidget {
  const UnOverwhelmMeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(upcomingTasksProvider);
    final currentProject = tasks.isEmpty ? null : tasks.first;

    return Column(
      children: [
        // Mascot Header Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF5EFE3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: NeurootNetworkImage(
                  url: 'https://lh3.googleusercontent.com/aida/ADBb0uiaLar68Amma9ySBOYypt_eI0mQARhWJDKs9NTpVTGceSRwsfwB_dDGi_Xfsphkfc2Q7B9FhrATmZyedIc4muPfawcW-7n2wPm5qJ9vGfyLsMe1rBwQUn-_Cwj1HHUOKr2eno_-eFIsl6ncaTKtFgkZORZp1wZdkVzovM5Lr0jGQhr_uneUyoRnk4hEg6AOxZvNLRTgiiYwG7VzI2jBnWJ6TfV46rz44r5An3Is2t5i3mI_Ctjy0UpbRQ',
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(24),
                  errorIcon: Icons.eco,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                      bottomLeft: Radius.zero,
                    ),
                    border: Border.all(color: const Color(0xFFF5EFE3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    currentProject != null
                        ? "I've broken this down for you. You've got this!"
                        : "You're all caught up! No tasks left. Time to chill! 🌱",
                    style: AppTypography.bodySmall(color: const Color(0xFF4E4634))
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        if (currentProject != null) ...[
          // Main Project Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFF5EFE3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CURRENT PROJECT',
                        style: AppTypography.labelSmall(color: const Color(0xFF5A5A5A))
                            .copyWith(letterSpacing: 0.8, fontSize: 11),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECEC), // bloom-red-bg
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Scary Scale: 😱',
                          style: AppTypography.labelSmall(color: const Color(0xFF5A5A5A)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentProject.title,
                    style: AppTypography.titleMedium(color: AppColors.primaryContainer).copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI generated microtasks below',
                    style: AppTypography.bodySmall(color: const Color(0xFF4E4634)).copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Microtask List with Magic Relief Background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF9F1), // bloom-cream
                  Color(0xFFEBF5EB), // bloom-sage-bg
                  Color(0xFFF0ECFF), // bloom-lavender-bg
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your 15-Minute Wins',
                      style: AppTypography.titleMedium(color: const Color(0xFF1B1C1C)).copyWith(fontSize: 18),
                    ),
                    const Icon(Icons.auto_awesome, color: AppColors.sageDark, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMicrotaskCard('Review requirements for ${currentProject.title}'),
                const SizedBox(height: 10),
                _buildMicrotaskCard('Set up project structure'),
                const SizedBox(height: 10),
                _buildMicrotaskCard('Find 2 reference materials'),
                const SizedBox(height: 10),
                _buildMicrotaskCard('Write down the 3 main objectives'),
                
                const SizedBox(height: 24),
                
                GestureDetector(
                  onTap: () => context.push('/ai-roadmap'),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View Full AI Roadmap',
                          style: AppTypography.titleSmall(color: const Color(0xFF6D5400)).copyWith(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, color: Color(0xFF6D5400), size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildMicrotaskCard(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFF3C4), width: 2), // bloom-yellow-soft
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium(color: const Color(0xFF1B1C1C)).copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: Color(0xFF5A5A5A)),
                    const SizedBox(width: 4),
                    Text(
                      '15 MIN',
                      style: AppTypography.labelSmall(color: const Color(0xFF5A5A5A)).copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
