import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/models/task_model.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/planning/providers/task_provider.dart';
import 'package:neuroot/features/planning/screens/task_detail_screen.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';
import 'package:neuroot/shared/widgets/neuroot_widgets.dart';

import '../widgets/planner_header.dart';
import '../widgets/exam_countdown_card.dart';
import '../widgets/quick_add_task_sheet.dart';
import '../widgets/un_overwhelm_me_view.dart';
import 'calendar_screen.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  int _activeTab = 0;
  List<String>? _customOrderIds;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksStreamProvider);
    final filter = ref.watch(activeTaskFilterProvider);

    // Feedback snackbars
    ref.listen<TaskActionState>(taskNotifierProvider, (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.successMessage!,
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
        ref.read(taskNotifierProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.errorMessage!,
              style: AppTypography.bodyMedium(color: AppColors.white),
            ),
            backgroundColor: const Color(0xFFE05C5C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        ref.read(taskNotifierProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                children: [
                  PlannerHeader(
                    onCalendarTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CalendarScreen(),
                        ),
                      );
                    },
                  ),

                  // Tab switcher
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.softGrey,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          _buildTab(0, '📋 Tasks'),
                          _buildTab(1, '✨ AI Plan'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter chips
                  if (_activeTab == 0)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: TaskFilter.values.map((f) {
                          final isSelected = f == filter;
                          return GestureDetector(
                            onTap: () => ref
                                .read(activeTaskFilterProvider.notifier)
                                .setFilter(f),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryContainer
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: const Color(0xFFE8E0D4),
                                      ),
                              ),
                              child: Text(
                                _filterLabel(f),
                                style: AppTypography.labelSmall(
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : const Color(0xFF8B8070),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ── Content ──────────────────────────────────────────────────────
            if (_activeTab == 0) ...[
              const SliverToBoxAdapter(child: ExamCountdownCard()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              ...tasksAsync.when<List<Widget>>(
                loading: () => [
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: ShimmerListLoading(count: 3),
                    ),
                  ),
                ],
                error: (e, stack) {
                  debugPrint('[PlannerScreen] Error loading tasks: $e\n$stack');
                  return [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECEC),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "Couldn't load tasks: ${e.toString().split('\n').first}",
                            style: AppTypography.bodyMedium(
                              color: const Color(0xFFE05C5C),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                data: (allTasks) {
                  final tasks = _applyFilter(allTasks, filter);
                  final incomplete = tasks
                      .where((t) => !t.isCompleted)
                      .toList();
                  final completed = tasks.where((t) => t.isCompleted).toList();

                  if (tasks.isEmpty) {
                    return [
                      SliverToBoxAdapter(
                        child: _EmptyTasksView(
                          onAdd: () => _openAddTask(context),
                        ),
                      ),
                    ];
                  }

                  // Sync and sort local custom order
                  if (_customOrderIds == null) {
                    _customOrderIds = incomplete.map((t) => t.id).toList();
                  } else {
                    // Sync: add new items, remove deleted ones
                    final currentIds = incomplete.map((t) => t.id).toSet();
                    _customOrderIds!.removeWhere(
                      (id) => !currentIds.contains(id),
                    );
                    final orderedSet = _customOrderIds!.toSet();
                    for (final t in incomplete) {
                      if (!orderedSet.contains(t.id)) {
                        _customOrderIds!.add(t.id);
                      }
                    }
                  }

                  // Sort incomplete tasks according to _customOrderIds
                  incomplete.sort((a, b) {
                    final indexA = _customOrderIds!.indexOf(a.id);
                    final indexB = _customOrderIds!.indexOf(b.id);
                    return indexA.compareTo(indexB);
                  });

                  return [
                    // Incomplete Header
                    if (incomplete.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Text(
                            'TO DO · DRAG TO REORDER 📋',
                            style: AppTypography.labelSmall(
                              color: const Color(0xFF8B8070),
                            ),
                          ),
                        ),
                      ),

                    // Incomplete List (Reorderable)
                    if (incomplete.isNotEmpty)
                      SliverReorderableList(
                        itemCount: incomplete.length,
                        itemBuilder: (context, index) {
                          final task = incomplete[index];
                          return ReorderableDelayedDragStartListener(
                            key: ValueKey(task.id),
                            index: index,
                            child: _LiveTaskCard(
                              task: task,
                              onComplete: (done) => ref
                                  .read(taskNotifierProvider.notifier)
                                  .toggleComplete(task.id, isCompleted: done),
                              onDelete: () =>
                                  _confirmDelete(context, ref, task.id),
                              key: ValueKey(task.id),
                            ),
                          );
                        },
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final item = incomplete.removeAt(oldIndex);
                            incomplete.insert(newIndex, item);
                            _customOrderIds = incomplete
                                .map((t) => t.id)
                                .toList();
                          });
                        },
                      ),

                    // Completed Section
                    if (completed.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Text(
                            'DONE ✅',
                            style: AppTypography.labelSmall(
                              color: AppColors.sageDark,
                            ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final task = completed[index];
                          return _LiveTaskCard(
                            key: ValueKey(task.id),
                            task: task,
                            onComplete: (done) => ref
                                .read(taskNotifierProvider.notifier)
                                .toggleComplete(task.id, isCompleted: done),
                            onDelete: () =>
                                _confirmDelete(context, ref, task.id),
                          );
                        }, childCount: completed.length),
                      ),
                    ],
                  ];
                },
              ),
            ] else ...[
              const SliverToBoxAdapter(child: UnOverwhelmMeView()),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: _activeTab == 0
          ? FloatingActionButton(
              onPressed: () => _openAddTask(context),
              backgroundColor: AppColors.primaryContainer,
              elevation: 4,
              child: const Icon(Icons.add, color: Color(0xFF6D5400), size: 28),
            )
          : null,
    );
  }

  Widget _buildTab(int index, String label) {
    final isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelMedium(
              color: isActive
                  ? const Color(0xFF1B1C1C)
                  : const Color(0xFF8B8070),
            ),
          ),
        ),
      ),
    );
  }

  void _openAddTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuickAddTaskSheet(),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String taskId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete task?',
          style: AppTypography.titleSmall(color: AppColors.textPrimary),
        ),
        content: Text(
          "This can't be undone.",
          style: AppTypography.bodyMedium(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTypography.labelMedium(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: AppTypography.labelMedium(color: const Color(0xFFE05C5C)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(taskNotifierProvider.notifier).deleteTask(taskId);
    }
  }

  List<TaskModel> _applyFilter(List<TaskModel> tasks, TaskFilter f) {
    switch (f) {
      case TaskFilter.all:
        return tasks;
      case TaskFilter.assignments:
        return tasks.where((t) => t.type == TaskType.assignment).toList();
      case TaskFilter.exams:
        return tasks.where((t) => t.type == TaskType.exam).toList();
      case TaskFilter.labs:
        return tasks.where((t) => t.type == TaskType.lab).toList();
    }
  }

  Map<String, List<TaskModel>> _groupByDate(List<TaskModel> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final result = <String, List<TaskModel>>{};

    for (final task in tasks) {
      final d = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      String label;
      if (d == today) {
        label = 'TODAY · ${_urgencyLabel(task.priority)}';
      } else if (d == tomorrow) {
        label = 'TOMORROW';
      } else if (d.isBefore(today)) {
        label = 'OVERDUE ⚠️';
      } else {
        label = _formatDate(task.dueDate).toUpperCase();
      }
      result.putIfAbsent(label, () => []).add(task);
    }
    return result;
  }

  Color _dateHeaderColor(String label) {
    if (label.contains('OVERDUE') || label.contains('TODAY')) {
      return const Color(0xFFE05C5C);
    }
    return const Color(0xFF8B8070);
  }

  String _urgencyLabel(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return 'URGENT';
      case TaskPriority.medium:
        return 'MEDIUM';
      case TaskPriority.low:
        return 'LOW';
    }
  }

  String _filterLabel(TaskFilter f) {
    switch (f) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.assignments:
        return '📝 Assignments';
      case TaskFilter.exams:
        return '📖 Exams';
      case TaskFilter.labs:
        return '🔬 Labs';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}

// ─── Live Task Card ───────────────────────────────────────────────────────────

class _LiveTaskCard extends StatefulWidget {
  const _LiveTaskCard({
    required this.task,
    required this.onComplete,
    required this.onDelete,
    required ValueKey<String> key,
  });

  final TaskModel task;
  final void Function(bool) onComplete;
  final VoidCallback onDelete;

  @override
  State<_LiveTaskCard> createState() => _LiveTaskCardState();
}

class _LiveTaskCardState extends State<_LiveTaskCard> {
  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isCompleted = task.isCompleted;
    final priorityColor = _priorityColor(task.priority);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFEBF5EB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              task.isCompleted ? Icons.undo : Icons.check_circle_outline,
              color: AppColors.sageDark,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              task.isCompleted ? 'Mark Active' : 'Complete',
              style: AppTypography.labelSmall(
                color: AppColors.sageDark,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFECEC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: AppTypography.labelSmall(
                color: const Color(0xFFE05C5C),
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.delete_outline,
              color: Color(0xFFE05C5C),
              size: 24,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          widget.onComplete(!task.isCompleted);
          return false;
        } else if (direction == DismissDirection.endToStart) {
          widget.onDelete();
          return false;
        }
        return false;
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFFF8F8F8) : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFFEEEEEE)
                  : const Color(0xFFEDE6F5),
            ),
            boxShadow: isCompleted
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Complete toggle
              GestureDetector(
                onTap: () => widget.onComplete(!isCompleted),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.sageDark
                        : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.sageDark
                          : const Color(0xFFEDE6F5),
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style:
                                AppTypography.bodyMedium(
                                  color: isCompleted
                                      ? const Color(0xFFB0A898)
                                      : const Color(0xFF1B1C1C),
                                ).copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (task.subjectId.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5EFE3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              task.subjectId,
                              style: AppTypography.labelSmall(
                                color: const Color(0xFF7F7662),
                              ).copyWith(fontSize: 10),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: priorityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _subtitleText(task),
                          style: AppTypography.bodySmall(
                            color: const Color(0xFFB0A898),
                          ).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitleText(TaskModel task) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr = '${task.dueDate.day} ${months[task.dueDate.month - 1]}';
    final priority =
        '${task.priority.name[0].toUpperCase()}${task.priority.name.substring(1)} priority';
    return '$dateStr · $priority · ${task.type.name}';
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return const Color(0xFFE05C5C);
      case TaskPriority.medium:
        return const Color(0xFFD49800);
      case TaskPriority.low:
        return AppColors.sageDark;
    }
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyTasksView extends StatelessWidget {
  const _EmptyTasksView({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Opacity(
            opacity: 0.7,
            child: NeurootNetworkImage(
              url:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCGAc2fsEi31o6PdDuRC1oBoT9gJ1hvP1bw2p3t1AxUd_f6t9fb9q4ONR5jhWot8mHDR8mCmFZK2jpkwleXbgbq6W_yf_0C9qakFGZo6fnJhEK3eb5ZJZASllQ7hsgMHUhwAOKDnDxH0DfvIWdTONSgtucV1ZmZ1VWz6KBx8KGqE6rty14jS_SzE4CVXuv_bGlNeM6f_DQRkitsZp7NYujmbxrzNT6mCG7OIBcf5wHJB6HGi7RAoLZ4OX21fReh4abVUaRgGve9pqk',
              height: 120,
              fit: BoxFit.contain,
              errorIcon: Icons.eco,
              placeholderColor: Colors.transparent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet 🎉',
            style: AppTypography.titleSmall(
              color: const Color(0xFF1B1C1C),
            ).copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            "Sprout says you're ahead of schedule!",
            style: AppTypography.bodySmall(
              color: const Color(0xFF8B8070),
            ).copyWith(fontWeight: FontWeight.normal),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Add your first task',
                style: AppTypography.buttonMedium(color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
