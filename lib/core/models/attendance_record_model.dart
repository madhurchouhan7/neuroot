import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus { present, absent, cancelled }

extension AttendanceStatusExtension on AttendanceStatus {
  String get value {
    switch (this) {
      case AttendanceStatus.present:
        return 'present';
      case AttendanceStatus.absent:
        return 'absent';
      case AttendanceStatus.cancelled:
        return 'cancelled';
    }
  }

  static AttendanceStatus fromString(String s) {
    switch (s) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'cancelled':
        return AttendanceStatus.cancelled;
      default:
        return AttendanceStatus.absent;
    }
  }
}

/// Mirrors Firestore: users/{uid}/attendance/{recordId}
class AttendanceRecord {
  final String id;
  final String subjectId;
  final DateTime date;
  final AttendanceStatus status;

  const AttendanceRecord({
    required this.id,
    required this.subjectId,
    required this.date,
    required this.status,
  });

  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceRecord(
      id: doc.id,
      subjectId: data['subjectId'] as String? ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: AttendanceStatusExtension.fromString(
          data['status'] as String? ?? 'absent'),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'subjectId': subjectId,
        'date': Timestamp.fromDate(date),
        'status': status.value,
      };

  AttendanceRecord copyWith({
    String? subjectId,
    DateTime? date,
    AttendanceStatus? status,
  }) =>
      AttendanceRecord(
        id: id,
        subjectId: subjectId ?? this.subjectId,
        date: date ?? this.date,
        status: status ?? this.status,
      );
}
