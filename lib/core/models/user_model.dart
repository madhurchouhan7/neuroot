import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors Firestore: users/{uid}
class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final String college;
  final bool onboardingComplete;
  final int xp;
  final int level;
  final int streak;
  final DateTime? lastActiveDate;

  final String equippedCosmetic;
  final List<String> unlockedCosmetics;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl = '',
    this.college = '',
    this.onboardingComplete = false,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.lastActiveDate,
    this.equippedCosmetic = '',
    this.unlockedCosmetics = const ['scholar_hat', 'sunny_room'],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      college: data['college'] as String? ?? '',
      onboardingComplete: data['onboardingComplete'] as bool? ?? false,
      xp: data['xp'] as int? ?? 0,
      level: data['level'] as int? ?? 1,
      streak: data['streak'] as int? ?? 0,
      lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate(),
      equippedCosmetic: data['equippedCosmetic'] as String? ?? '',
      unlockedCosmetics: List<String>.from(data['unlockedCosmetics'] ?? ['scholar_hat', 'sunny_room']),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'college': college,
        'onboardingComplete': onboardingComplete,
        'xp': xp,
        'level': level,
        'streak': streak,
        'lastActiveDate':
            lastActiveDate != null ? Timestamp.fromDate(lastActiveDate!) : null,
        'equippedCosmetic': equippedCosmetic,
        'unlockedCosmetics': unlockedCosmetics,
      };

  UserModel copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    String? college,
    bool? onboardingComplete,
    int? xp,
    int? level,
    int? streak,
    DateTime? lastActiveDate,
    String? equippedCosmetic,
    List<String>? unlockedCosmetics,
  }) =>
      UserModel(
        uid: uid,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        college: college ?? this.college,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        xp: xp ?? this.xp,
        level: level ?? this.level,
        streak: streak ?? this.streak,
        lastActiveDate: lastActiveDate ?? this.lastActiveDate,
        equippedCosmetic: equippedCosmetic ?? this.equippedCosmetic,
        unlockedCosmetics: unlockedCosmetics ?? this.unlockedCosmetics,
      );
}
