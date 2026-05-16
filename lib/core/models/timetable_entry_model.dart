import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors Firestore: users/{uid}/timetable/{entryId}
class TimetableEntry {
  final String id;
  final String subjectId;
  final String subjectName;
  final int dayOfWeek; // 0=Mon ... 6=Sun
  final String startTime; // "09:00"
  final String endTime;   // "10:00"
  final String room;

  const TimetableEntry({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room = '',
  });

  factory TimetableEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TimetableEntry(
      id: doc.id,
      subjectId: data['subjectId'] as String? ?? '',
      subjectName: data['subjectName'] as String? ?? '',
      dayOfWeek: data['dayOfWeek'] as int? ?? 0,
      startTime: data['startTime'] as String? ?? '09:00',
      endTime: data['endTime'] as String? ?? '10:00',
      room: data['room'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'subjectId': subjectId,
        'subjectName': subjectName,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'room': room,
      };

  TimetableEntry copyWith({
    String? subjectId,
    String? subjectName,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
  }) =>
      TimetableEntry(
        id: id,
        subjectId: subjectId ?? this.subjectId,
        subjectName: subjectName ?? this.subjectName,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        room: room ?? this.room,
      );
}
