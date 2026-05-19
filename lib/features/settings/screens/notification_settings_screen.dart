import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/settings/providers/settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final masterOn = s.notificationsEnabled;

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
        title: Text('Notification Settings', style: AppTypography.titleSmall(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Intro Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF0E8DC)),
                ),
                child: Row(
                  children: [
                    const Text('🌱', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bloom never spams.', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('Every notification is intentional and supportive — never guilt-tripping.', style: AppTypography.bodySmall(color: const Color(0xFF8B8070)).copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Master Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF0E8DC)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('All notifications', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text('Master switch for everything below', style: AppTypography.bodySmall(color: const Color(0xFF8B8070)).copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: masterOn,
                      onChanged: (v) => ref.read(settingsProvider.notifier).setNotifications(v),
                      activeThumbColor: AppColors.amber,
                      activeTrackColor: AppColors.amber.withValues(alpha: 0.25),
                    ),
                  ],
                ),
              ),

              if (masterOn) ...[
                const SizedBox(height: 24),
                
                // Group 1
                _SectionLabel('ATTENDANCE'),
                _ToggleGroup([
                  _ToggleData('Attendance danger alert', 'When you drop below threshold', true),
                  _ToggleData('Before-class reminder', '15 min before class starts', true),
                  _ToggleData('Weekly attendance summary', 'Every Sunday evening', false),
                ]),

                const SizedBox(height: 24),

                // Group 2
                _SectionLabel('TASKS & EXAMS'),
                _ToggleGroup([
                  _ToggleData('Due today reminder', 'Morning of due date', true),
                  _ToggleData('Exam countdown', '3 days, 1 day before exam', true),
                  _ToggleData('Overdue task nudge', 'Gentle reminder after 1 day', true),
                ]),

                const SizedBox(height: 24),

                // Group 3
                _SectionLabel('FOCUS & STREAKS'),
                _ToggleGroup([
                  _ToggleData('Daily study prompt', 'Evening check-in from Sprout', true),
                  _ToggleData('Streak at-risk warning', 'If you haven\'t studied by 9 PM', false),
                ]),

                const SizedBox(height: 24),

                // Group 4
                _SectionLabel('SPROUT'),
                _ToggleGroup([
                  _ToggleData('Sprout level-up celebration', 'When Sprout gains a level', true),
                  _ToggleData('Recovery / rest suggestions', 'When burnout detected', true),
                ]),

                const SizedBox(height: 24),

                // Quiet Hours
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFF0E8DC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Quiet Hours', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                              Text('Bloom will not notify during these hours', style: AppTypography.bodySmall(color: const Color(0xFF8B8070)).copyWith(fontSize: 12)),
                            ],
                          ),
                          Switch.adaptive(
                            value: true,
                            onChanged: (v) {},
                            activeThumbColor: AppColors.amber,
                            activeTrackColor: AppColors.amber.withValues(alpha: 0.25),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _TimePill(Icons.nightlight_round, '11:00 PM'),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.arrow_forward_rounded, color: Color(0xFFC8C0B8), size: 16),
                          ),
                          Expanded(
                            child: _TimePill(Icons.wb_sunny_rounded, '07:00 AM'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(label, style: AppTypography.labelSmall(color: const Color(0xFFB0A898)).copyWith(letterSpacing: 1.2, fontSize: 10)),
  );
}

class _ToggleData {
  final String title;
  final String sub;
  final bool initialVal;
  _ToggleData(this.title, this.sub, this.initialVal);
}

class _ToggleGroup extends StatefulWidget {
  final List<_ToggleData> items;
  const _ToggleGroup(this.items);

  @override
  State<_ToggleGroup> createState() => _ToggleGroupState();
}

class _ToggleGroupState extends State<_ToggleGroup> {
  late List<bool> _vals;

  @override
  void initState() {
    super.initState();
    _vals = widget.items.map((e) => e.initialVal).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0E8DC)),
      ),
      child: Column(
        children: widget.items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Column(
            children: [
              SizedBox(
                height: 52,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(item.sub, style: AppTypography.bodySmall(color: const Color(0xFFB0A898)).copyWith(fontSize: 11)),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _vals[i],
                        onChanged: (v) => setState(() => _vals[i] = v),
                        activeThumbColor: AppColors.amber,
                        activeTrackColor: AppColors.amber.withValues(alpha: 0.25),
                      ),
                    ],
                  ),
                ),
              ),
              if (i < widget.items.length - 1)
                const Divider(height: 1, color: Color(0xFFF5EFE8)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  final IconData icon;
  final String time;
  const _TimePill(this.icon, this.time);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0D8CE)),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF8B8070)),
          const SizedBox(width: 6),
          Text(time, style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
