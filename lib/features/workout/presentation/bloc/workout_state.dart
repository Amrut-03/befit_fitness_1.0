import 'package:equatable/equatable.dart';

import 'package:fitness_app/features/workout/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';

class WorkoutState extends Equatable {
  final bool isLoading;

  final List<ExerciseEntity> exercises;

  final List<ExerciseEntity> allExercises;

  final List<WorkoutHistoryEntity> history;

  final String? error;

  final bool hasReachedMax;

  final int offset;

  final String searchQuery;

  const WorkoutState({
    this.isLoading = false,

    this.exercises = const [],

    this.allExercises = const [],

    this.error,

    this.hasReachedMax = false,

    this.offset = 0,

    this.searchQuery = '',

    this.history = const [],
  });

  factory WorkoutState.initial() {
    return const WorkoutState();
  }

  WorkoutState copyWith({
    bool? isLoading,

    List<ExerciseEntity>? exercises,

    List<WorkoutHistoryEntity>? history,

    List<ExerciseEntity>? allExercises,

    String? error,

    bool? hasReachedMax,

    int? offset,

    String? searchQuery,
  }) {
    return WorkoutState(
      isLoading: isLoading ?? this.isLoading,

      exercises: exercises ?? this.exercises,

      allExercises: allExercises ?? this.allExercises,

      history: history ?? this.history,

      error: error ?? this.error,

      hasReachedMax: hasReachedMax ?? this.hasReachedMax,

      offset: offset ?? this.offset,

      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,

    exercises,

    error,

    hasReachedMax,

    offset,

    searchQuery,

    allExercises,

    history,
  ];
}
