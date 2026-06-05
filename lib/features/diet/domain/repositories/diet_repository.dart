import 'package:fitness_app/features/diet/domain/entities/diet_history_entity.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';
import 'package:fitness_app/features/diet/domain/entities/macro_entity.dart';
import 'package:fitness_app/features/diet/domain/entities/meal_entity.dart';

abstract class DietRepository {
  Stream<List<DietPlanEntity>> getDietPlans();

  Stream<DietPlanEntity?> getActiveDietPlan();

  Future<void> saveDietPlan(DietPlanEntity plan);

  Future<void> deleteDietPlan(String id);

  Future<void> updateMealStatus(String planId, List<MealEntity> meals);

  Stream<MacroEntity> getTodayMacros();

  Future<void> setActiveDietPlan(String planId);

  Stream<List<DietHistoryEntity>> getDietHistory();

  Future<void> saveDietHistory(DietHistoryEntity history);
}
