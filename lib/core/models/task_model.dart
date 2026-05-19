import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskType { assignment, exam, lab, task }
enum TaskPriority { high, medium, low }

extension TaskTypeExtension on TaskType {
  String get value => name;
  static TaskType fromString(String s) =>
      TaskType.values.firstWhere((e) => e.name == s, orElse: () => TaskType.task);
}

extension TaskPriorityExtension on TaskPriority {
  String get value => name;
  static TaskPriority fromString(String s) =>
      TaskPriority.values.firstWhere((e) => e.name == s,
          orElse: () => TaskPriority.medium);
}

/// A subtask item with a title and completion flag.
class SubtaskItem {
  final String title;
  final bool isDone;
  const SubtaskItem({required this.title, this.isDone = false});

  SubtaskItem copyWith({String? title, bool? isDone}) =>
      SubtaskItem(title: title ?? this.title, isDone: isDone ?? this.isDone);

  Map<String, dynamic> toMap() => {'title': title, 'isDone': isDone};
  factory SubtaskItem.fromMap(Map<String, dynamic> m) =>
      SubtaskItem(title: m['title'] as String? ?? '', isDone: m['isDone'] as bool? ?? false);
}

/// A topic/checklist item used by Exam and Lab screens.
class TopicItem {
  final String title;
  final bool isDone;
  const TopicItem({required this.title, this.isDone = false});

  TopicItem copyWith({String? title, bool? isDone}) =>
      TopicItem(title: title ?? this.title, isDone: isDone ?? this.isDone);

  Map<String, dynamic> toMap() => {'title': title, 'isDone': isDone};
  factory TopicItem.fromMap(Map<String, dynamic> m) =>
      TopicItem(title: m['title'] as String? ?? '', isDone: m['isDone'] as bool? ?? false);
}

/// Mirrors Firestore: users/{uid}/tasks/{taskId}
class TaskModel {
  final String id;
  final String title;
  final String subjectId;
  final TaskType type;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime? completedAt;
  final String notes;
  final List<SubtaskItem> subtasks;
  final List<TopicItem> topics;

  const TaskModel({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.dueDate,
    this.type = TaskType.task,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    this.completedAt,
    this.notes = '',
    this.subtasks = const [],
    this.topics = const [],
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    List<SubtaskItem> subtasks = [];
    if (data['subtasks'] is List) {
      subtasks = (data['subtasks'] as List)
          .map((e) => SubtaskItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    List<TopicItem> topics = [];
    if (data['topics'] is List) {
      topics = (data['topics'] as List)
          .map((e) => TopicItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return TaskModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      subjectId: data['subjectId'] as String? ?? '',
      type: TaskTypeExtension.fromString(data['type'] as String? ?? 'task'),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priority: TaskPriorityExtension.fromString(
          data['priority'] as String? ?? 'medium'),
      isCompleted: data['isCompleted'] as bool? ?? false,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      notes: data['notes'] as String? ?? '',
      subtasks: subtasks,
      topics: topics,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'subjectId': subjectId,
        'type': type.value,
        'dueDate': Timestamp.fromDate(dueDate),
        'priority': priority.value,
        'isCompleted': isCompleted,
        'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
        'notes': notes,
        'subtasks': subtasks.map((s) => s.toMap()).toList(),
        'topics': topics.map((t) => t.toMap()).toList(),
      };

  TaskModel copyWith({
    String? title,
    String? subjectId,
    TaskType? type,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? completedAt,
    String? notes,
    List<SubtaskItem>? subtasks,
    List<TopicItem>? topics,
  }) =>
      TaskModel(
        id: id,
        title: title ?? this.title,
        subjectId: subjectId ?? this.subjectId,
        type: type ?? this.type,
        dueDate: dueDate ?? this.dueDate,
        priority: priority ?? this.priority,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt ?? this.completedAt,
        notes: notes ?? this.notes,
        subtasks: subtasks ?? this.subtasks,
        topics: topics ?? this.topics,
      );
}
