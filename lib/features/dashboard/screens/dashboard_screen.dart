import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';

import '../widgets/dashboard_header.dart';
import '../widgets/mood_check_in_strip.dart';
import '../widgets/next_class_card.dart';
import '../widgets/today_priorities_card.dart';
import '../widgets/attendance_alert_card.dart';
import '../widgets/start_focus_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: Stack(
        children: [
          // Gradient Background (Top Third)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFEFD5).withValues(alpha: 0.8), // PapayaWhip
                    const Color(0xFFFFF9F1).withValues(alpha: 0.0), // Transparent bloom-cream
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        const DashboardHeader(),
                        const SizedBox(height: 20),
                        const MoodCheckInStrip(),
                        const SizedBox(height: 20),
                        const NextClassCard(),
                        const SizedBox(height: 20),
                        const TodayPrioritiesCard(),
                        const SizedBox(height: 20),
                        const AttendanceAlertCard(),
                        const SizedBox(height: 20),
                        const StartFocusButton(),
                        const SizedBox(height: 40), // Extra padding for bottom nav
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
