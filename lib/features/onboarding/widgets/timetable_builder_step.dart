import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/onboarding/providers/onboarding_provider.dart';
import 'package:neuroot/shared/widgets/neuroot_widgets.dart';

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

class TimetableBuilderStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const TimetableBuilderStep({super.key, required this.onNext});

  @override
  ConsumerState<TimetableBuilderStep> createState() =>
      _TimetableBuilderStepState();
}

class _TimetableBuilderStepState extends ConsumerState<TimetableBuilderStep> {
  int _selectedDayIndex = 0;

  Color _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.amber;
    }
  }

  // ── Add Class bottom sheet ───────────────────────────────────────────────────

  void _showAddClass() {
    final subjects = ref.read(onboardingProvider).subjects;
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Add at least one subject first 🌱',
              style: AppTypography.bodyMedium(color: AppColors.white)),
          backgroundColor: AppColors.sageDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    String selectedSubjectCode = subjects.first['code'] ?? '';
    final roomCtrl = TextEditingController();
    final profCtrl = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 30);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) {
          String _fmtTime(TimeOfDay t) {
            final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
            final m = t.minute.toString().padLeft(2, '0');
            return '$h:$m ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
          }

          return Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
                    'Add class for ${_days[_selectedDayIndex]}',
                    style: AppTypography.titleMedium(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),

                  // Subject picker
                  Text('Subject',
                      style: AppTypography.labelLarge(color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF0EBE3), width: 1.5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSubjectCode,
                        isExpanded: true,
                        items: subjects.map((sub) {
                          final c = _hexColor(sub['color'] ?? '#A8D5BA');
                          return DropdownMenuItem(
                            value: sub['code'],
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      color: c, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                Text('${sub['code']} – ${sub['name']}',
                                    style: AppTypography.bodyMedium(
                                        color: AppColors.textPrimary)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setModal(() => selectedSubjectCode = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Time row
                  Row(
                    children: [
                      Expanded(
                        child: _timeField(ctx, 'Start', _fmtTime(startTime), () async {
                          final t = await showTimePicker(
                              context: ctx, initialTime: startTime);
                          if (t != null) setModal(() => startTime = t);
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _timeField(ctx, 'End', _fmtTime(endTime), () async {
                          final t = await showTimePicker(
                              context: ctx, initialTime: endTime);
                          if (t != null) setModal(() => endTime = t);
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Room
                  _sheetTextField(roomCtrl, 'Room (e.g. Room 204)'),
                  const SizedBox(height: 12),

                  // Professor
                  _sheetTextField(profCtrl, 'Professor (optional)'),
                  const SizedBox(height: 20),

                  // Add button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        final sub = subjects.firstWhere(
                          (s) => s['code'] == selectedSubjectCode,
                          orElse: () => subjects.first,
                        );
                        String _fmtTime2(TimeOfDay t) {
                          final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
                          final m = t.minute.toString().padLeft(2, '0');
                          return '$h:$m ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
                        }

                        ref.read(onboardingProvider.notifier).addTimetableClass(
                          _days[_selectedDayIndex],
                          {
                            'subjectName': sub['name'] ?? '',
                            'subjectCode': sub['code'] ?? '',
                            'subjectColor': sub['color'] ?? '#A8D5BA',
                            'startTime': _fmtTime2(startTime),
                            'endTime': _fmtTime2(endTime),
                            'room': roomCtrl.text.trim(),
                            'professor': profCtrl.text.trim(),
                          },
                        );
                        Navigator.pop(ctx);
                      },
                      child: Text('Add Class',
                          style: AppTypography.buttonMedium(
                              color: AppColors.textPrimary)),
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

  Widget _timeField(
      BuildContext ctx, String label, String value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelSmall(color: const Color(0xFF7F7662))),
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
                const Icon(Icons.schedule,
                    size: 16, color: AppColors.sageDark),
                const SizedBox(width: 6),
                Text(value,
                    style: AppTypography.bodyMedium(
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sheetTextField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            AppTypography.bodyMedium(color: const Color(0xFFB0A898)),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final timetable = ref.watch(onboardingProvider).timetable;
    final selectedDay = _days[_selectedDayIndex];
    final classes = timetable[selectedDay] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Step badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'STEP 3 OF 4',
                  style: AppTypography.labelSmall(color: AppColors.amber)
                      .copyWith(fontWeight: FontWeight.w700, letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 12),
              Text('Build your timetable',
                  style: AppTypography.titleXL(color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text('Add your weekly classes. Color-code by subject.',
                  style:
                      AppTypography.bodyMedium(color: const Color(0xFF7F7662))),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // Day tab bar
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _days.length,
            itemBuilder: (_, i) {
              final isSelected = i == _selectedDayIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.amber : AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.amber
                          : const Color(0xFFF0EBE3),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _days[i],
                    style: AppTypography.labelLarge(
                      color: isSelected
                          ? AppColors.textPrimary
                          : const Color(0xFF7F7662),
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Class list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              ...classes.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ClassCard(
                      entry: e.value,
                      onDelete: () => ref
                          .read(onboardingProvider.notifier)
                          .removeTimetableClass(selectedDay, e.key),
                      hexColor: _hexColor,
                    ),
                  )),

              // Add class button
              GestureDetector(
                onTap: _showAddClass,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.warmCream,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: const Color(0xFFD1C5AE), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add,
                          size: 18, color: Color(0xFF7F7662)),
                      const SizedBox(width: 6),
                      Text('Add class for $selectedDay',
                          style: AppTypography.labelLarge(
                              color: const Color(0xFF7F7662))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom CTA
        Padding(
          padding: const EdgeInsets.all(24),
          child: NeurootButton(
            label: 'Continue  → Almost Done!',
            backgroundColor: AppColors.amber,
            textColor: AppColors.textPrimary,
            onTap: widget.onNext,
          ),
        ),
      ],
    );
  }
}

// ─── Class Card ───────────────────────────────────────────────────────────────

class _ClassCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onDelete;
  final Color Function(String) hexColor;

  const _ClassCard({
    required this.entry,
    required this.onDelete,
    required this.hexColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = hexColor(entry['subjectColor'] as String? ?? '#A8D5BA');
    final bgColor = color.withValues(alpha: 0.15);
    final code = entry['subjectCode'] as String? ?? '';
    final name = entry['subjectName'] as String? ?? '';
    final start = entry['startTime'] as String? ?? '';
    final end = entry['endTime'] as String? ?? '';
    final room = entry['room'] as String? ?? '';
    final prof = entry['professor'] as String? ?? '';

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFDAD6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A)),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF0EBE3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name.isNotEmpty ? name : code,
                                  style: AppTypography.labelLarge(
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.schedule,
                                      size: 13, color: Color(0xFF7F7662)),
                                  const SizedBox(width: 4),
                                  Text('$start – $end',
                                      style: AppTypography.labelSmall(
                                          color: const Color(0xFF7F7662))),
                                ],
                              ),
                              if (room.isNotEmpty || prof.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    if (room.isNotEmpty) ...[
                                      const Icon(Icons.location_on_outlined,
                                          size: 13, color: Color(0xFF7F7662)),
                                      const SizedBox(width: 4),
                                      Text(room,
                                          style: AppTypography.labelSmall(
                                              color: const Color(0xFF7F7662))),
                                    ],
                                    if (room.isNotEmpty && prof.isNotEmpty)
                                      const SizedBox(width: 12),
                                    if (prof.isNotEmpty) ...[
                                      const Icon(Icons.person_outline,
                                          size: 13, color: Color(0xFF7F7662)),
                                      const SizedBox(width: 4),
                                      Text(prof,
                                          style: AppTypography.labelSmall(
                                              color: const Color(0xFF7F7662))),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(code,
                              style: AppTypography.labelSmall(color: color)
                                  .copyWith(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
