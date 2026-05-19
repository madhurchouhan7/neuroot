import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/models/task_model.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/academic/providers/attendance_provider.dart';
import 'package:neuroot/features/planning/providers/task_provider.dart';
import 'package:shimmer/shimmer.dart';

/// Fully wired add-task bottom sheet.
/// Reads subjects from Firestore, saves to Firestore via [TaskNotifier].
class QuickAddTaskSheet extends ConsumerStatefulWidget {
  const QuickAddTaskSheet({super.key});

  @override
  ConsumerState<QuickAddTaskSheet> createState() =>
      _QuickAddTaskSheetState();
}

class _QuickAddTaskSheetState extends ConsumerState<QuickAddTaskSheet> {
  final _titleCtrl = TextEditingController();
  bool _aiEnabled = true;
  TaskType _selectedType = TaskType.assignment;
  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _selectedSubjectId;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    Navigator.pop(context);
    await ref.read(taskNotifierProvider.notifier).addTask(
          title: title,
          type: _selectedType,
          priority: _selectedPriority,
          subjectId: _selectedSubjectId ?? '',
          dueDate: _dueDate,
        );
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsStreamProvider);
    final isLoading = ref.watch(taskNotifierProvider).isLoading;

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 40, offset: Offset(0, -10)),
        ],
      ),
      child: Column(
        children: [
          // ── Handle ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0D8D0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add Task',
                    style: AppTypography.titleMedium(
                            color: const Color(0xFF2B2B2B))
                        .copyWith(fontSize: 18)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5EFE3),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.close,
                        size: 18, color: Color(0xFF7F7662)),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task title
                  TextField(
                    controller: _titleCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'What do you need to do?',
                      hintStyle: AppTypography.bodyMedium(
                          color: const Color(0xFFC8C0B8)),
                      border: const UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFFF0E8DC), width: 1.5)),
                      enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFFF0E8DC), width: 1.5)),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.primaryContainer, width: 1.5)),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: AppTypography.bodyMedium(
                        color: const Color(0xFF1B1C1C)),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),

                  // ── Type ────────────────────────────────────────────────
                  _sectionLabel('TYPE'),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: TaskType.values.map((t) {
                        final isSelected = t == _selectedType;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedType = t),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryContainer
                                  : const Color(0xFFF5EFE3),
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: const Color(0xFFE0D8D0)),
                            ),
                            child: Text(
                              _typeLabel(t),
                              style: AppTypography.labelSmall(
                                      color: isSelected
                                          ? AppColors.textPrimary
                                          : const Color(0xFF7F7662))
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Subject ─────────────────────────────────────────────
                  _sectionLabel('SUBJECT'),
                  const SizedBox(height: 10),
                  subjectsAsync.when(
                    loading: () => SizedBox(
                      height: 32,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (_, __) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Shimmer.fromColors(
                            baseColor: const Color(0xFFEEDDCC).withValues(alpha: 0.5),
                            highlightColor: const Color(0xFFFAF6F0),
                            child: Container(
                              width: 80,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (subjects) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // None chip
                            GestureDetector(
                              onTap: () => setState(() {
                                _selectedSubjectId = null;
                              }),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _selectedSubjectId == null
                                      ? const Color(0xFFE0D8D0)
                                      : const Color(0xFFF5EFE3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text('None',
                                    style: AppTypography.labelSmall(
                                        color: const Color(0xFF7F7662))),
                              ),
                            ),
                            ...subjects.map((s) {
                              final isSelected =
                                  s.id == _selectedSubjectId;
                              final color = _colorFromHex(s.color);
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _selectedSubjectId = s.id;
                                }),
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? color.withValues(alpha: 0.2)
                                        : const Color(0xFFF5EFE3),
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    border: isSelected
                                        ? Border.all(
                                            color: color.withValues(
                                                alpha: 0.5))
                                        : null,
                                  ),
                                  child: Text(s.code.isNotEmpty ? s.code : s.name,
                                      style: AppTypography.labelSmall(
                                              color: isSelected
                                                  ? color
                                                  : const Color(0xFF7F7662))
                                          .copyWith(
                                              fontWeight:
                                                  FontWeight.bold)),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Due Date ────────────────────────────────────────────
                  _sectionLabel('DUE DATE'),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _dueDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F0E8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: Color(0xFF7F7662)),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(_dueDate),
                            style: AppTypography.bodySmall(
                                    color: const Color(0xFF4E4634))
                                .copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Priority ────────────────────────────────────────────
                  _sectionLabel('PRIORITY'),
                  const SizedBox(height: 10),
                  Row(
                    children: TaskPriority.values.map((p) {
                      final isSelected = p == _selectedPriority;
                      final color = _priorityColor(p);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedPriority = p),
                          child: Container(
                            margin: EdgeInsets.only(
                                right:
                                    p != TaskPriority.values.last ? 8 : 0),
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withValues(alpha: 0.15)
                                  : const Color(0xFFF5EFE3),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: color.withValues(alpha: 0.4))
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _priorityLabel(p),
                              style: AppTypography.labelSmall(
                                      color: isSelected
                                          ? color
                                          : const Color(0xFF7F7662))
                                  .copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // ── AI Toggle ───────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EFE3).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF0E8DC)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('✨',
                                      style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Let AI break this into subtasks',
                                    style: AppTypography.bodySmall(
                                            color: const Color(0xFF1B1C1C))
                                        .copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sprout will suggest step-by-step subtasks',
                                style: AppTypography.bodySmall(
                                        color: const Color(0xFF7F7662))
                                    .copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _aiEnabled,
                          onChanged: (v) =>
                              setState(() => _aiEnabled = v),
                          activeThumbColor: AppColors.white,
                          activeTrackColor: AppColors.primaryContainer,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Save Button ───────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.paddingOf(context).bottom > 0
                  ? MediaQuery.paddingOf(context).bottom
                  : 16,
            ),
            child: GestureDetector(
              onTap: isLoading ? null : _save,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isLoading
                      ? AppColors.softGrey
                      : AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textPrimary))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('✏️',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text('Add Task',
                              style: AppTypography.titleSmall(
                                      color: const Color(0xFF6D5400))
                                  .copyWith(fontSize: 15)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: AppTypography.labelSmall(color: const Color(0xFF7F7662))
            .copyWith(letterSpacing: 0.8, fontSize: 11),
      );

  String _typeLabel(TaskType t) {
    switch (t) {
      case TaskType.assignment:
        return '📝 Assignment';
      case TaskType.exam:
        return '📖 Exam';
      case TaskType.lab:
        return '🔬 Lab';
      case TaskType.task:
        return '📌 Task';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  String _priorityLabel(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
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

  Color _colorFromHex(String hex) {
    try {
      return Color(
          int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.sageDark;
    }
  }
}
