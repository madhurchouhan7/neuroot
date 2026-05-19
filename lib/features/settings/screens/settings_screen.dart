import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/auth/providers/auth_provider.dart';
import 'package:neuroot/features/settings/providers/settings_provider.dart';
import 'package:neuroot/features/settings/widgets/appearance_card.dart';
import 'package:neuroot/features/settings/widgets/semester_card.dart';
import 'package:neuroot/features/settings/widgets/settings_section_header.dart';
import 'package:neuroot/features/settings/widgets/settings_tile.dart';
import 'package:neuroot/features/settings/widgets/settings_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    // Show snack on success / error
    ref.listen<SettingsState>(settingsProvider, (prev, next) {
      if (next.successMessage != null && next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!, style: AppTypography.bodyMedium(color: AppColors.white)),
            backgroundColor: AppColors.sageDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        ref.read(settingsProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!, style: AppTypography.bodyMedium(color: AppColors.white)),
            backgroundColor: const Color(0xFFBA1A1A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        ref.read(settingsProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          ),
        ),
        title: Text(
          'Settings',
          style: AppTypography.titleMedium(color: AppColors.textPrimary),
        ),
        actions: [
          if (settings.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  color: AppColors.amber,
                  strokeWidth: 2,
                ),
              ),
            ),
          IconButton(
            onPressed: () => ref.read(settingsProvider.notifier).reload(),
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 20),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(settingsProvider.notifier).reload(),
        color: AppColors.amber,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  const SizedBox(height: 8),

                  // ── Profile Header ──────────────────────────────────────────
                  const SettingsProfileHeader(),
                  const SizedBox(height: 8),

                  // ── Semester ───────────────────────────────────────────────
                  const SettingsSectionHeader('Semester'),
                  const SemesterCard(),
                  const SizedBox(height: 8),

                  // ── Timetable ──────────────────────────────────────────────
                  const SettingsSectionHeader('Timetable'),
                  const TimetableManagerCard(),

                  // ── Appearance ─────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SettingsSectionHeader('Appearance'),
                      GestureDetector(
                        onTap: () => context.push('/settings/appearance'),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8, bottom: 8),
                          child: Text('Full settings →', style: AppTypography.bodyMedium(color: AppColors.amber).copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                  const AppearanceCard(),

                  // ── Preferences ────────────────────────────────────────────
                  const SettingsSectionHeader('Preferences'),
                  _preferencesCard(context, ref, settings),

                  // ── Data & Privacy ─────────────────────────────────────────
                  const SettingsSectionHeader('Data & Privacy'),
                  _listCard([
                    SettingsTile(
                      icon: Icons.download_rounded,
                      iconColor: const Color(0xFF6BAF8B),
                      iconBg: const Color(0xFFEAF4EE),
                      title: 'Export my data',
                      onTap: () => context.push('/settings/export_data'),
                    ),
                    const _Divider(),
                    SettingsTile(
                      icon: Icons.delete_forever_outlined,
                      iconColor: const Color(0xFFF5A623),
                      iconBg: const Color(0xFFFFF3D8),
                      title: 'Request data deletion',
                      onTap: () => context.push('/settings/export_data'),
                    ),
                    const _Divider(),
                    SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      iconColor: AppColors.textSecondary,
                      iconBg: AppColors.warmCream,
                      title: 'Privacy policy',
                      onTap: () => _notImplemented(context),
                    ),
                  ]),

                  // ── Support ────────────────────────────────────────────────
                  const SettingsSectionHeader('Support'),
                  _listCard([
                    SettingsTile(
                      icon: Icons.feedback_outlined,
                      iconColor: const Color(0xFF7C5CBF),
                      iconBg: const Color(0xFFF3EEFA),
                      title: 'Send feedback',
                      onTap: () => context.push('/settings/help_feedback'),
                    ),
                    const _Divider(),
                    SettingsTile(
                      icon: Icons.star_outline_rounded,
                      iconColor: const Color(0xFFF5A623),
                      iconBg: const Color(0xFFFFF3D8),
                      title: 'Rate Bloom',
                      onTap: () => _notImplemented(context),
                    ),
                    const _Divider(),
                    SettingsTile(
                      icon: Icons.help_outline_rounded,
                      iconColor: const Color(0xFF52B788),
                      iconBg: const Color(0xFFEAF4EE),
                      title: 'Help & FAQ',
                      onTap: () => context.push('/settings/help_feedback'),
                    ),
                    const _Divider(),
                    SettingsTile(
                      icon: Icons.description_outlined,
                      iconColor: AppColors.textSecondary,
                      iconBg: AppColors.warmCream,
                      title: 'Terms of service',
                      onTap: () => _notImplemented(context),
                    ),
                  ]),

                  // ── Sign Out ───────────────────────────────────────────────
                  const SizedBox(height: 20),
                  _signOutTile(context, ref),
                  const SizedBox(height: 16),

                  // ── Danger Zone ────────────────────────────────────────────
                  const SettingsSectionHeader('Danger Zone'),
                  DangerZoneCard(
                    onClearData: () => _confirmClearData(context, ref),
                    onDeleteAccount: () => context.push('/settings/delete_account'),
                  ),

                  // ── Footer ─────────────────────────────────────────────────
                  const SizedBox(height: 20),
                  const SettingsFooter(),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Preferences card ───────────────────────────────────────────────────────

  Widget _preferencesCard(BuildContext context, WidgetRef ref, SettingsState s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EBE3)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          SettingsToggle(
            icon: Icons.notifications_rounded,
            iconColor: const Color(0xFFF5A623),
            iconBg: const Color(0xFFFFF3D8),
            title: 'Notifications',
            subtitle: 'Task reminders & class alerts',
            value: s.notificationsEnabled,
            onChanged: (v) => ref.read(settingsProvider.notifier).setNotifications(v),
            trailing: GestureDetector(
              onTap: () => context.push('/settings/notifications'),
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.chevron_right_rounded, color: Color(0xFFC8C0B8)),
              ),
            ),
          ),
          const _Divider(),
          SettingsToggle(
            icon: Icons.local_florist_rounded,
            iconColor: const Color(0xFF52B788),
            iconBg: const Color(0xFFEAF4EE),
            title: 'Sprout AI Coach',
            subtitle: 'Personalised study suggestions',
            value: s.sproutAIEnabled,
            onChanged: (v) => ref.read(settingsProvider.notifier).setSproutAI(v),
          ),
          const _Divider(),
          SettingsToggle(
            icon: Icons.music_note_rounded,
            iconColor: const Color(0xFF7C5CBF),
            iconBg: const Color(0xFFF3EEFA),
            title: 'Focus sounds',
            subtitle: 'Ambient audio during focus sessions',
            value: s.focusSoundsEnabled,
            onChanged: (v) => ref.read(settingsProvider.notifier).setFocusSounds(v),
          ),
          const _Divider(),
          SettingsToggle(
            icon: Icons.calendar_today_rounded,
            iconColor: const Color(0xFFF5A623),
            iconBg: const Color(0xFFFFF3D8),
            title: 'Dynamic timetable',
            subtitle: 'Auto-adjust based on your schedule',
            value: s.dynamicTimetableEnabled,
            onChanged: (v) => ref.read(settingsProvider.notifier).setDynamicTimetable(v),
          ),
        ],
      ),
    );
  }

  // ── Generic white card wrapper ─────────────────────────────────────────────

  Widget _listCard(List<Widget> children) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFF0EBE3)),
      boxShadow: AppColors.softShadow,
    ),
    child: Column(children: children),
  );

  // ── Sign Out Tile ──────────────────────────────────────────────────────────

  Widget _signOutTile(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _confirmSignOut(context, ref),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0EBE3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.logout_rounded, size: 20, color: Color(0xFFBA1A1A)),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Sign out',
                  style: AppTypography.bodyMedium(color: const Color(0xFFBA1A1A))
                      .copyWith(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.white,
        title: Text('Sign out?', style: AppTypography.titleSmall(color: AppColors.textPrimary)),
        content: Text('You will need to sign in again.', style: AppTypography.bodyMedium()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out', style: TextStyle(color: Color(0xFFBA1A1A))),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(authNotifierProvider.notifier).signOut();
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.white,
        title: Text('Clear semester data?', style: AppTypography.titleSmall(color: const Color(0xFFBA1A1A))),
        content: Text(
          'This will permanently delete your semester, all subjects, and your timetable. Attendance records are kept.',
          style: AppTypography.bodyMedium(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(settingsProvider.notifier).clearSemesterData();
  }

  void _notImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coming soon 🌱', style: AppTypography.bodyMedium(color: AppColors.white)),
        backgroundColor: AppColors.sageDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Divider(color: const Color(0xFFF0EBE3), height: 1, indent: 52, endIndent: 0);
  }
}
