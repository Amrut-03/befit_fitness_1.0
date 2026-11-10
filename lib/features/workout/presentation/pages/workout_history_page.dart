import 'package:fitness_app/core/models/history_detail_data.dart';
import 'package:fitness_app/core/models/history_item.dart';
import 'package:fitness_app/core/widgets/history_page.dart';
import 'package:fitness_app/core/widgets/show_history_detail_bottom_sheet.dart';

import 'package:fitness_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_event.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_state.dart';
import 'package:fitness_app/features/workout/presentation/widgets/session/ticker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutHistoryPage extends StatefulWidget {
  const WorkoutHistoryPage({super.key});

  @override
  State<WorkoutHistoryPage> createState() => _WorkoutHistoryPageState();
}

class _WorkoutHistoryPageState extends State<WorkoutHistoryPage> {
  @override
  void initState() {
    super.initState();

    context.read<WorkoutBloc>().add(LoadWorkoutHistory());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutBloc, WorkoutState>(
      builder: (context, state) {
        final items = state.history.map((history) {
          return HistoryItem(
            id: history.completedAt.millisecondsSinceEpoch.toString(),

            title: history.workoutName,

            subtitle: history.exerciseLogs.isEmpty
                ? history.bodyPart
                : '${history.exerciseLogs.length} exercises · '
                      '${history.totalSets} sets',

            value: "Completed",

            date: history.completedAt,

            completed: true,
          );
        }).toList();

        return HistoryListPage(
          title: "Workout History",

          items: items,

          onItemTap: (item) {
            final history = state.history.firstWhere(
              (e) => e.completedAt.millisecondsSinceEpoch.toString() == item.id,
            );

            showHistoryDetailBottomSheet(
              context,
              HistoryDetailData(
                title: history.workoutName,
                completedAt: history.completedAt,
                items: history.exerciseLogs.isEmpty
                    ? history.exercises
                    : [
                        for (final log in history.exerciseLogs)
                          '${log.name} — ${log.summary}',
                      ],
                stats: {
                  "Target": history.bodyPart,
                  if (history.durationSeconds != null)
                    "Duration": formatDuration(
                      Duration(seconds: history.durationSeconds!),
                    ),
                  if (history.totalSets > 0) "Sets": '${history.totalSets}',
                  if (history.volumeKg > 0)
                    "Volume": '${history.volumeKg.round()} kg',
                },
              ),
            );
          },
        );
      },
    );
  }
}
