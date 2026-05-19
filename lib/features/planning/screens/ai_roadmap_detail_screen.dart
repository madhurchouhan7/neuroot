import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/models/task_model.dart';
import 'package:neuroot/core/services/gemini_service.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/planning/providers/task_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/shared/widgets/neuroot_widgets.dart';

class RoadmapNode {
  final String title;
  final String subject;
  final String date;
  final bool isCompleted;

  RoadmapNode({
    required this.title,
    required this.subject,
    required this.date,
    this.isCompleted = false,
  });

  factory RoadmapNode.fromJson(Map<String, dynamic> json) => RoadmapNode(
    title: json['title'] as String? ?? '',
    subject: json['subject'] as String? ?? '',
    date: json['date'] as String? ?? '',
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}

class WeekPlan {
  final int week;
  final List<RoadmapNode> nodes;

  WeekPlan({required this.week, required this.nodes});

  factory WeekPlan.fromJson(Map<String, dynamic> json) {
    final list = json['nodes'] as List? ?? [];
    return WeekPlan(
      week: json['week'] as int? ?? 1,
      nodes: list
          .map((e) => RoadmapNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

final aiRoadmapProvider = FutureProvider.family<List<WeekPlan>, TaskModel>((
  ref,
  task,
) async {
  final gemini = ref.watch(geminiServiceProvider);
  final nowStr = DateTime.now().toIso8601String();
  final prompt =
      '''
You are a brilliant study organizer AI called Sprout.
Create a highly tailored 3-week study roadmap leading up to the due date of this specific assignment/task.

Task details:
- Title: "${task.title}"
- Subject: "${task.subjectId.isEmpty ? 'General Study' : task.subjectId}"
- Due Date: "${task.dueDate.toIso8601String()}"
- Notes: "${task.notes}"
- Current Time: "$nowStr"

Respond with ONLY a raw JSON array representing the 3-week plan. Do not include markdown code block formatting (like ```json), comments, or extra text.
The JSON array should contain exactly 3 objects (one for each of the 3 weeks leading to the due date). Each week must have exactly 2-3 specific micro-actions (nodes) that are highly tailored to this task's subject and title.
Use a realistic and helpful progression of academic preparation.
Calculate and suggest highly realistic dates for each node relative to the due date.

Example JSON output format:
[
  {
    "week": 1,
    "nodes": [
      {
        "title": "Analyze assignment guidelines and plan research topics",
        "subject": "CS 401",
        "date": "Mon, Oct 12"
      },
      {
        "title": "Outline initial sections and draft thesis statement",
        "subject": "CS 401",
        "date": "Wed, Oct 14"
      }
    ]
  },
  {
    "week": 2,
    "nodes": [
      {
        "title": "Write primary body paragraphs and insert source citations",
        "subject": "CS 401",
        "date": "Mon, Oct 19"
      },
      {
        "title": "Draft conclusion and peer review structure",
        "subject": "CS 401",
        "date": "Wed, Oct 21"
      }
    ]
  },
  {
    "week": 3,
    "nodes": [
      {
        "title": "Polishing draft, bibliography checks and fine-tuning",
        "subject": "CS 401",
        "date": "Mon, Oct 26"
      },
      {
        "title": "Final checks and submission upload preparation",
        "subject": "CS 401",
        "date": "Wed, Oct 28"
      }
    ]
  }
]
''';

  try {
    final response = await gemini.generateText(prompt);
    String cleaned = response.trim();
    if (cleaned.startsWith('```')) {
      final lines = cleaned.split('\n');
      if (lines.first.startsWith('```')) {
        lines.removeAt(0);
      }
      if (lines.isNotEmpty && lines.last.startsWith('```')) {
        lines.removeLast();
      }
      cleaned = lines.join('\n').trim();
    }

    final list = jsonDecode(cleaned) as List;
    return list
        .map((e) => WeekPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    debugPrint(
      '[AiRoadmapProvider] Error generating roadmap: $e. Falling back to default roadmap.',
    );
    final subjectLabel = task.subjectId.isEmpty ? 'Study' : task.subjectId;
    return [
      WeekPlan(
        week: 1,
        nodes: [
          RoadmapNode(
            title:
                'Review requirements and compile study materials for ${task.title}',
            subject: subjectLabel,
            date: 'Week 1 Start',
          ),
          RoadmapNode(
            title: 'Draft core outline and organize sections',
            subject: subjectLabel,
            date: 'Week 1 Mid',
          ),
        ],
      ),
      WeekPlan(
        week: 2,
        nodes: [
          RoadmapNode(
            title: 'Detail first half of deliverables & key references',
            subject: subjectLabel,
            date: 'Week 2 Start',
          ),
          RoadmapNode(
            title: 'Flesh out remaining contents & verify formulas/code',
            subject: subjectLabel,
            date: 'Week 2 Mid',
          ),
        ],
      ),
      WeekPlan(
        week: 3,
        nodes: [
          RoadmapNode(
            title: 'Polish, double-check grading rubric and review topics',
            subject: subjectLabel,
            date: 'Week 3 Start',
          ),
          RoadmapNode(
            title: 'Final check & submit ${task.title} 🎉',
            subject: subjectLabel,
            date: 'Due Date',
          ),
        ],
      ),
    ];
  }
});

class AiRoadmapDetailScreen extends ConsumerWidget {
  const AiRoadmapDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(upcomingTasksProvider);
    final task = tasks.isEmpty ? null : tasks.first;

    final roadmapAsync = task != null
        ? ref.watch(aiRoadmapProvider(task))
        : null;

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
          if (task != null)
            IconButton(
              icon: const Icon(Icons.auto_awesome, color: AppColors.amber),
              onPressed: () {
                ref.invalidate(aiRoadmapProvider(task));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Regenerating roadmap tailored to ${task.title}... 🌱',
                      style: AppTypography.bodyMedium(color: AppColors.white),
                    ),
                    backgroundColor: AppColors.sageDark,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
            ),
        ],
      ),
      body: task == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🌱', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(
                      'No Active Projects Found',
                      style: AppTypography.titleMedium(
                        color: const Color(0xFF4A4A4A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add a homework assignment, lab, or exam in your Planner tab to unlock Sprout\'s 3-week adaptive study roadmap.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall(
                        color: const Color(0xFF8B857F),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
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
                                      "3-Week Plan Active",
                                      style: AppTypography.titleMedium(
                                        color: const Color(0xFF2B4D2F),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Tailored roadmap for: ${task.title}",
                                      style: AppTypography.bodySmall(
                                        color: const Color(0xFF4A4A4A),
                                      ).copyWith(fontWeight: FontWeight.bold),
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
                          style: AppTypography.titleMedium(
                            color: const Color(0xFF4A4A4A),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
                if (roadmapAsync != null)
                  roadmapAsync.when(
                    loading: () => const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerListLoading(count: 3),
                            SizedBox(height: 16),
                            Center(
                              child: Text(
                                'Sprout is generating study roadmap... 🌱',
                                style: TextStyle(
                                  color: Color(0xFF4A4A4A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    error: (e, stack) => SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Failed to load study roadmap. Try again or check network.',
                          style: AppTypography.bodySmall(
                            color: const Color(0xFFE05C5C),
                          ),
                        ),
                      ),
                    ),
                    data: (weeks) {
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return _buildWeekSection(weeks[index]);
                          }, childCount: weeks.length),
                        ),
                      );
                    },
                  ),
              ],
            ),
      floatingActionButton: task == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                context.pop();
              },
              backgroundColor: AppColors.amber,
              elevation: 4,
              icon: const Icon(Icons.check, color: Color(0xFF4A4A4A)),
              label: Text(
                'Apply Roadmap',
                style: AppTypography.labelLarge(
                  color: const Color(0xFF4A4A4A),
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildWeekSection(WeekPlan plan) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A4A4A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'WEEK ${plan.week}',
                  style: AppTypography.labelSmall(
                    color: AppColors.white,
                  ).copyWith(letterSpacing: 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(height: 1, color: const Color(0xFFE5E0D5)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...plan.nodes.asMap().entries.map((entry) {
            final idx = entry.key;
            final node = entry.value;
            final isLast = idx == plan.nodes.length - 1;
            return _buildTimelineNode(
              title: node.title,
              subject: node.subject,
              date: node.date,
              isCompleted:
                  plan.week == 1 &&
                  idx == 0, // Feel-good auto-complete first item
              isLast: isLast,
            );
          }),
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
                    color: isCompleted
                        ? AppColors.sageDark
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.sageDark
                          : const Color(0xFFC4BCAF),
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 12,
                          color: AppColors.white,
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: const Color(0xFFE5E0D5)),
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
                          style: AppTypography.labelSmall(
                            color: const Color(0xFF8B857F),
                          ),
                        ),
                        Text(
                          date,
                          style: AppTypography.labelSmall(
                            color: const Color(0xFF8B857F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: AppTypography.titleSmall(
                        color: const Color(0xFF2B2B2B),
                      ),
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
