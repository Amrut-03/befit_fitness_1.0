import 'package:fitness_app/features/workout/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise_page_entity.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';
import 'package:fitness_app/features/workout/domain/usecases/get_exercises.dart';
import 'package:fitness_app/features/workout/domain/usecases/get_workout_history.dart';
import 'package:fitness_app/features/workout/domain/usecases/save_workout_history.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_event.dart';
import 'package:flutter_test/flutter_test.dart';

ExerciseEntity _ex(String id) => ExerciseEntity(
  id: id,
  name: 'Exercise $id',
  bodyPart: 'chest',
  target: 'pectorals',
  equipment: 'body weight',
  instructions: const [],
);

class _FakeRepo implements WorkoutRepository {
  final calls = <({String? cursor, String? bodyPart})>[];

  @override
  Future<ExercisePageEntity> getExercises({
    int limit = 20,
    String? cursor,
    String? bodyPart,
  }) async {
    calls.add((cursor: cursor, bodyPart: bodyPart));
    if (cursor == null) {
      return ExercisePageEntity(
        exercises: [_ex('1'), _ex('2')],
        nextCursor: 'c2',
      );
    }
    return ExercisePageEntity(exercises: [_ex('3')]);
  }

  @override
  Stream<List<WorkoutHistoryEntity>> getWorkoutHistory() =>
      const Stream.empty();

  @override
  Future<void> saveWorkoutHistory(WorkoutHistoryEntity workout) async {}
}

void main() {
  late _FakeRepo repo;
  late WorkoutBloc bloc;

  setUp(() {
    repo = _FakeRepo();
    bloc = WorkoutBloc(
      getExercises: GetExercises(repo),
      saveWorkoutHistory: SaveWorkoutHistory(repo),
      getWorkoutHistory: GetWorkoutHistory(repo),
    );
  });

  tearDown(() => bloc.close());

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test(
    'load more reuses body part and cursor, then stops at last page',
    () async {
      bloc.add(const LoadExercisesEvent(bodyPart: 'chest'));
      await settle();

      expect(bloc.state.allExercises.map((e) => e.id), ['1', '2']);
      expect(bloc.state.nextCursor, 'c2');
      expect(bloc.state.hasReachedMax, isFalse);

      bloc.add(const LoadExercisesEvent(loadMore: true));
      await settle();

      expect(repo.calls.last, (cursor: 'c2', bodyPart: 'chest'));
      expect(bloc.state.allExercises.map((e) => e.id), ['1', '2', '3']);
      expect(bloc.state.hasReachedMax, isTrue);

      bloc.add(const LoadExercisesEvent(loadMore: true));
      await settle();
      expect(repo.calls, hasLength(2));
    },
  );

  test(
    'duplicate load-more events while fetching trigger one request',
    () async {
      bloc.add(const LoadExercisesEvent());
      await settle();

      bloc
        ..add(const LoadExercisesEvent(loadMore: true))
        ..add(const LoadExercisesEvent(loadMore: true))
        ..add(const LoadExercisesEvent(loadMore: true));
      await settle();

      expect(repo.calls, hasLength(2));
      expect(bloc.state.allExercises, hasLength(3));
    },
  );

  test('fresh load without body part clears the previous filter', () async {
    bloc.add(const LoadExercisesEvent(bodyPart: 'chest'));
    await settle();
    bloc.add(const LoadExercisesEvent());
    await settle();

    expect(bloc.state.bodyPart, isNull);
    expect(repo.calls.last, (cursor: null, bodyPart: null));
  });
}
