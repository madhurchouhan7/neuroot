import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_shell.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/emotional/screens/emotional_checkin_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/landing_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

// ─── Refresh Listenable ───────────────────────────────────────────────────────

/// Bridges Riverpod's [StreamProvider] → GoRouter's [refreshListenable].
/// GoRouter re-evaluates `redirect` every time the auth stream emits.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue>(authStateProvider, (_, __) => notifyListeners());
  }
  final WidgetRef _ref;
}

// ─── Router Factory ───────────────────────────────────────────────────────────

GoRouter buildAppRouter(WidgetRef ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) async {
      final authAsync = ref.read(authStateProvider);
      final user = authAsync.asData?.value;
      final location = state.uri.path;

      // Still loading auth — stay on splash
      if (authAsync.isLoading) {
        return location == '/splash' ? null : '/splash';
      }

      final isOnAuthRoute = location == '/landing' ||
          location == '/signin' ||
          location == '/signup' ||
          location == '/splash';

      // Not signed in → go to landing
      if (user == null) {
        if (location == '/splash') return '/landing';
        return isOnAuthRoute ? null : '/landing';
      }

      // Signed in → check onboarding flag
      if (isOnAuthRoute) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          final onboardingComplete =
              (doc.data()?['onboardingComplete'] as bool?) ?? false;
          return onboardingComplete ? '/home' : '/onboarding';
        } catch (_) {
          // Firestore unavailable — go home
          return '/home';
        }
      }

      return null; // no redirect needed
    },
    routes: [
      // ── Auth & Foundation ──────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SplashScreen(),
          transitionsBuilder: _fadeSlideTransition,
        ),
      ),
      GoRoute(
        path: '/landing',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LandingScreen(),
          transitionsBuilder: _fadeSlideTransition,
        ),
      ),
      GoRoute(
        path: '/signin',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SignInScreen(),
          transitionsBuilder: _fadeSlideTransition,
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SignUpScreen(),
          transitionsBuilder: _fadeSlideTransition,
        ),
      ),

      // ── Onboarding ─────────────────────────────────────────────────────────
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const OnboardingScreen(),
          transitionsBuilder: _fadeSlideTransition,
        ),
      ),

      // ── Emotional Check-in ─────────────────────────────────────────────────
      GoRoute(
        path: '/checkin',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: EmotionalCheckinScreen(
            onDone: () => context.go('/home'),
          ),
          transitionsBuilder: _fadeSlideTransition,
        ),
      ),

      // ── Main App Shell ─────────────────────────────────────────────────────
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AppShell(),
          transitionsBuilder: _fadeSlideTransition,
        ),
      ),
    ],
  );
}

// ─── Transition ───────────────────────────────────────────────────────────────

Widget _fadeSlideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
    child: SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}
