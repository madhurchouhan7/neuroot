import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neuroot/core/models/task_model.dart';
import 'package:neuroot/core/services/firestore_service.dart';

class TaskRepository {
  TaskRepository(this._fs);

  final FirestoreService _fs;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ─── Stream ────────────────────────────────────────────────────────────────

  /// Real-time stream of all tasks, sorted by due date ascending.
  Stream<List<TaskModel>> getTasksStream() {
    return _fs
        .collection('users/$_uid/tasks')
        .orderBy('dueDate')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TaskModel.fromFirestore(d)).toList());
  }

  // ─── CRUD ──────────────────────────────────────────────────────────────────

  /// Add a new task. Returns the auto-generated task ID.
  Future<String> addTask(TaskModel task) {
    return _fs.addDoc('users/$_uid/tasks', task.toFirestore());
  }

  /// Update specific fields of a task by ID.
  Future<void> updateTask(String taskId, Map<String, dynamic> updates) {
    return _fs.updateDoc('users/$_uid/tasks/$taskId', updates);
  }

  /// Delete a task permanently.
  Future<void> deleteTask(String taskId) {
    return _fs.deleteDoc('users/$_uid/tasks/$taskId');
  }

  /// Toggle a task's completed status.
  /// If completing, sets `completedAt` to server timestamp.
  Future<void> toggleComplete(String taskId, {required bool isCompleted}) {
    return _fs.updateDoc('users/$_uid/tasks/$taskId', {
      'isCompleted': isCompleted,
      'completedAt': isCompleted ? Timestamp.fromDate(DateTime.now()) : null,
    });
  }
}
