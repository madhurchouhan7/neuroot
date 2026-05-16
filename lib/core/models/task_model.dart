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
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      subjectId: data['subjectId'] as String? ?? '',
      type: TaskTypeExtension.fromString(data['type'] as String? ?? 'task'),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      priority: TaskPriorityExtension.fromString(
          data['priority'] as String? ?? 'medium'),
      isCompleted: data['isCompleted'] as bool? ?? false,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      notes: data['notes'] as String? ?? '',
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
      );
}
