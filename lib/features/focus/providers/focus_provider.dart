import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neuroot/features/auth/providers/user_provider.dart';

enum FocusPhase { idle, focusing, breakTime, completed }

enum AmbientSound { none, rain, forest, fire }

class FocusState {
  final FocusPhase phase;
  final int totalSeconds;
  final int elapsedSeconds;
  final int completedSessions;
  final int targetSessions;
  final String? taskName;
  final bool isDeepFocus;
  final AmbientSound ambientSound;
  final bool isPaused;

  const FocusState({
    this.phase = FocusPhase.idle,
    this.totalSeconds = 25 * 60,
    this.elapsedSeconds = 0,
    this.completedSessions = 0,
    this.targetSessions = 4,
    this.taskName,
    this.isDeepFocus = false,
    this.ambientSound = AmbientSound.none,
    this.isPaused = false,
  });

  int get remainingSeconds => totalSeconds - elapsedSeconds;
  double get progress => totalSeconds == 0 ? 0 : elapsedSeconds / totalSeconds;

  String get formattedTime {
    final r = remainingSeconds.clamp(0, totalSeconds);
    final m = (r ~/ 60).toString().padLeft(2, '0');
    final s = (r % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  FocusState copyWith({
    FocusPhase? phase, int? totalSeconds, int? elapsedSeconds,
    int? completedSessions, int? targetSessions, String? taskName,
    bool? isDeepFocus, AmbientSound? ambientSound, bool? isPaused,
  }) => FocusState(
    phase: phase ?? this.phase,
    totalSeconds: totalSeconds ?? this.totalSeconds,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    completedSessions: completedSessions ?? this.completedSessions,
    targetSessions: targetSessions ?? this.targetSessions,
    taskName: taskName ?? this.taskName,
    isDeepFocus: isDeepFocus ?? this.isDeepFocus,
    ambientSound: ambientSound ?? this.ambientSound,
    isPaused: isPaused ?? this.isPaused,
  );
}

// ─── Riverpod 3.x Notifier ───────────────────────────────────────────────────
class FocusNotifier extends Notifier<FocusState> {
  Timer? _timer;

  @override
  FocusState build() => const FocusState();

  void toggleDeepFocus() {
    state = state.copyWith(isDeepFocus: !state.isDeepFocus);
  }

  void setAmbientSound(AmbientSound sound) {
    state = state.copyWith(ambientSound: sound);
    // TODO: Integrate just_audio here to play sound based on selection
    if (sound != AmbientSound.none) {
      print('Playing $sound sound...');
    } else {
      print('Stopping ambient sound.');
    }
  }

  void startFocus({String? taskName}) {
    _timer?.cancel();
    state = FocusState(
      phase: FocusPhase.focusing,
      totalSeconds: 25 * 60,
      elapsedSeconds: 0,
      completedSessions: state.completedSessions,
      targetSessions: state.targetSessions,
      taskName: taskName ?? state.taskName,
      isDeepFocus: state.isDeepFocus,
      ambientSound: state.ambientSound,
      isPaused: false,
    );
    _tick();
  }

  void startBreak({bool isLong = false}) {
    _timer?.cancel();
    state = state.copyWith(
      phase: FocusPhase.breakTime,
      totalSeconds: isLong ? 15 * 60 : 5 * 60,
      elapsedSeconds: 0,
      isPaused: false,
    );
    _tick();
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isPaused: true);
  }

  void resume() {
    state = state.copyWith(isPaused: false);
    _tick();
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      phase: FocusPhase.idle,
      elapsedSeconds: 0,
      isPaused: false,
    );
  }

  void _tick() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.elapsedSeconds >= state.totalSeconds) {
        _timer?.cancel();
        if (state.phase == FocusPhase.focusing) {
          final newCompletedSessions = state.completedSessions + 1;
          state = state.copyWith(
            phase: FocusPhase.completed,
            completedSessions: newCompletedSessions,
          );
          ref.read(focusSessionProvider.notifier).saveSession(
            durationMinutes: state.totalSeconds ~/ 60,
            sessionsCompleted: 1, // saving one session at a time
          );
        } else {
          state = state.copyWith(phase: FocusPhase.idle);
        }
        return;
      }
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }
}

final focusProvider =
    NotifierProvider<FocusNotifier, FocusState>(FocusNotifier.new);

// ─── Session Persistence ──────────────────────────────────────────────────────

class FocusSessionNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> saveSession({
    required int durationMinutes,
    required int sessionsCompleted,
    String? linkedTaskId,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    state = const AsyncLoading();
    try {
      await FirebaseFirestore.instance.collection('users/$uid/focusSessions').add({
        'date': FieldValue.serverTimestamp(),
        'durationMinutes': durationMinutes,
        'sessionsCompleted': sessionsCompleted,
        'linkedTaskId': linkedTaskId,
      });

      // Award 25 XP per session completed
      ref.read(userNotifierProvider.notifier).awardXp(25 * sessionsCompleted);
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final focusSessionProvider =
    AsyncNotifierProvider<FocusSessionNotifier, void>(FocusSessionNotifier.new);

