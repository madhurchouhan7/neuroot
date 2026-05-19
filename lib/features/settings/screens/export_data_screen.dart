import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/auth/providers/user_provider.dart';

class ExportDataScreen extends ConsumerStatefulWidget {
  const ExportDataScreen({super.key});

  @override
  ConsumerState<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends ConsumerState<ExportDataScreen> {
  final Map<String, bool> _scopes = {
    'Attendance records': true,
    'Tasks & assignments': true,
    'Focus session history': true,
    'Planner & calendar': false,
    'Insights & stats': false,
  };
  final Map<String, String> _scopeSubs = {
    'Attendance records': 'All subjects, all dates',
    'Tasks & assignments': 'Current and past semester',
    'Focus session history': 'Time logs, streaks',
    'Planner & calendar': 'Custom events',
    'Insights & stats': 'Analytics data',
  };
  String _format = 'CSV';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userDocProvider).asData?.value;
    final email = user?.email ?? 'arjun@gmail.com';

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
        title: Text('Your Data', style: AppTypography.titleSmall(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Privacy Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEBF5EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(color: Color(0xFFEBF5EB), shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Icon(Icons.lock_rounded, color: Color(0xFF2A8052), size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your data belongs to you.', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('Bloom stores the minimum needed. You can export or delete it anytime.', style: AppTypography.bodySmall(color: const Color(0xFF8B8070)).copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Export Options Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF0E8DC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Export my data', style: AppTypography.titleSmall(color: AppColors.textPrimary).copyWith(fontSize: 15)),
                    const SizedBox(height: 16),
                    
                    // Scopes
                    ..._scopes.keys.map((key) {
                      final val = _scopes[key]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => setState(() => _scopes[key] = !val),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              Container(
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  color: val ? AppColors.amber : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: val ? AppColors.amber : const Color(0xFFD1C5AE)),
                                ),
                                alignment: Alignment.center,
                                child: val ? const Icon(Icons.check_rounded, size: 14, color: AppColors.textPrimary) : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(key, style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w500, fontSize: 13)),
                                    if (val) Text(_scopeSubs[key]!, style: AppTypography.bodySmall(color: const Color(0xFF8B8070)).copyWith(fontSize: 11)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, color: Color(0xFFF5EFE8)),
                    ),

                    // Format row
                    Row(
                      children: [
                        Text('Export as:', style: AppTypography.bodyMedium(color: const Color(0xFF8B8070)).copyWith(fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(width: 12),
                        ...['CSV', 'PDF', 'JSON'].map((f) {
                          final sel = _format == f;
                          return GestureDetector(
                            onTap: () => setState(() => _format = f),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: sel ? AppColors.amber : const Color(0xFFF8F5F0),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: sel ? AppColors.amber : const Color(0xFFD1C5AE)),
                              ),
                              child: Text(f, style: AppTypography.labelMedium(color: sel ? AppColors.textPrimary : const Color(0xFF8B8070))),
                            ),
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Export Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.amber,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Export ready! Check your Downloads folder 📦', style: AppTypography.bodyMedium(color: AppColors.white)),
                              backgroundColor: AppColors.sageDark,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        },
                        icon: const Icon(Icons.inventory_2_outlined, size: 18),
                        label: Text('Export Selected Data', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Request Data Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF0E8DC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Request full data copy', style: AppTypography.titleSmall(color: AppColors.textPrimary).copyWith(fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('We\'ll compile everything and email it to you within 48 hours.', style: AppTypography.bodyMedium(color: const Color(0xFF8B8070)).copyWith(fontSize: 13)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sent to: $email', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w500, fontSize: 13)),
                        const Icon(Icons.edit_rounded, size: 14, color: Color(0xFF8B8070)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: Color(0xFFE0D8CE)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Data request sent to $email ✓', style: AppTypography.bodyMedium(color: AppColors.white)),
                              backgroundColor: AppColors.sageDark,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        },
                        child: Text('Request Data via Email →', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              Center(
                child: Text('Last exported: Never', style: AppTypography.bodySmall(color: const Color(0xFFC8C0B8)).copyWith(fontSize: 12)),
              ),
              
              const SizedBox(height: 32),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Your data rights are protected under DPDPA 2023 (India). Contact support@bloomapp.in for questions.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall(color: const Color(0xFFC8C0B8)).copyWith(fontSize: 11),
                  ),
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
