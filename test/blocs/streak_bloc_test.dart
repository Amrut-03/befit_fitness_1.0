import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/error/exceptions.dart';
import 'package:fitness_app/features/streak/domain/entities/streak_entity.dart';
import 'package:fitness_app/features/streak/domain/usecases/get_streak.dart';
import 'package:fitness_app/features/streak/domain/usecases/update_streak.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_event.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGet extends Mock implements GetStreak {}

class _MockUpdate extends Mock implements UpdateStreak {}

void main() {
  late _MockGet getStreak;
  late _MockUpdate updateStreak;
  final today = DateTime(2026, 11, 10);

  setUp(() {
    getStreak = _MockGet();
    updateStreak = _MockUpdate();
  });

  blocTest<StreakBloc, StreakState>(
    'load → loading, loaded',
    setUp: () => when(() => getStreak()).thenAnswer(
      (_) async => StreakEntity(currentStreak: 3, lastActiveDate: today),
    ),
    build: () => StreakBloc(getStreak: getStreak, updateStreak: updateStreak),
    act: (b) => b.add(LoadStreakEvent()),
    expect: () => [
      const StreakState(isLoading: true),
      StreakState(currentStreak: 3, lastActiveDate: today),
    ],
  );

  blocTest<StreakBloc, StreakState>(
    'load failure → loading, friendly error',
    setUp: () =>
        when(() => getStreak()).thenThrow(const UnauthenticatedException()),
    build: () => StreakBloc(getStreak: getStreak, updateStreak: updateStreak),
    act: (b) => b.add(LoadStreakEvent()),
    expect: () => [
      const StreakState(isLoading: true),
      isA<StreakState>()
          .having((s) => s.isLoading, 'isLoading', false)
          .having((s) => s.error, 'error', isNotNull),
    ],
  );

  var activityCalls = 0;
  blocTest<StreakBloc, StreakState>(
    'update → records activity, then emits the refreshed streak',
    setUp: () {
      activityCalls = 0;
      when(() => updateStreak()).thenAnswer((_) async {});
      when(() => getStreak()).thenAnswer(
        (_) async => StreakEntity(currentStreak: 4, lastActiveDate: today),
      );
    },
    build: () => StreakBloc(
      getStreak: getStreak,
      updateStreak: updateStreak,
      onActivityRecorded: () async => activityCalls++,
    ),
    act: (b) => b.add(UpdateStreakEvent()),
    expect: () => [StreakState(currentStreak: 4, lastActiveDate: today)],
    verify: (_) {
      verify(() => updateStreak()).called(1);
      expect(activityCalls, 1);
    },
  );

  blocTest<StreakBloc, StreakState>(
    'a failing activity callback does not block the streak update',
    setUp: () {
      when(() => updateStreak()).thenAnswer((_) async {});
      when(() => getStreak()).thenAnswer(
        (_) async => StreakEntity(currentStreak: 1, lastActiveDate: today),
      );
    },
    build: () => StreakBloc(
      getStreak: getStreak,
      updateStreak: updateStreak,
      onActivityRecorded: () async => throw Exception('notifications off'),
    ),
    act: (b) => b.add(UpdateStreakEvent()),
    expect: () => [StreakState(currentStreak: 1, lastActiveDate: today)],
  );
}
