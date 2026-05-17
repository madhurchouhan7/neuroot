import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

import 'package:neuroot/shared/widgets/bounce_button.dart';
import 'package:neuroot/shared/widgets/ambient_motion.dart';
class TaskCard extends StatefulWidget {
  final String title;
  final String subject;
  final Color subjectColor;
  final Color subjectBgColor;
  final String subtitle;
  final bool initiallyExpanded;
  final List<String>? subtasks;
  final bool isRecurring;

  const TaskCard({
    super.key,
    required this.title,
    required this.subject,
    required this.subjectColor,
    required this.subjectBgColor,
    required this.subtitle,
    this.initiallyExpanded = false,
    this.subtasks,
    this.isRecurring = false,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return BreathingWidget(
      child: BounceButton(
        onTap: widget.subtasks != null ? () => setState(() => _expanded = !_expanded) : null,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEDE6F5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFEDE6F5), width: 2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                style: AppTypography.bodyMedium(color: const Color(0xFF1B1C1C))
                                    .copyWith(fontWeight: FontWeight.w500, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.subjectBgColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                widget.subject,
                                style: AppTypography.labelSmall(color: widget.subjectColor).copyWith(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (widget.isRecurring) ...[
                              const Icon(Icons.autorenew, size: 12, color: Color(0xFFB0A898)),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                widget.subtitle,
                                style: AppTypography.bodySmall(color: const Color(0xFFB0A898))
                                    .copyWith(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.subtasks != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: const Color(0xFFB0A898),
                    ),
                  ],
                ],
              ),
              if (_expanded && widget.subtasks != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Color(0xFFF0E8FF), height: 1),
                ),
                Column(
                  children: widget.subtasks!.asMap().entries.map((entry) {
                    final isDone = entry.key < 2; // Mocking first 2 as done
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                            size: 16,
                            color: isDone ? AppColors.sageDark : const Color(0xFFEDE6F5),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: AppTypography.bodySmall(
                                color: isDone ? const Color(0xFFB0A898) : const Color(0xFF1B1C1C),
                              ).copyWith(
                                fontSize: 13,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '2/${widget.subtasks!.length} subtasks',
                      style: AppTypography.bodySmall(color: const Color(0xFFB0A898)).copyWith(fontSize: 11),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE6F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 2 / widget.subtasks!.length,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B4BE8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
