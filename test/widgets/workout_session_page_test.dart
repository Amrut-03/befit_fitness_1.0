import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_event.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_state.dart';
import 'package:fitness_app/features/workout/domain/usecases/get_workout_history.dart';
import 'package:fitness_app/features/workout/domain/usecases/save_workout_history.dart';
import 'package:fitness_app/features/workout/presentation/cubit/workout_session_cubit.dart';
import 'package:fitness_app/features/workout/presentation/pages/workout_list_page.dart';
import 'package:fitness_app/features/workout/presentation/pages/workout_session_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../features/workout/session/fakes.dart';
import 'pump_app.dart';

class _Streak extends MockBloc<StreakEvent, StreakState>
    implements StreakBloc {}

void main() {
  setUpAll(() => registerFallbackValue(UpdateStreakEvent()));

  late FakeWorkoutRepository repo;
  late WorkoutSessionCubit cubit;
  late _Streak streak;

  setUp(() {
    repo = FakeWorkoutRepository();
    cubit = WorkoutSessionCubit(
      store: MemoryStore(),
      saveWorkoutHistory: SaveWorkoutHistory(repo),
      getWorkoutHistory: GetWorkoutHistory(repo),
    );
    streak = _Streak();
    when(() => streak.state).thenReturn(StreakState.initial());
  });

  tearDown(() => cubit.close());

  Future<void> pump(WidgetTester t, Widget child) => t.pumpApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<WorkoutSessionCubit>.value(value: cubit),
        BlocProvider<StreakBloc>.value(value: streak),
      ],
      child: child,
    ),
  );

  testWidgets('no session: invites to browse exercises', (t) async {
    await pump(t, const WorkoutSessionPage());

    expect(find.text('No workout in progress'), findsOneWidget);
  });

  testWidgets('complete a set, rest, finish: saves and bumps the streak', (
    t,
  ) async {
    await t.runAsync(() => cubit.addExercise(exercise('1')));
    await pump(t, const WorkoutSessionPage());

    expect(find.text('Exercise 1'), findsOneWidget);
    expect(find.text('0/3'), findsOneWidget);

    await t.tap(find.byTooltip('Complete set').first);
    await t.pump();
    await t.pump(const Duration(seconds: 1));

    expect(find.text('1/3'), findsOneWidget);
    expect(find.text('Rest'), findsOneWidget);

    await t.tap(find.text('Skip'));
    await t.pump();
    await t.pump(const Duration(seconds: 1));
    expect(find.text('Rest'), findsNothing);

    await t.tap(find.text('Finish workout'));
    await t.pump();
    await t.pump();

    expect(find.text('Workout saved 🔥'), findsOneWidget);
    expect(repo.saved.single.totalSets, 1);
    verify(() => streak.add(any(that: isA<UpdateStreakEvent>()))).called(1);
  });

  testWidgets('editing reps updates the session', (t) async {
    await t.runAsync(() => cubit.addExercise(exercise('1')));
    await pump(t, const WorkoutSessionPage());

    // Fields per set row: kg, then reps.
    await t.enterText(find.byType(TextField).at(1), '12');
    await t.enterText(find.byType(TextField).at(0), '22.5');
    await t.pump();

    final set = cubit.state.session!.exercises.single.sets.first;
    expect(set.reps, 12);
    expect(set.weightKg, 22.5);
  });

  testWidgets('add-to-workout button on the exercise list', (t) async {
    await pump(t, Scaffold(body: AddToSessionButton(exercise: exercise('9'))));

    await t.tap(find.byTooltip('Add to workout'));
    await t.pump();

    expect(cubit.state.contains('9'), isTrue);
    expect(find.byTooltip('In your workout'), findsOneWidget);
  });
}
