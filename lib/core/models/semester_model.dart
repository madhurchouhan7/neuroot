import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors Firestore: users/{uid}/semesters/{semId}
class SemesterModel {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final int attendanceThreshold; // 75, 80, or 85
  final bool isActive;

  const SemesterModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.attendanceThreshold = 75,
    this.isActive = true,
  });

  factory SemesterModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SemesterModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      attendanceThreshold: data['attendanceThreshold'] as int? ?? 75,
      isActive: data['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'attendanceThreshold': attendanceThreshold,
        'isActive': isActive,
      };

  SemesterModel copyWith({
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    int? attendanceThreshold,
    bool? isActive,
  }) =>
      SemesterModel(
        id: id,
        name: name ?? this.name,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        attendanceThreshold: attendanceThreshold ?? this.attendanceThreshold,
        isActive: isActive ?? this.isActive,
      );
}
