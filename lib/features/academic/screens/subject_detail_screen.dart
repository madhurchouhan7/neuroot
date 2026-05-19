import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/models/attendance_record_model.dart';
import 'package:neuroot/core/models/subject_model.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/academic/providers/attendance_provider.dart';
import 'package:neuroot/features/settings/providers/settings_provider.dart';
import 'package:neuroot/shared/widgets/neuroot_widgets.dart';

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
    final recordsAsync = ref.watch(
      attendanceRecordsProvider(widget.subject.id),
    );
    final safeLeaves = ref.watch(safeLeavesProvider(widget.subject));
    final actionState = ref.watch(attendanceNotifierProvider);

    // Snack feedback
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
    });

    final subject = widget.subject;
    final pct = subject.attendancePercentage;
    final color = _colorFromHex(subject.color);

    final settings = ref.watch(settingsProvider);
    final threshold = settings.attendanceThreshold;

    // What-if calculation
    final int simTotal;
    final int simPresent;
    if (_whatIfExtra >= 0) {
      // User is simulating attending more classes
      simTotal = subject.totalClasses + _whatIfExtra;
      simPresent = subject.presentClasses + _whatIfExtra;
    } else {
      // User is simulating missing more classes
      simTotal = subject.totalClasses + _whatIfExtra.abs();
      simPresent = subject.presentClasses;
    }

    final simPct = simTotal == 0 ? 0.0 : (simPresent / simTotal) * 100;

    final double t = threshold / 100;
    final int simSafeLeaves;
    if (simPresent >= t * simTotal) {
      simSafeLeaves = ((simPresent - t * simTotal) / t).floor();
    } else {
      final recovery = ((t * simTotal - simPresent) / (1 - t)).ceil();
      simSafeLeaves = -recovery;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2B2B2B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          subject.name,
          style: AppTypography.titleMedium(color: const Color(0xFF2B2B2B)),
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
                                Text(
                                  subject.code,
                                  style: AppTypography.labelSmall(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${pct.toStringAsFixed(1)}%',
                                  style: AppTypography.titleXL(
                                    color: _riskColor(pct),
                                  ).copyWith(fontSize: 40),
                                ),
                                Text(
                                  '${subject.presentClasses} / ${subject.totalClasses} classes',
                                  style: AppTypography.bodyMedium(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
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
                                    valueColor: AlwaysStoppedAnimation(
                                      _riskColor(pct),
                                    ),
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
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _riskBgColor(pct),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            safeLeaves >= 0
                                ? 'Safe to miss $safeLeaves more class${safeLeaves == 1 ? '' : 'es'} 🌱'
                                : 'Need to attend ${safeLeaves.abs()} more to recover ⚠️',
                            style: AppTypography.labelSmall(
                              color: _riskColor(pct),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Mark Today ──────────────────────────────────────────
                  Text(
                    'MARK TODAY',
                    style: AppTypography.labelSmall(
                      color: const Color(0xFF4E4634),
                    ).copyWith(letterSpacing: 1, fontSize: 11),
                  ),
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

                  // ── AI Attendance Simulator Card ──────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFE8E0D4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF5B4A3A,
                          ).withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '🔮',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'AI What-If Predictor',
                                  style: AppTypography.titleSmall(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0EFFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFC7C2FA),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                'AI ENGINE',
                                style:
                                    AppTypography.labelSmall(
                                      color: const Color(0xFF635BFF),
                                    ).copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      fontSize: 9,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _whatIfExtra == 0
                              ? 'Slide to simulate future class scenarios:'
                              : _whatIfExtra > 0
                              ? 'Scenario: Attending $_whatIfExtra consecutive future classes'
                              : 'Scenario: Missing ${_whatIfExtra.abs()} consecutive future classes',
                          style: AppTypography.bodyMedium(
                            color: AppColors.textSecondary,
                          ).copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _whatIfExtra.toDouble(),
                          min: -15,
                          max: 15,
                          divisions: 30,
                          activeColor: _riskColor(simPct),
                          inactiveColor: const Color(0xFFE8E0D4),
                          label: _whatIfExtra > 0
                              ? '+$_whatIfExtra'
                              : '$_whatIfExtra',
                          onChanged: (v) =>
                              setState(() => _whatIfExtra = v.round()),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Simulated: ${simPct.toStringAsFixed(1)}%',
                              style: AppTypography.titleMedium(
                                color: _riskColor(simPct),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _riskBgColor(simPct),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                simSafeLeaves >= 0
                                    ? '+$simSafeLeaves classes (Safe) 🌱'
                                    : '${simSafeLeaves} classes (Risk) ⚠️',
                                style: AppTypography.labelSmall(
                                  color: _riskColor(simPct),
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Mascot Sprout AI Tip
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: simSafeLeaves >= 0
                                ? const Color(0xFFEBF5EB).withValues(alpha: 0.6)
                                : const Color(
                                    0xFFFFECEC,
                                  ).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: simSafeLeaves >= 0
                                  ? const Color(0xFFEBF5EB)
                                  : const Color(0xFFFFECEC),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                simSafeLeaves >= 0 ? '🌱' : '⚠️',
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _whatIfExtra == 0
                                      ? (simSafeLeaves >= 0
                                            ? 'Sprout says: Your attendance is currently stable! You have a buffer of $simSafeLeaves classes you can safely miss while remaining above the $threshold% threshold.'
                                            : 'Sprout warns: You are currently below your target threshold. You need to attend ${simSafeLeaves.abs()} consecutive classes to recover!')
                                      : _whatIfExtra > 0
                                      ? 'Sprout\'s Prediction: Attending $_whatIfExtra classes will lift your attendance to ${simPct.toStringAsFixed(1)}%. ' +
                                            (simSafeLeaves >= 0
                                                ? 'This puts you in the safe zone with $simSafeLeaves buffer classes remaining!'
                                                : 'This helps, but you still need to attend ${simSafeLeaves.abs()} more consecutive classes to hit $threshold%.')
                                      : 'Sprout\'s Warning: Missing ${_whatIfExtra.abs()} classes will drop your attendance to ${simPct.toStringAsFixed(1)}%. ' +
                                            (simSafeLeaves >= 0
                                                ? 'You will remain above threshold, but your buffer will shrink to only $simSafeLeaves classes!'
                                                : 'You will fall below the target! You would then need to attend ${simSafeLeaves.abs()} consecutive classes to recover!'),
                                  style: AppTypography.bodyMedium(
                                    color: simSafeLeaves >= 0
                                        ? const Color(0xFF2C6B2C)
                                        : const Color(0xFFB53F3F),
                                  ).copyWith(fontSize: 12, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Attendance Log ──────────────────────────────────────
                  Text(
                    'ATTENDANCE LOG',
                    style: AppTypography.labelSmall(
                      color: const Color(0xFF4E4634),
                    ).copyWith(letterSpacing: 1, fontSize: 11),
                  ),
                  const SizedBox(height: 12),

                  recordsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: ShimmerListLoading(count: 3),
                    ),
                    error: (e, _) => Text(
                      'Could not load records',
                      style: AppTypography.bodyMedium(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    data: (records) {
                      if (records.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              'No records yet. Mark attendance above 🌱',
                              style: AppTypography.bodyMedium(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: records
                            .map(
                              (r) => _AttendanceLogRow(
                                record: r,
                                subject: subject,
                                formattedDate: _formatDate(r.date),
                                ref: ref,
                              ),
                            )
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
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
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
        child: Text(
          label,
          style: AppTypography.labelSmall(
            color: color,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─── Log Row ──────────────────────────────────────────────────────────────────

class _AttendanceLogRow extends StatelessWidget {
  const _AttendanceLogRow({
    required this.record,
    required this.subject,
    required this.formattedDate,
    required this.ref,
  });
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
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    record.status.name.toUpperCase(),
                    style: AppTypography.labelSmall(
                      color: color,
                    ).copyWith(fontSize: 10, letterSpacing: 0.5),
                  ),
                ],
              ),
            ],
          ),
          // Quick-edit toggle
          PopupMenuButton<AttendanceStatus>(
            icon: const Icon(
              Icons.more_horiz,
              color: Color(0xFF8B8070),
              size: 20,
            ),
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
                .map(
                  (s) => PopupMenuItem(
                    value: s,
                    child: Text(s.name[0].toUpperCase() + s.name.substring(1)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
