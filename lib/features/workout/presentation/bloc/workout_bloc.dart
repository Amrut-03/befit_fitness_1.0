import 'dart:async';

import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';
import 'package:fitness_app/features/workout/domain/usecases/get_workout_history.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_app/features/workout/domain/usecases/save_workout_history.dart';
import 'package:fitness_app/features/workout/domain/usecases/get_exercises.dart';
import 'workout_event.dart';
import 'workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final GetExercises getExercises;

  final SaveWorkoutHistory saveWorkoutHistory;

  final GetWorkoutHistory getWorkoutHistory;

  StreamSubscription? _historySubscription;

  WorkoutBloc({
    required this.getExercises,

    required this.saveWorkoutHistory,

    required this.getWorkoutHistory,
  }) : super(WorkoutState.initial()) {
    on<LoadExercisesEvent>(_onLoadExercises);

    on<SearchExercisesEvent>(_onSearch);

    on<LoadWorkoutHistory>(_onLoadWorkoutHistory);

    on<SaveWorkoutHistoryEvent>(_onSaveWorkoutHistory);

    on<WorkoutHistoryUpdated>(_onWorkoutHistoryUpdated);
  }

  /// SEARCH
  void _onSearch(SearchExercisesEvent event, Emitter<WorkoutState> emit) {
    final query = event.query.trim().toLowerCase();

    if (query.isEmpty) {
      emit(state.copyWith(exercises: state.allExercises, searchQuery: ''));

      return;
    }

    final filtered = state.allExercises.where((exercise) {
      return exercise.name.toLowerCase().contains(query) ||
          exercise.bodyPart.toLowerCase().contains(query) ||
          exercise.target.toLowerCase().contains(query);
    }).toList();

    emit(state.copyWith(exercises: filtered, searchQuery: query));
  }

  Future<void> _onSaveWorkoutHistory(
    SaveWorkoutHistoryEvent event,

    Emitter<WorkoutState> emit,
  ) async {
    try {
      await saveWorkoutHistory(
        WorkoutHistoryEntity(
          workoutName: event.workoutName,

          bodyPart: event.bodyPart,

          exercises: event.exercises,

          completedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onLoadWorkoutHistory(
    LoadWorkoutHistory event,

    Emitter<WorkoutState> emit,
  ) async {
    await _historySubscription?.cancel();

    _historySubscription = getWorkoutHistory().listen((history) {
      add(WorkoutHistoryUpdated(history));
    });
  }

  void _onWorkoutHistoryUpdated(
    WorkoutHistoryUpdated event,

    Emitter<WorkoutState> emit,
  ) {
    emit(state.copyWith(history: event.history));
  }

  /// LOAD EXERCISES
  Future<void> _onLoadExercises(
    LoadExercisesEvent event,

    Emitter<WorkoutState> emit,
  ) async {
    if (state.hasReachedMax && event.loadMore) {
      return;
    }

    try {
      if (!event.loadMore) {
        emit(state.copyWith(isLoading: true, offset: 0));
      }

      final exercises = await getExercises(
        limit: 20,

        offset: event.loadMore ? state.offset : 0,

        bodyPart: event.bodyPart,
      );

      final updatedExercises = event.loadMore
          ? [...state.allExercises, ...exercises]
          : exercises;

      emit(
        state.copyWith(
          isLoading: false,

          exercises: updatedExercises,

          allExercises: updatedExercises,

          offset: updatedExercises.length,

          hasReachedMax: exercises.isEmpty,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to load exercises'));
    }
  }

  @override
  Future<void> close() {
    _historySubscription?.cancel();

    return super.close();
  }
}
