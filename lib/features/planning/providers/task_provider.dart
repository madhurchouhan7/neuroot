import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/models/task_model.dart';
import 'package:neuroot/features/auth/providers/user_provider.dart';
import 'package:neuroot/features/planning/repositories/task_repository.dart';

// ─── Repository Provider ──────────────────────────────────────────────────────

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.read(firestoreServiceProvider));
});

// ─── Filter Enum ──────────────────────────────────────────────────────────────

enum TaskFilter { all, assignments, exams, labs }

class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => TaskFilter.all;
  void setFilter(TaskFilter f) => state = f;
}

final activeTaskFilterProvider =
    NotifierProvider<TaskFilterNotifier, TaskFilter>(TaskFilterNotifier.new);

// ─── Tasks Stream ─────────────────────────────────────────────────────────────

/// Real-time stream of all tasks ordered by due date.
final tasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  return ref.watch(taskRepositoryProvider).getTasksStream();
});

// ─── Filtered Tasks ───────────────────────────────────────────────────────────

/// Derived: tasks filtered by [activeTaskFilterProvider].
final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksStreamProvider).asData?.value ?? [];
  final filter = ref.watch(activeTaskFilterProvider);

  switch (filter) {
    case TaskFilter.all:
      return tasks;
    case TaskFilter.assignments:
      return tasks
          .where((t) => t.type == TaskType.assignment && !t.isCompleted)
          .toList();
    case TaskFilter.exams:
      return tasks
          .where((t) => t.type == TaskType.exam && !t.isCompleted)
          .toList();
    case TaskFilter.labs:
      return tasks
          .where((t) => t.type == TaskType.lab && !t.isCompleted)
          .toList();
  }
});

// ─── Upcoming Tasks (Dashboard) ───────────────────────────────────────────────

/// Top 3 incomplete tasks sorted by due date + priority.
final upcomingTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksStreamProvider).asData?.value ?? [];
  final incomplete = tasks.where((t) => !t.isCompleted).toList()
    ..sort((a, b) {
      final dateCmp = a.dueDate.compareTo(b.dueDate);
      if (dateCmp != 0) return dateCmp;
      return a.priority.index.compareTo(b.priority.index);
    });
  return incomplete.take(3).toList();
});

// ─── Task Action State ────────────────────────────────────────────────────────

class TaskActionState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const TaskActionState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  TaskActionState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) =>
      TaskActionState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
        successMessage:
            clearMessages ? null : successMessage ?? this.successMessage,
      );
}

// ─── Task Notifier ────────────────────────────────────────────────────────────

class TaskNotifier extends Notifier<TaskActionState> {
  @override
  TaskActionState build() => const TaskActionState();

  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  Future<void> addTask({
    required String title,
    required TaskType type,
    required TaskPriority priority,
    String subjectId = '',
    DateTime? dueDate,
    String notes = '',
  }) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final task = TaskModel(
        id: '',
        title: title,
        subjectId: subjectId,
        type: type,
        priority: priority,
        dueDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
        notes: notes,
      );
      await _repo.addTask(task);
      state = state.copyWith(
          isLoading: false, successMessage: '✅ Task added!');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Couldn't add task. Try again 🌱",
      );
    }
  }

  Future<void> toggleComplete(String taskId,
      {required bool isCompleted}) async {
    try {
      await _repo.toggleComplete(taskId, isCompleted: isCompleted);
      if (isCompleted) {
        // Award 10 XP on task completion
        try {
          await ref.read(userNotifierProvider.notifier).awardXp(10);
        } catch (_) {}
        state = state.copyWith(
            successMessage: '🎉 Task complete! +10 XP');
      }
    } catch (e) {
      state = state.copyWith(
          errorMessage: "Couldn't update task 🌱");
    }
  }

  Future<void> deleteTask(String taskId) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      await _repo.deleteTask(taskId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Couldn't delete task 🌱",
      );
    }
  }

  Future<void> updateTask(
      String taskId, Map<String, dynamic> updates) async {
    try {
      await _repo.updateTask(taskId, updates);
    } catch (e) {
      state =
          state.copyWith(errorMessage: "Couldn't update task 🌱");
    }
  }

  void clearMessages() => state = state.copyWith(clearMessages: true);
}

final taskNotifierProvider =
    NotifierProvider<TaskNotifier, TaskActionState>(TaskNotifier.new);
