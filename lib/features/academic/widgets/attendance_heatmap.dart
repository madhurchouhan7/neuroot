import 'package:flutter/material.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

class AttendanceHeatmap extends StatelessWidget {
  const AttendanceHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF5EFE3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "This Month's Heatmap",
            style: AppTypography.titleMedium(color: const Color(0xFF1B1C1C)).copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          
          // Heatmap grid (mocked)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _DayLabel('M'), _DayLabel('T'), _DayLabel('W'), _DayLabel('T'),
              _DayLabel('F'), _DayLabel('S', dim: true), _DayLabel('S', dim: true),
            ],
          ),
          const SizedBox(height: 8),
          
          // Week 1
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _HeatmapCell(type: _CellType.present), _HeatmapCell(type: _CellType.present), _HeatmapCell(type: _CellType.present),
              _HeatmapCell(type: _CellType.absent), _HeatmapCell(type: _CellType.present), _HeatmapCell(type: _CellType.none), _HeatmapCell(type: _CellType.none),
            ],
          ),
          const SizedBox(height: 8),
          // Week 2
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _HeatmapCell(type: _CellType.present), _HeatmapCell(type: _CellType.present), _HeatmapCell(type: _CellType.cancelled),
              _HeatmapCell(type: _CellType.present), _HeatmapCell(type: _CellType.present), _HeatmapCell(type: _CellType.none), _HeatmapCell(type: _CellType.none),
            ],
          ),
          const SizedBox(height: 8),
          // Week 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _HeatmapCell(type: _CellType.absent), _HeatmapCell(type: _CellType.present), _HeatmapCell(type: _CellType.present),
              _HeatmapCell(type: _CellType.present), _HeatmapCell(type: _CellType.present), _HeatmapCell(type: _CellType.none), _HeatmapCell(type: _CellType.none),
            ],
          ),
          const SizedBox(height: 8),
          // Week 4
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _HeatmapCell(type: _CellType.present), _HeatmapCell(type: _CellType.today), _HeatmapCell(type: _CellType.future),
              _HeatmapCell(type: _CellType.future), _HeatmapCell(type: _CellType.future), _HeatmapCell(type: _CellType.futureNone), _HeatmapCell(type: _CellType.futureNone),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem(AppColors.sageDark.withValues(alpha: 0.8), 'Present', isBorder: false),
              _buildLegendItem(const Color(0xFFE05C5C).withValues(alpha: 0.7), 'Absent', isBorder: false),
              _buildLegendItem(const Color(0xFFEAE7E7), 'Cancelled', isBorder: true, borderColor: const Color(0xFFD1C5AE)),
              _buildLegendItem(Colors.transparent, 'Future', isBorder: true, borderColor: const Color(0xFFD1C5AE).withValues(alpha: 0.4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {required bool isBorder, Color? borderColor}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: isBorder ? Border.all(color: borderColor!) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall(color: const Color(0xFF4E4634)).copyWith(fontSize: 10),
        ),
      ],
    );
  }
}

enum _CellType { present, absent, cancelled, future, none, today, futureNone }

class _DayLabel extends StatelessWidget {
  final String label;
  final bool dim;
  
  const _DayLabel(this.label, {this.dim = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.labelSmall(color: const Color(0xFF4E4634)).copyWith(
          fontSize: 10,
          color: dim ? const Color(0xFF4E4634).withValues(alpha: 0.5) : const Color(0xFF4E4634),
        ),
      ),
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  final _CellType type;

  const _HeatmapCell({required this.type});

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.transparent;
    Border? border;
    Widget? child;

    switch (type) {
      case _CellType.present:
        bgColor = AppColors.sageDark.withValues(alpha: 0.8);
        break;
      case _CellType.absent:
        bgColor = const Color(0xFFE05C5C).withValues(alpha: 0.7);
        break;
      case _CellType.cancelled:
        bgColor = const Color(0xFFEAE7E7);
        border = Border.all(color: const Color(0xFFD1C5AE));
        child = const Center(child: Text('C', style: TextStyle(fontSize: 8, color: Color(0xFF4E4634))));
        break;
      case _CellType.future:
        border = Border.all(color: const Color(0xFFD1C5AE).withValues(alpha: 0.4));
        break;
      case _CellType.none:
        bgColor = const Color(0xFFE4E2E1); // highest
        break;
      case _CellType.futureNone:
        bgColor = const Color(0xFFE4E2E1).withValues(alpha: 0.3); // highest
        break;
      case _CellType.today:
        bgColor = AppColors.white;
        border = Border.all(color: AppColors.primaryContainer, width: 2);
        child = Center(
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
        break;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: border,
      ),
      child: child,
    );
  }
}
