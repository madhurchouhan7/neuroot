import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/onboarding/providers/onboarding_provider.dart';
import 'package:neuroot/shared/widgets/neuroot_widgets.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';

// ─── Color palette for new subjects ───────────────────────────────────────────
const _subjectColors = [
  '#FF8A65',
  '#7C5CBF',
  '#52B788',
  '#E8A020',
  '#BA1A1A',
  '#4A90D9',
  '#E76F51',
  '#2A9D8F',
  '#E9C46A',
  '#264653',
];

class SemesterSetupStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const SemesterSetupStep({super.key, required this.onNext});

  @override
  ConsumerState<SemesterSetupStep> createState() => _SemesterSetupStepState();
}

class _SemesterSetupStepState extends ConsumerState<SemesterSetupStep> {
  late TextEditingController _nameCtrl;
  final _dateFmt = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: ref.read(onboardingProvider).semesterName,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // ── Date picker ──────────────────────────────────────────────────────────────

  Future<void> _pickDate(bool isStart) async {
    final s = ref.read(onboardingProvider);
    final init = isStart
        ? (s.startDate ?? DateTime.now())
        : (s.endDate ?? DateTime.now().add(const Duration(days: 120)));
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.amber,
            onPrimary: Colors.white,
            surface: AppColors.warmCream,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    if (isStart) {
      ref.read(onboardingProvider.notifier).setStartDate(picked);
    } else {
      ref.read(onboardingProvider.notifier).setEndDate(picked);
    }
  }

  // ── Add Subject bottom sheet ─────────────────────────────────────────────────

  void _showAddSubject() {
    String name = '';
    String code = '';
    String selectedColor = _subjectColors[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.warmCream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Subject',
                    style: AppTypography.titleMedium(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sheetField('Subject Name', (v) => name = v),
                  const SizedBox(height: 12),
                  _sheetField('Short Code (e.g. DSA)', (v) => code = v),
                  const SizedBox(height: 16),
                  Text(
                    'Pick a colour',
                    style: AppTypography.labelLarge(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: _subjectColors.map((hex) {
                      final color = _hexColor(hex);
                      final isSelected = hex == selectedColor;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColor = hex),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (name.trim().isEmpty) return;
                        ref.read(onboardingProvider.notifier).addSubject({
                          'name': name.trim(),
                          'code': code.trim().isNotEmpty
                              ? code.trim().toUpperCase()
                              : name
                                    .trim()
                                    .substring(
                                      0,
                                      name.trim().length.clamp(0, 4),
                                    )
                                    .toUpperCase(),
                          'color': selectedColor,
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Add Subject',
                        style: AppTypography.buttonMedium(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sheetField(String hint, ValueChanged<String> onChanged) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMedium(color: const Color(0xFFB0A898)),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF0EBE3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF0EBE3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.amber, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Color _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.amber;
    }
  }

  String _formatDate(DateTime? d) =>
      d != null ? _dateFmt.format(d) : 'Pick date';

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(onboardingProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Mascot + step badge
                  Center(
                    child: NeurootNetworkImage(
                      url:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBkgJVMoaR_-QpCUz412ZSDt4ReD_578rnJOcYb8zClZg5eZGgtZ0H4ghYACDV1qSs3zX6X0pcID2HZBosYoXp7VOcPs6BzYbAxUt68R7HkLl-GuF2dUYw37N6KmLZ06wS9r8fdDXPB1_b-yu6ajukdE-yR3jLepK6Sp2E88lHojp3nS-ORacSBesxBAFwl1JV4hG1_M-HlLiKn6fzH70e21v0D267lkor3oJxHj-v5mwciL_XILaUGZzxW4zs5r1kI3aJvf72wzLQ',
                      width: 72,
                      height: 72,
                      fit: BoxFit.contain,
                      errorIcon: Icons.school_rounded,
                      placeholderColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Step badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'STEP 2 OF 4',
                        style: AppTypography.labelSmall(color: AppColors.amber)
                            .copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Center(
                    child: Text(
                      'Set up your semester',
                      style: AppTypography.titleXL(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Takes under 2 minutes. We promise.',
                      style: AppTypography.bodyMedium(
                        color: const Color(0xFF7F7662),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Semester Name
                  Text(
                    'Semester Name',
                    style: AppTypography.labelLarge(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _nameField(s),
                  const SizedBox(height: 20),

                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: _dateField(
                          'Start Date',
                          s.startDate,
                          () => _pickDate(true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dateField(
                          'End Date',
                          s.endDate,
                          () => _pickDate(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Target Attendance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target Attendance',
                        style: AppTypography.labelLarge(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Most require 75%',
                        style: AppTypography.labelSmall(
                          color: const Color(0xFF7F7662),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [75, 80, 85].map((pct) {
                      final isSelected = s.attendanceThreshold == pct;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => ref
                              .read(onboardingProvider.notifier)
                              .setAttendanceThreshold(pct),
                          child: Container(
                            margin: EdgeInsets.only(right: pct == 85 ? 0 : 10),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.amber
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.amber
                                    : const Color(0xFFF0EBE3),
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$pct%',
                              style: AppTypography.labelLarge(
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : const Color(0xFF7F7662),
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Subjects
                  Text(
                    'Subjects',
                    style: AppTypography.labelLarge(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...s.subjects.asMap().entries.map((e) {
                        final color = _hexColor(e.value['color'] ?? '#A8D5BA');
                        final bg = color.withValues(alpha: 0.15);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                e.value['code'] ?? '',
                                style: AppTypography.labelMedium(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => ref
                                    .read(onboardingProvider.notifier)
                                    .removeSubject(e.key),
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: AppColors.textPrimary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Add Subject button
                      GestureDetector(
                        onTap: _showAddSubject,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFD1C5AE),
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add,
                                size: 16,
                                color: Color(0xFF7F7662),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Add Subject',
                                style: AppTypography.labelMedium(
                                  color: const Color(0xFF7F7662),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bottom CTA
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                NeurootButton(
                  label: 'Continue',
                  backgroundColor: AppColors.amber,
                  textColor: AppColors.textPrimary,
                  icon: const Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                  onTap: widget.onNext,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '✦',
                      style: TextStyle(color: AppColors.amber, fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'You can edit these anytime',
                      style: AppTypography.labelSmall(
                        color: const Color(0xFF7F7662),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────────

  Widget _nameField(OnboardingState s) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0EBE3), width: 2),
      ),
      child: TextField(
        controller: _nameCtrl,
        onChanged: ref.read(onboardingProvider.notifier).setSemesterName,
        style: AppTypography.bodyMedium(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'e.g. Sem 4 · 2025–26',
          hintStyle: AppTypography.bodyMedium(color: const Color(0xFFB0A898)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: s.semesterName.isNotEmpty
              ? const Icon(
                  Icons.check_circle,
                  color: AppColors.sageDark,
                  size: 20,
                )
              : null,
        ),
      ),
    );
  }

  Widget _dateField(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF0EBE3), width: 2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(date),
                    style: AppTypography.bodyMedium(
                      color: date != null
                          ? AppColors.textPrimary
                          : const Color(0xFFB0A898),
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.sageDark,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
