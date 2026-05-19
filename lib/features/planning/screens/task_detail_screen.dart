import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/models/task_model.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/planning/providers/task_provider.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final TaskModel task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  late TaskModel _task;
  late List<SubtaskItem> _subtasks;
  late List<TopicItem> _topics;
  late String _notes;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _subtasks = List.from(_task.subtasks);
    _topics = List.from(_task.topics);
    _notes = _task.notes;
  }

  void _toggleComplete() {
    final newState = !_task.isCompleted;
    ref
        .read(taskNotifierProvider.notifier)
        .toggleComplete(_task.id, isCompleted: newState);
    setState(() {
      _task = _task.copyWith(isCompleted: newState);
    });
    if (newState) {
      Navigator.pop(context);
    }
  }

  // ─── Notes helpers ─────────────────────────────────────────────────────────
  void _editNotes() async {
    final ctrl = TextEditingController(text: _notes);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Notes', style: AppTypography.titleSmall(color: const Color(0xFF1B1C1C))),
        content: TextField(
          controller: ctrl,
          maxLines: 6,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Add your notes here…',
            hintStyle: AppTypography.bodyMedium(color: const Color(0xFFB0A898)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: Size.zero, backgroundColor: AppColors.sageDark, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() => _notes = result);
      ref.read(taskNotifierProvider.notifier).updateNotes(_task.id, result);
    }
  }

  // ─── Subtask helpers ───────────────────────────────────────────────────────
  void _addSubtask() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Subtask', style: AppTypography.titleSmall(color: const Color(0xFF1B1C1C))),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Write introduction…',
            hintStyle: AppTypography.bodyMedium(color: const Color(0xFFB0A898)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: Size.zero, backgroundColor: AppColors.sageDark, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _subtasks.add(SubtaskItem(title: result)));
      _saveSubtasks();
    }
  }

  void _toggleSubtask(int index) {
    setState(() {
      _subtasks[index] = _subtasks[index].copyWith(isDone: !_subtasks[index].isDone);
    });
    _saveSubtasks();
  }

  void _deleteSubtask(int index) {
    setState(() => _subtasks.removeAt(index));
    _saveSubtasks();
  }

  void _saveSubtasks() {
    ref.read(taskNotifierProvider.notifier).updateSubtasks(_task.id, _subtasks.map((s) => s.toMap()).toList());
  }

  // ─── Topic/Checklist helpers ───────────────────────────────────────────────
  void _addTopic(String hint, String dialogTitle) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(dialogTitle, style: AppTypography.titleSmall(color: const Color(0xFF1B1C1C))),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium(color: const Color(0xFFB0A898)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: Size.zero, backgroundColor: const Color(0xFF5E4B8B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _topics.add(TopicItem(title: result)));
      _saveTopics();
    }
  }

  void _toggleTopic(int index) {
    setState(() {
      _topics[index] = _topics[index].copyWith(isDone: !_topics[index].isDone);
    });
    _saveTopics();
  }

  void _deleteTopic(int index) {
    setState(() => _topics.removeAt(index));
    _saveTopics();
  }

  void _saveTopics() {
    ref.read(taskNotifierProvider.notifier).updateTopics(_task.id, _topics.map((t) => t.toMap()).toList());
  }

  @override
  Widget build(BuildContext context) {
    switch (_task.type) {
      case TaskType.exam:
        return _buildExamScreen();
      case TaskType.lab:
        return _buildLabScreen();
      case TaskType.assignment:
        return _buildAssignmentScreen();
      case TaskType.task:
        return _buildGeneralScreen();
    }
  }

  // ─── 1. EXAM SCREEN ────────────────────────────────────────────────────────
  Widget _buildExamScreen() {
    final daysLeft = _task.dueDate.difference(DateTime.now()).inDays;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF), // light purple tint
      body: Stack(
        children: [
          // Header Gradient
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF5E4B8B),
                  Color(0xFF7E66C5),
                ], // Deep purple gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AppBar
                      _buildTransparentAppBar(Colors.white),

                      // Title block
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildPill(
                                  'EXAM',
                                  Colors.transparent,
                                  Colors.white,
                                  borderColor: Colors.white54,
                                ),
                                const SizedBox(width: 8),
                                if (_task.subjectId.isNotEmpty)
                                  _buildPill(
                                    _task.subjectId,
                                    Colors.white24,
                                    Colors.white,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    _task.title,
                                    style: AppTypography.titleXL(
                                      color: Colors.white,
                                    ).copyWith(fontSize: 28, height: 1.1),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      daysLeft >= 0 ? '$daysLeft' : '0',
                                      style: AppTypography.titleXL(
                                        color: Colors.white,
                                      ).copyWith(fontSize: 48, height: 1),
                                    ),
                                    Text(
                                      'DAYS LEFT',
                                      style: AppTypography.labelSmall(
                                        color: Colors.white70,
                                      ).copyWith(letterSpacing: 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Info Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DATE',
                                      style: AppTypography.labelSmall(
                                        color: const Color(0xFFB0A898),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(_task.dueDate),
                                      style: AppTypography.bodyMedium(
                                        color: const Color(0xFF1B1C1C),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'VENUE',
                                      style: AppTypography.labelSmall(
                                        color: const Color(0xFFB0A898),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Check Schedule',
                                      style: AppTypography.bodyMedium(
                                        color: const Color(0xFF1B1C1C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TIME',
                                      style: AppTypography.labelSmall(
                                        color: const Color(0xFFB0A898),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'TBA',
                                      style: AppTypography.bodyMedium(
                                        color: const Color(0xFF1B1C1C),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'DURATION',
                                      style: AppTypography.labelSmall(
                                        color: const Color(0xFFB0A898),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '3 Hours',
                                      style: AppTypography.bodyMedium(
                                        color: const Color(0xFF1B1C1C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Topics / Syllabus Card — interactive
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF0EBE3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Topics / Syllabus',
                                        style: AppTypography.titleSmall(color: const Color(0xFF1B1C1C)),
                                      ),
                                      const SizedBox(width: 8),
                                      if (_topics.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFEDE8FF), borderRadius: BorderRadius.circular(12)),
                                          child: Text(
                                            '${_topics.where((t) => t.isDone).length}/${_topics.length}',
                                            style: AppTypography.labelSmall(color: const Color(0xFF5E4B8B)),
                                          ),
                                        ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => _addTopic('e.g. Chapter 5 – Recursion', 'Add Topic'),
                                    child: Text(
                                      '+ Add topic',
                                      style: AppTypography.labelMedium(color: const Color(0xFF5E4B8B)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_topics.isEmpty)
                                Text(
                                  'No topics added yet. Tap "+ Add topic" to get started.',
                                  style: AppTypography.bodySmall(color: const Color(0xFFB0A898)),
                                )
                              else ...[
                                ...List.generate(_topics.length, (i) {
                                  final t = _topics[i];
                                  return Dismissible(
                                    key: ValueKey('topic_$i${t.title}'),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (_) => _deleteTopic(i),
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 12),
                                      child: const Icon(Icons.delete_outline, color: Color(0xFFE05C5C), size: 20),
                                    ),
                                    child: GestureDetector(
                                      onTap: () => _toggleTopic(i),
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 22, height: 22,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: t.isDone ? const Color(0xFF5E4B8B) : Colors.transparent,
                                                border: Border.all(color: t.isDone ? const Color(0xFF5E4B8B) : const Color(0xFFD1C5AE)),
                                              ),
                                              child: t.isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                t.title,
                                                style: AppTypography.bodyMedium(color: t.isDone ? const Color(0xFF8B8070) : const Color(0xFF1B1C1C)).copyWith(
                                                  decoration: t.isDone ? TextDecoration.lineThrough : null,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 8),
                                // Progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: _topics.isEmpty ? 0 : _topics.where((t) => t.isDone).length / _topics.length,
                                    minHeight: 6,
                                    backgroundColor: const Color(0xFFF0EBE3),
                                    valueColor: const AlwaysStoppedAnimation(Color(0xFF5E4B8B)),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${_topics.where((t) => t.isDone).length} of ${_topics.length} topics covered',
                                  style: AppTypography.labelSmall(color: const Color(0xFF8B8070)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sprout AI Plan Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF0EBE3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    color: Color(0xFF5E4B8B),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Sprout's ${daysLeft > 0 ? daysLeft : 1}-Day Plan",
                                    style: AppTypography.titleSmall(
                                      color: const Color(0xFF1B1C1C),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'DAY 1 (TODAY)',
                                style: AppTypography.labelSmall(
                                  color: const Color(0xFF5E4B8B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildBullet('Revise key concepts'),
                              _buildBullet('Past paper practice'),
                              const SizedBox(height: 16),
                              Text(
                                'DAY 2 (TOMORROW)',
                                style: AppTypography.labelSmall(
                                  color: const Color(0xFF5E4B8B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildBullet('Quick formula review'),
                              _buildBullet('Rest + Light breakfast 🍳'),
                              const SizedBox(height: 16),
                              Text(
                                'Open Full AI Plan →',
                                style: AppTypography.labelMedium(
                                  color: const Color(0xFF5E4B8B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5FF),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        backgroundColor: const Color(0xFF5E4B8B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: Text(
                        'AI Revision Plan',
                        style: AppTypography.buttonMedium(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1B1C1C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFE8E0D4)),
                        ),
                      ),
                      onPressed: _toggleComplete,
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(
                        'Mark Revised',
                        style: AppTypography.buttonMedium(
                          color: const Color(0xFF1B1C1C),
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

  // ─── 2. LAB SCREEN ─────────────────────────────────────────────────────────
  Widget _buildLabScreen() {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: Stack(
        children: [
          // Header Green Background
          Container(
            height: 220,
            color: const Color(0xFFEBF5EB), // bloom-sage-bg
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AppBar
                      _buildTransparentAppBar(const Color(0xFF4E4634)),

                      // Title block
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_task.subjectId.isNotEmpty)
                              _buildPill(
                                '${_task.subjectId} Lab',
                                AppColors.sageDark,
                                Colors.white,
                              ),
                            const SizedBox(height: 12),
                            Text(
                              _task.title,
                              style: AppTypography.titleXL(
                                color: const Color(0xFF1B1C1C),
                              ).copyWith(fontSize: 28, height: 1.1),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Lab · Prof. TBA · Lab Block',
                              style: AppTypography.bodySmall(
                                color: const Color(0xFF7F7662),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildPill(
                                  'Pending Submission',
                                  const Color(0xFFFFF3C4),
                                  const Color(0xFF6D5400),
                                ),
                                const SizedBox(height: 8),
                                _buildPill(
                                  'Recurring · Weekly',
                                  const Color(0xFFE8E4FF),
                                  const Color(0xFF5E4B8B),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size.zero,
                                backgroundColor: const Color(0xFF2B2B2B),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {},
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Start Focus',
                                    style: AppTypography.buttonMedium(
                                      color: Colors.white,
                                    ).copyWith(fontSize: 13),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward, size: 14),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submission Due Card
                      _buildStandardCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SUBMISSION DUE',
                                  style: AppTypography.labelSmall(
                                    color: const Color(0xFF7F7662),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatDate(_task.dueDate)} · Before Lab',
                                  style: AppTypography.bodyMedium(
                                    color: const Color(0xFF1B1C1C),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3C4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '2 days left',
                                style: AppTypography.labelSmall(
                                  color: const Color(0xFF6D5400),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Details Card
                      _buildStandardCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'EXPERIMENT NAME',
                                  style: AppTypography.labelSmall(
                                    color: const Color(0xFF7F7662),
                                  ),
                                ),
                                Text(
                                  'Edit',
                                  style: AppTypography.labelSmall(
                                    color: AppColors.amber,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _task.title,
                              style: AppTypography.bodyMedium(
                                color: const Color(0xFF1B1C1C),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'AIM',
                                  style: AppTypography.labelSmall(
                                    color: const Color(0xFF7F7662),
                                  ),
                                ),
                                Text(
                                  'Edit',
                                  style: AppTypography.labelSmall(
                                    color: AppColors.amber,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: _editNotes,
                              child: Text(
                                _notes.isNotEmpty
                                    ? _notes
                                    : 'Tap to add the aim of this experiment…',
                                style: AppTypography.bodyMedium(
                                  color: _notes.isNotEmpty ? const Color(0xFF4E4634) : const Color(0xFFB0A898),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Lab Record Checklist — interactive
                      _buildStandardCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.checklist, color: Color(0xFFD49800), size: 18),
                                    const SizedBox(width: 8),
                                    Text('Lab Record Checklist', style: AppTypography.titleSmall(color: const Color(0xFF1B1C1C))),
                                    const SizedBox(width: 8),
                                    if (_topics.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFFFFF3C4), borderRadius: BorderRadius.circular(12)),
                                        child: Text(
                                          '${_topics.where((t) => t.isDone).length}/${_topics.length}',
                                          style: AppTypography.labelSmall(color: const Color(0xFF6D5400)),
                                        ),
                                      ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => _addTopic('e.g. Observation table filled', 'Add Checklist Item'),
                                  child: Text('+ Add', style: AppTypography.labelSmall(color: AppColors.amber)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_topics.isEmpty)
                              Text(
                                'No checklist items yet. Tap "+ Add" to create one.',
                                style: AppTypography.bodySmall(color: const Color(0xFFB0A898)),
                              )
                            else
                              ...List.generate(_topics.length, (i) {
                                final t = _topics[i];
                                return Dismissible(
                                  key: ValueKey('lab_topic_$i${t.title}'),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (_) => _deleteTopic(i),
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 12),
                                    child: const Icon(Icons.delete_outline, color: Color(0xFFE05C5C), size: 20),
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _toggleTopic(i),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 22, height: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: t.isDone ? AppColors.sageDark : Colors.transparent,
                                              border: Border.all(color: t.isDone ? AppColors.sageDark : const Color(0xFFD1C5AE)),
                                            ),
                                            child: t.isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              t.title,
                                              style: AppTypography.bodyMedium(
                                                color: t.isDone ? const Color(0xFF8B8070) : const Color(0xFF1B1C1C),
                                              ).copyWith(decoration: t.isDone ? TextDecoration.lineThrough : null),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.warmCream,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        backgroundColor: const Color(0xFF2B2B2B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.timer_outlined, size: 18),
                      label: Text(
                        'Start Focus',
                        style: AppTypography.buttonMedium(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        backgroundColor: AppColors.sageDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _toggleComplete,
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(
                        'Mark Submitted',
                        style: AppTypography.buttonMedium(color: Colors.white),
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

  // ─── 3. ASSIGNMENT SCREEN ──────────────────────────────────────────────────
  Widget _buildAssignmentScreen() {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AppBar
                      _buildTransparentAppBar(const Color(0xFF8B8070)),

                      // Title block
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9EAE1), // light orange tint
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_task.subjectId.isNotEmpty)
                                _buildPill(
                                  _task.subjectId,
                                  const Color(0xFFD37D5A),
                                  Colors.white,
                                ),
                              const SizedBox(height: 12),
                              Text(
                                _task.title,
                                style: AppTypography.titleXL(
                                  color: const Color(0xFF2B2B2B),
                                ).copyWith(fontSize: 24, height: 1.2),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Assignment · Prof. TBA · Room TBA',
                                style: AppTypography.bodySmall(
                                  color: const Color(0xFF7F7662),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Status Pills & Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildPill(
                                  'In Progress',
                                  Colors.transparent,
                                  const Color(0xFFD49800),
                                  borderColor: const Color(0xFFF9E8B2),
                                ),
                                const SizedBox(width: 8),
                                _buildPill(
                                  '${_task.priority.name.toUpperCase()} Priority',
                                  const Color(0xFFFFECEC),
                                  const Color(0xFFE05C5C),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size.zero,
                                backgroundColor: const Color(0xFF2B2B2B),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              onPressed: () {},
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Start Focus',
                                    style: AppTypography.buttonMedium(
                                      color: Colors.white,
                                    ).copyWith(fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward, size: 12),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Due Date
                      _buildStandardCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DUE DATE',
                                  style: AppTypography.labelSmall(
                                    color: const Color(0xFF7F7662),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(_task.dueDate),
                                  style: AppTypography.bodyMedium(
                                    color: const Color(0xFF1B1C1C),
                                  ),
                                ),
                                Text(
                                  '11:59 PM',
                                  style: AppTypography.bodyMedium(
                                    color: const Color(0xFF4E4634),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFECEC),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '8',
                                    style: AppTypography.titleMedium(
                                      color: const Color(0xFFE05C5C),
                                    ).copyWith(fontSize: 20),
                                  ),
                                  Text(
                                    'hours left',
                                    style: AppTypography.labelSmall(
                                      color: const Color(0xFFE05C5C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes — interactive
                      _buildStandardCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Notes', style: AppTypography.titleSmall(color: const Color(0xFF1B1C1C))),
                                GestureDetector(
                                  onTap: _editNotes,
                                  child: Text('Edit ✏️', style: AppTypography.labelSmall(color: AppColors.amber)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _editNotes,
                              child: Text(
                                _notes.isNotEmpty ? _notes : 'Tap to add notes for this assignment…',
                                style: AppTypography.bodyMedium(
                                  color: _notes.isNotEmpty ? const Color(0xFF4E4634) : const Color(0xFFB0A898),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subtasks — interactive
                      _buildStandardCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text('Subtasks', style: AppTypography.titleSmall(color: const Color(0xFF1B1C1C))),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: const Color(0xFFE8E0D4), borderRadius: BorderRadius.circular(12)),
                                      child: Text(
                                        '${_subtasks.where((s) => s.isDone).length} / ${_subtasks.length} done',
                                        style: AppTypography.labelSmall(color: const Color(0xFF7F7662)),
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: _addSubtask,
                                  child: Text('+ Add', style: AppTypography.labelSmall(color: const Color(0xFF6D5400))),
                                ),
                              ],
                            ),
                            if (_subtasks.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: _subtasks.isEmpty ? 0 : _subtasks.where((s) => s.isDone).length / _subtasks.length,
                                  minHeight: 6,
                                  backgroundColor: const Color(0xFFF0EBE3),
                                  valueColor: const AlwaysStoppedAnimation(Color(0xFFD37D5A)),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            if (_subtasks.isEmpty)
                              Text('No subtasks yet. Tap "+ Add" to break this down.', style: AppTypography.bodySmall(color: const Color(0xFF8B8070)))
                            else
                              ...List.generate(_subtasks.length, (i) {
                                final s = _subtasks[i];
                                return Dismissible(
                                  key: ValueKey('subtask_$i${s.title}'),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (_) => _deleteSubtask(i),
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 12),
                                    child: const Icon(Icons.delete_outline, color: Color(0xFFE05C5C), size: 20),
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _toggleSubtask(i),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 22, height: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: s.isDone ? const Color(0xFFD37D5A) : Colors.transparent,
                                              border: Border.all(color: s.isDone ? const Color(0xFFD37D5A) : const Color(0xFFD1C5AE)),
                                            ),
                                            child: s.isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              s.title,
                                              style: AppTypography.bodyMedium(
                                                color: s.isDone ? const Color(0xFF8B8070) : const Color(0xFF1B1C1C),
                                              ).copyWith(decoration: s.isDone ? TextDecoration.lineThrough : null),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.warmCream,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        backgroundColor: const Color(0xFF2B2B2B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.timer_outlined, size: 18),
                      label: Text(
                        'Start Focus',
                        style: AppTypography.buttonMedium(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        backgroundColor: AppColors.amber,
                        foregroundColor: const Color(0xFF2B2B2B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _toggleComplete,
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(
                        'Mark Done',
                        style: AppTypography.buttonMedium(
                          color: const Color(0xFF2B2B2B),
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

  // ─── 4. GENERAL TASK SCREEN ────────────────────────────────────────────────
  Widget _buildGeneralScreen() {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AppBar
                      _buildTransparentAppBar(const Color(0xFF8B8070)),

                      // Title block
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPill(
                              'Personal',
                              const Color(0xFFF5EFE3),
                              const Color(0xFF7F7662),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _task.title,
                              style: AppTypography.titleXL(
                                color: const Color(0xFF1B1C1C),
                              ).copyWith(fontSize: 26, height: 1.2),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Quick Task · No subject linked',
                              style: AppTypography.bodySmall(
                                color: const Color(0xFF7F7662),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Status Pills
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            _buildPill(
                              'Pending',
                              const Color(0xFFE8E0D4),
                              const Color(0xFF4E4634),
                              showDot: true,
                            ),
                            const SizedBox(width: 12),
                            _buildPill(
                              '${_task.priority.name.toUpperCase()} Priority',
                              const Color(0xFFFFF3C4),
                              const Color(0xFFD49800),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Deadline Card
                      _buildStandardCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEBF5EB),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.calendar_today,
                                    color: AppColors.sageDark,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Deadline',
                                      style: AppTypography.labelSmall(
                                        color: const Color(0xFF7F7662),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Due ${_formatDate(_task.dueDate)}',
                                      style: AppTypography.bodyMedium(
                                        color: const Color(0xFF1B1C1C),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBF5EB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Active',
                                style: AppTypography.labelSmall(
                                  color: AppColors.sageDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes — interactive
                      _buildStandardCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.notes, color: Color(0xFF1B1C1C), size: 20),
                                    const SizedBox(width: 8),
                                    Text('Notes', style: AppTypography.titleSmall(color: const Color(0xFF1B1C1C))),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: _editNotes,
                                  child: Text('Edit ✏️', style: AppTypography.labelSmall(color: AppColors.amber)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: _editNotes,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F7F4),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _notes.isNotEmpty ? _notes : 'Tap to add details, links, or context…',
                                  style: AppTypography.bodyMedium(
                                    color: _notes.isNotEmpty ? const Color(0xFF4E4634) : const Color(0xFFB0A898),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subtasks — interactive
                      _buildStandardCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text('Subtasks', style: AppTypography.titleSmall(color: const Color(0xFF1B1C1C))),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: const Color(0xFFE8E0D4), borderRadius: BorderRadius.circular(12)),
                                      child: Text(
                                        '${_subtasks.where((s) => s.isDone).length} / ${_subtasks.length}',
                                        style: AppTypography.labelSmall(color: const Color(0xFF7F7662)),
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: _addSubtask,
                                  child: Text('+ Add subtask', style: AppTypography.labelMedium(color: AppColors.amber)),
                                ),
                              ],
                            ),
                            if (_subtasks.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: _subtasks.isEmpty ? 0 : _subtasks.where((s) => s.isDone).length / _subtasks.length,
                                  minHeight: 6,
                                  backgroundColor: const Color(0xFFF0EBE3),
                                  valueColor: AlwaysStoppedAnimation(AppColors.amber),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            if (_subtasks.isEmpty)
                              GestureDetector(
                                onTap: _addSubtask,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                                  child: CustomPaint(
                                    painter: _DashedBorderPainter(color: const Color(0xFFD1C5AE)),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        const Icon(Icons.add, color: Color(0xFF8B8070)),
                                        const SizedBox(height: 8),
                                        Text('Break it into steps?', style: AppTypography.bodyMedium(color: const Color(0xFF8B8070))),
                                        const SizedBox(height: 8),
                                        Text('+ Add subtask', style: AppTypography.labelMedium(color: AppColors.amber)),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...List.generate(_subtasks.length, (i) {
                                final s = _subtasks[i];
                                return Dismissible(
                                  key: ValueKey('gen_subtask_$i${s.title}'),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (_) => _deleteSubtask(i),
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 12),
                                    child: const Icon(Icons.delete_outline, color: Color(0xFFE05C5C), size: 20),
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _toggleSubtask(i),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 22, height: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: s.isDone ? AppColors.amber : Colors.transparent,
                                              border: Border.all(color: s.isDone ? AppColors.amber : const Color(0xFFD1C5AE)),
                                            ),
                                            child: s.isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              s.title,
                                              style: AppTypography.bodyMedium(
                                                color: s.isDone ? const Color(0xFF8B8070) : const Color(0xFF1B1C1C),
                                              ).copyWith(decoration: s.isDone ? TextDecoration.lineThrough : null),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warmCream.withValues(alpha: 0),
                    AppColors.warmCream,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size.zero,
                            backgroundColor: AppColors.amber,
                            foregroundColor: const Color(0xFF1B1C1C),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          onPressed: _toggleComplete,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Mark as Done',
                                style: AppTypography.buttonMedium(
                                  color: const Color(0xFF1B1C1C),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.check, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: Color(0xFF8B8070),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Start Focus on this task',
                        style: AppTypography.bodySmall(
                          color: const Color(0xFF8B8070),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildTransparentAppBar(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: textColor, size: 20),
            label: Text(
              'Planner',
              style: AppTypography.labelMedium(color: textColor),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_horiz, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(
    String label,
    Color bg,
    Color text, {
    Color? borderColor,
    bool showDot = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: text, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTypography.labelSmall(
              color: text,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardCard({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0EBE3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }


  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(color: Color(0xFF4E4634), fontSize: 14),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium(color: const Color(0xFF4E4634)),
            ),
          ),
        ],
      ),
    );
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
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(20),
    );
    path.addRRect(rrect);

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double extractPathLength = 0.0;
      while (extractPathLength < metric.length) {
        final extractPath = metric.extractPath(
          extractPathLength,
          extractPathLength + 8,
        );
        canvas.drawPath(extractPath, paint);
        extractPathLength += 16; // 8 draw, 8 skip
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
