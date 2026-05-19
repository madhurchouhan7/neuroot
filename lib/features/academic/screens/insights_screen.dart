import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

import '../widgets/weekly_wrap_card.dart';
import '../widgets/study_time_chart.dart';
import '../widgets/attendance_summary_widget.dart';
import '../widgets/focus_streaks_widget.dart';
import '../widgets/mood_trend_chart.dart';
import 'attendance_screen.dart' as neuroot_attendance;

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F1), // bloom-cream
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9F1),
        elevation: 0,
        centerTitle: true,

        title: Text(
          'Insights',
          style: AppTypography.titleMedium(
            color: AppColors.primaryContainer,
          ).copyWith(fontSize: 20),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'This Week',
                  style: AppTypography.bodySmall(
                    color: AppColors.primaryContainer,
                  ).copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.primaryContainer,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const WeeklyWrapCard(),
                const SizedBox(height: 20),

                const StudyTimeChart(),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const neuroot_attendance.AttendanceScreen(),
                            ),
                          );
                        },
                        child: const AttendanceSummaryWidget(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: FocusStreaksWidget()),
                  ],
                ),

                const SizedBox(height: 20),
                const MoodTrendChart(),

                const SizedBox(height: 100), // Bottom padding for nav
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
