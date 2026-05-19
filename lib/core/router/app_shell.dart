import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/planning/screens/planner_screen.dart';
import '../../features/focus/screens/focus_screen.dart';
import '../../features/focus/providers/focus_provider.dart';
import '../../features/academic/screens/insights_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

import '../../features/auth/providers/auth_provider.dart';

// ─── Shell Nav Index Provider ────────────────────────────────────────────────
class ShellNavIndexNotifier extends Notifier<int> {
  @override
  int build() {
    // Reset index to 0 (Dashboard) on auth changes (logout/login)
    ref.listen(authStateProvider, (prev, next) {
      state = 0;
    });
    return 0;
  }
  void setIndex(int index) => state = index;
}

final shellNavIndexProvider = NotifierProvider<ShellNavIndexNotifier, int>(
  ShellNavIndexNotifier.new,
);

// ─── App Shell ───────────────────────────────────────────────────────────────
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _screens = [
    DashboardScreen(),
    PlannerScreen(),
    FocusScreen(),
    InsightsScreen(), // Assuming this will be used for insights
    ProfileScreen(), // Profile screen
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(shellNavIndexProvider);

    final focus = ref.watch(focusProvider);
    final isFocusing = focus.phase != FocusPhase.idle;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: IndexedStack(index: index, children: _screens),
      bottomNavigationBar: isFocusing
          ? null
          : _NeurootBottomNav(
              currentIndex: index,
              onTap: (i) => ref.read(shellNavIndexProvider.notifier).setIndex(i),
            ),
    );
  }
}



// ─── Custom Bottom Nav ────────────────────────────────────────────────────────
class _NeurootBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _NeurootBottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavDef(icon: Icons.home_rounded, outlineIcon: Icons.home_outlined, label: 'Home'),
    _NavDef(icon: Icons.calendar_month_rounded, outlineIcon: Icons.calendar_month_outlined, label: 'Planner'),
    _NavDef(icon: Icons.timer_rounded, outlineIcon: Icons.timer_outlined, label: 'Focus'),
    _NavDef(icon: Icons.analytics_rounded, outlineIcon: Icons.analytics_outlined, label: 'Insights'),
    _NavDef(icon: Icons.person_rounded, outlineIcon: Icons.person_outlined, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72 + MediaQuery.paddingOf(context).bottom,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (i) => _NavTile(
                def: _items[i],
                isSelected: currentIndex == i,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavDef {
  final IconData icon;
  final IconData outlineIcon;
  final String label;
  const _NavDef({required this.icon, required this.outlineIcon, required this.label});
}

class _NavTile extends StatelessWidget {
  final _NavDef def;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTile({
    required this.def,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? def.icon : def.outlineIcon,
              size: 24,
              color: isSelected ? const Color(0xFF755B00) : const Color(0xFF7F7662), // Primary vs Outline
            ),
            const SizedBox(height: 4),
            Text(
              def.label,
              style: AppTypography.labelSmall(
                color: isSelected ? const Color(0xFF755B00) : const Color(0xFF7F7662),
              ).copyWith(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.08),
            ),
            const SizedBox(height: 4),
            // Active dot indicator
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.amber,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

