import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/onboarding/providers/onboarding_provider.dart';
import 'package:neuroot/shared/widgets/neuroot_widgets.dart';

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const double _gridHourHeight = 60.0; // 60 pixels per hour
const double _gridStartHour = 8.0;   // starts at 8 AM
const double _gridEndHour = 20.0;    // ends at 8 PM (12 hours total)

class TimetableBuilderStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const TimetableBuilderStep({super.key, required this.onNext});

  @override
  ConsumerState<TimetableBuilderStep> createState() =>
      _TimetableBuilderStepState();
}

class _TimetableBuilderStepState extends ConsumerState<TimetableBuilderStep> {
  int _selectedDayIndex = 0;
  bool _isGridView = true; // Default to the interactive timeline grid view
  double? _draggedOverHour; // For showing visual snap preview during drag

  Color _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.amber;
    }
  }

  double _parseTimeToDouble(String t) {
    try {
      final clean = t.trim().toUpperCase();
      if (clean.contains('AM') || clean.contains('PM')) {
        final parts = clean.split(' ');
        final timeParts = parts[0].split(':');
        double h = double.parse(timeParts[0]);
        final m = double.parse(timeParts[1]);
        final isPm = parts[1] == 'PM';
        if (isPm && h != 12) h += 12;
        if (!isPm && h == 12) h = 0;
        return h + (m / 60.0);
      } else {
        // 24h format e.g. "09:30"
        final parts = clean.split(':');
        final h = double.parse(parts[0]);
        final m = double.parse(parts[1]);
        return h + (m / 60.0);
      }
    } catch (_) {
      return 9.0;
    }
  }

  String _formatDoubleToTime(double h) {
    final hourInt = h.toInt();
    final minInt = ((h - hourInt) * 60).round();
    
    final period = hourInt >= 12 ? 'PM' : 'AM';
    var displayHour = hourInt % 12;
    if (displayHour == 0) displayHour = 12;
    
    final minStr = minInt.toString().padLeft(2, '0');
    return '$displayHour:$minStr $period';
  }

  // ── Add/Edit Class bottom sheet ───────────────────────────────────────────────

  void _showAddClass({double? prefilledStartHour}) {
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

    if (prefilledStartHour != null) {
      final hourInt = prefilledStartHour.toInt();
      final minInt = ((prefilledStartHour - hourInt) * 60).round();
      startTime = TimeOfDay(hour: hourInt, minute: minInt);
      
      final endHourVal = prefilledStartHour + 1.0; // 1 hour default duration
      final endHourInt = endHourVal.toInt();
      final endMinInt = ((endHourVal - endHourInt) * 60).round();
      endTime = TimeOfDay(hour: endHourInt % 24, minute: endMinInt);
    }

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
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1C5AE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add class for ${_days[_selectedDayIndex]}',
                    style: AppTypography.titleMedium(color: AppColors.textPrimary)
                        .copyWith(fontWeight: FontWeight.bold),
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
                                  width: 12,
                                  height: 12,
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
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
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
              Text('Add your weekly classes. Try the interactive Timeline Builder!',
                  style:
                      AppTypography.bodyMedium(color: const Color(0xFF7F7662))),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // Toggle: List View vs Timeline Builder Segment
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EBE3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isGridView = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isGridView ? AppColors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: !_isGridView ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ] : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.list_rounded, size: 16, color: Color(0xFF7F7662)),
                          const SizedBox(width: 6),
                          Text(
                            'List View',
                            style: AppTypography.labelMedium(
                              color: !_isGridView ? AppColors.textPrimary : const Color(0xFF7F7662),
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isGridView = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isGridView ? AppColors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _isGridView ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ] : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_view_day_rounded, size: 16, color: Color(0xFF7F7662)),
                          const SizedBox(width: 6),
                          Text(
                            'Timeline Builder 🌱',
                            style: AppTypography.labelMedium(
                              color: _isGridView ? AppColors.textPrimary : const Color(0xFF7F7662),
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

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
        const SizedBox(height: 16),

        // Content Area
        Expanded(
          child: _isGridView 
            ? _buildTimelineGrid(selectedDay, classes)
            : _buildListView(selectedDay, classes),
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

  // ── 1. List View ─────────────────────────────────────────────────────────────

  Widget _buildListView(String selectedDay, List<Map<String, dynamic>> classes) {
    return ListView(
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
          onTap: () => _showAddClass(),
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
    );
  }

  // ── 2. Timeline Grid View ───────────────────────────────────────────────────

  Widget _buildTimelineGrid(String selectedDay, List<Map<String, dynamic>> classes) {
    final double totalHours = _gridEndHour - _gridStartHour;
    final double gridHeight = totalHours * _gridHourHeight;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time axis column
          Container(
            width: 54,
            height: gridHeight,
            padding: const EdgeInsets.only(top: 8),
            child: Stack(
              children: List.generate(totalHours.toInt() + 1, (i) {
                final double hr = _gridStartHour + i;
                final double top = i * _gridHourHeight;
                
                String timeLabel = "";
                if (hr == 12) timeLabel = "12 PM";
                else if (hr > 12) timeLabel = "${(hr - 12).toInt()} PM";
                else timeLabel = "${hr.toInt()} AM";

                return Positioned(
                  top: top,
                  left: 0,
                  child: Text(
                    timeLabel,
                    style: AppTypography.labelSmall(color: const Color(0xFF8B8070))
                        .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                );
              }),
            ),
          ),

          // Main timeline canvas with DragTarget
          Expanded(
            child: DragTarget<Map<String, dynamic>>(
              onWillAcceptWithDetails: (details) {
                // Return true to allow dropping
                return true;
              },
              onMove: (details) {
                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                final localOffset = renderBox.globalToLocal(details.offset);
                
                // Estimate drop hour based on vertical offset relative to grid top
                // Add scrolling offset into account if needed, but since it's local it is offset to this widget
                double relativeY = localOffset.dy - 120; // approximate top padding
                if (relativeY < 0) relativeY = 0;
                
                double calculatedHour = _gridStartHour + (relativeY / _gridHourHeight);
                // Snap to nearest 15 minutes
                calculatedHour = (calculatedHour * 4).round() / 4.0;
                
                if (calculatedHour >= _gridStartHour && calculatedHour < _gridEndHour) {
                  setState(() {
                    _draggedOverHour = calculatedHour;
                  });
                }
              },
              onLeave: (_) {
                setState(() {
                  _draggedOverHour = null;
                });
              },
              onAcceptWithDetails: (details) {
                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                final localOffset = renderBox.globalToLocal(details.offset);
                
                double relativeY = localOffset.dy - 120;
                if (relativeY < 0) relativeY = 0;
                
                double calculatedHour = _gridStartHour + (relativeY / _gridHourHeight);
                calculatedHour = (calculatedHour * 4).round() / 4.0;
                
                if (calculatedHour < _gridStartHour) calculatedHour = _gridStartHour;
                if (calculatedHour > _gridEndHour - 0.5) calculatedHour = _gridEndHour - 0.5;

                final data = details.data;
                final int index = data['index'] as int;
                final cls = data['class'] as Map<String, dynamic>;
                
                final double originalDuration = 
                    _parseTimeToDouble(cls['endTime'] as String? ?? '') - 
                    _parseTimeToDouble(cls['startTime'] as String? ?? '');

                final double newStart = calculatedHour;
                final double newEnd = calculatedHour + (originalDuration > 0 ? originalDuration : 1.0);

                ref.read(onboardingProvider.notifier).updateTimetableClassTime(
                  selectedDay,
                  index,
                  _formatDoubleToTime(newStart),
                  _formatDoubleToTime(newEnd),
                );

                setState(() {
                  _draggedOverHour = null;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rescheduled to ${_formatDoubleToTime(newStart)} 🌱',
                        style: AppTypography.bodyMedium(color: AppColors.white)),
                    backgroundColor: AppColors.sageDark,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
              builder: (ctx, candidateData, rejectedData) {
                return GestureDetector(
                  onTapUp: (details) {
                    final double relativeY = details.localPosition.dy;
                    double tappedHour = _gridStartHour + (relativeY / _gridHourHeight);
                    // Snap to nearest 30 mins
                    tappedHour = (tappedHour * 2).round() / 2.0;
                    _showAddClass(prefilledStartHour: tappedHour);
                  },
                  child: Container(
                    height: gridHeight,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF0EBE3)),
                    ),
                    child: Stack(
                      children: [
                        // 1. Grid lines (dotted/dashed horizontal dividers)
                        ...List.generate(totalHours.toInt() + 1, (i) {
                          final double top = i * _gridHourHeight;
                          return Positioned(
                            top: top,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: const Color(0xFFECEAE5),
                                    style: i == 0 ? BorderStyle.solid : BorderStyle.solid,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        // 2. Tapped prompt background overlay guide
                        Positioned.fill(
                          child: Center(
                            child: Opacity(
                              opacity: classes.isEmpty ? 0.6 : 0.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('🌱', style: TextStyle(fontSize: 32)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap any slot to add class',
                                    style: AppTypography.bodySmall(color: const Color(0xFF7F7662)),
                                  ),
                                  Text(
                                    'Drag cards to reschedule',
                                    style: AppTypography.bodySmall(color: const Color(0xFF7F7662)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 3. Visual preview of snaps during drag
                        if (_draggedOverHour != null)
                          Positioned(
                            top: (_draggedOverHour! - _gridStartHour) * _gridHourHeight,
                            left: 4,
                            right: 4,
                            height: _gridHourHeight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.amber.withValues(alpha: 0.15),
                                border: Border.all(color: AppColors.amber, width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Move here (${_formatDoubleToTime(_draggedOverHour!)})',
                                style: AppTypography.labelSmall(color: AppColors.textPrimary)
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                        // 4. Render absolutely positioned Class Cards!
                        ...classes.asMap().entries.map((e) {
                          final int idx = e.key;
                          final cls = e.value;
                          
                          final double start = _parseTimeToDouble(cls['startTime'] as String? ?? '9:00 AM');
                          final double end = _parseTimeToDouble(cls['endTime'] as String? ?? '10:30 AM');
                          
                          // Convert hours to positions
                          double top = (start - _gridStartHour) * _gridHourHeight;
                          double height = (end - start) * _gridHourHeight;
                          
                          // Constraints to avoid rendering outside the canvas
                          if (top < 0) {
                            height += top;
                            top = 0;
                          }
                          if (height < 30) height = 30; // Min height for readability
                          if (top + height > gridHeight) {
                            height = gridHeight - top;
                          }

                          final color = _hexColor(cls['subjectColor'] as String? ?? '#A8D5BA');
                          final code = cls['subjectCode'] as String? ?? '';
                          final name = cls['subjectName'] as String? ?? '';
                          final room = cls['room'] as String? ?? '';
                          
                          return Positioned(
                            top: top + 2,
                            left: 4,
                            right: 4,
                            height: height - 4,
                            child: LongPressDraggable<Map<String, dynamic>>(
                              data: {'index': idx, 'class': cls},
                              feedback: Material(
                                color: Colors.transparent,
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 100,
                                  height: height - 4,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        code,
                                        style: AppTypography.labelLarge(color: AppColors.white)
                                            .copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Dragging to reschedule...',
                                        style: AppTypography.labelSmall(color: AppColors.white.withValues(alpha: 0.8)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: color, width: 1.5, style: BorderStyle.solid),
                                  ),
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 5,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    name.isNotEmpty ? name : code,
                                                    style: AppTypography.labelMedium(color: AppColors.textPrimary)
                                                        .copyWith(fontWeight: FontWeight.bold),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    ref
                                                        .read(onboardingProvider.notifier)
                                                        .removeTimetableClass(selectedDay, idx);
                                                  },
                                                  child: Icon(
                                                    Icons.close_rounded,
                                                    size: 14,
                                                    color: AppColors.textPrimary.withValues(alpha: 0.4),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(Icons.schedule, size: 10, color: Color(0xFF7F7662)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${cls['startTime']} – ${cls['endTime']}',
                                                  style: AppTypography.labelSmall(color: const Color(0xFF7F7662))
                                                      .copyWith(fontSize: 10),
                                                ),
                                                if (room.isNotEmpty) ...[
                                                  const SizedBox(width: 8),
                                                  const Icon(Icons.location_on_outlined, size: 10, color: Color(0xFF7F7662)),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    room,
                                                    style: AppTypography.labelSmall(color: const Color(0xFF7F7662))
                                                        .copyWith(fontSize: 10),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
