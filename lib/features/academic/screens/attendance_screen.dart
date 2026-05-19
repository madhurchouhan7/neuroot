import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/academic/providers/attendance_provider.dart';
import 'package:neuroot/features/academic/repositories/attendance_repository.dart';
import 'package:neuroot/features/academic/screens/subject_detail_screen.dart';
import 'package:neuroot/features/academic/widgets/attendance_subject_card.dart';
import 'package:neuroot/features/academic/widgets/overall_attendance_card.dart';
import 'package:neuroot/features/academic/widgets/attendance_heatmap.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsStreamProvider);
    final overallPct = ref.watch(overallAttendanceProvider);
    final actionState = ref.watch(attendanceNotifierProvider);

    // Show success/error snackbar
    ref.listen<AttendanceActionState>(attendanceNotifierProvider, (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.successMessage!,
              style: AppTypography.bodyMedium(color: AppColors.white),
            ),
            backgroundColor: AppColors.sageDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        ref.read(attendanceNotifierProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.errorMessage!,
              style: AppTypography.bodyMedium(color: AppColors.white),
            ),
            backgroundColor: AppColors.dangerSoftRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        ref.read(attendanceNotifierProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2B2B2B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Attendance',
          style: AppTypography.titleMedium(
            color: const Color(0xFF2B2B2B),
          ).copyWith(fontSize: 20),
        ),
        actions: [
          if (actionState.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.sageDark,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF2B2B2B),
            ),
            onPressed: () => _showAddSubjectSheet(context, ref),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ── Overall Card ────────────────────────────────────────
                  subjectsAsync.when(
                    loading: () => const _LoadingCard(),
                    error: (e, _) => _ErrorCard(message: e.toString()),
                    data: (subjects) {
                      final pct = overallPct ?? 0;
                      final safeLeaves = subjects.isEmpty
                          ? 0
                          : subjects
                                .map(
                                  (s) =>
                                      AttendanceRepository.computeSafeLeaves(s),
                                )
                                .fold(0, (a, b) => a + (b > 0 ? b : 0));
                      return OverallAttendanceCard(
                        percentage: pct,
                        safeLeaves: safeLeaves,
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // ── Subjects Header ─────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'SUBJECTS',
                        style: AppTypography.labelSmall(
                          color: const Color(0xFF4E4634),
                        ).copyWith(letterSpacing: 1, fontSize: 11),
                      ),
                      GestureDetector(
                        onTap: () {}, // TODO: sort toggle
                        child: Row(
                          children: [
                            Text(
                              'Sort by risk',
                              style: AppTypography.labelSmall(
                                color: AppColors.primaryContainer,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_downward,
                              size: 14,
                              color: AppColors.primaryContainer,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Subject Cards ───────────────────────────────────────
                  subjectsAsync.when(
                    loading: () => const _SubjectsLoadingSkeleton(),
                    error: (e, _) => _ErrorCard(message: e.toString()),
                    data: (subjects) {
                      if (subjects.isEmpty) {
                        return _EmptySubjectsCard(
                          onAdd: () => _showAddSubjectSheet(context, ref),
                        );
                      }

                      // Sort: danger first, then warning, then safe
                      final sorted = [...subjects]
                        ..sort((a, b) {
                          return a.attendancePercentage.compareTo(
                            b.attendancePercentage,
                          );
                        });

                      return Column(
                        children: sorted.map((subject) {
                          final pct = subject.attendancePercentage;
                          final safeLeaves =
                              AttendanceRepository.computeSafeLeaves(subject);
                          final risk = pct >= 80
                              ? AttendanceRisk.safe
                              : pct >= 75
                              ? AttendanceRisk.warning
                              : AttendanceRisk.danger;
                          final dotColor = _colorFromHex(subject.color);

                          return AttendanceSubjectCard(
                            title: subject.name,
                            professor: subject.code,
                            percentage: pct,
                            dotColor: dotColor,
                            iconBgColor: dotColor.withValues(alpha: 0.15),
                            riskLevel: risk,
                            leavesLeft: safeLeaves.abs(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SubjectDetailScreen(subject: subject),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  const AttendanceHeatmap(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFromHex(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return AppColors.sageDark;
    }
  }

  void _showAddSubjectSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSubjectSheet(ref: ref),
    );
  }
}

// ─── Add Subject Sheet ────────────────────────────────────────────────────────

class _AddSubjectSheet extends StatefulWidget {
  const _AddSubjectSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<_AddSubjectSheet> {
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  String _selectedColor = '#A8D5BA';

  final _colors = [
    '#A8D5BA',
    '#FF8A65',
    '#645495',
    '#D49800',
    '#E05C5C',
    '#7CB9E8',
    '#95D5B2',
    '#CDB4DB',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0D8D0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add Subject 📚',
            style: AppTypography.titleMedium(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          _buildField('Subject Name', 'e.g. Data Structures', _nameCtrl),
          const SizedBox(height: 12),
          _buildField('Subject Code', 'e.g. CS301', _codeCtrl),
          const SizedBox(height: 16),
          Text(
            'COLOR',
            style: AppTypography.labelSmall(
              color: const Color(0xFF8B8070),
            ).copyWith(letterSpacing: 0.8, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: _colors.map((c) {
              final isSelected = c == _selectedColor;
              final color = Color(
                int.parse('FF${c.replaceAll('#', '')}', radix: 16),
              );
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: AppColors.textPrimary, width: 2)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                if (_nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(context);
                await widget.ref
                    .read(attendanceNotifierProvider.notifier)
                    .addSubject(
                      name: _nameCtrl.text.trim(),
                      code: _codeCtrl.text.trim(),
                      color: _selectedColor,
                    );
              },
              child: Text(
                'Add Subject',
                style: AppTypography.buttonMedium(color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelSmall(
            color: const Color(0xFF8B8070),
          ).copyWith(letterSpacing: 0.8, fontSize: 11),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium(color: const Color(0xFFB0A898)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E0D4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E0D4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryContainer),
            ),
          ),
          style: AppTypography.bodyMedium(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.sageDark),
      ),
    );
  }
}

class _SubjectsLoadingSkeleton extends StatelessWidget {
  const _SubjectsLoadingSkeleton();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (i) => Container(
          height: 96,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.softGrey,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECEC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Color(0xFFE05C5C)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Couldn't load data. Check your connection 🌱",
              style: AppTypography.bodyMedium(color: const Color(0xFFE05C5C)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySubjectsCard extends StatelessWidget {
  const _EmptySubjectsCard({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8E0D4), width: 1.5),
        ),
        child: Column(
          children: [
            Opacity(
              opacity: 0.85,
              child: NeurootNetworkImage(
                url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCGAc2fsEi31o6PdDuRC1oBoT9gJ1hvP1bw2p3t1AxUd_f6t9fb9q4ONR5jhWot8mHDR8mCmFZK2jpkwleXbgbq6W_yf_0C9qakFGZo6fnJhEK3eb5ZJZASllQ7hsgMHUhwAOKDnDxH0DfvIWdTONSgtucV1ZmZ1VWz6KBx8KGqE6rty14jS_SzE4CVXuv_bGlNeM6f_DQRkitsZp7NYujmbxrzNT6mCG7OIBcf5wHJB6HGi7RAoLZ4OX21fReh4abVUaRgGve9pqk', // Placeholder for Sprout with clipboard
                height: 140,
                fit: BoxFit.contain,
                errorIcon: Icons.assignment_outlined,
                placeholderColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No attendance tracked yet',
              style: AppTypography.titleSmall(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Mark your first class today and Sprout\nwill start tracking your progress.',
              style: AppTypography.bodyMedium(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Mark Today\'s Classes →',
                style: AppTypography.buttonMedium(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
