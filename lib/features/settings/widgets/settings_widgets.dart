import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/auth/providers/user_provider.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';

class SettingsProfileHeader extends ConsumerWidget {
  const SettingsProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDocProvider).asData?.value;
    final name = user?.displayName ?? 'Student';
    final email = user?.email ?? '';
    final initials = name.trim().split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();
    final photoUrl = user?.photoUrl ?? '';

    final level = user?.level ?? 1;
    final college = user?.college ?? '';
    final collegeText = college.isNotEmpty ? college : 'VIT Pune · B.Tech CSE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF252525), // Premium dark carbon background
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDCB52), // Gold/Yellow square box
                  borderRadius: BorderRadius.circular(22),
                ),
                clipBehavior: Clip.antiAlias,
                child: photoUrl.isNotEmpty
                    ? NeurootNetworkImage(url: photoUrl, height: 72, width: 72, fit: BoxFit.cover)
                    : Center(
                        child: Text(
                          initials.isEmpty ? '🌱' : initials,
                          style: AppTypography.titleMedium(color: const Color(0xFF252525)).copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF429F77), // Emerald Green level badge
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF252525), width: 2),
                  ),
                  child: Text(
                    'Lv $level',
                    style: AppTypography.labelSmall(color: Colors.white).copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTypography.titleMedium(color: Colors.white).copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: AppTypography.bodyMedium(color: Colors.white.withValues(alpha: 0.5)).copyWith(
                    fontSize: 13,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  collegeText,
                  style: AppTypography.bodySmall(color: Colors.white.withValues(alpha: 0.35)).copyWith(
                    fontSize: 12,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.push('/settings/edit_profile'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08), // Semi-transparent glass background
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit ',
                    style: AppTypography.labelSmall(color: const Color(0xFFFDCB52)).copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFFFDCB52),
                    size: 13,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings Toggle Row ──────────────────────────────────────────────────────

class SettingsToggle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? trailing;

  const SettingsToggle({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600)),
                if (subtitle != null)
                  Text(subtitle!, style: AppTypography.bodySmall(color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.amber,
            activeTrackColor: AppColors.amber.withValues(alpha: 0.25),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

// ─── Danger Zone Card ─────────────────────────────────────────────────────────

class DangerZoneCard extends ConsumerWidget {
  final VoidCallback onClearData;
  final VoidCallback onDeleteAccount;

  const DangerZoneCard({
    super.key,
    required this.onClearData,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFDAD6)),
      ),
      child: Column(
        children: [
          _DangerRow(
            icon: Icons.delete_sweep_outlined,
            label: 'Clear semester data',
            onTap: onClearData,
          ),
          Divider(color: const Color(0xFFFFDAD6), height: 20),
          _DangerRow(
            icon: Icons.no_accounts_outlined,
            label: 'Delete account',
            onTap: onDeleteAccount,
          ),
        ],
      ),
    );
  }
}

class _DangerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DangerRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFBA1A1A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium(color: const Color(0xFFBA1A1A))
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFBA1A1A), size: 20),
        ],
      ),
    );
  }
}

// ─── App Footer ───────────────────────────────────────────────────────────────

class SettingsFooter extends StatelessWidget {
  const SettingsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.sageSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sage.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            'Bloom v1.0.0',
            style: AppTypography.labelMedium(color: AppColors.sageDark),
          ),
          const SizedBox(height: 4),
          Text(
            'Sprout believes in you, always.',
            style: AppTypography.bodySmall(color: AppColors.sageDark.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}
