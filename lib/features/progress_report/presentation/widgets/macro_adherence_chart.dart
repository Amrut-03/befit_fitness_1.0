import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/weekly_report.dart';

abstract final class MacroColors {
  static const protein = AppColors.accentPink;
  static const carbs = AppColors.warning;
  static const fat = AppColors.primary;
}

/// Protein, carbs and fat per day as a % of goal; the dashed line is 100 %.
class MacroAdherenceChart extends StatelessWidget {
  const MacroAdherenceChart({
    super.key,
    required this.days,
    required this.goals,
    this.height,
  });

  /// Shown above 150 % as a full bar.
  static const capPct = 150.0;

  final List<MacroDay> days;
  final MacroGoals? goals;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final h = height ?? 150.h;
    final g = goals;
    if (g == null || !g.isSet) {
      return _note(h, 'Set macro goals in your profile to track adherence.');
    }
    if (!days.any((d) => d.logged)) {
      return _note(h, 'Tick off meals in your diet plan to see your macros.');
    }

    double pct(double eaten, double goal) =>
        (eaten / goal * 100).clamp(0, capPct).toDouble();

    BarChartRodData rod(double y, Color c, bool logged) => BarChartRodData(
      toY: logged ? y : 0,
      width: 6.w,
      color: c,
      borderRadius: BorderRadius.circular(2.r),
    );

    return Column(
      children: [
        SizedBox(
          height: h,
          child: BarChart(
            BarChartData(
              maxY: capPct,
              minY: 0,
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 100,
                    color: AppColors.textMuted,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ],
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.surfaceHigh,
                  getTooltipItem: (group, _, rod, i) {
                    final d = days[group.x];
                    if (!d.logged) return null;
                    final label = ['Protein', 'Carbs', 'Fat'][i];
                    final eaten = [d.protein, d.carbs, d.fat][i];
                    final goal = [g.protein, g.carbs, g.fat][i];
                    return BarTooltipItem(
                      '$label ${eaten.round()}/${goal.round()} g',
                      const TextStyle(color: AppColors.textPrimary),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        DateFormat.E().format(days[v.toInt()].day)[0],
                        style: TextStyle(
                          color: days[v.toInt()].logged
                              ? AppColors.textSecondary
                              : AppColors.textMuted.withValues(alpha: 0.5),
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
                    barsSpace: 2.w,
                    barRods: [
                      rod(
                        pct(days[i].protein, g.protein),
                        MacroColors.protein,
                        days[i].logged,
                      ),
                      rod(
                        pct(days[i].carbs, g.carbs),
                        MacroColors.carbs,
                        days[i].logged,
                      ),
                      rod(
                        pct(days[i].fat, g.fat),
                        MacroColors.fat,
                        days[i].logged,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8.h),
        const MacroLegend(),
      ],
    );
  }

  Widget _note(double h, String text) => SizedBox(
    height: h * 0.6,
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
      ),
    ),
  );
}

class MacroLegend extends StatelessWidget {
  const MacroLegend({super.key});

  @override
  Widget build(BuildContext context) {
    Widget item(String label, Color c) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10.w, height: 10.w, color: c),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
        ),
      ],
    );

    return Wrap(
      spacing: 12.w,
      runSpacing: 4.h,
      alignment: WrapAlignment.center,
      children: [
        item('Protein', MacroColors.protein),
        item('Carbs', MacroColors.carbs),
        item('Fat', MacroColors.fat),
        Text(
          '- - 100% of goal',
          style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
        ),
      ],
    );
  }
}
