import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/models/attendance_record_model.dart';
import 'package:neuroot/core/models/subject_model.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/academic/providers/attendance_provider.dart';

/// Subject detail screen: shows attendance history, what-if calculator,
/// and lets the user mark today's attendance.
class SubjectDetailScreen extends ConsumerStatefulWidget {
  final SubjectModel subject;
  const SubjectDetailScreen({super.key, required this.subject});

  @override
  ConsumerState<SubjectDetailScreen> createState() =>
      _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends ConsumerState<SubjectDetailScreen> {
  // What-if slider state (extra future classes to simulate)
  int _whatIfExtra = 0;

  @override
  Widget build(BuildContext context) {
    final recordsAsync =
        ref.watch(attendanceRecordsProvider(widget.subject.id));
    final safeLeaves = ref.watch(safeLeavesProvider(widget.subject));
    final actionState = ref.watch(attendanceNotifierProvider);

    // Snack feedback
    ref.listen<AttendanceActionState>(attendanceNotifierProvider, (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMessage!,
              style: AppTypography.bodyMedium(color: AppColors.white)),
          backgroundColor: AppColors.sageDark,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
        ref.read(attendanceNotifierProvider.notifier).clearMessages();
      }
    });

    final subject = widget.subject;
    final pct = subject.attendancePercentage;
    final color = _colorFromHex(subject.color);

    // What-if calculation
    final simTotal = subject.totalClasses + _whatIfExtra;
    final simPct = simTotal == 0
        ? 0.0
        : (subject.presentClasses / simTotal) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2B2B2B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(subject.name,
            style: AppTypography.titleMedium(color: const Color(0xFF2B2B2B))),
        actions: [
          if (actionState.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.sageDark),
              ),
            ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats Card ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(subject.code,
                                    style: AppTypography.labelSmall(
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Text('${pct.toStringAsFixed(1)}%',
                                    style: AppTypography.titleXL(
                                        color: _riskColor(pct)).copyWith(
                                      fontSize: 40,
                                    )),
                                Text(
                                    '${subject.presentClasses} / ${subject.totalClasses} classes',
                                    style: AppTypography.bodyMedium(
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: pct / 100,
                                    strokeWidth: 8,
                                    backgroundColor: const Color(0xFFE8E0D4),
                                    valueColor:
                                        AlwaysStoppedAnimation(_riskColor(pct)),
                                  ),
                                ),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Risk pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _riskBgColor(pct),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            safeLeaves >= 0
                                ? 'Safe to miss $safeLeaves more class${safeLeaves == 1 ? '' : 'es'} 🌱'
                                : 'Need to attend ${safeLeaves.abs()} more to recover ⚠️',
                            style: AppTypography.labelSmall(
                                color: _riskColor(pct)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Mark Today ──────────────────────────────────────────
                  Text('MARK TODAY',
                      style: AppTypography.labelSmall(
                              color: const Color(0xFF4E4634))
                          .copyWith(letterSpacing: 1, fontSize: 11)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MarkButton(
                          label: 'Present ✅',
                          color: AppColors.sageDark,
                          bgColor: const Color(0xFFEBF5EB),
                          onTap: () => ref
                              .read(attendanceNotifierProvider.notifier)
                              .markAttendance(
                                subjectId: subject.id,
                                date: DateTime.now(),
                                status: AttendanceStatus.present,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MarkButton(
                          label: 'Absent 😔',
                          color: const Color(0xFFE05C5C),
                          bgColor: const Color(0xFFFFECEC),
                          onTap: () => ref
                              .read(attendanceNotifierProvider.notifier)
                              .markAttendance(
                                subjectId: subject.id,
                                date: DateTime.now(),
                                status: AttendanceStatus.absent,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MarkButton(
                          label: 'Cancelled 📌',
                          color: AppColors.amber,
                          bgColor: const Color(0xFFFFF8E8),
                          onTap: () => ref
                              .read(attendanceNotifierProvider.notifier)
                              .markAttendance(
                                subjectId: subject.id,
                                date: DateTime.now(),
                                status: AttendanceStatus.cancelled,
                              ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── What-If Calculator ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: const Color(0xFFE8E0D4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🔮',
                                style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text('What-If Calculator',
                                style: AppTypography.titleSmall(
                                    color: AppColors.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                            'If I miss $_whatIfExtra more class${_whatIfExtra == 1 ? '' : 'es'}…',
                            style: AppTypography.bodyMedium(
                                color: AppColors.textSecondary)),
                        Slider(
                          value: _whatIfExtra.toDouble(),
                          min: 0,
                          max: 20,
                          divisions: 20,
                          activeColor: _riskColor(simPct),
                          inactiveColor: const Color(0xFFE8E0D4),
                          label: '$_whatIfExtra',
                          onChanged: (v) =>
                              setState(() => _whatIfExtra = v.round()),
                        ),
                        Text(
                          'Simulated attendance: ${simPct.toStringAsFixed(1)}%',
                          style: AppTypography.labelMedium(
                              color: _riskColor(simPct)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Attendance Log ──────────────────────────────────────
                  Text('ATTENDANCE LOG',
                      style: AppTypography.labelSmall(
                              color: const Color(0xFF4E4634))
                          .copyWith(letterSpacing: 1, fontSize: 11)),
                  const SizedBox(height: 12),

                  recordsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                            color: AppColors.sageDark),
                      ),
                    ),
                    error: (e, _) => Text('Could not load records',
                        style: AppTypography.bodyMedium(
                            color: AppColors.textSecondary)),
                    data: (records) {
                      if (records.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text('No records yet. Mark attendance above 🌱',
                                style: AppTypography.bodyMedium(
                                    color: AppColors.textSecondary)),
                          ),
                        );
                      }
                      return Column(
                        children: records
                            .map((r) => _AttendanceLogRow(
                                record: r,
                                subject: subject,
                                formattedDate: _formatDate(r.date),
                                ref: ref))
                            .toList(),
                      );
                    },
                  ),
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
      return Color(
          int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.sageDark;
    }
  }

  Color _riskColor(double pct) {
    if (pct >= 80) return AppColors.sageDark;
    if (pct >= 75) return AppColors.amber;
    return const Color(0xFFE05C5C);
  }

  Color _riskBgColor(double pct) {
    if (pct >= 80) return const Color(0xFFEBF5EB);
    if (pct >= 75) return const Color(0xFFFFF3C4);
    return const Color(0xFFFFECEC);
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
  }
}

// ─── Mark Button ──────────────────────────────────────────────────────────────

class _MarkButton extends StatelessWidget {
  const _MarkButton({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: AppTypography.labelSmall(color: color)
                .copyWith(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ─── Log Row ──────────────────────────────────────────────────────────────────

class _AttendanceLogRow extends StatelessWidget {
  const _AttendanceLogRow(
      {required this.record, required this.subject, required this.formattedDate, required this.ref});
  final AttendanceRecord record;
  final SubjectModel subject;
  final String formattedDate;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final isPresent = record.status == AttendanceStatus.present;
    final isAbsent = record.status == AttendanceStatus.absent;
    final emoji = isPresent
        ? '✅'
        : isAbsent
            ? '😔'
            : '📌';
    final color = isPresent
        ? AppColors.sageDark
        : isAbsent
            ? const Color(0xFFE05C5C)
            : AppColors.amber;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      formattedDate,
                      style: AppTypography.bodyMedium(
                          color: AppColors.textPrimary)),
                  Text(record.status.name.toUpperCase(),
                      style: AppTypography.labelSmall(color: color)
                          .copyWith(fontSize: 10, letterSpacing: 0.5)),
                ],
              ),
            ],
          ),
          // Quick-edit toggle
          PopupMenuButton<AttendanceStatus>(
            icon: const Icon(Icons.more_horiz,
                color: Color(0xFF8B8070), size: 20),
            onSelected: (newStatus) {
              ref
                  .read(attendanceNotifierProvider.notifier)
                  .editAttendance(
                    recordId: record.id,
                    subjectId: subject.id,
                    oldStatus: record.status,
                    newStatus: newStatus,
                  );
            },
            itemBuilder: (_) => AttendanceStatus.values
                .where((s) => s != record.status)
                .map((s) => PopupMenuItem(
                      value: s,
                      child: Text(s.name[0].toUpperCase() +
                          s.name.substring(1)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
