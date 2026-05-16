import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

class FocusStreaksWidget extends StatelessWidget {
  const FocusStreaksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF5EFE3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Focus Streaks',
            style: AppTypography.titleMedium(color: const Color(0xFF5A5A5A)).copyWith(fontSize: 15),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [
              // Mocked heatmap
              ..._generateMockData(),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _generateMockData() {
    final values = [
      1, 3, 0, 3, 1, 0, 0, // W1
      3, 3, 3, 2, 3, 1, 0, // W2
      0, 1, 3, 3, 0, 0, 0, // W3
      3, 2, 0, 3, 0, 0, 0, // W4
    ];
    
    return values.map((val) {
      Color color;
      switch (val) {
        case 3:
          color = const Color(0xFFF6C945);
          break;
        case 2:
          color = const Color(0xFFEEC13E);
          break;
        case 1:
          color = const Color(0xFFFFF3C4);
          break;
        default:
          color = const Color(0xFFEAE7E7);
      }
      return Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }).toList();
  }
}
