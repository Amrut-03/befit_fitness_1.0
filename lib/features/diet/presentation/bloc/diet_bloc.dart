import 'dart:async';

import 'package:fitness_app/features/diet/domain/entities/diet_history_entity.dart';
import 'package:fitness_app/features/diet/domain/usecases/get_diet_history.dart';
import 'package:fitness_app/features/diet/domain/usecases/save_diet_history.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fitness_app/features/diet/domain/usecases/delete_diet_plan.dart';
import 'package:fitness_app/features/diet/domain/usecases/get_diet_plans.dart';
import 'package:fitness_app/features/diet/domain/usecases/save_diet_plan.dart';
import 'package:fitness_app/features/diet/domain/usecases/set_active_diet_plan.dart';
import 'package:fitness_app/features/diet/domain/usecases/update_meal_status.dart';

import 'diet_event.dart';
import 'diet_state.dart';

class DietBloc extends Bloc<DietEvent, DietState> {
  final GetDietPlans getDietPlans;

  final SaveDietPlan saveDietPlan;

  final DeleteDietPlan deleteDietPlan;

  final UpdateMealStatus updateMealStatus;

  final SetActiveDietPlan setActiveDietPlan;

  final GetDietHistory getDietHistory;

  StreamSubscription? _plansSubscription;

  StreamSubscription? _historySubscription;

  final SaveDietHistory saveDietHistory;

  DietBloc({
    required this.getDietPlans,

    required this.saveDietPlan,

    required this.setActiveDietPlan,

    required this.deleteDietPlan,

    required this.updateMealStatus,

    required this.getDietHistory,

    required this.saveDietHistory,
  }) : super(DietState.initial()) {
    on<LoadDietPlans>(_onLoadDietPlans);

    on<SaveDietPlanEvent>(_onSavePlan);

    on<SetActiveDietPlanEvent>(_onSetActiveDietPlan);

    on<DeleteDietPlanEvent>(_onDeletePlan);

    on<LoadDietHistory>(_onLoadDietHistory);

    on<DietHistoryUpdated>(_onDietHistoryUpdated);

    on<UpdateMealStatusEvent>(_onUpdateMeals);

    on<DietPlansUpdated>(_onDietPlansUpdated);
  }

  /// LOAD PLANS
  Future<void> _onLoadDietPlans(
    LoadDietPlans event,

    Emitter<DietState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    await _plansSubscription?.cancel();

    try {
      _plansSubscription = getDietPlans().listen(
        (plans) {
          print("PLANS RECEIVED: ${plans.length}");

          add(DietPlansUpdated(plans));
        },

        onError: (e) {
          print("STREAM ERROR: $e");

          addError(e);
        },
      );
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, error: 'Failed to load diet plans'),
      );
    }
  }

  Future<void> _onLoadDietHistory(
    LoadDietHistory event,

    Emitter<DietState> emit,
  ) async {
    await _historySubscription?.cancel();

    _historySubscription = getDietHistory().listen((history) {
      add(DietHistoryUpdated(history));
    });
  }

  void _onDietHistoryUpdated(
    DietHistoryUpdated event,

    Emitter<DietState> emit,
  ) {
    emit(state.copyWith(history: event.history));
  }

  /// STREAM UPDATE
  void _onDietPlansUpdated(DietPlansUpdated event, Emitter<DietState> emit) {
    for (final plan in event.plans) {
      print(
        "BLOC PLAN ${plan.name}"
        " activeDate=${plan.activeDate}"
        " activeToday=${plan.isActiveToday}",
      );
    }

    emit(
      state.copyWith(
        isLoading: false,

        plans: List.from(event.plans),

        clearError: true,
      ),
    );
  }

  /// SAVE PLAN
  Future<void> _onSavePlan(
    SaveDietPlanEvent event,

    Emitter<DietState> emit,
  ) async {
    try {
      await saveDietPlan(event.plan);
    } catch (e) {
      emit(state.copyWith(error: "Failed to save plan"));
    }
  }

  /// SET ACTIVE PLAN
  Future<void> _onSetActiveDietPlan(
    SetActiveDietPlanEvent event,

    Emitter<DietState> emit,
  ) async {
    try {
      await setActiveDietPlan(event.planId);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update active plan'));
    }
  }

  /// DELETE PLAN
  Future<void> _onDeletePlan(
    DeleteDietPlanEvent event,

    Emitter<DietState> emit,
  ) async {
    try {
      await deleteDietPlan(event.id);
    } catch (e) {
      emit(state.copyWith(error: "Failed to delete plan"));
    }
  }

  /// UPDATE MEAL STATUS
  Future<void> _onUpdateMeals(
    UpdateMealStatusEvent event,

    Emitter<DietState> emit,
  ) async {
    try {
      await updateMealStatus(planId: event.planId, meals: event.meals);

      final updatedPlan = state.plans
          .firstWhere((e) => e.id == event.planId)
          .copyWith(meals: event.meals);

      if (updatedPlan.isCompletedToday) {
        final alreadySaved = state.history.any((h) {
          final samePlan = h.planId == updatedPlan.id;

          final sameDay =
              h.completedAt.year == DateTime.now().year &&
              h.completedAt.month == DateTime.now().month &&
              h.completedAt.day == DateTime.now().day;

          return samePlan && sameDay;
        });

        if (!alreadySaved) {
          print(
            "SAVING HISTORY MEALS = ${updatedPlan.meals.map((e) => e.name).toList()}",
          );

          await saveDietHistory(
            DietHistoryEntity(
              id: DateTime.now().millisecondsSinceEpoch.toString(),

              planId: updatedPlan.id,

              planName: updatedPlan.name,

              calories: updatedPlan.totalCalories,

              protein: updatedPlan.meals.fold<double>(
                0.0,
                (sum, meal) => sum + meal.protein,
              ),

              carbs: updatedPlan.meals.fold<double>(
                0.0,
                (sum, meal) => sum + meal.carbs,
              ),

              fat: updatedPlan.meals.fold<double>(
                0.0,
                (sum, meal) => sum + meal.fat,
              ),

              completedAt: DateTime.now(),

              meals: updatedPlan.meals.map((e) => e.name).toList(),
            ),
          );
        }
      }
    } catch (e) {
      emit(state.copyWith(error: "Failed to update meals"));
    }
  }

  @override
  Future<void> close() {
    _plansSubscription?.cancel();

    _historySubscription?.cancel();

    return super.close();
  }
}
