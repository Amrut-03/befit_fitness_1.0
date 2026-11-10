import 'package:equatable/equatable.dart';

import 'package:fitness_app/features/workout/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';

class WorkoutState extends Equatable {
  final bool isLoading;

  /// True while the next page is being fetched (infinite scroll).
  final bool isLoadingMore;

  final List<ExerciseEntity> exercises;

  final List<ExerciseEntity> allExercises;

  final List<WorkoutHistoryEntity> history;

  final String? error;

  final bool hasReachedMax;

  /// Cursor for the next page from the exercises API.
  final String? nextCursor;

  /// Body part filter the current list was loaded with (`null` = all).
  final String? bodyPart;

  final String searchQuery;

  const WorkoutState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.exercises = const [],
    this.allExercises = const [],
    this.error,
    this.hasReachedMax = false,
    this.nextCursor,
    this.bodyPart,
    this.searchQuery = '',
    this.history = const [],
  });

  factory WorkoutState.initial() {
    return const WorkoutState();
  }

  static const Object _unset = Object();

  WorkoutState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<ExerciseEntity>? exercises,
    List<WorkoutHistoryEntity>? history,
    List<ExerciseEntity>? allExercises,
    Object? error = _unset,
    bool? hasReachedMax,
    Object? nextCursor = _unset,
    Object? bodyPart = _unset,
    String? searchQuery,
  }) {
    return WorkoutState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      exercises: exercises ?? this.exercises,
      allExercises: allExercises ?? this.allExercises,
      history: history ?? this.history,
      error: identical(error, _unset) ? this.error : error as String?,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      nextCursor: identical(nextCursor, _unset)
          ? this.nextCursor
          : nextCursor as String?,
      bodyPart: identical(bodyPart, _unset)
          ? this.bodyPart
          : bodyPart as String?,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isLoadingMore,
    exercises,
    error,
    hasReachedMax,
    nextCursor,
    bodyPart,
    searchQuery,
    allExercises,
    history,
  ];
}
