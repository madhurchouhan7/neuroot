import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/models/user_model.dart';
import 'package:neuroot/core/services/firestore_service.dart';
import 'package:neuroot/features/auth/providers/auth_provider.dart';

// ─── Service Provider ─────────────────────────────────────────────────────────

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

// ─── Current UID Helper ───────────────────────────────────────────────────────

/// Convenience provider — throws if called when not signed in.
final currentUidProvider = Provider<String>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) throw StateError('Not authenticated');
  return user.uid;
});

// ─── User Document Stream ─────────────────────────────────────────────────────

/// Real-time stream of the current user's Firestore document.
/// Emits null while loading or if the document doesn't exist yet.
final userDocProvider = StreamProvider<UserModel?>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final user = authAsync.asData?.value;
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snap) => snap.exists ? UserModel.fromFirestore(snap) : null);
});

// ─── User Notifier ────────────────────────────────────────────────────────────

class UserNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  FirestoreService get _fs => ref.read(firestoreServiceProvider);

  /// Create or merge-update a user document.
  Future<void> createOrUpdateUser(User firebaseUser, {String? college}) async {
    state = const AsyncValue.loading();
    try {
      final path = 'users/${firebaseUser.uid}';
      final existing = await _fs.getDoc(path);

      if (existing == null) {
        // First sign-up: write a fresh document
        await _fs.setDoc(path, {
          'displayName': firebaseUser.displayName ?? '',
          'email': firebaseUser.email ?? '',
          'photoUrl': firebaseUser.photoURL ?? '',
          'college': college ?? '',
          'onboardingComplete': false,
          'xp': 0,
          'level': 1,
          'streak': 0,
          'lastActiveDate': FieldValue.serverTimestamp(),
        });
      } else {
        // Returning user: just refresh last active date
        await _fs.updateDoc(path, {
          'lastActiveDate': FieldValue.serverTimestamp(),
        });
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update arbitrary profile fields (name, college, photo, etc.)
  Future<void> updateProfile(Map<String, dynamic> fields) async {
    state = const AsyncValue.loading();
    try {
      final uid = ref.read(currentUidProvider);
      await _fs.updateDoc('users/$uid', fields);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Award XP to the user document.
  /// Automatically bumps level every 500 XP.
  Future<void> awardXp(int amount) async {
    try {
      final uid = ref.read(currentUidProvider);
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (!snap.exists) return;

      final currentXp = snap.data()?['xp'] as int? ?? 0;
      final newXp = currentXp + amount;
      final newLevel = (newXp ~/ 500) + 1;

      await _fs.updateDoc('users/$uid', {
        'xp': newXp,
        'level': newLevel,
      });
    } catch (_) {
      // Silently ignore — XP is non-critical
    }
  }
}

final userNotifierProvider =
    NotifierProvider<UserNotifier, AsyncValue<void>>(UserNotifier.new);
