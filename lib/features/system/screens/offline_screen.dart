import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/shared/widgets/bounce_button.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1A), // Dark relaxing background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Sprout Sleeping Illustration
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2A28), // Inner dark circle
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF111111).withValues(alpha: 0.5),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '😴🌱',
                    style: TextStyle(fontSize: 96),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Text Content
              Text(
                'You are off-grid.',
                style: AppTypography.titleXL(color: AppColors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'No internet connection detected.\nSprout is taking a nap while we wait for connection. You can still access cached data.',
                style: AppTypography.bodyMedium(color: const Color(0xFF8B857F)).copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Actions
              BounceButton(
                onTap: () {
                  // In a real app we'd trigger a connectivity check
                  // For now, let's just pop back if possible or route home
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.amber,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Try Again',
                    style: AppTypography.titleMedium(color: const Color(0xFF2B2B2B)).copyWith(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BounceButton(
                onTap: () => context.go('/home'),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF4A4641)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Continue Offline',
                    style: AppTypography.titleMedium(color: const Color(0xFF8B857F)).copyWith(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
