import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_history_entity.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';
import 'package:fitness_app/features/diet/domain/entities/meal_entity.dart';
import 'package:fitness_app/features/diet/domain/usecases/delete_diet_plan.dart';
import 'package:fitness_app/features/diet/domain/usecases/get_diet_history.dart';
import 'package:fitness_app/features/diet/domain/usecases/get_diet_plans.dart';
import 'package:fitness_app/features/diet/domain/usecases/save_diet_history.dart';
import 'package:fitness_app/features/diet/domain/usecases/save_diet_plan.dart';
import 'package:fitness_app/features/diet/domain/usecases/set_active_diet_plan.dart';
import 'package:fitness_app/features/diet/domain/usecases/update_meal_status.dart';
import 'package:fitness_app/features/diet/domain/entities/daily_nutrition.dart';
import 'package:fitness_app/features/diet/domain/usecases/nutrition_log_usecases.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_event.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _GetPlans extends Mock implements GetDietPlans {}

class _SavePlan extends Mock implements SaveDietPlan {}

class _SetActive extends Mock implements SetActiveDietPlan {}

class _Delete extends Mock implements DeleteDietPlan {}

class _UpdateMeals extends Mock implements UpdateMealStatus {}

class _GetHistory extends Mock implements GetDietHistory {}

class _SaveHistory extends Mock implements SaveDietHistory {}

class _Record extends Mock implements RecordDailyNutrition {}

MealEntity _meal(String id, {DateTime? consumedAt}) => MealEntity(
  id: id,
  name: 'Meal $id',
  calories: 300,
  protein: 20,
  carbs: 30,
  fat: 10,
  consumedAt: consumedAt,
);

void main() {
  late _GetPlans getPlans;
  late _UpdateMeals updateMeals;
  late _SaveHistory saveHistory;
  late _Delete delete;

  final plan = DietPlanEntity(
    id: 'p1',
    name: 'Cut',
    meals: [_meal('a'), _meal('b')],
  );

  setUpAll(() {
    registerFallbackValue(DailyNutrition(day: DateTime(2026)));
    registerFallbackValue(
      DietHistoryEntity(
        id: '',
        planId: '',
        planName: '',
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        completedAt: DateTime(2026),
        meals: const [],
      ),
    );
  });

  setUp(() {
    getPlans = _GetPlans();
    updateMeals = _UpdateMeals();
    saveHistory = _SaveHistory();
    delete = _Delete();
  });

  DietBloc build() => DietBloc(
    getDietPlans: getPlans,
    saveDietPlan: _SavePlan(),
    setActiveDietPlan: _SetActive(),
    deleteDietPlan: delete,
    updateMealStatus: updateMeals,
    getDietHistory: _GetHistory(),
    saveDietHistory: saveHistory,
  );

  group('load', () {
    blocTest<DietBloc, DietState>(
      'emits loading, then plans from the stream',
      setUp: () =>
          when(() => getPlans()).thenAnswer((_) => Stream.value([plan])),
      build: build,
      act: (b) => b.add(LoadDietPlans()),
      expect: () => [
        const DietState(isLoading: true),
        DietState(plans: [plan]),
      ],
    );

    blocTest<DietBloc, DietState>(
      'stream error → loading cleared with an error',
      setUp: () => when(
        () => getPlans(),
      ).thenAnswer((_) => Stream.error(Exception('permission-denied'))),
      build: build,
      act: (b) => b.add(LoadDietPlans()),
      expect: () => [
        const DietState(isLoading: true),
        const DietState(error: 'Failed to load diet plans'),
      ],
    );

    blocTest<DietBloc, DietState>(
      'refresh replaces the old subscription',
      setUp: () {
        var call = 0;
        when(() => getPlans()).thenAnswer(
          (_) => Stream.value(++call == 1 ? <DietPlanEntity>[] : [plan]),
        );
      },
      build: build,
      act: (b) async {
        b.add(LoadDietPlans());
        await Future<void>.delayed(Duration.zero);
        b.add(LoadDietPlans());
      },
      skip: 2,
      expect: () => [
        const DietState(isLoading: true),
        DietState(plans: [plan]),
      ],
    );
  });

  blocTest<DietBloc, DietState>(
    'delete failure surfaces an error',
    setUp: () => when(() => delete('p1')).thenThrow(Exception()),
    build: build,
    act: (b) => b.add(const DeleteDietPlanEvent('p1')),
    expect: () => const [DietState(error: 'Failed to delete plan')],
  );

  group('update meals', () {
    blocTest<DietBloc, DietState>(
      'completing the last meal saves today\'s history once',
      setUp: () {
        when(
          () => updateMeals(
            planId: any(named: 'planId'),
            meals: any(named: 'meals'),
          ),
        ).thenAnswer((_) async {});
        when(() => saveHistory(any())).thenAnswer((_) async {});
      },
      build: build,
      seed: () => DietState(plans: [plan]),
      act: (b) => b.add(
        UpdateMealStatusEvent(
          planId: 'p1',
          meals: [
            _meal('a', consumedAt: DateTime.now()),
            _meal('b', consumedAt: DateTime.now()),
          ],
        ),
      ),
      expect: () => const <DietState>[],
      verify: (_) {
        final saved =
            verify(() => saveHistory(captureAny())).captured.single
                as DietHistoryEntity;
        expect(saved.planId, 'p1');
        expect(saved.calories, 600);
        expect(saved.protein, 40);
      },
    );

    blocTest<DietBloc, DietState>(
      'a partially eaten plan does not save history',
      setUp: () => when(
        () => updateMeals(
          planId: any(named: 'planId'),
          meals: any(named: 'meals'),
        ),
      ).thenAnswer((_) async {}),
      build: build,
      seed: () => DietState(plans: [plan]),
      act: (b) => b.add(
        UpdateMealStatusEvent(
          planId: 'p1',
          meals: [
            _meal('a', consumedAt: DateTime.now()),
            _meal('b'),
          ],
        ),
      ),
      verify: (_) => verifyNever(() => saveHistory(any())),
    );

    blocTest<DietBloc, DietState>(
      'write failure surfaces an error',
      setUp: () => when(
        () => updateMeals(
          planId: any(named: 'planId'),
          meals: any(named: 'meals'),
        ),
      ).thenThrow(Exception()),
      build: build,
      act: (b) => b.add(const UpdateMealStatusEvent(planId: 'p1', meals: [])),
      expect: () => const [DietState(error: 'Failed to update meals')],
    );
  });

  group('nutrition log', () {
    test('ticking a meal records today\'s totals across plans', () async {
      final record = _Record();
      when(() => record(any())).thenAnswer((_) async {});
      when(
        () => updateMeals(
          planId: any(named: 'planId'),
          meals: any(named: 'meals'),
        ),
      ).thenAnswer((_) async {});
      final other = DietPlanEntity(
        id: 'p2',
        name: 'Snacks',
        meals: [_meal('s', consumedAt: DateTime.now())],
      );
      when(() => getPlans()).thenAnswer((_) => Stream.value([plan, other]));

      final bloc = DietBloc(
        getDietPlans: getPlans,
        saveDietPlan: _SavePlan(),
        setActiveDietPlan: _SetActive(),
        deleteDietPlan: delete,
        updateMealStatus: updateMeals,
        getDietHistory: _GetHistory(),
        saveDietHistory: saveHistory,
        recordDailyNutrition: record,
      )..add(LoadDietPlans());
      await Future<void>.delayed(Duration.zero);

      bloc.add(
        UpdateMealStatusEvent(
          planId: 'p1',
          meals: [
            _meal('a', consumedAt: DateTime.now()),
            _meal('b'),
          ],
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final day =
          verify(() => record(captureAny())).captured.single as DailyNutrition;
      expect(day.calories, 600); // meal a + the snack
      expect(day.protein, 40);
      await bloc.close();
    });
  });
}
