import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/services/firestore_service.dart';
import 'package:neuroot/features/auth/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── App Theme Mode ───────────────────────────────────────────────────────────

enum AppThemeMode { light, dark, system, sakuraSpring, darkAcademia }

// ─── Settings State ───────────────────────────────────────────────────────────

class SettingsState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  // Semester
  final String semesterId;
  final String semesterName;
  final DateTime? semesterStart;
  final DateTime? semesterEnd;
  final DateTime? examPeriodStart;
  final int attendanceThreshold;
  final List<Map<String, dynamic>> subjects; // [{id, name, code, color}]

  // Timetable (day → list of class entries)
  final Map<String, List<Map<String, dynamic>>> timetable;

  // Preferences
  final bool notificationsEnabled;
  final bool sproutAIEnabled;
  final bool focusSoundsEnabled;
  final bool dynamicTimetableEnabled;
  final AppThemeMode themeMode;

  const SettingsState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.semesterId = '',
    this.semesterName = '',
    this.semesterStart,
    this.semesterEnd,
    this.examPeriodStart,
    this.attendanceThreshold = 75,
    this.subjects = const [],
    this.timetable = const {},
    this.notificationsEnabled = true,
    this.sproutAIEnabled = true,
    this.focusSoundsEnabled = false,
    this.dynamicTimetableEnabled = true,
    this.themeMode = AppThemeMode.light,
  });

  SettingsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    String? semesterId,
    String? semesterName,
    DateTime? semesterStart,
    DateTime? semesterEnd,
    DateTime? examPeriodStart,
    int? attendanceThreshold,
    List<Map<String, dynamic>>? subjects,
    Map<String, List<Map<String, dynamic>>>? timetable,
    bool? notificationsEnabled,
    bool? sproutAIEnabled,
    bool? focusSoundsEnabled,
    bool? dynamicTimetableEnabled,
    AppThemeMode? themeMode,
    bool clearMessages = false,
  }) =>
      SettingsState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
        successMessage: clearMessages ? null : successMessage ?? this.successMessage,
        semesterId: semesterId ?? this.semesterId,
        semesterName: semesterName ?? this.semesterName,
        semesterStart: semesterStart ?? this.semesterStart,
        semesterEnd: semesterEnd ?? this.semesterEnd,
        examPeriodStart: examPeriodStart ?? this.examPeriodStart,
        attendanceThreshold: attendanceThreshold ?? this.attendanceThreshold,
        subjects: subjects ?? this.subjects,
        timetable: timetable ?? this.timetable,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        sproutAIEnabled: sproutAIEnabled ?? this.sproutAIEnabled,
        focusSoundsEnabled: focusSoundsEnabled ?? this.focusSoundsEnabled,
        dynamicTimetableEnabled: dynamicTimetableEnabled ?? this.dynamicTimetableEnabled,
        themeMode: themeMode ?? this.themeMode,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class SettingsNotifier extends Notifier<SettingsState> {
  static const _prefNotifications = 'pref_notifications';
  static const _prefSproutAI = 'pref_sprout_ai';
  static const _prefFocusSounds = 'pref_focus_sounds';
  static const _prefDynamicTimetable = 'pref_dynamic_timetable';
  static const _prefThemeMode = 'pref_theme_mode';

  @override
  SettingsState build() {
    _load();
    return const SettingsState(isLoading: true);
  }

  FirestoreService get _fs => ref.read(firestoreServiceProvider);
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> _load() async {
    try {
      // ── Load local prefs first (fast) ──────────────────────────────────────
      final prefs = await SharedPreferences.getInstance();
      final themeModeIdx = prefs.getInt(_prefThemeMode) ?? 0;

      state = state.copyWith(
        notificationsEnabled: prefs.getBool(_prefNotifications) ?? true,
        sproutAIEnabled: prefs.getBool(_prefSproutAI) ?? true,
        focusSoundsEnabled: prefs.getBool(_prefFocusSounds) ?? false,
        dynamicTimetableEnabled: prefs.getBool(_prefDynamicTimetable) ?? true,
        themeMode: AppThemeMode.values[themeModeIdx.clamp(0, AppThemeMode.values.length - 1)],
      );

      // ── Load Firestore data ────────────────────────────────────────────────
      final semSnap = await _fs
          .collection('users/$_uid/semesters')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (semSnap.docs.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final semDoc = semSnap.docs.first;
      final semData = semDoc.data() as Map<String, dynamic>;
      final semId = semDoc.id;

      // Load subjects
      final subSnap = await _fs
          .collection('users/$_uid/subjects')
          .orderBy('name')
          .get();

      final subjects = subSnap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return {
          'id': d.id,
          'name': data['name'] ?? '',
          'code': data['code'] ?? '',
          'color': data['color'] ?? '#A8D5BA',
        };
      }).toList();

      // Load timetable
      final ttSnap = await _fs
          .collection('users/$_uid/timetable')
          .orderBy('dayOfWeek')
          .get();

      final timetable = <String, List<Map<String, dynamic>>>{};
      for (final doc in ttSnap.docs) {
        final d = doc.data() as Map<String, dynamic>;
        final day = d['day'] as String? ?? '';
        if (day.isEmpty) continue;
        timetable[day] = [
          ...(timetable[day] ?? []),
          {'id': doc.id, ...d},
        ];
      }

      state = state.copyWith(
        isLoading: false,
        semesterId: semId,
        semesterName: semData['name'] as String? ?? '',
        semesterStart: (semData['startDate'] as Timestamp?)?.toDate(),
        semesterEnd: (semData['endDate'] as Timestamp?)?.toDate(),
        examPeriodStart: (semData['examPeriodStart'] as Timestamp?)?.toDate(),
        attendanceThreshold: semData['attendanceThreshold'] as int? ?? 75,
        subjects: subjects,
        timetable: timetable,
      );
    } catch (e, stack) {
      debugPrint('[SettingsNotifier] _load error: $e\n$stack');
      state = state.copyWith(isLoading: false, errorMessage: e.toString().split('\n').first);
    }
  }

  // ── Reload ────────────────────────────────────────────────────────────────

  Future<void> reload() async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    await _load();
  }

  // ── Semester Update ───────────────────────────────────────────────────────

  Future<void> updateSemester({
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? examPeriodStart,
    int? attendanceThreshold,
  }) async {
    if (state.semesterId.isEmpty) return;
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (startDate != null) data['startDate'] = Timestamp.fromDate(startDate);
      if (endDate != null) data['endDate'] = Timestamp.fromDate(endDate);
      if (examPeriodStart != null) data['examPeriodStart'] = Timestamp.fromDate(examPeriodStart);
      if (attendanceThreshold != null) data['attendanceThreshold'] = attendanceThreshold;

      await _fs.updateDoc('users/$_uid/semesters/${state.semesterId}', data);

      state = state.copyWith(
        isLoading: false,
        semesterName: name ?? state.semesterName,
        semesterStart: startDate ?? state.semesterStart,
        semesterEnd: endDate ?? state.semesterEnd,
        examPeriodStart: examPeriodStart ?? state.examPeriodStart,
        attendanceThreshold: attendanceThreshold ?? state.attendanceThreshold,
        successMessage: '✅ Semester updated!',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Could not update semester 🌱');
    }
  }

  // ── Subjects CRUD ─────────────────────────────────────────────────────────

  Future<void> addSubject({
    required String name,
    required String code,
    required String color,
  }) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final docId = await _fs.addDoc('users/$_uid/subjects', {
        'name': name,
        'code': code,
        'color': color,
        'semesterId': state.semesterId,
        'totalClasses': 0,
        'presentClasses': 0,
        'cancelledClasses': 0,
      });

      final newSub = {'id': docId, 'name': name, 'code': code, 'color': color};
      state = state.copyWith(
        isLoading: false,
        subjects: [...state.subjects, newSub],
        successMessage: '✅ Subject added!',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Could not add subject 🌱');
    }
  }

  Future<void> removeSubject(String subjectId) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      await _fs.deleteDoc('users/$_uid/subjects/$subjectId');
      
      final updatedSubs = state.subjects.where((s) => s['id'] != subjectId).toList();
      state = state.copyWith(
        isLoading: false,
        subjects: updatedSubs,
        successMessage: '🗑️ Subject removed!',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Could not remove subject 🌱');
    }
  }

  // ── Timetable CRUD ────────────────────────────────────────────────────────

  Future<void> addTimetableClass({
    required String day,
    required int dayOfWeek,
    required String subjectName,
    required String subjectCode,
    required String subjectColor,
    required String subjectId,
    required String startTime,
    required String endTime,
    String room = '',
    String professor = '',
  }) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final id = await _fs.addDoc('users/$_uid/timetable', {
        'day': day,
        'dayOfWeek': dayOfWeek,
        'subjectName': subjectName,
        'subjectCode': subjectCode,
        'subjectColor': subjectColor,
        'subjectId': subjectId,
        'startTime': startTime,
        'endTime': endTime,
        'room': room,
        'professor': professor,
        'semesterId': state.semesterId,
      });

      final entry = {
        'id': id, 'day': day, 'dayOfWeek': dayOfWeek,
        'subjectName': subjectName, 'subjectCode': subjectCode,
        'subjectColor': subjectColor, 'subjectId': subjectId,
        'startTime': startTime, 'endTime': endTime, 'room': room,
        'professor': professor,
      };

      final updatedTT = Map<String, List<Map<String, dynamic>>>.from(state.timetable);
      updatedTT[day] = [...(updatedTT[day] ?? []), entry]
        ..sort((a, b) => (a['startTime'] as String).compareTo(b['startTime'] as String));

      state = state.copyWith(isLoading: false, timetable: updatedTT, successMessage: '✅ Class added!');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Could not add class 🌱');
    }
  }

  Future<void> deleteTimetableClass(String day, String entryId) async {
    state = state.copyWith(clearMessages: true);
    try {
      await _fs.deleteDoc('users/$_uid/timetable/$entryId');

      final updatedTT = Map<String, List<Map<String, dynamic>>>.from(state.timetable);
      updatedTT[day] = (updatedTT[day] ?? []).where((e) => e['id'] != entryId).toList();

      state = state.copyWith(timetable: updatedTT, successMessage: '🗑️ Class removed!');
    } catch (e) {
      state = state.copyWith(errorMessage: 'Could not delete class 🌱');
    }
  }

  // ── Preferences (local SharedPreferences) ─────────────────────────────────

  Future<void> setNotifications(bool v) async {
    state = state.copyWith(notificationsEnabled: v);
    (await SharedPreferences.getInstance()).setBool(_prefNotifications, v);
  }

  Future<void> setSproutAI(bool v) async {
    state = state.copyWith(sproutAIEnabled: v);
    (await SharedPreferences.getInstance()).setBool(_prefSproutAI, v);
  }

  Future<void> setFocusSounds(bool v) async {
    state = state.copyWith(focusSoundsEnabled: v);
    (await SharedPreferences.getInstance()).setBool(_prefFocusSounds, v);
  }

  Future<void> setDynamicTimetable(bool v) async {
    state = state.copyWith(dynamicTimetableEnabled: v);
    (await SharedPreferences.getInstance()).setBool(_prefDynamicTimetable, v);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    (await SharedPreferences.getInstance()).setInt(_prefThemeMode, mode.index);
  }

  // ── Clear semester data ───────────────────────────────────────────────────

  Future<void> clearSemesterData() async {
    if (state.semesterId.isEmpty) return;
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final batch = FirebaseFirestore.instance.batch();

      final ttDocs = await _fs.collection('users/$_uid/timetable').get();
      for (final doc in ttDocs.docs) {
        batch.delete(doc.reference);
      }

      final subDocs = await _fs.collection('users/$_uid/subjects').get();
      for (final doc in subDocs.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(FirebaseFirestore.instance.doc('users/$_uid/semesters/${state.semesterId}'));
      await batch.commit();

      state = const SettingsState(successMessage: '🧹 Semester data cleared!');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Could not clear data 🌱');
    }
  }

  void clearMessages() => state = state.copyWith(clearMessages: true);
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
