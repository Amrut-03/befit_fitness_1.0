import 'package:fitness_app/core/routes/routes.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/water_entry.dart';
import '../../domain/utils/water_goal.dart';
import '../bloc/water_intake_bloc.dart';
import '../widgets/water_amount_sheet.dart';
import '../widgets/water_format.dart';
import '../widgets/water_progress_ring.dart';
import '../widgets/water_week_chart.dart';

class WaterIntakePage extends StatefulWidget {
  const WaterIntakePage({super.key});

  @override
  State<WaterIntakePage> createState() => _WaterIntakePageState();
}

class _WaterIntakePageState extends State<WaterIntakePage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<WaterIntakeBloc>();
    bloc.add(
      bloc.state.status == WaterStatus.initial
          ? const WaterIntakeStarted()
          : const WaterIntakeRefreshed(),
    );
  }

  Future<void> _editGoal(WaterIntakeState state) async {
    final bloc = context.read<WaterIntakeBloc>();
    final ml = await showWaterAmountSheet(
      context,
      title: 'Daily water goal',
      hint:
          'Recommended for your weight: '
          '${formatWater(state.recommendedGoalMl)}',
      initialMl: state.goalMl,
      min: WaterGoal.minMl,
      max: WaterGoal.maxMl,
    );
    if (ml != null && ml != state.goalMl) bloc.add(WaterGoalUpdated(ml));
  }

  Future<void> _addCustom() async {
    final bloc = context.read<WaterIntakeBloc>();
    final ml = await showWaterAmountSheet(
      context,
      title: 'Add water',
      min: 1,
      max: 3000,
      confirmLabel: 'Add',
    );
    if (ml != null) bloc.add(WaterAdded(ml));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WaterIntakeBloc, WaterIntakeState>(
      listenWhen: (_, s) => s.message != null,
      listener: (context, state) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message!))),
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppHeader(
            title: 'Water',
            actions: [
              IconButton(
                tooltip: 'Edit goal',
                icon: const Icon(Icons.flag_outlined),
                onPressed: state.status == WaterStatus.ready
                    ? () => _editGoal(state)
                    : null,
              ),
            ],
          ),
          body: switch (state.status) {
            WaterStatus.initial ||
            WaterStatus.loading when state.today == null => const AppLoader(),
            WaterStatus.failure when state.today == null => _Failure(
              onRetry: () => context.read<WaterIntakeBloc>().add(
                const WaterIntakeStarted(),
              ),
            ),
            _ => RefreshIndicator(
              onRefresh: () async => context.read<WaterIntakeBloc>().add(
                const WaterIntakeRefreshed(),
              ),
              child: ListView(
                padding: EdgeInsets.all(20.w),
                children: [
                  Center(
                    child: WaterProgressRing(
                      totalMl: state.totalMl,
                      goalMl: state.goalMl,
                      progress: state.progress,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _QuickAdd(onCustom: _addCustom),
                  SizedBox(height: 24.h),
                  _TodayLog(entries: state.today?.entries ?? const []),
                  SizedBox(height: 24.h),
                  WaterWeekChart(days: state.week),
                  SizedBox(height: 16.h),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.water,
                    ),
                    title: const Text(
                      'Hydration reminders',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: const Text(
                      'Every 2 hours, 10 AM to 6 PM. Paused for the day once '
                      'you hit your goal.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                    ),
                    onTap: () => context.push(Routes.notificationSettings),
                  ),
                ],
              ),
            ),
          },
        );
      },
    );
  }
}

class _QuickAdd extends StatelessWidget {
  const _QuickAdd({required this.onCustom});

  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      alignment: WrapAlignment.center,
      children: [
        for (final ml in WaterGoal.quickAddMl)
          ActionChip(
            avatar: const Icon(Icons.add, size: 18, color: AppColors.water),
            label: Text(formatWater(ml)),
            labelStyle: const TextStyle(color: AppColors.textPrimary),
            backgroundColor: AppColors.surfaceHigh,
            side: BorderSide(color: AppColors.water.withValues(alpha: 0.4)),
            onPressed: () =>
                context.read<WaterIntakeBloc>().add(WaterAdded(ml)),
          ),
        ActionChip(
          avatar: const Icon(Icons.edit, size: 18, color: AppColors.water),
          label: const Text('Custom'),
          labelStyle: const TextStyle(color: AppColors.textPrimary),
          backgroundColor: AppColors.surfaceHigh,
          side: BorderSide(color: AppColors.water.withValues(alpha: 0.4)),
          onPressed: onCustom,
        ),
      ],
    );
  }
}

class _TodayLog extends StatelessWidget {
  const _TodayLog({required this.entries});

  final List<WaterEntry> entries;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.jm();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        if (entries.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: const Text(
              'Nothing logged yet. Tap an amount above.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          )
        else
          for (final entry in entries.reversed)
            Dismissible(
              key: ValueKey(entry.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 16.w),
                color: AppColors.error.withValues(alpha: 0.2),
                child: const Icon(Icons.delete_outline, color: AppColors.error),
              ),
              onDismissed: (_) =>
                  context.read<WaterIntakeBloc>().add(WaterEntryRemoved(entry)),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.water_drop_outlined,
                  color: AppColors.water,
                ),
                title: Text(
                  formatWater(entry.ml),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                trailing: Text(
                  time.format(entry.at),
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),
        if (entries.isNotEmpty)
          Text(
            'Swipe left to remove an entry.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
          ),
      ],
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Couldn't load your water log.",
            style: TextStyle(color: AppColors.textPrimary),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
