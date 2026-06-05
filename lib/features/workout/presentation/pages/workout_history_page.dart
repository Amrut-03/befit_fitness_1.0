import 'package:fitness_app/core/models/history_detail_data.dart';
import 'package:fitness_app/core/models/history_item.dart';
import 'package:fitness_app/core/widgets/history_page.dart';
import 'package:fitness_app/core/widgets/showHistoryDetailBottomSheet.dart';

import 'package:fitness_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_event.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_state.dart';

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

            subtitle: history.bodyPart,

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
                items: history.exercises,
                stats: {"Target": history.bodyPart},
              ),
            );
          },
        );
      },
    );
  }
}
