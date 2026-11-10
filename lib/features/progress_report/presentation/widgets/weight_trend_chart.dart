import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/weekly_report.dart';
import 'report_format.dart';

/// Weekly average weight over the last 8 weeks; the selected week is the
/// highlighted dot.
class WeightTrendChart extends StatelessWidget {
  const WeightTrendChart({
    super.key,
    required this.trend,
    required this.week,
    this.height,
  });

  final List<WeeklyWeight> trend;
  final WeekRange week;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final h = height ?? 140.h;
    if (trend.isEmpty) {
      return _Empty(height: h, text: 'Log your weight to see the trend.');
    }

    final values = trend.map((w) => w.avgKg);
    final lo = values.reduce((a, b) => a < b ? a : b);
    final hi = values.reduce((a, b) => a > b ? a : b);
    final pad = ((hi - lo) * 0.3).clamp(0.5, 5).toDouble();
    final weekX = {
      for (var i = 0; i < 8; i++) week.shift(i - 7).start: i.toDouble(),
    };

    return Semantics(
      label: 'Weight trend: ${trend.map((w) => kg(w.avgKg)).join(', ')}',
      child: SizedBox(
        height: h,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 7,
            minY: lo - pad,
            maxY: hi + pad,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => AppColors.surfaceHigh,
                getTooltipItems: (spots) => [
                  for (final s in spots)
                    LineTooltipItem(
                      kg(s.y),
                      const TextStyle(color: AppColors.textPrimary),
                    ),
                ],
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32.w,
                  getTitlesWidget: (v, meta) => v == meta.min || v == meta.max
                      ? const SizedBox.shrink()
                      : Text(
                          v.toStringAsFixed(0),
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10.sp,
                          ),
                        ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i != v || i < 0 || i > 7 || i.isOdd) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        DateFormat('d MMM').format(week.shift(i - 7).start),
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10.sp,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (final w in trend)
                    if (weekX[w.weekStart] != null)
                      FlSpot(weekX[w.weekStart]!, w.avgKg),
                ],
                isCurved: true,
                preventCurveOverShooting: true,
                color: AppColors.primary,
                barWidth: 3,
                dotData: FlDotData(
                  getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                    radius: spot.x == 7 ? 5 : 3,
                    color: spot.x == 7
                        ? AppColors.primary
                        : AppColors.surfaceHigh,
                    strokeColor: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.height, required this.text});

  final double height;
  final String text;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height * 0.6,
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
      ),
    ),
  );
}
