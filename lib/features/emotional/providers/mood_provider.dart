import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Mood enum ────────────────────────────────────────────────────────────────
enum UserMood { happy, focused, overwhelmed, burnedOut, calm, anxious, none }

extension UserMoodLabel on UserMood {
  String get label {
    switch (this) {
      case UserMood.happy:       return 'Happy';
      case UserMood.focused:     return 'Focused';
      case UserMood.overwhelmed: return 'Overwhelmed';
      case UserMood.burnedOut:   return 'Burned Out';
      case UserMood.calm:        return 'Calm';
      case UserMood.anxious:     return 'Anxious';
      case UserMood.none:        return 'Unknown';
    }
  }
}

// ─── Riverpod 3.x — Notifier ─────────────────────────────────────────────────
class MoodNotifier extends Notifier<UserMood> {
  @override
  UserMood build() => UserMood.none;

  void setMood(UserMood mood) => state = mood;
  void clear() => state = UserMood.none;
}

final moodNotifierProvider =
    NotifierProvider<MoodNotifier, UserMood>(MoodNotifier.new);

