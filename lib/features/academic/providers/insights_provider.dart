import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/models/focus_session_model.dart';
import 'package:neuroot/core/models/mood_log_model.dart';
import 'package:neuroot/features/academic/providers/attendance_provider.dart';

// ─── Focus Sessions Insights ──────────────────────────────────────────────────

final weeklyFocusSessionsProvider = StreamProvider<List<FocusSession>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);
  
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));
  
  return FirebaseFirestore.instance
      .collection('users/$uid/focusSessions')
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
      .snapshots()
      .map((snap) => snap.docs.map((doc) => FocusSession.fromFirestore(doc)).toList());
});

final weeklyFocusHoursProvider = Provider<List<double>>((ref) {
  final sessions = ref.watch(weeklyFocusSessionsProvider).asData?.value ?? [];
  
  // Create an array of 7 days, 0 = 6 days ago, 6 = today
  List<double> hoursPerDay = List.filled(7, 0.0);
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  
  for (var s in sessions) {
    final diff = todayStart.difference(DateTime(s.date.year, s.date.month, s.date.day)).inDays;
    if (diff >= 0 && diff < 7) {
      final index = 6 - diff;
      hoursPerDay[index] += (s.durationMinutes * s.sessionsCompleted) / 60.0;
    }
  }
  
  return hoursPerDay;
});

// ─── Attendance Insights ──────────────────────────────────────────────────────

final weeklyAttendanceProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final subjects = ref.watch(subjectsStreamProvider).asData?.value ?? [];
  
  return subjects.map((s) => {
    'name': s.code.isNotEmpty ? s.code : s.name,
    'percentage': s.attendancePercentage,
    'colorHex': s.color,
  }).toList();
});

// ─── Mood Trends ──────────────────────────────────────────────────────────────

final moodTrendProvider = StreamProvider<List<MoodLog>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);
  
  return FirebaseFirestore.instance
      .collection('users/$uid/moodLogs')
      .orderBy('date', descending: true)
      .limit(7)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => MoodLog.fromFirestore(doc)).toList());
});
