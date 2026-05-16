import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/models/timetable_entry_model.dart';
import 'package:neuroot/core/models/mood_log_model.dart';
import 'package:neuroot/features/auth/providers/user_provider.dart';

// ─── Timetable Stream ─────────────────────────────────────────────────────────

final timetableStreamProvider = StreamProvider<List<TimetableEntry>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);
  
  return FirebaseFirestore.instance
      .collection('users/$uid/timetable')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => TimetableEntry.fromFirestore(doc))
          .toList());
});

// ─── Today's Classes ──────────────────────────────────────────────────────────

final todayClassesProvider = Provider<List<TimetableEntry>>((ref) {
  final entries = ref.watch(timetableStreamProvider).asData?.value ?? [];
  final today = DateTime.now().weekday - 1; // 0 = Monday
  
  final todayEntries = entries.where((e) => e.dayOfWeek == today).toList();
  
  // Sort by start time (assuming "HH:MM" format)
  todayEntries.sort((a, b) => a.startTime.compareTo(b.startTime));
  
  return todayEntries;
});

// ─── User Greeting ────────────────────────────────────────────────────────────

final userGreetingProvider = Provider<String>((ref) {
  final user = ref.watch(userDocProvider).asData?.value;
  final name = user?.displayName.split(' ').first ?? 'Student';
  
  final hour = DateTime.now().hour;
  String greeting = 'Good evening';
  String emoji = '🌙';
  
  if (hour >= 5 && hour < 12) {
    greeting = 'Good morning';
    emoji = '☀️';
  } else if (hour >= 12 && hour < 17) {
    greeting = 'Good afternoon';
    emoji = '🌤️';
  }
  
  return '$greeting,\n$name $emoji';
});

// ─── Today's Mood ─────────────────────────────────────────────────────────────

class TodayMoodNotifier extends Notifier<MoodType?> {
  @override
  MoodType? build() {
    _fetchTodayMood();
    return null;
  }

  Future<void> _fetchTodayMood() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    try {
      final snap = await FirebaseFirestore.instance
        .collection('users/$uid/moodLogs')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('date', descending: true)
        .limit(1)
        .get();
        
      if (snap.docs.isNotEmpty) {
        state = MoodTypeExtension.fromString(snap.docs.first.data()['mood'] as String);
      }
    } catch (_) {}
  }

  Future<void> setMood(MoodType mood) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    state = mood;
    
    try {
      await FirebaseFirestore.instance.collection('users/$uid/moodLogs').add({
        'date': FieldValue.serverTimestamp(),
        'mood': mood.value,
        'energy': 3,
      });
    } catch (_) {}
  }
}

final todayMoodProvider = NotifierProvider<TodayMoodNotifier, MoodType?>(TodayMoodNotifier.new);

