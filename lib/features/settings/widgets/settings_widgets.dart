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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EBE3)),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.amber.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.amber.withValues(alpha: 0.4), width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: photoUrl.isNotEmpty
                ? NeurootNetworkImage(url: photoUrl, height: 52, fit: BoxFit.cover)
                : Center(
                    child: Text(
                      initials.isEmpty ? '🌱' : initials,
                      style: AppTypography.titleSmall(color: AppColors.amber),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.titleSmall(color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(email, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/settings/edit_profile'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Edit ✏️', style: AppTypography.labelSmall(color: const Color(0xFF8B8070))),
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
