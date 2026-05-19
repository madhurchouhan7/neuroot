import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_typography.dart';

class SettingsSectionHeader extends StatelessWidget {
  final String title;
  const SettingsSectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall(color: const Color(0xFF9B9280))
            .copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w700),
      ),
    );
  }
}
