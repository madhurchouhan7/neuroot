import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TaskStatus { pending, inProgress, done }
enum PlannerTab { tasks, aiPlan }

class Microtask {
  final String id;
  final String title;
  final String subject;
  final int estimatedMinutes;
  final TaskStatus status;

  const Microtask({required this.id, required this.title, required this.subject, required this.estimatedMinutes, this.status = TaskStatus.pending});

  Microtask copyWith({TaskStatus? status}) => Microtask(
    id: id, title: title, subject: subject, estimatedMinutes: estimatedMinutes,
    status: status ?? this.status,
  );
}

class PlannerTask {
  final String id;
  final String title;
  final String subject;
  final String colorHex;
  final DateTime dueDate;
  final TaskStatus status;
  final String? description;
  final List<Microtask> microtasks;

  const PlannerTask({required this.id, required this.title, required this.subject, required this.colorHex, required this.dueDate, this.status = TaskStatus.pending, this.description, this.microtasks = const []});

  bool get isOverdue => dueDate.isBefore(DateTime.now()) && status != TaskStatus.done;

  String get dueDateLabel {
    final now = DateTime.now();
    final diff = dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return 'Due Today';
    if (diff == 1) return 'Due Tomorrow';
    if (diff < 0) return 'Overdue by ${-diff}d';
    return 'Due in ${diff}d';
  }

  PlannerTask copyWith({TaskStatus? status}) => PlannerTask(
    id: id, title: title, subject: subject, colorHex: colorHex, dueDate: dueDate,
    status: status ?? this.status, description: description, microtasks: microtasks,
  );
}

class PlannerState {
  final List<PlannerTask> tasks;
  final PlannerTab activeTab;
  final bool isGeneratingAI;
  final List<Microtask> aiMicrotasks;
  final String? aiTaskInput;

  const PlannerState({this.tasks = const [], this.activeTab = PlannerTab.tasks, this.isGeneratingAI = false, this.aiMicrotasks = const [], this.aiTaskInput});

  List<PlannerTask> get pendingTasks => tasks.where((t) => t.status != TaskStatus.done).toList();
  List<PlannerTask> get doneTasks    => tasks.where((t) => t.status == TaskStatus.done).toList();
  int get completedToday => doneTasks.length;

  PlannerState copyWith({List<PlannerTask>? tasks, PlannerTab? activeTab, bool? isGeneratingAI, List<Microtask>? aiMicrotasks, String? aiTaskInput}) =>
      PlannerState(
        tasks: tasks ?? this.tasks, activeTab: activeTab ?? this.activeTab,
        isGeneratingAI: isGeneratingAI ?? this.isGeneratingAI,
        aiMicrotasks: aiMicrotasks ?? this.aiMicrotasks,
        aiTaskInput: aiTaskInput ?? this.aiTaskInput,
      );
}

// ─── Riverpod 3.x Notifier ───────────────────────────────────────────────────
class PlannerNotifier extends Notifier<PlannerState> {
  @override
  PlannerState build() {
    final now = DateTime.now();
    return PlannerState(
      tasks: [
        PlannerTask(
          id: '1', title: 'OS Assignment — Process Scheduling',
          subject: 'Operating Systems', colorHex: '#7CB9E8',
          dueDate: now.add(const Duration(days: 1)),
          description: 'Implement Round Robin and Priority Scheduling',
          microtasks: const [
            Microtask(id: 'm1', title: 'Read Chapter 5 — CPU Scheduling', subject: 'OS', estimatedMinutes: 15),
            Microtask(id: 'm2', title: 'Code Round Robin algorithm',       subject: 'OS', estimatedMinutes: 20),
            Microtask(id: 'm3', title: 'Test with sample processes',       subject: 'OS', estimatedMinutes: 10),
            Microtask(id: 'm4', title: 'Write report section',             subject: 'OS', estimatedMinutes: 15),
          ],
        ),
        PlannerTask(
          id: '2', title: 'DSA Lab Report',
          subject: 'Data Structures', colorHex: '#A8D5BA',
          dueDate: now.add(const Duration(days: 3)),
          microtasks: const [
            Microtask(id: 'm5', title: 'Complete Linked List implementation', subject: 'DSA', estimatedMinutes: 20),
            Microtask(id: 'm6', title: 'Document time complexity analysis',   subject: 'DSA', estimatedMinutes: 15),
          ],
        ),
        PlannerTask(
          id: '3', title: 'Networks Quiz Revision',
          subject: 'Computer Networks', colorHex: '#CDB4DB',
          dueDate: now.add(const Duration(days: 5)),
          microtasks: const [
            Microtask(id: 'm7', title: 'Revise OSI model layers',       subject: 'CN', estimatedMinutes: 15),
            Microtask(id: 'm8', title: 'Practice TCP/IP problems',       subject: 'CN', estimatedMinutes: 20),
            Microtask(id: 'm9', title: 'Review past quiz questions',     subject: 'CN', estimatedMinutes: 10),
          ],
        ),
      ],
    );
  }

  void setTab(PlannerTab tab) => state = state.copyWith(activeTab: tab);

  void toggleTaskDone(String id) {
    final updated = state.tasks.map((t) {
      if (t.id != id) return t;
      return t.copyWith(status: t.status == TaskStatus.done ? TaskStatus.pending : TaskStatus.done);
    }).toList();
    state = state.copyWith(tasks: updated);
  }

  Future<void> generateMicrotasks(String taskDescription) async {
    state = state.copyWith(isGeneratingAI: true, aiTaskInput: taskDescription);
    await Future<void>.delayed(const Duration(seconds: 2));
    state = state.copyWith(
      isGeneratingAI: false,
      aiMicrotasks: [
        Microtask(id: 'ai1', title: 'Read introduction & overview',    subject: taskDescription, estimatedMinutes: 15),
        Microtask(id: 'ai2', title: 'Note down key concepts',          subject: taskDescription, estimatedMinutes: 10),
        Microtask(id: 'ai3', title: 'Practice 3 example problems',     subject: taskDescription, estimatedMinutes: 20),
        Microtask(id: 'ai4', title: 'Review and summarise learning',   subject: taskDescription, estimatedMinutes: 10),
        Microtask(id: 'ai5', title: 'Take a short quiz / self-test',   subject: taskDescription, estimatedMinutes: 15),
      ],
    );
  }

  void clearAIPlan() => state = state.copyWith(aiMicrotasks: [], aiTaskInput: null);
}

final plannerProvider =
    NotifierProvider<PlannerNotifier, PlannerState>(PlannerNotifier.new);

