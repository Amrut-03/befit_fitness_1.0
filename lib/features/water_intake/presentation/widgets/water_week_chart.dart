import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/water_day.dart';
import 'water_format.dart';

/// Litres per day for the last 7 days; met days are green.
class WaterWeekChart extends StatelessWidget {
  const WaterWeekChart({super.key, required this.days});

  final List<WaterDay> days;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    final maxMl = days
        .map((d) => d.totalMl > d.goalMl ? d.totalMl : d.goalMl)
        .reduce((a, b) => a > b ? a : b);
    final metCount = days.where((d) => d.goalReached).length;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.metricLast7Days,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                context.l10n.waterGoalMet(metCount),
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 160.h,
            child: BarChart(
              BarChartData(
                maxY: maxMl * 1.15 / 1000,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surfaceHigh,
                    getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                      formatWater(days[group.x].totalMl),
                      const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: Text(
                          DateFormat.E().format(days[value.toInt()].day),
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < days.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: days[i].totalMl / 1000,
                          width: 18.w,
                          borderRadius: BorderRadius.circular(6.r),
                          color: days[i].goalReached
                              ? AppColors.success
                              : AppColors.water,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: days[i].goalMl / 1000,
                            color: AppColors.water.withValues(alpha: 0.12),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
