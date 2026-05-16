import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/models/attendance_record_model.dart';
import 'package:neuroot/core/models/subject_model.dart';
import 'package:neuroot/features/academic/repositories/attendance_repository.dart';
import 'package:neuroot/features/auth/providers/user_provider.dart';

// ─── Repository Provider ──────────────────────────────────────────────────────

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.read(firestoreServiceProvider));
});

// ─── Subjects Stream ──────────────────────────────────────────────────────────

/// Real-time stream of all subjects sorted by name.
final subjectsStreamProvider = StreamProvider<List<SubjectModel>>((ref) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getSubjectsStream();
});

// ─── Attendance Records Stream ────────────────────────────────────────────────

/// Real-time stream of attendance records for a given [subjectId].
final attendanceRecordsProvider =
    StreamProvider.family<List<AttendanceRecord>, String>((ref, subjectId) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getAttendanceStream(subjectId);
});

// ─── Overall Attendance ───────────────────────────────────────────────────────

/// Derived: combined attendance % across ALL subjects.
final overallAttendanceProvider = Provider<double?>((ref) {
  final subjects = ref.watch(subjectsStreamProvider).asData?.value;
  if (subjects == null || subjects.isEmpty) return null;

  int totalPresent = 0;
  int totalClasses = 0;
  for (final s in subjects) {
    totalPresent += s.presentClasses;
    totalClasses += s.totalClasses;
  }
  if (totalClasses == 0) return null;
  return (totalPresent / totalClasses) * 100;
});

// ─── Safe Leaves ─────────────────────────────────────────────────────────────

/// Derived: safe leaves remaining for a specific subject.
final safeLeavesProvider = Provider.family<int, SubjectModel>((ref, subject) {
  return AttendanceRepository.computeSafeLeaves(subject, threshold: 75);
});

// ─── Danger Subjects ──────────────────────────────────────────────────────────

/// Subjects with attendance % below 75.
final dangerSubjectsProvider = Provider<List<SubjectModel>>((ref) {
  final subjects = ref.watch(subjectsStreamProvider).asData?.value ?? [];
  return subjects
      .where((s) => s.totalClasses > 0 && s.attendancePercentage < 75)
      .toList();
});

// ─── Attendance Notifier State ────────────────────────────────────────────────

class AttendanceActionState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const AttendanceActionState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  AttendanceActionState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) =>
      AttendanceActionState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
        successMessage:
            clearMessages ? null : successMessage ?? this.successMessage,
      );
}

// ─── Attendance Notifier ──────────────────────────────────────────────────────

class AttendanceNotifier extends Notifier<AttendanceActionState> {
  @override
  AttendanceActionState build() => const AttendanceActionState();

  AttendanceRepository get _repo => ref.read(attendanceRepositoryProvider);

  Future<void> markAttendance({
    required String subjectId,
    required DateTime date,
    required AttendanceStatus status,
  }) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      await _repo.markAttendance(
          subjectId: subjectId, date: date, status: status);
      final emoji = status == AttendanceStatus.present
          ? '✅'
          : (status == AttendanceStatus.absent ? '😔' : '📌');
      state = state.copyWith(
        isLoading: false,
        successMessage: '$emoji Attendance marked!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Couldn't mark attendance. Try again 🌱",
      );
    }
  }

  Future<void> editAttendance({
    required String recordId,
    required String subjectId,
    required AttendanceStatus oldStatus,
    required AttendanceStatus newStatus,
  }) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      await _repo.editAttendance(
        recordId: recordId,
        subjectId: subjectId,
        oldStatus: oldStatus,
        newStatus: newStatus,
      );
      state = state.copyWith(isLoading: false, successMessage: '✏️ Updated!');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Couldn't update attendance 🌱",
      );
    }
  }

  Future<void> addSubject({
    required String name,
    required String code,
    required String color,
  }) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final semSnap = await ref
          .read(firestoreServiceProvider)
          .collection('users/$uid/semesters')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      final semId =
          semSnap.docs.isNotEmpty ? semSnap.docs.first.id : 'default';
      await _repo.addSubject(
          name: name, code: code, color: color, semesterId: semId);
      state = state.copyWith(
          isLoading: false, successMessage: '🌱 Subject added!');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Couldn't add subject 🌱",
      );
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      await _repo.deleteSubject(subjectId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Couldn't delete subject 🌱",
      );
    }
  }

  void clearMessages() => state = state.copyWith(clearMessages: true);
}

final attendanceNotifierProvider =
    NotifierProvider<AttendanceNotifier, AttendanceActionState>(
        AttendanceNotifier.new);
