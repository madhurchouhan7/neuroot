import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/services/firestore_service.dart';
import 'package:neuroot/features/auth/providers/user_provider.dart';

// ─── Default subjects ─────────────────────────────────────────────────────────

const _defaultSubjects = <Map<String, String>>[
  {'name': 'Data Structures', 'code': 'DSA', 'color': '#FF8A65'},
  {'name': 'Computer Networks', 'code': 'CN', 'color': '#7C5CBF'},
  {'name': 'Operating Systems', 'code': 'OS', 'color': '#52B788'},
  {'name': 'EMFT', 'code': 'EMFT', 'color': '#E8A020'},
  {'name': 'DBMS', 'code': 'DBMS', 'color': '#BA1A1A'},
];

// ─── Onboarding State ─────────────────────────────────────────────────────────

class OnboardingState {
  final bool isLoading;
  final String? errorMessage;
  final bool isComplete;

  // Semester fields
  final String semesterName;
  final DateTime? startDate;
  final DateTime? endDate;
  final int attendanceThreshold;
  final List<Map<String, String>> subjects; // [{name, code, color}]

  // Timetable: day → list of class entries
  final Map<String, List<Map<String, dynamic>>> timetable;

  const OnboardingState({
    this.isLoading = false,
    this.errorMessage,
    this.isComplete = false,
    this.semesterName = '',
    this.startDate,
    this.endDate,
    this.attendanceThreshold = 75,
    this.subjects = _defaultSubjects,
    this.timetable = const {},
  });

  OnboardingState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isComplete,
    String? semesterName,
    DateTime? startDate,
    DateTime? endDate,
    int? attendanceThreshold,
    List<Map<String, String>>? subjects,
    Map<String, List<Map<String, dynamic>>>? timetable,
    bool clearError = false,
  }) =>
      OnboardingState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        isComplete: isComplete ?? this.isComplete,
        semesterName: semesterName ?? this.semesterName,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        attendanceThreshold: attendanceThreshold ?? this.attendanceThreshold,
        subjects: subjects ?? this.subjects,
        timetable: timetable ?? this.timetable,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  FirestoreService get _fs => ref.read(firestoreServiceProvider);
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ── Setters ──────────────────────────────────────────────────────────────────

  void setSemesterName(String name) => state = state.copyWith(semesterName: name);
  void setStartDate(DateTime d) => state = state.copyWith(startDate: d);
  void setEndDate(DateTime d) => state = state.copyWith(endDate: d);
  void setAttendanceThreshold(int t) => state = state.copyWith(attendanceThreshold: t);

  void addSubject(Map<String, String> sub) =>
      state = state.copyWith(subjects: [...state.subjects, sub]);

  void removeSubject(int index) {
    final updated = [...state.subjects]..removeAt(index);
    state = state.copyWith(subjects: updated);
  }

  // ── Day / time helpers ───────────────────────────────────────────────────────

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static int _dayIndex(String day) {
    final idx = _dayNames.indexOf(day);
    return idx < 0 ? 0 : idx;
  }

  /// Converts "9:30 AM" / "10:00 PM" → "09:30" / "22:00"
  static String _to24h(String t) {
    try {
      final parts = t.split(' ');
      if (parts.length != 2) return t;
      final timeParts = parts[0].split(':');
      int h = int.parse(timeParts[0]);
      final m = int.parse(timeParts[1]);
      final isPm = parts[1].toUpperCase() == 'PM';
      if (isPm && h != 12) h += 12;
      if (!isPm && h == 12) h = 0;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    } catch (_) {
      return t;
    }
  }

  void addTimetableClass(String day, Map<String, dynamic> entry) {
    final updated = Map<String, List<Map<String, dynamic>>>.from(state.timetable);
    updated[day] = [...(updated[day] ?? []), entry];
    state = state.copyWith(timetable: updated);
  }

  void removeTimetableClass(String day, int index) {
    final updated = Map<String, List<Map<String, dynamic>>>.from(state.timetable);
    final dayList = <Map<String, dynamic>>[...(updated[day] ?? [])]..removeAt(index);
    updated[day] = dayList;
    state = state.copyWith(timetable: updated);
  }

  // ── Save to Firestore (post-auth) ────────────────────────────────────────────

  Future<bool> createSemester() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final now = DateTime.now();
      final semId = await _fs.addDoc('users/$_uid/semesters', {
        'name': state.semesterName.isNotEmpty ? state.semesterName : 'My Semester',
        'startDate': Timestamp.fromDate(state.startDate ?? now),
        'endDate': Timestamp.fromDate(state.endDate ?? now.add(const Duration(days: 120))),
        'attendanceThreshold': state.attendanceThreshold,
        'isActive': true,
      });

      // Write subjects, collect code→id map
      final subjectIds = <String, String>{};
      for (final sub in state.subjects) {
        final id = await _fs.addDoc('users/$_uid/subjects', {
          'name': sub['name'] ?? '',
          'code': sub['code'] ?? '',
          'color': sub['color'] ?? '#A8D5BA',
          'semesterId': semId,
          'totalClasses': 0,
          'presentClasses': 0,
          'cancelledClasses': 0,
        });
        subjectIds[sub['code'] ?? ''] = id;
      }

      // Write timetable entries
      for (final entry in state.timetable.entries) {
        for (final cls in entry.value) {
          await _fs.addDoc('users/$_uid/timetable', {
            'day': entry.key,
            'dayOfWeek': _dayIndex(entry.key), // int 0=Mon…6=Sun
            'subjectName': cls['subjectName'] ?? '',
            'subjectCode': cls['subjectCode'] ?? '',
            'subjectColor': cls['subjectColor'] ?? '#A8D5BA',
            'subjectId': subjectIds[cls['subjectCode'] ?? ''] ?? '',
            'startTime': _to24h(cls['startTime'] as String? ?? ''),
            'endTime': _to24h(cls['endTime'] as String? ?? ''),
            'room': cls['room'] ?? '',
            'professor': cls['professor'] ?? '',
            'semesterId': semId,
          });
        }
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Couldn't save your semester. Try again 🌱",
      );
      return false;
    }
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _fs.updateDoc('users/$_uid', {
        'onboardingComplete': true,
        'lastActiveDate': FieldValue.serverTimestamp(),
      });
      ref.invalidate(userDocProvider);
      state = state.copyWith(isLoading: false, isComplete: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Couldn't complete setup. Try again 🌱",
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(OnboardingNotifier.new);
