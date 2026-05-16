import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors Firestore: users/{uid}/subjects/{subId}
class SubjectModel {
  final String id;
  final String name;
  final String code;
  final String color; // hex e.g. "#A8D5BA"
  final String semesterId;
  final int totalClasses;
  final int presentClasses;
  final int cancelledClasses;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.semesterId,
    this.code = '',
    this.color = '#A8D5BA',
    this.totalClasses = 0,
    this.presentClasses = 0,
    this.cancelledClasses = 0,
  });

  /// Effective attendance % ignoring cancelled classes.
  double get attendancePercentage {
    final effective = totalClasses - cancelledClasses;
    if (effective <= 0) return 100.0;
    return (presentClasses / effective * 100).clamp(0, 100);
  }

  factory SubjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubjectModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      code: data['code'] as String? ?? '',
      color: data['color'] as String? ?? '#A8D5BA',
      semesterId: data['semesterId'] as String? ?? '',
      totalClasses: data['totalClasses'] as int? ?? 0,
      presentClasses: data['presentClasses'] as int? ?? 0,
      cancelledClasses: data['cancelledClasses'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'code': code,
        'color': color,
        'semesterId': semesterId,
        'totalClasses': totalClasses,
        'presentClasses': presentClasses,
        'cancelledClasses': cancelledClasses,
      };

  SubjectModel copyWith({
    String? name,
    String? code,
    String? color,
    String? semesterId,
    int? totalClasses,
    int? presentClasses,
    int? cancelledClasses,
  }) =>
      SubjectModel(
        id: id,
        name: name ?? this.name,
        code: code ?? this.code,
        color: color ?? this.color,
        semesterId: semesterId ?? this.semesterId,
        totalClasses: totalClasses ?? this.totalClasses,
        presentClasses: presentClasses ?? this.presentClasses,
        cancelledClasses: cancelledClasses ?? this.cancelledClasses,
      );
}
