import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/settings/providers/settings_provider.dart';

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const _dayIndices = [0, 1, 2, 3, 4, 5];

class SemesterCard extends ConsumerWidget {
  const SemesterCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);

    final startStr = s.semesterStart != null
        ? _fmt(s.semesterStart!)
        : '—';
    final endStr = s.semesterEnd != null ? _fmt(s.semesterEnd!) : '—';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EBE3)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  s.semesterName.isEmpty ? 'My Semester' : s.semesterName,
                  style: AppTypography.titleSmall(color: AppColors.textPrimary),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/settings/edit_semester'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.sageSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_rounded, size: 12, color: AppColors.sageDark),
                      const SizedBox(width: 4),
                      Text('Edit', style: AppTypography.labelSmall(color: AppColors.sageDark)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dates row
          Row(
            children: [
              _statChip('START', startStr, const Color(0xFF6BAF8B), const Color(0xFFEAF4EE)),
              const SizedBox(width: 10),
              _statChip('END', endStr, const Color(0xFFF5A623), const Color(0xFFFFF3D8)),
              const SizedBox(width: 10),
              _statChip('ATT %', '${s.attendanceThreshold}%', const Color(0xFF7C5CBF), const Color(0xFFF3EEFA)),
              const SizedBox(width: 10),
              _statChip('SUBJECTS', '${s.subjects.length}', const Color(0xFFBA1A1A), const Color(0xFFFFDAD6)),
            ],
          ),

          const SizedBox(height: 16),

          // Attendance Goal chips
          _AttendanceGoalRow(
            current: s.attendanceThreshold,
            onChanged: (v) => ref.read(settingsProvider.notifier).updateSemester(attendanceThreshold: v),
          ),

          const SizedBox(height: 14),

          // Subject chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ...s.subjects.map((sub) => _SubjectChip(sub: sub)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color textColor, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label,
                style: AppTypography.labelSmall(color: textColor.withValues(alpha: 0.7))
                    .copyWith(fontSize: 8, letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(value,
                style: AppTypography.statSmall(color: textColor)
                    .copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${_months[d.month - 1]} ${d.day}';

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

}

class _AttendanceGoalRow extends StatelessWidget {
  final int current;
  final ValueChanged<int> onChanged;

  const _AttendanceGoalRow({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [65, 70, 75, 80, 85];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attendance Goal',
            style: AppTypography.labelMedium(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((v) {
            final isSelected = current == v;
            return GestureDetector(
              onTap: () => onChanged(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.amber : AppColors.warmCream,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.amber : const Color(0xFFD1C5AE)),
                ),
                child: Text(
                  '$v%',
                  style: AppTypography.labelMedium(
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 12, color: Color(0xFF9B9280)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Most Indian colleges require 75% minimum attendance.',
                style: AppTypography.bodySmall(color: const Color(0xFF9B9280)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SubjectChip extends StatelessWidget {
  final Map<String, dynamic> sub;
  const _SubjectChip({required this.sub});

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.sage;
    try {
      final hex = (sub['color'] as String?)?.replaceAll('#', '') ?? 'A8D5BA';
      color = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        sub['code'] as String? ?? '',
        style: AppTypography.labelMedium(color: color.withValues(alpha: 0.85))
            .copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ─── Timetable Manager ────────────────────────────────────────────────────────

class TimetableManagerCard extends ConsumerStatefulWidget {
  const TimetableManagerCard({super.key});

  @override
  ConsumerState<TimetableManagerCard> createState() => _TimetableManagerCardState();
}

class _TimetableManagerCardState extends ConsumerState<TimetableManagerCard> {
  late int _selectedDayIndex;

  String get _selectedDay => _days[_selectedDayIndex];

  @override
  void initState() {
    super.initState();
    final currentWeekday = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
    if (currentWeekday >= 1 && currentWeekday <= 6) {
      _selectedDayIndex = currentWeekday - 1;
    } else {
      _selectedDayIndex = 0; // Default to Monday if Sunday
    }
  }

  @override
  Widget build(BuildContext context) {
    final timetable = ref.watch(settingsProvider).timetable;
    final classes = timetable[_selectedDay] ?? [];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EBE3)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Weekly Timetable', style: AppTypography.titleSmall(color: AppColors.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddClass(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.sageSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_rounded, size: 14, color: AppColors.sageDark),
                      const SizedBox(width: 4),
                      Text('Add', style: AppTypography.labelSmall(color: AppColors.sageDark)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Day tabs
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              itemBuilder: (_, i) {
                final isSel = i == _selectedDayIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDayIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.amber : AppColors.warmCream,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSel ? AppColors.amber : const Color(0xFFD1C5AE)),
                    ),
                    child: Text(
                      _days[i],
                      style: AppTypography.labelMedium(
                          color: isSel ? AppColors.textPrimary : AppColors.textSecondary)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Classes list
          if (classes.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('No classes for $_selectedDay',
                    style: AppTypography.bodyMedium(color: AppColors.textMuted)),
              ),
            )
          else
            ...classes.map((cls) => _ClassRow(
              cls: cls,
              day: _selectedDay,
              onDelete: () => ref.read(settingsProvider.notifier)
                  .deleteTimetableClass(_selectedDay, cls['id'] as String),
            )),
        ],
      ),
    );
  }

  void _showAddClass(BuildContext context) {
    final subjects = ref.read(settingsProvider).subjects;
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No subjects found. Complete your semester setup first. 🌱',
              style: AppTypography.bodyMedium(color: AppColors.white)),
          backgroundColor: AppColors.sageDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    String selectedSubjectCode = subjects.first['code'] as String? ?? '';
    final roomCtrl = TextEditingController();
    final profCtrl = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 30);
    int selectedDay = _selectedDayIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setModal) {
        String fmtTime(TimeOfDay t) {
          final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
          final m = t.minute.toString().padLeft(2, '0');
          return '$h:$m ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
        }

        String to24h(TimeOfDay t) {
          final h = t.hour.toString().padLeft(2, '0');
          final m = t.minute.toString().padLeft(2, '0');
          return '$h:$m';
        }

        return Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF9F1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1C5AE),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Add Class', style: AppTypography.titleSmall(color: AppColors.textPrimary)),
                const SizedBox(height: 20),

                // Day selector
                Text('Day', style: AppTypography.labelMedium(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _days.length,
                    itemBuilder: (_, i) {
                      final isSel = i == selectedDay;
                      return GestureDetector(
                        onTap: () => setModal(() => selectedDay = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.amber : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSel ? AppColors.amber : const Color(0xFFF0EBE3)),
                          ),
                          child: Text(_days[i],
                              style: AppTypography.labelMedium(
                                  color: isSel ? AppColors.textPrimary : AppColors.textSecondary)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Subject
                Text('Subject', style: AppTypography.labelMedium(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF0EBE3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedSubjectCode,
                      items: subjects.map((s) => DropdownMenuItem(
                        value: s['code'] as String,
                        child: Text(
                          '${s['code']} – ${s['name']}',
                          style: AppTypography.bodyMedium(color: AppColors.textPrimary),
                        ),
                      )).toList(),
                      onChanged: (v) => setModal(() => selectedSubjectCode = v ?? ''),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Time
                Row(
                  children: [
                    Expanded(
                      child: _timeField(ctx, 'Start Time', fmtTime(startTime), () async {
                        final t = await showTimePicker(context: ctx, initialTime: startTime);
                        if (t != null) setModal(() => startTime = t);
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _timeField(ctx, 'End Time', fmtTime(endTime), () async {
                        final t = await showTimePicker(context: ctx, initialTime: endTime);
                        if (t != null) setModal(() => endTime = t);
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Room
                TextField(
                  controller: roomCtrl,
                  decoration: InputDecoration(
                    hintText: 'Room / Location (optional)',
                    filled: true, fillColor: AppColors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFF0EBE3))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.amber, width: 2)),
                  ),
                ),
                const SizedBox(height: 14),

                // Professor
                TextField(
                  controller: profCtrl,
                  decoration: InputDecoration(
                    hintText: 'Professor (optional)',
                    filled: true, fillColor: AppColors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFF0EBE3))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.amber, width: 2)),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amber,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      final sub = subjects.firstWhere(
                        (s) => s['code'] == selectedSubjectCode,
                        orElse: () => subjects.first,
                      );
                      ref.read(settingsProvider.notifier).addTimetableClass(
                        day: _days[selectedDay],
                        dayOfWeek: _dayIndices[selectedDay],
                        subjectName: sub['name'] as String? ?? '',
                        subjectCode: sub['code'] as String? ?? '',
                        subjectColor: sub['color'] as String? ?? '#A8D5BA',
                        subjectId: sub['id'] as String? ?? '',
                        startTime: to24h(startTime),
                        endTime: to24h(endTime),
                        room: roomCtrl.text.trim(),
                        professor: profCtrl.text.trim(),
                      );
                      Navigator.pop(ctx);
                    },
                    child: Text('Add Class', style: AppTypography.buttonMedium()),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _timeField(BuildContext ctx, String label, String value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall(color: const Color(0xFF7F7662))),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF0EBE3), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: AppColors.sageDark),
                const SizedBox(width: 6),
                Text(value, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ClassRow extends StatelessWidget {
  final Map<String, dynamic> cls;
  final String day;
  final VoidCallback onDelete;

  const _ClassRow({required this.cls, required this.day, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.sage;
    try {
      final hex = (cls['subjectColor'] as String?)?.replaceAll('#', '') ?? 'A8D5BA';
      color = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}

    return Dismissible(
      key: ValueKey(cls['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFDAD6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A)),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: AppColors.white,
            title: Text('Delete Class?', style: AppTypography.titleSmall(color: AppColors.textPrimary)),
            content: Text(
              'Remove ${cls['subjectName']} (${cls['startTime']}) from $day?',
              style: AppTypography.bodyMedium(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: Color(0xFFBA1A1A))),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warmCream,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0EBE3)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cls['subjectName'] as String? ?? '',
                    style: AppTypography.bodyMedium(color: AppColors.textPrimary)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${cls['startTime']} – ${cls['endTime']}${(cls['room'] as String?)?.isNotEmpty == true ? '  ·  ${cls['room']}' : ''}',
                    style: AppTypography.bodySmall(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                cls['subjectCode'] as String? ?? '',
                style: AppTypography.labelSmall(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
