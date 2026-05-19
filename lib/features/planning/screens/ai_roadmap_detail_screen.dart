import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:go_router/go_router.dart';

class AiRoadmapDetailScreen extends ConsumerWidget {
  const AiRoadmapDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F1), // Cozy cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A4A4A)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'AI Study Roadmap',
          style: AppTypography.titleMedium(color: const Color(0xFF4A4A4A)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppColors.amber),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Regenerating roadmap... 🌱',
                      style: AppTypography.bodyMedium(color: AppColors.white)),
                  backgroundColor: AppColors.sageDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEBF5EB), Color(0xFFF9F7F1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD3E4D3)),
                    ),
                    child: Row(
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 48)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Multi-Week Plan Active",
                                style: AppTypography.titleMedium(color: const Color(0xFF2B4D2F)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "I've broken down your major assignments into manageable weekly chunks.",
                                style: AppTypography.bodySmall(color: const Color(0xFF4A4A4A)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Your Interactive Timeline',
                    style: AppTypography.titleMedium(color: const Color(0xFF4A4A4A)),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildWeekSection(index + 1);
                },
                childCount: 3,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Confirm changes logic
          context.pop();
        },
        backgroundColor: AppColors.amber,
        elevation: 4,
        icon: const Icon(Icons.check, color: Color(0xFF4A4A4A)),
        label: Text(
          'Apply Roadmap',
          style: AppTypography.labelLarge(color: const Color(0xFF4A4A4A)).copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildWeekSection(int week) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A4A4A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'WEEK $week',
                  style: AppTypography.labelSmall(color: AppColors.white).copyWith(letterSpacing: 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFE5E0D5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimelineNode(
            title: 'Research & Literature Review',
            subject: 'CS 401',
            date: 'Mon, Oct 12',
            isCompleted: week == 1,
          ),
          _buildTimelineNode(
            title: 'Draft First Sections',
            subject: 'CS 401',
            date: 'Wed, Oct 14',
            isCompleted: false,
          ),
          _buildTimelineNode(
            title: 'Create Diagrams',
            subject: 'CS 401',
            date: 'Fri, Oct 16',
            isCompleted: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode({
    required String title,
    required String subject,
    required String date,
    required bool isCompleted,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.sageDark : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? AppColors.sageDark : const Color(0xFFC4BCAF),
                      width: 2,
                    ),
                  ),
                  child: isCompleted ? const Icon(Icons.check, size: 12, color: AppColors.white) : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFE5E0D5),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0EBE3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
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
                          subject,
                          style: AppTypography.labelSmall(color: const Color(0xFF8B857F)),
                        ),
                        Text(
                          date,
                          style: AppTypography.labelSmall(color: const Color(0xFF8B857F)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: AppTypography.titleSmall(color: const Color(0xFF2B2B2B)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
