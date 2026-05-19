import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_shell.dart';
import '../../features/onboarding/screens/intro_screen.dart';
import '../../features/onboarding/screens/setup_screen.dart';
import '../../features/emotional/screens/emotional_checkin_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/landing_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/edit_profile_screen.dart';
import '../../features/settings/screens/edit_semester_screen.dart';
import '../../features/settings/screens/notification_settings_screen.dart';
import '../../features/settings/screens/appearance_settings_screen.dart';
import '../../features/settings/screens/export_data_screen.dart';
import '../../features/settings/screens/help_feedback_screen.dart';
import '../../features/settings/screens/delete_account_screen.dart';
import '../../features/planning/screens/ai_roadmap_detail_screen.dart';
import '../../features/system/screens/offline_screen.dart';

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

      // Routes that are valid while unauthenticated
      final isOnUnauthRoute = location == '/intro' ||
          location == '/landing' ||
          location == '/signin' ||
          location == '/signup' ||
          location == '/splash';

      // ── Not signed in ────────────────────────────────────────────────────────
      // Always start with the intro onboarding flow
      if (user == null) {
        if (location == '/splash') return '/intro';
        return isOnUnauthRoute ? null : '/intro';
      }

      // ── Signed in ────────────────────────────────────────────────────────────
      // If the user is on an unauth route (e.g. just logged in from /landing),
      // check their Firestore onboarding status.
      if (isOnUnauthRoute) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          final onboardingComplete =
              (doc.data()?['onboardingComplete'] as bool?) ?? false;
          return onboardingComplete ? '/home' : '/setup';
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

      // ── Pre-auth Intro Onboarding ──────────────────────────────────────────
      GoRoute(
        path: '/intro',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const IntroScreen(),
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

      // ── Post-auth Setup (Semester + Timetable) ─────────────────────────────
      GoRoute(
        path: '/setup',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SetupScreen(),
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

      // ── AI Roadmap Detail ──────────────────────────────────────────────────
      GoRoute(
        path: '/ai-roadmap',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AiRoadmapDetailScreen(),
          transitionsBuilder: _fadeSlideTransition,
        ),
      ),

      // ── Offline Screen ─────────────────────────────────────────────────────
      GoRoute(
        path: '/offline',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const OfflineScreen(),
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

      // ── Settings ───────────────────────────────────────────────────────────
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SettingsScreen(),
          transitionsBuilder: _fadeSlideTransition,
        ),
        routes: [
          GoRoute(
            path: 'edit_profile',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const EditProfileScreen(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: 'edit_semester',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const EditSemesterScreen(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: 'notifications',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const NotificationSettingsScreen(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: 'appearance',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const AppearanceSettingsScreen(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: 'export_data',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const ExportDataScreen(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: 'help_feedback',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const HelpFeedbackScreen(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: 'delete_account',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const DeleteAccountScreen(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
        ],
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
