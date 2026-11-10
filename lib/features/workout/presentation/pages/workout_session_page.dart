import 'package:fitness_app/core/routes/routes.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/workout_history_entity.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/utils/session_defaults.dart';
import '../cubit/workout_session_cubit.dart';
import '../widgets/session/rest_timer_panel.dart';
import '../widgets/session/session_exercise_card.dart';
import '../widgets/session/ticker.dart';

class WorkoutSessionPage extends StatelessWidget {
  const WorkoutSessionPage({super.key});

  Future<void> _confirmDiscard(BuildContext context) async {
    final cubit = context.read<WorkoutSessionCubit>();
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Discard workout?'),
        content: const Text(
          "Your sets won't be saved and this won't count toward your streak.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true) await cubit.discard();
  }

  Future<void> _onFinished(
    BuildContext context,
    WorkoutHistoryEntity workout,
  ) async {
    // A saved session counts as today's activity.
    context.read<StreakBloc>().add(UpdateStreakEvent());
    await showDialog<void>(
      context: context,
      builder: (ctx) => _SummaryDialog(workout: workout),
    );
    if (context.mounted && context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutSessionCubit, WorkoutSessionState>(
      listenWhen: (a, b) =>
          b.message != null || (b.finished != null && a.finished == null),
      listener: (context, state) {
        if (state.finished != null) {
          _onFinished(context, state.finished!);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, state) {
        final session = state.session;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppHeader(
            title: 'Workout',
            actions: [
              if (session != null)
                IconButton(
                  tooltip: 'Discard workout',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDiscard(context),
                ),
            ],
          ),
          body: session == null
              ? _NoSession(saved: state.finished != null)
              : _SessionBody(session: session, state: state),
        );
      },
    );
  }
}

class _SessionBody extends StatelessWidget {
  const _SessionBody({required this.session, required this.state});

  final WorkoutSession session;
  final WorkoutSessionState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkoutSessionCubit>();

    return Column(
      children: [
        _StatsStrip(session: session),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            children: [
              for (var i = 0; i < session.exercises.length; i++)
                SessionExerciseCard(
                  key: ValueKey(session.exercises[i].exerciseId),
                  index: i,
                  exercise: session.exercises[i],
                  lastTime: SessionDefaults.lastTimeSummary(
                    session.exercises[i].name,
                    state.history,
                  ),
                ),
              if (session.exercises.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: const Text(
                    'No exercises yet. Add some to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () => context.push(Routes.workout),
                icon: const Icon(Icons.add),
                label: const Text('Add exercise'),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RestTimerPanel(session: session),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    onPressed: state.saving ? null : cubit.finish,
                    child: state.saving
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Finish workout',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    Widget stat(String label, Widget value) => Expanded(
      child: Column(
        children: [
          DefaultTextStyle(
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
            child: value,
          ),
          Text(
            label,
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
          ),
        ],
      ),
    );

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          stat(
            'Duration',
            Ticker(
              builder: (_, now) =>
                  Text(formatDuration(now.difference(session.startedAt))),
            ),
          ),
          stat('Sets', Text('${session.completedSets}/${session.totalSets}')),
          stat('Volume', Text(_volume(session.volumeKg))),
        ],
      ),
    );
  }
}

String _volume(double kg) =>
    kg >= 1000 ? '${(kg / 1000).toStringAsFixed(1)} t' : '${kg.round()} kg';

class _NoSession extends StatelessWidget {
  const _NoSession({required this.saved});

  final bool saved;

  @override
  Widget build(BuildContext context) {
    if (saved) return const SizedBox.shrink();
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, color: AppColors.primary, size: 48.sp),
            SizedBox(height: 12.h),
            const Text(
              'No workout in progress',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            SizedBox(height: 4.h),
            const Text(
              'Add exercises from the list to start a session.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => context.push(Routes.workout),
              child: const Text('Browse exercises'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryDialog extends StatelessWidget {
  const _SummaryDialog({required this.workout});

  final WorkoutHistoryEntity workout;

  @override
  Widget build(BuildContext context) {
    final duration = Duration(seconds: workout.durationSeconds ?? 0);
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      title: const Text('Workout saved 🔥'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workout.workoutName,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8.h),
          Text('Duration: ${formatDuration(duration)}'),
          Text('Sets: ${workout.totalSets}'),
          if (workout.volumeKg > 0)
            Text('Volume: ${_volume(workout.volumeKg)}'),
          SizedBox(height: 8.h),
          for (final log in workout.exerciseLogs)
            Text(
              '• ${log.name}: ${log.summary}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
