import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/error/result.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise_page_entity.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';
import 'package:fitness_app/features/workout/domain/usecases/get_exercises.dart';
import 'package:fitness_app/features/workout/domain/usecases/get_workout_history.dart';
import 'package:fitness_app/features/workout/domain/usecases/save_workout_history.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_event.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _GetExercises extends Mock implements GetExercises {}

class _GetHistory extends Mock implements GetWorkoutHistory {}

class _SaveHistory extends Mock implements SaveWorkoutHistory {}

const _pushUp = ExerciseEntity(
  id: '1',
  name: 'Push-up',
  bodyPart: 'chest',
  target: 'pectorals',
  equipment: 'body weight',
  instructions: [],
);
const _squat = ExerciseEntity(
  id: '2',
  name: 'Squat',
  bodyPart: 'upper legs',
  target: 'quads',
  equipment: 'body weight',
  instructions: [],
);

void main() {
  late _GetExercises getExercises;
  late _GetHistory getHistory;

  setUp(() {
    getExercises = _GetExercises();
    getHistory = _GetHistory();
  });

  WorkoutBloc build() => WorkoutBloc(
    getExercises: getExercises,
    saveWorkoutHistory: _SaveHistory(),
    getWorkoutHistory: getHistory,
  );

  void stubExercises(Result<ExercisePageEntity> result) => when(
    () => getExercises(
      limit: any(named: 'limit'),
      cursor: any(named: 'cursor'),
      bodyPart: any(named: 'bodyPart'),
    ),
  ).thenAnswer((_) async => result);

  blocTest<WorkoutBloc, WorkoutState>(
    'load success → loading, exercises',
    setUp: () => stubExercises(
      const Ok(ExercisePageEntity(exercises: [_pushUp, _squat])),
    ),
    build: build,
    act: (b) => b.add(const LoadExercisesEvent()),
    expect: () => [
      isA<WorkoutState>().having((s) => s.isLoading, 'isLoading', true),
      isA<WorkoutState>()
          .having((s) => s.isLoading, 'isLoading', false)
          .having((s) => s.exercises, 'exercises', [_pushUp, _squat])
          .having((s) => s.hasReachedMax, 'hasReachedMax', true),
    ],
  );

  blocTest<WorkoutBloc, WorkoutState>(
    'load failure → loading, failure message',
    setUp: () => stubExercises(const Err(NetworkFailure())),
    build: build,
    act: (b) => b.add(const LoadExercisesEvent()),
    expect: () => [
      isA<WorkoutState>().having((s) => s.isLoading, 'isLoading', true),
      isA<WorkoutState>()
          .having((s) => s.isLoading, 'isLoading', false)
          .having((s) => s.error, 'error', const NetworkFailure().message),
    ],
  );

  blocTest<WorkoutBloc, WorkoutState>(
    'search filters loaded exercises by name, body part or target',
    build: build,
    seed: () => WorkoutState.initial().copyWith(
      exercises: const [_pushUp, _squat],
      allExercises: const [_pushUp, _squat],
    ),
    act: (b) => b
      ..add(const SearchExercisesEvent('quad'))
      ..add(const SearchExercisesEvent('')),
    expect: () => [
      isA<WorkoutState>().having((s) => s.exercises, 'exercises', [_squat]),
      isA<WorkoutState>().having((s) => s.exercises, 'exercises', [
        _pushUp,
        _squat,
      ]),
    ],
  );

  blocTest<WorkoutBloc, WorkoutState>(
    'history stream error → error message',
    setUp: () => when(
      () => getHistory(),
    ).thenAnswer((_) => Stream<List<WorkoutHistoryEntity>>.error(Exception())),
    build: build,
    act: (b) => b.add(LoadWorkoutHistory()),
    expect: () => [
      isA<WorkoutState>().having(
        (s) => s.error,
        'error',
        'Failed to load workout history',
      ),
    ],
  );
}
