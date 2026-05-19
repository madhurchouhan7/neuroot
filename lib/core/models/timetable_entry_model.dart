import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors Firestore: users/{uid}/timetable/{entryId}
class TimetableEntry {
  final String id;
  final String subjectId;
  final String subjectName;
  final String subjectCode;
  final String subjectColor; // hex e.g. "#FF8A65"
  final int dayOfWeek; // 0=Mon ... 6=Sun
  final String startTime; // "09:00"
  final String endTime; // "10:00"
  final String room;
  final String professor;

  const TimetableEntry({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    this.subjectCode = '',
    this.subjectColor = '#A8D5BA',
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room = '',
    this.professor = '',
  });

  factory TimetableEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    int parsedDay = 0;
    if (data['dayOfWeek'] is int) {
      parsedDay = data['dayOfWeek'] as int;
    } else if (data['dayOfWeek'] is String) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      parsedDay = days.indexOf(data['dayOfWeek'] as String);
      if (parsedDay < 0) parsedDay = 0;
    }

    return TimetableEntry(
      id: doc.id,
      subjectId: data['subjectId'] as String? ?? '',
      subjectName: data['subjectName'] as String? ?? '',
      subjectCode: data['subjectCode'] as String? ?? '',
      subjectColor: data['subjectColor'] as String? ?? '#A8D5BA',
      dayOfWeek: parsedDay,
      startTime: data['startTime'] as String? ?? '09:00',
      endTime: data['endTime'] as String? ?? '10:00',
      room: data['room'] as String? ?? '',
      professor: data['professor'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'subjectId': subjectId,
    'subjectName': subjectName,
    'subjectCode': subjectCode,
    'subjectColor': subjectColor,
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'endTime': endTime,
    'room': room,
    'professor': professor,
  };

  TimetableEntry copyWith({
    String? subjectId,
    String? subjectName,
    String? subjectCode,
    String? subjectColor,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
    String? professor,
  }) => TimetableEntry(
    id: id,
    subjectId: subjectId ?? this.subjectId,
    subjectName: subjectName ?? this.subjectName,
    subjectCode: subjectCode ?? this.subjectCode,
    subjectColor: subjectColor ?? this.subjectColor,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    room: room ?? this.room,
    professor: professor ?? this.professor,
  );
}
