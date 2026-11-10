import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/weekly_report.dart';
import 'report_format.dart';

/// Weight change, macro adherence, workouts and water for the week.
class ReportStatTiles extends StatelessWidget {
  const ReportStatTiles({super.key, required this.report});

  final WeeklyReport report;

  @override
  Widget build(BuildContext context) {
    final r = report;
    final change = r.weightChangeKg;
    final days = r.daysElapsed == 0 ? 7 : r.daysElapsed;

    return LayoutBuilder(
      builder: (context, c) {
        final tileWidth = (c.maxWidth - 8.w) / 2;
        return Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _Tile(
              width: tileWidth,
              icon: Icons.monitor_weight_outlined,
              color: AppColors.primary,
              label: context.l10n.statWeight,
              value: change != null
                  ? signedKg(change)
                  : (r.latestWeightKg != null ? kg(r.latestWeightKg!) : '—'),
              caption: change != null
                  ? context.l10n.reportVsLastWeek
                  : context.l10n.reportLatest,
            ),
            _Tile(
              width: tileWidth,
              icon: Icons.pie_chart_outline,
              color: AppColors.accentPink,
              label: context.l10n.reportMacrosOnTarget,
              value: r.adherencePct == null
                  ? '—'
                  : '${r.adherencePct!.round()}%',
              caption: context.l10n.reportLoggedDays(r.loggedDays, days),
            ),
            _Tile(
              width: tileWidth,
              icon: Icons.fitness_center,
              color: AppColors.accentOrange,
              label: context.l10n.reportWorkouts,
              value: '${r.workouts}',
              caption: r.workoutSets > 0
                  ? context.l10n.reportSetsCount(r.workoutSets) +
                        (r.workoutMinutes > 0
                            ? ' · ${context.l10n.unitMinutes('${r.workoutMinutes}')}'
                            : '')
                  : context.l10n.reportThisWeekCaption,
            ),
            _Tile(
              width: tileWidth,
              icon: Icons.water_drop_outlined,
              color: AppColors.water,
              label: context.l10n.reportWaterGoal,
              value: '${r.waterDaysMet}/$days',
              caption: context.l10n.reportDaysMet,
            ),
          ],
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.width,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.caption,
  });

  final double width;
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            caption,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
          ),
        ],
      ),
    );
  }
}
