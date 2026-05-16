import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// Handles all Firebase Authentication operations.
/// Used by [AuthNotifier] in the providers layer.
class AuthService {
  AuthService()
      : _auth = FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  // ─── Stream ──────────────────────────────────────────────────────────────────

  /// Real-time auth state changes. Emits null when signed out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user (null if not signed in).
  User? get currentUser => _auth.currentUser;

  // ─── Email / Password ─────────────────────────────────────────────────────

  /// Sign in with email and password.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Create account with email and password.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Update display name immediately after creation
    await credential.user?.updateDisplayName(displayName.trim());
    return credential;
  }

  /// Send password reset email.
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────

  /// Sign in / sign up with Google OAuth.
  /// Returns null if the user cancelled the flow.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthService] Google sign-in error: $e');
      rethrow;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  /// Sign out of Firebase and Google.
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Human-readable error message for common FirebaseAuth errors.
  static String friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "Hmm, we couldn't find that account 🌱";
      case 'wrong-password':
        return "That password doesn't seem right. Try again?";
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Your password needs to be at least 6 characters.';
      case 'network-request-failed':
        return "Couldn't connect right now. We'll retry soon 🌱";
      case 'too-many-requests':
        return 'Too many attempts. Take a breather and try again.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      default:
        return "Something went wrong. Let's try again 🌱";
    }
  }
}
