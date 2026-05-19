import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neuroot/core/models/attendance_record_model.dart';
import 'package:neuroot/core/models/subject_model.dart';
import 'package:neuroot/core/services/firestore_service.dart';

class AttendanceRepository {
  AttendanceRepository(this._fs);

  final FirestoreService _fs;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ─── Streams ──────────────────────────────────────────────────────────────

  /// Real-time stream of all subjects for the current user.
  Stream<List<SubjectModel>> getSubjectsStream() {
    return _fs
        .collection('users/$_uid/subjects')
        .orderBy('name')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => SubjectModel.fromFirestore(d)).toList());
  }

  /// Real-time stream of attendance records for a specific subject.
  Stream<List<AttendanceRecord>> getAttendanceStream(String subjectId) {
    return _fs
        .collection('users/$_uid/attendance')
        .where('subjectId', isEqualTo: subjectId)
        .snapshots()
        .map((snap) {
          final records = snap.docs
              .map((d) => AttendanceRecord.fromFirestore(d))
              .toList();
          // Sort in memory — avoids requiring a composite Firestore index
          records.sort((a, b) => b.date.compareTo(a.date));
          return records;
        });
  }

  /// Real-time stream of ALL attendance records for heatmap (current month).
  Stream<List<AttendanceRecord>> getMonthAttendanceStream(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return _fs
        .collection('users/$_uid/attendance')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AttendanceRecord.fromFirestore(d)).toList());
  }


  // ─── Mark Attendance ─────────────────────────────────────────────────────

  /// Marks attendance for a subject on a date.
  /// Uses a Firestore transaction to atomically update record + counters.
  /// If a record already exists for that date, it edits instead.
  Future<void> markAttendance({
    required String subjectId,
    required DateTime date,
    required AttendanceStatus status,
  }) async {
    final dayOnly = DateTime(date.year, date.month, date.day);

    // Check if a record already exists for this date
    final existing = await _fs
        .collection('users/$_uid/attendance')
        .where('subjectId', isEqualTo: subjectId)
        .where('date', isEqualTo: Timestamp.fromDate(dayOnly))
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final oldRecord = AttendanceRecord.fromFirestore(existing.docs.first);
      await editAttendance(
        recordId: oldRecord.id,
        subjectId: subjectId,
        newStatus: status,
        oldStatus: oldRecord.status,
      );
      return;
    }

    // New record — use a transaction to atomically update counters
    final subjectRef = _fs.doc('users/$_uid/subjects/$subjectId');
    final newRecordRef =
        _fs.collection('users/$_uid/attendance').doc();

    await _fs.runTransaction((tx) async {
      final subSnap = await tx.get(subjectRef);
      final subData = subSnap.data() as Map<String, dynamic>? ?? {};

      final total = (subData['totalClasses'] as int? ?? 0) + 1;
      int present = subData['presentClasses'] as int? ?? 0;
      int cancelled = subData['cancelledClasses'] as int? ?? 0;

      if (status == AttendanceStatus.present) present++;
      if (status == AttendanceStatus.cancelled) cancelled++;

      tx.set(newRecordRef, {
        'subjectId': subjectId,
        'date': Timestamp.fromDate(dayOnly),
        'status': status.value,
      });

      tx.update(subjectRef, {
        'totalClasses': total,
        'presentClasses': present,
        'cancelledClasses': cancelled,
      });

      return null;
    });
  }

  /// Edit an existing attendance record and recalculate subject counters.
  Future<void> editAttendance({
    required String recordId,
    required String subjectId,
    required AttendanceStatus oldStatus,
    required AttendanceStatus newStatus,
  }) async {
    if (oldStatus == newStatus) return;

    final subjectRef = _fs.doc('users/$_uid/subjects/$subjectId');
    final recordRef = _fs.doc('users/$_uid/attendance/$recordId');

    await _fs.runTransaction((tx) async {
      final subSnap = await tx.get(subjectRef);
      final subData = subSnap.data() as Map<String, dynamic>? ?? {};

      int present = subData['presentClasses'] as int? ?? 0;
      int cancelled = subData['cancelledClasses'] as int? ?? 0;

      // Undo old
      if (oldStatus == AttendanceStatus.present) present--;
      if (oldStatus == AttendanceStatus.cancelled) cancelled--;
      // Apply new
      if (newStatus == AttendanceStatus.present) present++;
      if (newStatus == AttendanceStatus.cancelled) cancelled++;

      tx.update(recordRef, {'status': newStatus.value});
      tx.update(subjectRef, {
        'presentClasses': present.clamp(0, 9999),
        'cancelledClasses': cancelled.clamp(0, 9999),
      });

      return null;
    });
  }

  /// Delete a subject and all its attendance records.
  Future<void> deleteSubject(String subjectId) async {
    final records = await _fs
        .collection('users/$_uid/attendance')
        .where('subjectId', isEqualTo: subjectId)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in records.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_fs.doc('users/$_uid/subjects/$subjectId'));
    await batch.commit();
  }

  /// Add a new subject document.
  Future<String> addSubject({
    required String name,
    required String code,
    required String color,
    required String semesterId,
  }) {
    return _fs.addDoc('users/$_uid/subjects', {
      'name': name,
      'code': code,
      'color': color,
      'semesterId': semesterId,
      'totalClasses': 0,
      'presentClasses': 0,
      'cancelledClasses': 0,
    });
  }

  // ─── Safe Leave Calculator ────────────────────────────────────────────────

  /// Returns how many more classes can be skipped while staying ≥ [threshold]%.
  /// Negative result means student must attend that many to recover.
  static int computeSafeLeaves(SubjectModel subject, {int threshold = 75}) {
    final total = subject.totalClasses;
    final present = subject.presentClasses;
    final t = threshold / 100;
    if (t == 0) return 0;
    return ((present - t * total) / t).floor();
  }
}
