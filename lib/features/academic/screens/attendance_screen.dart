import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/academic/providers/attendance_provider.dart';
import 'package:neuroot/features/academic/repositories/attendance_repository.dart';
import 'package:neuroot/features/academic/screens/subject_detail_screen.dart';
import 'package:neuroot/features/academic/widgets/attendance_subject_card.dart';
import 'package:neuroot/features/academic/widgets/overall_attendance_card.dart';
import 'package:neuroot/features/academic/widgets/attendance_heatmap.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';
import 'package:neuroot/features/settings/providers/settings_provider.dart';
import 'package:neuroot/core/models/attendance_record_model.dart';

final sortByRiskProvider = StateProvider<bool>((ref) => false);

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsStreamProvider);
    final overallPct = ref.watch(overallAttendanceProvider);
    final actionState = ref.watch(attendanceNotifierProvider);
    final settings = ref.watch(settingsProvider);
    final threshold = settings.attendanceThreshold;
    final sortByRisk = ref.watch(sortByRiskProvider);

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
                      final hasData = overallPct != null;
                      final pct = overallPct ?? 0;
                      // Safe leaves = average across subjects that have classes
                      final activeSubjects = subjects
                          .where((s) => s.totalClasses > 0)
                          .toList();
                      final safeLeaves = activeSubjects.isEmpty
                          ? 0
                          : activeSubjects
                                .map(
                                  (s) => AttendanceRepository.computeSafeLeaves(
                                    s,
                                    threshold: threshold,
                                  ),
                                )
                                .fold(0, (a, b) => a + b);
                      return OverallAttendanceCard(
                        percentage: pct,
                        safeLeaves: safeLeaves,
                        threshold: threshold,
                        hasData: hasData,
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // ── Subjects Header ─────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'SUBJECTS',
                        style: AppTypography.labelSmall(
                          color: const Color(0xFF4E4634),
                        ).copyWith(letterSpacing: 1, fontSize: 11),
                      ),
                      GestureDetector(
                        onTap: () =>
                            ref.read(sortByRiskProvider.notifier).state =
                                !sortByRisk,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: sortByRisk
                                ? const Color(0xFFFFECEC)
                                : const Color(
                                    0xFFE8E0D4,
                                  ).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: sortByRisk
                                  ? const Color(
                                      0xFFE05C5C,
                                    ).withValues(alpha: 0.3)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Sort by risk',
                                style: AppTypography.labelSmall(
                                  color: sortByRisk
                                      ? const Color(0xFFE05C5C)
                                      : const Color(0xFF4E4634),
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                sortByRisk
                                    ? Icons.warning_amber_rounded
                                    : Icons.swap_vert,
                                size: 14,
                                color: sortByRisk
                                    ? const Color(0xFFE05C5C)
                                    : const Color(0xFF4E4634),
                              ),
                            ],
                          ),
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

                      final hasNoClassesLogged = subjects.every(
                        (s) => s.totalClasses == 0,
                      );
                      if (hasNoClassesLogged) {
                        return _EmptyAttendanceLogCard(
                          onMarkQuickly: () =>
                              _showQuickMarkSheet(context, ref, subjects),
                        );
                      }

                      final sorted = [...subjects];
                      if (sortByRisk) {
                        // Sort by attendance % ascending (danger first)
                        sorted.sort((a, b) {
                          // Subjects with 0 classes go to the bottom
                          if (a.totalClasses == 0 && b.totalClasses == 0)
                            return 0;
                          if (a.totalClasses == 0) return 1;
                          if (b.totalClasses == 0) return -1;
                          return a.attendancePercentage.compareTo(
                            b.attendancePercentage,
                          );
                        });
                      } else {
                        // Sort alphabetically by name
                        sorted.sort(
                          (a, b) => a.name.toLowerCase().compareTo(
                            b.name.toLowerCase(),
                          ),
                        );
                      }

                      return Column(
                        children: sorted.map((subject) {
                          final hasClasses = subject.totalClasses > 0;
                          final pct = hasClasses
                              ? subject.attendancePercentage
                              : 0.0;
                          final safeLeaves = hasClasses
                              ? AttendanceRepository.computeSafeLeaves(
                                  subject,
                                  threshold: threshold,
                                )
                              : 0;
                          final risk = !hasClasses
                              ? AttendanceRisk
                                    .safe // show neutral for untouched subjects
                              : pct >= threshold
                              ? AttendanceRisk.safe
                              : pct >= (threshold - 3)
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
                            leavesLeft: hasClasses ? safeLeaves.abs() : 0,
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
      floatingActionButton: subjectsAsync.when(
        data: (subjects) {
          if (subjects.isEmpty) return null;
          return FloatingActionButton.extended(
            onPressed: () => _showQuickMarkSheet(context, ref, subjects),
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: AppColors.textPrimary,
            icon: const Icon(Icons.check_circle_outline),
            label: Text(
              'Mark Today',
              style: AppTypography.buttonMedium(color: AppColors.textPrimary),
            ),
          );
        },
        loading: () => null,
        error: (_, __) => null,
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

  void _showQuickMarkSheet(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> subjects,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mark Today\'s Attendance 📝',
                        style: AppTypography.titleMedium(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quickly update attendance for today\'s classes',
                        style: AppTypography.bodySmall(
                          color: const Color(0xFF8B8070),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF4E4634)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: subjects.map((subj) {
                      final dotColor = _colorFromHex(subj.color);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F7F1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF0EBE3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subj.name,
                                    style: AppTypography.bodyMedium(
                                      color: AppColors.textPrimary,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    subj.code.isEmpty ? 'No code' : subj.code,
                                    style: AppTypography.labelSmall(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Quick Status Buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildQuickBtn(
                                  label: 'Present',
                                  activeColor: const Color(0xFFE8F5E9),
                                  textColor: const Color(0xFF2E7D32),
                                  borderActiveColor: const Color(0xFF81C784),
                                  onTap: () {
                                    ref
                                        .read(
                                          attendanceNotifierProvider.notifier,
                                        )
                                        .markAttendance(
                                          subjectId: subj.id,
                                          date: DateTime.now(),
                                          status: AttendanceStatus.present,
                                        );
                                  },
                                ),
                                const SizedBox(width: 6),
                                _buildQuickBtn(
                                  label: 'Absent',
                                  activeColor: const Color(0xFFFFEBEE),
                                  textColor: const Color(0xFFC62828),
                                  borderActiveColor: const Color(0xFFEF5350),
                                  onTap: () {
                                    ref
                                        .read(
                                          attendanceNotifierProvider.notifier,
                                        )
                                        .markAttendance(
                                          subjectId: subj.id,
                                          date: DateTime.now(),
                                          status: AttendanceStatus.absent,
                                        );
                                  },
                                ),
                                const SizedBox(width: 6),
                                _buildQuickBtn(
                                  label: 'Cancel',
                                  activeColor: const Color(0xFFFFF3E0),
                                  textColor: const Color(0xFFE65100),
                                  borderActiveColor: const Color(0xFFFFB74D),
                                  onTap: () {
                                    ref
                                        .read(
                                          attendanceNotifierProvider.notifier,
                                        )
                                        .markAttendance(
                                          subjectId: subj.id,
                                          date: DateTime.now(),
                                          status: AttendanceStatus.cancelled,
                                        );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickBtn({
    required String label,
    required Color activeColor,
    required Color textColor,
    required Color borderActiveColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: activeColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderActiveColor.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall(
            color: textColor,
          ).copyWith(fontWeight: FontWeight.bold, fontSize: 10),
        ),
      ),
    );
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
                url:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCGAc2fsEi31o6PdDuRC1oBoT9gJ1hvP1bw2p3t1AxUd_f6t9fb9q4ONR5jhWot8mHDR8mCmFZK2jpkwleXbgbq6W_yf_0C9qakFGZo6fnJhEK3eb5ZJZASllQ7hsgMHUhwAOKDnDxH0DfvIWdTONSgtucV1ZmZ1VWz6KBx8KGqE6rty14jS_SzE4CVXuv_bGlNeM6f_DQRkitsZp7NYujmbxrzNT6mCG7OIBcf5wHJB6HGi7RAoLZ4OX21fReh4abVUaRgGve9pqk',
                height: 140,
                fit: BoxFit.contain,
                errorIcon: Icons.assignment_outlined,
                placeholderColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No subjects tracked yet',
              style: AppTypography.titleSmall(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first subject today and Sprout\nwill start tracking your academic progress.',
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
                'Create a Subject →',
                style: AppTypography.buttonMedium(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAttendanceLogCard extends StatelessWidget {
  const _EmptyAttendanceLogCard({required this.onMarkQuickly});
  final VoidCallback onMarkQuickly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E0D4), width: 1.5),
      ),
      child: Column(
        children: [
          const Text('📅🌱', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No attendance logged yet',
            style: AppTypography.titleSmall(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Your subjects are created! Now, tap the button below to quickly mark today\'s attendance or tap any subject to manage detailed logs.',
            style: AppTypography.bodyMedium(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onMarkQuickly,
            child: Container(
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
          ),
        ],
      ),
    );
  }
}
