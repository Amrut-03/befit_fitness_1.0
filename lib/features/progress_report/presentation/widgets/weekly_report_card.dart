import 'package:fitness_app/core/routes/routes.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../bloc/weekly_report_bloc.dart';
import 'macro_adherence_chart.dart';
import 'report_format.dart';
import 'report_stat_tiles.dart';
import 'weight_trend_chart.dart';

/// Home: this week's progress with the weight trend and macro adherence.
class WeeklyReportCard extends StatefulWidget {
  const WeeklyReportCard({super.key});

  @override
  State<WeeklyReportCard> createState() => _WeeklyReportCardState();
}

class _WeeklyReportCardState extends State<WeeklyReportCard> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<WeeklyReportBloc>();
    if (bloc.state.status == ReportStatus.initial) {
      bloc.add(const WeeklyReportRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WeeklyReportBloc>().state;
    final report = state.report;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly progress',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (report != null)
                      Text(
                        weekDates(report.week),
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.sp,
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.push(Routes.weeklyReport),
                child: const Text('Full report'),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (report == null)
            SizedBox(
              height: 120.h,
              child: Center(
                child: state.status == ReportStatus.failure
                    ? TextButton(
                        onPressed: () => context.read<WeeklyReportBloc>().add(
                          const WeeklyReportRefreshed(),
                        ),
                        child: const Text("Couldn't load. Retry"),
                      )
                    : const CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            ReportStatTiles(report: report),
            SizedBox(height: 16.h),
            const _SectionTitle('Weight trend'),
            WeightTrendChart(
              trend: report.weightTrend,
              week: report.week,
              height: 110.h,
            ),
            SizedBox(height: 16.h),
            const _SectionTitle('Macro adherence'),
            MacroAdherenceChart(
              days: report.macroDays,
              goals: report.goals,
              height: 110.h,
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
