import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/services/auth_service.dart';
import 'package:neuroot/features/auth/providers/user_provider.dart';

// ─── Service Provider ─────────────────────────────────────────────────────────

/// Singleton AuthService instance for the whole app.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ─── Stream Provider ──────────────────────────────────────────────────────────

/// Real-time auth state. Emits User? — null means signed out.
/// The router's refreshListenable is driven by this.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ─── Auth State ───────────────────────────────────────────────────────────────

/// Immutable state for sign-in / sign-up actions.
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        isSuccess: isSuccess ?? this.isSuccess,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

/// Handles sign-in / sign-up / sign-out actions + error state.
/// After every successful auth, bootstraps the Firestore user document.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthService get _service => ref.read(authServiceProvider);

  // ── Sign In ─────────────────────────────────────────────────────────────────

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cred =
          await _service.signInWithEmail(email: email, password: password);
      if (cred.user != null) {
        await ref
            .read(userNotifierProvider.notifier)
            .createOrUpdateUser(cred.user!);
      }
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthService.friendlyError(e),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Something went wrong. Let's try again 🌱",
      );
    }
  }

  // ── Sign Up ─────────────────────────────────────────────────────────────────

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? college,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cred = await _service.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (cred.user != null) {
        await ref
            .read(userNotifierProvider.notifier)
            .createOrUpdateUser(cred.user!, college: college);
      }
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthService.friendlyError(e),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Something went wrong. Let's try again 🌱",
      );
    }
  }

  // ── Google Sign-In ───────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.signInWithGoogle();
      if (result == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      if (result.user != null) {
        await ref
            .read(userNotifierProvider.notifier)
            .createOrUpdateUser(result.user!);
      }
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthService.friendlyError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Google sign-in error: ${e.toString().split('\n').first}",
      );
    }
  }

  // ── Sign Out ─────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _service.signOut();
    state = const AuthState();
  }

  // ── Password Reset ───────────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.sendPasswordReset(email);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthService.friendlyError(e),
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

/// Provider for the [AuthNotifier].
final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
