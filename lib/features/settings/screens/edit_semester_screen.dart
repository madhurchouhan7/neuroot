import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/settings/providers/settings_provider.dart';
import 'package:intl/intl.dart';

class EditSemesterScreen extends ConsumerStatefulWidget {
  const EditSemesterScreen({super.key});

  @override
  ConsumerState<EditSemesterScreen> createState() => _EditSemesterScreenState();
}

class _EditSemesterScreenState extends ConsumerState<EditSemesterScreen> {
  late TextEditingController _nameCtrl;
  bool _hasChanges = false;
  int _threshold = 75;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _examPeriodStart;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _nameCtrl = TextEditingController(text: s.semesterName);
    _threshold = s.attendanceThreshold;
    _startDate = s.semesterStart;
    _endDate = s.semesterEnd;
    _examPeriodStart = s.examPeriodStart;
    _nameCtrl.addListener(() => setState(() => _hasChanges = true));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_hasChanges) return;
    
    await ref.read(settingsProvider.notifier).updateSemester(
      name: _nameCtrl.text.trim(),
      attendanceThreshold: _threshold,
      startDate: _startDate,
      endDate: _endDate,
      examPeriodStart: _examPeriodStart,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Semester saved ✓ Sprout updated your schedule.', style: AppTypography.bodyMedium(color: AppColors.white)),
          backgroundColor: AppColors.sageDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      context.pop();
    }
  }

  void _onThreshold(int t) {
    setState(() {
      _threshold = t;
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => context.pop(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF8B8070), size: 14),
                const SizedBox(width: 4),
                Text('Settings', style: AppTypography.bodyMedium(color: const Color(0xFF8B8070)).copyWith(fontWeight: FontWeight.w500, fontSize: 13)),
              ],
            ),
          ),
        ),
        title: Text('Edit Semester', style: AppTypography.titleSmall(color: AppColors.textPrimary)),
        actions: [
          GestureDetector(
            onTap: _save,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                'Save',
                style: AppTypography.bodyMedium(
                  color: _hasChanges ? AppColors.amber : const Color(0xFFC8C0B8),
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Banner
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFC4900A), size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Changes apply to your current semester. Past attendance data is preserved.',
                        style: AppTypography.bodySmall(color: const Color(0xFFC4900A)).copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Form Fields
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF0E8DC)),
                ),
                child: Column(
                  children: [
                    _buildField(
                      label: 'SEMESTER NAME',
                      child: TextField(
                        controller: _nameCtrl,
                        style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                      ),
                      trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF82), size: 16),
                    ),
                    const _Div(),
                    _buildField(
                      label: 'DATE RANGE',
                      child: GestureDetector(
                        onTap: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                            initialDateRange: _startDate != null && _endDate != null
                                ? DateTimeRange(start: _startDate!, end: _endDate!)
                                : null,
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(primary: AppColors.sageDark),
                              ),
                              child: child!,
                            ),
                          );
                          if (range != null) {
                            setState(() {
                              _startDate = range.start;
                              _endDate = range.end;
                              _hasChanges = true;
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Expanded(child: Text(_startDate != null ? DateFormat('MMM dd, yyyy').format(_startDate!) : 'Select start', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w500))),
                            const Icon(Icons.edit_calendar_rounded, color: Color(0xFFC8C0B8), size: 16),
                            const SizedBox(width: 16),
                            Expanded(child: Text(_endDate != null ? DateFormat('MMM dd, yyyy').format(_endDate!) : 'Select end', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w500))),
                            const Icon(Icons.edit_calendar_rounded, color: Color(0xFFC8C0B8), size: 16),
                          ],
                        ),
                      ),
                    ),
                    const _Div(),
                    _buildField(
                      label: 'EXAM PERIOD START',
                      child: GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _examPeriodStart ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(primary: AppColors.amber),
                              ),
                              child: child!,
                            ),
                          );
                          if (date != null) {
                            setState(() {
                              _examPeriodStart = date;
                              _hasChanges = true;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFFFFF8E8), borderRadius: BorderRadius.circular(10)),
                          child: Text(_examPeriodStart != null ? DateFormat('MMM dd, yyyy').format(_examPeriodStart!) : 'Set exam date', style: AppTypography.bodyMedium(color: const Color(0xFFC4900A)).copyWith(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const _Div(),
                    _buildField(
                      label: 'ATTENDANCE THRESHOLD',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [70, 75, 80, 85].map((t) {
                              final sel = _threshold == t;
                              return GestureDetector(
                                onTap: () => _onThreshold(t),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: sel ? AppColors.amber : const Color(0xFFF8F5F0),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text('$t%', style: AppTypography.labelMedium(color: sel ? AppColors.textPrimary : const Color(0xFF8B8070))),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                          Text('✦ Most Indian colleges require 75%', style: AppTypography.bodySmall(color: const Color(0xFFA8CFA8)).copyWith(fontWeight: FontWeight.w600, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subjects Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF0E8DC)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Your Subjects', style: AppTypography.titleSmall(color: AppColors.textPrimary).copyWith(fontSize: 15)),
                        Text('Manage →', style: AppTypography.bodyMedium(color: AppColors.amber).copyWith(fontWeight: FontWeight.w600, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: [
                        ...s.subjects.map((sub) => _SubjectEditChip(
                              sub: sub,
                              onDelete: () {
                                ref.read(settingsProvider.notifier).removeSubject(sub['id']);
                              },
                            )),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const _AddSubjectSheet(),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFD1C5AE), style: BorderStyle.solid), // Should be dashed ideally
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('+ Add Subject', style: AppTypography.labelMedium(color: const Color(0xFF8B8070))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // New Semester CTA
              GestureDetector(
                onTap: () {
                  // TODO: implement archive flow
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD1C5AE), style: BorderStyle.solid), // dashed
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start a new semester', style: AppTypography.bodyMedium(color: const Color(0xFF8B8070)).copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('Sem 5 → Archive current semester and start fresh', style: AppTypography.bodySmall(color: const Color(0xFFB0A898))),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: Color(0xFF8B8070), size: 18),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.amber,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _hasChanges ? _save : () => context.pop(),
                  child: Text('Save Changes', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({required String label, required Widget child, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall(color: const Color(0xFFB0A898)).copyWith(letterSpacing: 1.2, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: child),
              ?trailing,
            ],
          ),
        ],
      ),
    );
  }
}

class _Div extends StatelessWidget {
  const _Div();
  @override
  Widget build(BuildContext context) => const Divider(height: 1, color: Color(0xFFF5EFE8));
}

class _SubjectEditChip extends StatelessWidget {
  final Map<String, dynamic> sub;
  final VoidCallback onDelete;
  const _SubjectEditChip({required this.sub, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.sage;
    try {
      final hex = (sub['color'] as String?)?.replaceAll('#', '') ?? 'A8D5BA';
      color = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.only(left: 6, right: 10, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.drag_indicator_rounded, size: 14, color: color.withValues(alpha: 0.7)),
          const SizedBox(width: 4),
          Text(
            sub['code'] as String? ?? '',
            style: AppTypography.labelMedium(color: color.withValues(alpha: 0.85))
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close_rounded, size: 14, color: color.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

class _AddSubjectSheet extends ConsumerStatefulWidget {
  const _AddSubjectSheet();

  @override
  ConsumerState<_AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends ConsumerState<_AddSubjectSheet> {
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  String _selectedColor = '#A8D5BA';

  final _colors = [
    '#A8D5BA', '#FF8A65', '#645495', '#D49800', 
    '#E05C5C', '#7CB9E8', '#95D5B2', '#CDB4DB',
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
        left: 20, right: 20, top: 24,
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
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE0D8D0), borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Add Subject 📚', style: AppTypography.titleMedium(color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          _buildField('Subject Name', 'e.g. Data Structures', _nameCtrl),
          const SizedBox(height: 12),
          _buildField('Subject Code', 'e.g. CS301', _codeCtrl),
          const SizedBox(height: 16),
          Text(
            'COLOR',
            style: AppTypography.labelSmall(color: const Color(0xFF8B8070)).copyWith(letterSpacing: 0.8, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: _colors.map((c) {
              final isSelected = c == _selectedColor;
              final color = Color(int.parse('FF${c.replaceAll('#', '')}', radix: 16));
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: AppColors.textPrimary, width: 2) : null,
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                if (_nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(context);
                await ref.read(settingsProvider.notifier).addSubject(
                  name: _nameCtrl.text.trim(),
                  code: _codeCtrl.text.trim(),
                  color: _selectedColor,
                );
              },
              child: Text('Add Subject', style: AppTypography.buttonMedium(color: AppColors.textPrimary)),
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
          style: AppTypography.labelSmall(color: const Color(0xFF8B8070)).copyWith(letterSpacing: 0.8, fontSize: 11),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium(color: const Color(0xFFB0A898)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E0D4))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E0D4))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryContainer)),
          ),
          style: AppTypography.bodyMedium(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
