import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:neuroot/features/auth/providers/user_provider.dart';
import 'package:neuroot/features/dashboard/providers/dashboard_provider.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(userGreetingProvider);
    final userState = ref.watch(userDocProvider);
    
    // We only access these safely if available, else we show fallbacks
    final photoUrl = userState.asData?.value?.photoUrl;
    final level = userState.asData?.value?.level ?? 1;

    final dateStr = DateFormat('EEEE, d MMM').format(DateTime.now()).toUpperCase();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr,
              style: AppTypography.labelSmall(color: AppColors.primaryContainer)
                  .copyWith(letterSpacing: 0.08, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              greeting,
              style: AppTypography.titleXL(color: const Color(0xFF2B2B2B)).copyWith(fontSize: 28),
            ),
          ],
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3C4), // bloom-yellow-soft
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryContainer, width: 1.5),
              ),
              child: photoUrl != null && photoUrl.isNotEmpty
                ? NeurootNetworkImage(
                    url: photoUrl,
                    width: 62,
                    height: 62,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(18),
                    errorIcon: Icons.person_rounded,
                  )
                : const Icon(Icons.person_rounded, color: AppColors.primaryContainer, size: 32),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2B2B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.white),
                ),
                child: Text(
                  'Lv $level',
                  style: AppTypography.labelSmall(color: AppColors.white).copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
