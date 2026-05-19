import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/models/timetable_entry_model.dart';
import 'package:neuroot/core/models/mood_log_model.dart';
import 'package:neuroot/core/models/task_model.dart';
import 'package:neuroot/features/auth/providers/user_provider.dart';
import 'package:neuroot/features/planning/providers/task_provider.dart';
import 'package:neuroot/features/settings/providers/settings_provider.dart';

// ─── Timetable Stream ─────────────────────────────────────────────────────────

final timetableStreamProvider = StreamProvider<List<TimetableEntry>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users/$uid/timetable')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => TimetableEntry.fromFirestore(doc))
            .toList(),
      );
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

// ─── Time Ticker Provider ──────────────────────────────────────────────────────

final timeTickerProvider = StreamProvider<DateTime>((ref) {
  return (() async* {
    yield DateTime.now();
    yield* Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now());
  })();
});

// ─── User Greeting ────────────────────────────────────────────────────────────

final userGreetingProvider = Provider<String>((ref) {
  final user = ref.watch(userDocProvider).asData?.value;
  final name = user?.displayName.split(' ').first ?? 'Student';
  final now = ref.watch(timeTickerProvider).asData?.value ?? DateTime.now();
  final hour = now.hour;

  String greeting = 'Good evening';
  String emoji = '🌙';

  if (hour >= 6 && hour < 12) {
    greeting = 'Good morning';
    emoji = '☀️';
  } else if (hour >= 12 && hour < 18) {
    greeting = 'Good afternoon';
    emoji = '🌤️';
  } else if (hour >= 18 && hour < 21) {
    greeting = 'Good evening';
    emoji = '🌙';
  } else {
    greeting = 'Good night';
    emoji = '💤';
  }

  return '$greeting, \n$name $emoji';
});

// ─── Exam Week Mode ────────────────────────────────────────────────────────────

final isExamWeekProvider = Provider<bool>((ref) {
  final tasks = ref.watch(tasksStreamProvider).asData?.value ?? [];
  final now = ref.watch(timeTickerProvider).asData?.value ?? DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final thresholdDate = startOfToday.add(
    const Duration(days: 3, hours: 23, minutes: 59, seconds: 59),
  );

  return tasks.any(
    (t) =>
        t.type == TaskType.exam &&
        !t.isCompleted &&
        (t.dueDate.isAfter(startOfToday) ||
            t.dueDate.isAtSameMomentAs(startOfToday)) &&
        t.dueDate.isBefore(thresholdDate),
  );
});

final nextUpcomingExamProvider = Provider<TaskModel?>((ref) {
  final tasks = ref.watch(tasksStreamProvider).asData?.value ?? [];
  final exams =
      tasks.where((t) => t.type == TaskType.exam && !t.isCompleted).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return exams.isEmpty ? null : exams.first;
});

// ─── Dynamic Time-of-Day and Exam Theme ────────────────────────────────────────

class HomeThemeState {
  final List<Color> gradientColors;
  final String sproutEmoji;
  final String sproutStatusText;
  final String greetingText;
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;
  final Color accentColor;
  final bool isDark;

  const HomeThemeState({
    required this.gradientColors,
    required this.sproutEmoji,
    required this.sproutStatusText,
    required this.greetingText,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
    required this.accentColor,
    this.isDark = false,
  });
}

final isBurnoutModeProvider = Provider<bool>((ref) {
  final currentMood = ref.watch(todayMoodProvider);
  return currentMood == MoodType.overwhelmed || currentMood == MoodType.tired;
});

final homeThemeStateProvider = Provider<HomeThemeState>((ref) {
  final isExamWeek = ref.watch(isExamWeekProvider);
  final isBurnoutMode = ref.watch(isBurnoutModeProvider);
  final user = ref.watch(userDocProvider).asData?.value;
  final name = user?.displayName.split(' ').first ?? 'Student';
  final settings = ref.watch(settingsProvider);
  final now = ref.watch(timeTickerProvider).asData?.value ?? DateTime.now();

  if (settings.themeMode == AppThemeMode.sakuraSpring) {
    return HomeThemeState(
      gradientColors: [const Color(0xFFFFE4E1), const Color(0xFFFFF0F5)],
      sproutEmoji: '🌸🌱',
      sproutStatusText: 'Enjoying the spring breeze. Let\'s bloom today!',
      greetingText: 'Happy Spring, \n$name 🌸',
      backgroundColor: const Color(0xFFFFF0F5),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF8B1A1A),
      accentColor: const Color(0xFFC71585),
    );
  } else if (settings.themeMode == AppThemeMode.darkAcademia) {
    return HomeThemeState(
      gradientColors: [const Color(0xFF2B2121), const Color(0xFF1F1A1A)],
      sproutEmoji: '🕰️🌱',
      sproutStatusText: 'The library is quiet. A perfect time for deep work.',
      greetingText: 'Good morrow, \n$name ☕',
      backgroundColor: const Color(0xFF1F1A1A),
      cardColor: const Color(0xFF2C2424),
      textColor: const Color(0xFFD4C4A8),
      accentColor: const Color(0xFF8B4513),
      isDark: true,
    );
  }

  if (isBurnoutMode) {
    return HomeThemeState(
      gradientColors: [const Color(0xFFE2EBE9), const Color(0xFFF5F8F7)],
      sproutEmoji: '🧘🌱',
      sproutStatusText:
          'I sense you\'re feeling a bit overwhelmed or tired. Let\'s slow things down today. No rush, one small step at a time! 🧘🌱',
      greetingText: 'Take it easy, \n$name 🌿',
      backgroundColor: const Color(0xFFF5F8F7),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF2C4438),
      accentColor: const Color(0xFF6B8E7D),
    );
  }

  final hour = now.hour;

  if (isExamWeek) {
    // Exam Week Mode (Purple theme)
    return HomeThemeState(
      gradientColors: [const Color(0xFFECE2FA), const Color(0xFFFFFDF8)],
      sproutEmoji: '🤓🌱',
      sproutStatusText:
          'Exam week is close! Let\'s tackle one small topic at a time.',
      greetingText: 'Stay focused, \n$name 🔥',
      backgroundColor: const Color(0xFFFBF9FF),
      cardColor: const Color(0xFFFFFDF8),
      textColor: const Color(0xFF4A346E),
      accentColor: const Color(0xFF9F7AEA), // Purple Accent
    );
  }

  if (hour >= 6 && hour < 12) {
    // Morning (Warm Amber/Yellow morning glow)
    return HomeThemeState(
      gradientColors: [const Color(0xFFFFF2D4), const Color(0xFFFFFDF8)],
      sproutEmoji: '☕🌱',
      sproutStatusText:
          'Morning! Ready to start the day with a gentle focus session?',
      greetingText: 'Good morning, \n$name ☀️',
      backgroundColor: const Color(0xFFF8F5F0),
      cardColor: const Color(0xFFFFFDF8),
      textColor: const Color(0xFF2B2B2B),
      accentColor: const Color(0xFFFFB703),
    );
  } else if (hour >= 12 && hour < 18) {
    // Afternoon (Sage green fresh study gradient)
    return HomeThemeState(
      gradientColors: [const Color(0xFFE5EFE9), const Color(0xFFF8F5F0)],
      sproutEmoji: '📚🌱',
      sproutStatusText: 'Doing great! Let\'s keep steady and consistent.',
      greetingText: 'Good afternoon, \n$name 🌤️',
      backgroundColor: const Color(0xFFF8F5F0),
      cardColor: const Color(0xFFFFFDF8),
      textColor: const Color(0xFF2B2B2B),
      accentColor: const Color(0xFFA8D5BA),
    );
  } else if (hour >= 18 && hour < 21) {
    // Evening (Warm Amber gradient)
    return HomeThemeState(
      gradientColors: [
        const Color(0xFFFFEFD5).withValues(alpha: 0.8),
        const Color(0xFFFFF9F1).withValues(alpha: 0.0),
      ],
      sproutEmoji: '🍵🌱',
      sproutStatusText:
          'Evening check-in! Wind down or do a light study review.',
      greetingText: 'Good evening, \n$name 🌙',
      backgroundColor: const Color(0xFFF8F5F0),
      cardColor: const Color(0xFFFFFDF8),
      textColor: const Color(0xFF2B2B2B),
      accentColor: const Color(0xFFFFB703),
    );
  } else {
    // Night (Starry night cozy dark mode!)
    return HomeThemeState(
      gradientColors: [const Color(0xFF1A1A2E), const Color(0xFF161616)],
      sproutEmoji: '😴🌱',
      sproutStatusText:
          'You\'ve worked hard. Time to rest your mind and sleep.',
      greetingText: 'Good night, \n$name 💤',
      backgroundColor: const Color(0xFF161616),
      cardColor: const Color(0xFF222222),
      textColor: const Color(0xFFECEAE5),
      accentColor: const Color(0xFF7CB9E8),
      isDark: true,
    );
  }
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
        state = MoodTypeExtension.fromString(
          snap.docs.first.data()['mood'] as String,
        );
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

final todayMoodProvider = NotifierProvider<TodayMoodNotifier, MoodType?>(
  TodayMoodNotifier.new,
);
