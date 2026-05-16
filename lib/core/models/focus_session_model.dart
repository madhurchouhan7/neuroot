import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors Firestore: users/{uid}/focusSessions/{sessionId}
class FocusSession {
  final String id;
  final DateTime date;
  final int durationMinutes;
  final int sessionsCompleted;
  final String? linkedTaskId;

  const FocusSession({
    required this.id,
    required this.date,
    required this.durationMinutes,
    required this.sessionsCompleted,
    this.linkedTaskId,
  });

  factory FocusSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FocusSession(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'] as int? ?? 25,
      sessionsCompleted: data['sessionsCompleted'] as int? ?? 1,
      linkedTaskId: data['linkedTaskId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'date': Timestamp.fromDate(date),
        'durationMinutes': durationMinutes,
        'sessionsCompleted': sessionsCompleted,
        'linkedTaskId': linkedTaskId,
      };
}
