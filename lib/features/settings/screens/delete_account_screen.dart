import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/auth/providers/auth_provider.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final TextEditingController _ctrl = TextEditingController();
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final match = _ctrl.text.trim() == 'DELETE';
      if (match != _canDelete) setState(() => _canDelete = match);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDelete() {
    // 1. Loading state (simulated)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFE05C5C))),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      // 2. Perform delete + sign out
      ref.read(authNotifierProvider.notifier).signOut();
      
      // 3. Clear dialog and navigate to landing with toast
      Navigator.pop(context);
      context.go('/landing');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account deleted. Goodbye. 🌱', style: AppTypography.bodyMedium(color: AppColors.white)),
          backgroundColor: const Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => context.pop(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF8B8070), size: 14),
                const SizedBox(width: 4),
                Text('Settings', style: AppTypography.bodyMedium(color: const Color(0xFF8B8070)).copyWith(fontWeight: FontWeight.w500, fontSize: 13)),
              ],
            ),
          ),
        ),
        title: Text('Delete Account', style: AppTypography.titleSmall(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Sprout Sad Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFE8E8)),
                ),
                child: Column(
                  children: [
                    const Text('🥀', style: TextStyle(fontSize: 64)), // Placeholder for gently sad Sprout
                    const SizedBox(height: 10),
                    Text('We\'ll miss you.', style: AppTypography.titleSmall(color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text(
                      'Deleting your account will permanently remove all your data — attendance, tasks, insights, and Sprout\'s progress.\n\nThis cannot be undone.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(color: const Color(0xFF8B8070)).copyWith(height: 1.6, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // What will be deleted
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFE8E8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This will permanently delete:', style: AppTypography.bodyMedium(color: const Color(0xFFE05C5C)).copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 12),
                    _LossRow('All attendance records across all subjects'),
                    _LossRow('All tasks, assignments, exams, and notes'),
                    _LossRow('Your focus sessions, streaks, and insights'),
                    _LossRow('Sprout\'s progress, level, and unlocked cosmetics'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Alternative Option
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEBF5EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Not sure? Try this instead:', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => context.push('/settings/export_data'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF5EB),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Export my data first →', style: AppTypography.bodyMedium(color: const Color(0xFF2A8052)).copyWith(fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Take a break instead', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w500, fontSize: 13)),
                        Text('You can sign out and come back anytime.', style: AppTypography.bodySmall(color: const Color(0xFF8B8070)).copyWith(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Type to Confirm
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TYPE DELETE TO CONFIRM', style: AppTypography.labelSmall(color: const Color(0xFFE05C5C)).copyWith(letterSpacing: 1.2, fontSize: 10)),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _canDelete ? const Color(0xFFE05C5C) : const Color(0xFFFFCACA), width: 1.5),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Type DELETE here',
                        hintStyle: AppTypography.bodyMedium(color: const Color(0xFFC8C0B8)).copyWith(fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Delete Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canDelete ? const Color(0xFFE05C5C) : const Color(0xFFF5EFEB),
                    foregroundColor: _canDelete ? Colors.white : const Color(0xFFC8C0B8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _canDelete ? _onDelete : null,
                  child: Text('Delete Account', style: AppTypography.bodyMedium(color: _canDelete ? Colors.white : const Color(0xFFC8C0B8)).copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Link
              GestureDetector(
                onTap: () => context.pop(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Cancel — keep my account', style: AppTypography.bodyMedium(color: AppColors.amber).copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _LossRow extends StatelessWidget {
  final String text;
  const _LossRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Color(0xFFE05C5C)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppTypography.bodyMedium(color: const Color(0xFF5A5A5A)).copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
