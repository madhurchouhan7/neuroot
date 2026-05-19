import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:neuroot/core/models/task_model.dart';
import 'package:neuroot/core/services/gemini_service.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/planning/providers/task_provider.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/features/settings/providers/settings_provider.dart';

String _getTaskCacheKey(TaskModel task) {
  return 'microtasks_${task.id.isEmpty ? task.title.hashCode : task.id}';
}

final microtasksProvider = FutureProvider.family<List<String>, TaskModel>((ref, task) async {
  final cacheKey = _getTaskCacheKey(task);
  final box = await Hive.openBox('ai_microtasks_cache');

  // 1. Check if cache exists
  if (box.containsKey(cacheKey)) {
    final cachedData = box.get(cacheKey) as Map?;
    if (cachedData != null) {
      final winsList = cachedData['wins'] as List?;
      if (winsList != null && winsList.isNotEmpty) {
        debugPrint('[MicrotasksProvider] Loaded cached wins for ${task.title}');
        return winsList.map((e) => e.toString()).toList();
      }
    }
  }

  // 2. Call Gemini if not cached
  final gemini = ref.watch(geminiServiceProvider);
  final prompt = '''
You are a helpful and supportive student companion AI called Sprout.
Analyze this academic task and break it down into exactly 4 highly actionable, bite-sized, 15-minute microtasks (called "15-Minute Wins").
Each microtask should be simple, encouraging, and completeable in 15 minutes or less to help a student who is feeling overwhelmed.

Task details:
- Title: "${task.title}"
- Priority: "${task.priority.name}"
- Due Date: "${task.dueDate.toIso8601String()}"
- Notes: "${task.notes}"

Respond with ONLY a raw JSON array containing exactly 4 strings. No markdown formatting, no comments, no ```json formatting. Just the raw JSON array.
Example response format:
["Find 2 high-quality reference articles", "Write down 3 core thesis points", "Draft the introduction paragraph outline", "Set up project folders and code outline"]
''';

  List<String> wins = [];
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
    wins = list.map((item) => item.toString()).toList();
  } catch (e) {
    debugPrint('[MicrotasksProvider] Error breaking down task: $e. Falling back to default wins.');
    wins = [
      'Review requirements for ${task.title}',
      'Set up study space & open required tools',
      'Research the first core topic for 10 mins',
      'Jot down the next 3 main steps to take',
    ];
  }

  // 3. Store in local cache
  await box.put(cacheKey, {
    'wins': wins,
    'completed': <String>[],
  });

  return wins;
});

class UnOverwhelmMeView extends ConsumerStatefulWidget {
  const UnOverwhelmMeView({super.key});

  @override
  ConsumerState<UnOverwhelmMeView> createState() => _UnOverwhelmMeViewState();
}

class _UnOverwhelmMeViewState extends ConsumerState<UnOverwhelmMeView> {
  final Set<String> _completedWins = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompletedCache();
    });
  }

  Future<void> _loadCompletedCache() async {
    final tasks = ref.read(upcomingTasksProvider);
    if (tasks.isEmpty) return;
    final task = tasks.first;
    final cacheKey = _getTaskCacheKey(task);
    try {
      final box = await Hive.openBox('ai_microtasks_cache');
      if (box.containsKey(cacheKey)) {
        final cachedData = box.get(cacheKey) as Map?;
        if (cachedData != null) {
          final completedList = cachedData['completed'] as List?;
          if (completedList != null) {
            setState(() {
              _completedWins.clear();
              _completedWins.addAll(completedList.map((e) => e.toString()));
            });
          }
        }
      }
    } catch (e) {
      debugPrint('[UnOverwhelmMeView] Error loading completed cache: $e');
    }
  }

  Future<void> _updateCompletedCache(String win, bool add) async {
    final tasks = ref.read(upcomingTasksProvider);
    if (tasks.isEmpty) return;
    final task = tasks.first;
    final cacheKey = _getTaskCacheKey(task);
    try {
      final box = await Hive.openBox('ai_microtasks_cache');
      if (box.containsKey(cacheKey)) {
        final cachedData = box.get(cacheKey) as Map?;
        if (cachedData != null) {
          final completedList = List<String>.from(cachedData['completed'] as List? ?? []);
          if (add) {
            if (!completedList.contains(win)) {
              completedList.add(win);
            }
          } else {
            completedList.remove(win);
          }
          
          final Map<String, dynamic> updatedMap = {
            'wins': List<String>.from(cachedData['wins'] as List? ?? []),
            'completed': completedList,
          };
          await box.put(cacheKey, updatedMap);
        }
      }
    } catch (e) {
      debugPrint('[UnOverwhelmMeView] Error updating completed cache: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    if (!settings.sproutAIEnabled) {
      return Column(
        children: [
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
                  child: const Center(
                    child: Icon(Icons.eco_rounded, color: Color(0xFF6B6560), size: 48),
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
                      "Sprout's AI Coach is offline. Go to settings to activate it!",
                      style: AppTypography.bodySmall(color: const Color(0xFF4E4634))
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "Sprout's AI Coach is turned off. You need to turn it ON from Settings! 🤖🌱",
                    ),
                    backgroundColor: const Color(0xFFFF8A65),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
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
                  children: [
                    const Icon(Icons.local_florist_rounded, color: Color(0xFF52B788), size: 36),
                    const SizedBox(height: 12),
                    Text(
                      "Your 15-Minute Wins are turned off.",
                      style: AppTypography.titleSmall(color: AppColors.primaryContainer).copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "You need to turn Sprout AI Coach ON from Settings",
                      style: AppTypography.bodySmall(color: const Color(0xFF6B6560)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Proactive reload when the active task changes
    ref.listen<List<TaskModel>>(upcomingTasksProvider, (previous, next) {
      if (next.isNotEmpty) {
        _loadCompletedCache();
      }
    });
    final tasks = ref.watch(upcomingTasksProvider);
    final currentProject = tasks.isEmpty ? null : tasks.first;
    
    final microtasksAsync = currentProject != null 
        ? ref.watch(microtasksProvider(currentProject))
        : null;

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
                if (microtasksAsync != null)
                  microtasksAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.sageDark,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Sprout is breaking task scope down... 🌱',
                              style: TextStyle(
                                color: Color(0xFF4E4634),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    error: (e, stack) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Failed to load microtasks. Sprout suggests reviewing requirements.',
                        style: AppTypography.bodySmall(color: const Color(0xFFE05C5C)),
                      ),
                    ),
                    data: (wins) {
                      return Column(
                        children: wins.map((win) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildMicrotaskCard(win),
                          );
                        }).toList(),
                      );
                    },
                  ),
                
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
    final isCompleted = _completedWins.contains(title);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isCompleted ? 0.02 : 0.05),
            blurRadius: isCompleted ? 2 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              final newCompleted = !isCompleted;
              setState(() {
                if (isCompleted) {
                  _completedWins.remove(title);
                } else {
                  _completedWins.add(title);
                }
              });
              _updateCompletedCache(title, newCompleted);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.sageDark : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? AppColors.sageDark : const Color(0xFFFFF3C4),
                  width: 2,
                ),
                boxShadow: isCompleted
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(0xFFFFF3C4).withValues(alpha: 0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ],
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 18,
                      color: AppColors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  style: AppTypography.bodyMedium(
                    color: isCompleted ? const Color(0xFF8B857F) : const Color(0xFF1B1C1C),
                  ).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                  child: Text(title),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: isCompleted ? const Color(0xFFC4BCAF) : const Color(0xFF5A5A5A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '15 MIN',
                      style: AppTypography.labelSmall(
                        color: isCompleted ? const Color(0xFFC4BCAF) : const Color(0xFF5A5A5A),
                      ).copyWith(fontSize: 10),
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
