import 'package:cloud_firestore/cloud_firestore.dart';

enum MoodType { happy, focused, tired, overwhelmed, calm, anxious }

extension MoodTypeExtension on MoodType {
  String get value => name;

  static MoodType fromString(String s) =>
      MoodType.values.firstWhere((e) => e.name == s,
          orElse: () => MoodType.calm);

  String get emoji {
    switch (this) {
      case MoodType.happy:
        return '😊';
      case MoodType.focused:
        return '🎯';
      case MoodType.tired:
        return '😴';
      case MoodType.overwhelmed:
        return '😰';
      case MoodType.calm:
        return '😌';
      case MoodType.anxious:
        return '😟';
    }
  }

  String get label {
    switch (this) {
      case MoodType.happy:
        return 'Happy';
      case MoodType.focused:
        return 'Focused';
      case MoodType.tired:
        return 'Tired';
      case MoodType.overwhelmed:
        return 'Overwhelmed';
      case MoodType.calm:
        return 'Calm';
      case MoodType.anxious:
        return 'Anxious';
    }
  }
}

/// Mirrors Firestore: users/{uid}/moodLogs/{logId}
class MoodLog {
  final String id;
  final DateTime date;
  final MoodType mood;
  final int energy; // 1–5

  const MoodLog({
    required this.id,
    required this.date,
    required this.mood,
    required this.energy,
  });

  factory MoodLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MoodLog(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      mood:
          MoodTypeExtension.fromString(data['mood'] as String? ?? 'calm'),
      energy: (data['energy'] as int? ?? 3).clamp(1, 5),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'date': Timestamp.fromDate(date),
        'mood': mood.value,
        'energy': energy,
      };
}
