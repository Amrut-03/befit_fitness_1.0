import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/weekly_report.dart';
import '../../domain/utils/report_calculator.dart';
import '../bloc/weekly_report_bloc.dart';
import '../widgets/macro_adherence_chart.dart';
import '../widgets/report_format.dart';
import '../widgets/report_stat_tiles.dart';
import '../widgets/weight_trend_chart.dart';

/// The full weekly report, with paging back through past weeks. Has its own
/// bloc (provided by the route) so paging doesn't change the Home card.
class WeeklyReportPage extends StatelessWidget {
  const WeeklyReportPage({super.key, this.clock});

  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeeklyReportBloc, WeeklyReportState>(
      builder: (context, state) {
        final bloc = context.read<WeeklyReportBloc>();
        final report = state.report;
        final now = (clock ?? DateTime.now)();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppHeader(title: context.l10n.reportTitle),
          body: Column(
            children: [
              _WeekSwitcher(
                label: report == null ? '' : weekLabel(report.week, now),
                dates: report == null ? '' : weekDates(report.week),
                onPrevious: state.offset < WeeklyReportBloc.maxWeeksBack
                    ? () => bloc.add(WeeklyReportRequested(state.offset + 1))
                    : null,
                onNext: state.offset > 0
                    ? () => bloc.add(WeeklyReportRequested(state.offset - 1))
                    : null,
              ),
              Expanded(
                child: report == null
                    ? (state.status == ReportStatus.failure
                          ? Center(
                              child: TextButton(
                                onPressed: () =>
                                    bloc.add(const WeeklyReportRefreshed()),
                                child: Text(context.l10n.reportLoadFailed),
                              ),
                            )
                          : const AppLoader())
                    : RefreshIndicator(
                        onRefresh: () async =>
                            bloc.add(const WeeklyReportRefreshed()),
                        child: ListView(
                          padding: EdgeInsets.all(16.w),
                          children: [
                            ReportStatTiles(report: report),
                            SizedBox(height: 20.h),
                            _Section(
                              title: context.l10n.reportWeightTrend,
                              subtitle: report.latestWeightKg == null
                                  ? context.l10n.reportWeightTrendSub
                                  : context.l10n.reportWeightTrendLatest(
                                      kg(report.latestWeightKg!),
                                    ),
                              child: WeightTrendChart(
                                trend: report.weightTrend,
                                week: report.week,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            _Section(
                              title: context.l10n.reportMacroAdherence,
                              subtitle: report.adherencePct == null
                                  ? context.l10n.reportMacroSub
                                  : context.l10n.reportMacroOnTarget(
                                      report.adherencePct!.round(),
                                      report.loggedDays,
                                    ),
                              child: Column(
                                children: [
                                  MacroAdherenceChart(
                                    days: report.macroDays,
                                    goals: report.goals,
                                  ),
                                  if (report.goals?.isSet == true &&
                                      report.loggedDays > 0) ...[
                                    SizedBox(height: 12.h),
                                    _MacroTable(report: report),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WeekSwitcher extends StatelessWidget {
  const _WeekSwitcher({
    required this.label,
    required this.dates,
    this.onPrevious,
    this.onNext,
  });

  final String label;
  final String dates;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          IconButton(
            tooltip: context.l10n.reportPrevWeek,
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (label != dates)
                  Text(
                    dates,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.sp,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.reportNextWeek,
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

/// Per day: kcal, protein, carbs, fat (g) and the day's score.
class _MacroTable extends StatelessWidget {
  const _MacroTable({required this.report});

  final WeeklyReport report;

  @override
  Widget build(BuildContext context) {
    final g = report.goals!;
    final head = TextStyle(color: AppColors.textMuted, fontSize: 11.sp);
    final cell = TextStyle(color: AppColors.textSecondary, fontSize: 12.sp);

    TableRow row(List<String> cells, TextStyle style) => TableRow(
      children: [
        for (var i = 0; i < cells.length; i++)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(
              cells[i],
              textAlign: i == 0 ? TextAlign.left : TextAlign.right,
              style: style,
            ),
          ),
      ],
    );

    return Table(
      columnWidths: const {0: FlexColumnWidth(1.2)},
      children: [
        row(['', 'kcal', 'P', 'C', 'F', context.l10n.reportScore], head),
        row([
          context.l10n.reportGoal,
          '${g.calories.round()}',
          '${g.protein.round()}',
          '${g.carbs.round()}',
          '${g.fat.round()}',
          '',
        ], head),
        for (final d in report.macroDays)
          if (d.logged)
            row([
              DateFormat.E().format(d.day),
              '${d.calories.round()}',
              '${d.protein.round()}',
              '${d.carbs.round()}',
              '${d.fat.round()}',
              '${ReportCalculator.dayAdherence(d, g).round()}%',
            ], cell),
      ],
    );
  }
}
