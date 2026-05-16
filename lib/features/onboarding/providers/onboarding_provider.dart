import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/services/firestore_service.dart';
import 'package:neuroot/features/auth/providers/user_provider.dart';

// ─── Onboarding State ─────────────────────────────────────────────────────────

class OnboardingState {
  final bool isLoading;
  final String? errorMessage;
  final bool isComplete;

  // Collected data across steps
  final String semesterName;
  final DateTime? startDate;
  final DateTime? endDate;
  final int attendanceThreshold;
  final List<Map<String, String>> subjects; // [{name, color}]

  const OnboardingState({
    this.isLoading = false,
    this.errorMessage,
    this.isComplete = false,
    this.semesterName = '',
    this.startDate,
    this.endDate,
    this.attendanceThreshold = 75,
    this.subjects = const [],
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
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  FirestoreService get _fs => ref.read(firestoreServiceProvider);
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ── Local state setters (no network call) ────────────────────────────────────

  void setSemesterName(String name) =>
      state = state.copyWith(semesterName: name);

  void setStartDate(DateTime d) => state = state.copyWith(startDate: d);

  void setEndDate(DateTime d) => state = state.copyWith(endDate: d);

  void setAttendanceThreshold(int t) =>
      state = state.copyWith(attendanceThreshold: t);

  void setSubjects(List<Map<String, String>> subs) =>
      state = state.copyWith(subjects: subs);

  // ── Step 2: Save semester + subjects to Firestore ────────────────────────────

  Future<bool> createSemester() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final now = DateTime.now();
      final semData = {
        'name': state.semesterName.isNotEmpty
            ? state.semesterName
            : 'My Semester',
        'startDate':
            Timestamp.fromDate(state.startDate ?? now),
        'endDate': Timestamp.fromDate(
            state.endDate ?? now.add(const Duration(days: 120))),
        'attendanceThreshold': state.attendanceThreshold,
        'isActive': true,
      };

      final semId =
          await _fs.addDoc('users/$_uid/semesters', semData);

      // Write each subject
      for (final sub in state.subjects) {
        await _fs.addDoc('users/$_uid/subjects', {
          'name': sub['name'] ?? '',
          'code': sub['code'] ?? '',
          'color': sub['color'] ?? '#A8D5BA',
          'semesterId': semId,
          'totalClasses': 0,
          'presentClasses': 0,
          'cancelledClasses': 0,
        });
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

  // ── Final step: Mark onboarding complete ─────────────────────────────────────

  Future<void> completeOnboarding() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _fs.updateDoc('users/$_uid', {
        'onboardingComplete': true,
        'lastActiveDate': FieldValue.serverTimestamp(),
      });
      // Also invalidate userDocProvider so router redirect picks it up
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
    NotifierProvider<OnboardingNotifier, OnboardingState>(
        OnboardingNotifier.new);
