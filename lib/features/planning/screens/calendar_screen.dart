import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuroot/core/models/task_model.dart';
import 'package:neuroot/core/models/timetable_entry_model.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/dashboard/providers/dashboard_provider.dart';
import 'package:neuroot/features/planning/providers/task_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksStreamProvider).asData?.value ?? [];
    final classes = ref.watch(timetableStreamProvider).asData?.value ?? [];

    // Helper to get events for a day
    List<dynamic> _getEventsForDay(DateTime day) {
      final dayTasks = tasks.where((t) {
        return t.dueDate.year == day.year &&
            t.dueDate.month == day.month &&
            t.dueDate.day == day.day;
      }).toList();

      final dayClasses = classes.where((c) {
        // day.weekday: 1=Mon..7=Sun
        return (day.weekday - 1) == c.dayOfWeek;
      }).toList();

      return [...dayTasks, ...dayClasses];
    }

    final selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay);
    
    // Progress calculation for the selected day
    int total = selectedEvents.length;
    int completed = selectedEvents.where((e) => (e is TaskModel && e.isCompleted)).length;
    double progress = total > 0 ? completed / total : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F1), // Cream background matching image
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D5400)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Planner',
          style: AppTypography.titleMedium(color: const Color(0xFF6D5400)).copyWith(fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _focusedDay = DateTime.now();
                    _selectedDay = _focusedDay;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.amber),
                  ),
                  child: Text(
                    'Today',
                    style: AppTypography.labelMedium(color: const Color(0xFF6D5400)),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Month Navigator / Calendar Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Color(0xFF6D5400)),
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                      });
                    },
                  ),
                  Text(
                    DateFormat.yMMMM().format(_focusedDay),
                    style: AppTypography.titleMedium(color: const Color(0xFF6D5400)).copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Color(0xFF6D5400)),
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFFF4C542), 'EXAM'),
                const SizedBox(width: 12),
                _buildLegendItem(const Color(0xFFF29C38), 'ASSIGNMENT'),
                const SizedBox(width: 12),
                _buildLegendItem(const Color(0xFF52B788), 'LAB'),
                const SizedBox(width: 12),
                _buildLegendItem(const Color(0xFFCDB4DB), 'CLASS/OTHER'),
              ],
            ),
          ),

          // Calendar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              headerVisible: false, // We use custom header above
              calendarFormat: CalendarFormat.month,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: AppTypography.labelMedium(color: const Color(0xFFB0A898)),
                weekendStyle: AppTypography.labelMedium(color: const Color(0xFFB0A898)),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: AppTypography.bodyMedium(color: const Color(0xFF1B1C1C)),
                weekendTextStyle: AppTypography.bodyMedium(color: const Color(0xFF1B1C1C)),
                outsideTextStyle: AppTypography.bodyMedium(color: const Color(0xFFE8E0D4)),
                todayDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                todayTextStyle: AppTypography.bodyMedium(color: const Color(0xFF1B1C1C)),
                selectedDecoration: BoxDecoration(
                  color: AppColors.amber, // Dark gold
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6D5400), width: 2), // Ring around it
                ),
                selectedTextStyle: AppTypography.titleMedium(color: const Color(0xFF6D5400)),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final dayEvents = _getEventsForDay(date);
                  if (dayEvents.isEmpty) return const SizedBox();

                  return Positioned(
                    bottom: 6,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: dayEvents.take(3).map((e) {
                        Color dotColor = const Color(0xFFCDB4DB); // Class/Other default
                        if (e is TaskModel) {
                          if (e.type == TaskType.exam) dotColor = const Color(0xFFF4C542);
                          if (e.type == TaskType.assignment) dotColor = const Color(0xFFF29C38);
                          if (e.type == TaskType.lab) dotColor = const Color(0xFF52B788);
                        }
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotColor,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Bottom Sheet Content for Selected Day
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E0D4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  // Summary Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, MMM d').format(_selectedDay ?? _focusedDay),
                              style: AppTypography.titleMedium(color: const Color(0xFF1B1C1C)).copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$completed / $total complete',
                              style: AppTypography.bodyMedium(color: const Color(0xFF7F7662)),
                            ),
                          ],
                        ),
                        // Circular Progress
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 3,
                                color: const Color(0xFFE8E0D4),
                              ),
                              CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 3,
                                color: const Color(0xFF52B788), // Green progress
                                backgroundColor: Colors.transparent,
                                strokeCap: StrokeCap.round,
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: AppTypography.labelSmall(color: const Color(0xFF52B788)).copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(color: Color(0xFFF0EBE3), thickness: 1, height: 24),
                  
                  // Events List
                  Expanded(
                    child: selectedEvents.isEmpty
                        ? Center(
                            child: Text(
                              'No plans for this day! 🍃',
                              style: AppTypography.bodyMedium(color: const Color(0xFFB0A898)),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            itemCount: selectedEvents.length,
                            itemBuilder: (context, index) {
                              final event = selectedEvents[index];
                              if (event is TaskModel) {
                                return _buildTaskCard(event);
                              } else if (event is TimetableEntry) {
                                return _buildClassCard(event);
                              }
                              return const SizedBox();
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.labelSmall(color: const Color(0xFF7F7662)).copyWith(fontSize: 10, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final isExam = task.type == TaskType.exam;
    final isAssignment = task.type == TaskType.assignment;
    
    // Exam styling is a bit special (Yellow card)
    if (isExam) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF9E8B2)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF4C542).withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFF4C542),
                borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.info_outline, color: Color(0xFFF4C542)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: AppTypography.titleSmall(color: const Color(0xFF1B1C1C)).copyWith(fontSize: 15),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF4C542).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Exam',
                style: AppTypography.labelSmall(color: const Color(0xFFD49800)),
              ),
            )
          ],
        ),
      );
    }
    
    Color dotColor = const Color(0xFF52B788); // lab
    if (isAssignment) dotColor = const Color(0xFFF29C38);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: task.isCompleted ? const Color(0xFFF8F9FA) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: task.isCompleted ? const Color(0xFFF0EBE3) : const Color(0xFFF0EBE3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: task.isCompleted ? const Color(0xFF52B788) : const Color(0xFFD1C5AE),
                width: 2,
              ),
            ),
            child: task.isCompleted
                ? const Icon(Icons.check, size: 16, color: Color(0xFF52B788))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTypography.titleSmall(
                    color: task.isCompleted ? const Color(0xFFB0A898) : const Color(0xFF1B1C1C),
                  ).copyWith(
                    fontSize: 15,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      task.type.name.toUpperCase(),
                      style: AppTypography.labelSmall(color: const Color(0xFF7F7662)).copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildClassCard(TimetableEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF), // light purple tint
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF4F0FB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF5E4B8B), // Deep purple
                width: 2,
              ),
            ),
            child: const Icon(Icons.check, size: 16, color: Color(0xFF5E4B8B)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.subjectName.isNotEmpty ? '${entry.subjectName} Class' : '${entry.subjectCode} Class',
                  style: AppTypography.titleSmall(
                    color: const Color(0xFF4C3D70),
                  ).copyWith(fontSize: 15),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Color(0xFFCDB4DB), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'CLASS',
                      style: AppTypography.labelSmall(color: const Color(0xFF7F7662)).copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE6F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, size: 12, color: Color(0xFF5E4B8B)),
                const SizedBox(width: 4),
                Text(
                  entry.startTime,
                  style: AppTypography.labelSmall(color: const Color(0xFF5E4B8B)).copyWith(fontSize: 10),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
