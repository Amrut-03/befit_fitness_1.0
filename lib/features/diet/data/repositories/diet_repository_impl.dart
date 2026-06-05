import 'package:fitness_app/features/diet/data/datasources/remote/diet_remote_datasource.dart';
import 'package:fitness_app/features/diet/data/models/diet_history_model.dart';
import 'package:fitness_app/features/diet/data/models/diet_plan_model.dart';
import 'package:fitness_app/features/diet/data/models/macro_model.dart';
import 'package:fitness_app/features/diet/data/models/meal_model.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_history_entity.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';
import 'package:fitness_app/features/diet/domain/entities/macro_entity.dart';
import 'package:fitness_app/features/diet/domain/entities/meal_entity.dart';
import 'package:fitness_app/features/diet/domain/repositories/diet_repository.dart';

class DietRepositoryImpl implements DietRepository {
  final DietRemoteDataSource remoteDataSource;

  DietRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<DietPlanEntity>> getDietPlans() async* {
    print("REPOSITORY CALLED");

    await for (final models in remoteDataSource.getDietPlans()) {
      print("MODELS COUNT: ${models.length}");

      for (final model in models) {
        print(
          "REPO MODEL ${model.name}"
          " ACTIVE=${model.activeDate}",
        );
      }

      final entities = models.map((e) {
        final entity = e.toEntity();

        print(
          "ENTITY ${entity.name}"
          " ACTIVE=${entity.activeDate}",
        );

        return entity;
      }).toList();

      yield entities;
    }
  }

  @override
  Stream<DietPlanEntity?> getActiveDietPlan() {
    return remoteDataSource.getActivePlan().map((model) => model?.toEntity());
  }

  @override
  Future<void> saveDietPlan(DietPlanEntity plan) async {
    await remoteDataSource.savePlan(DietPlanModel.fromEntity(plan));
  }

  @override
  Future<void> deleteDietPlan(String id) async {
    await remoteDataSource.deletePlan(id);
  }

  @override
  Future<void> updateMealStatus(String planId, List<MealEntity> meals) async {
    await remoteDataSource.updateMeals(
      planId,
      meals.map((e) => MealModel.fromEntity(e)).toList(),
    );
  }

  @override
  Stream<MacroEntity> getTodayMacros() {
    return remoteDataSource.getMacros().map(
      (json) => MacroModel.fromJson(json).toEntity(),
    );
  }

  @override
  Future<void> setActiveDietPlan(String planId) {
    return remoteDataSource.setActiveDietPlan(planId);
  }

  @override
  Stream<List<DietHistoryEntity>> getDietHistory() {
    return remoteDataSource.getDietHistory().map(
      (models) => models.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  Future<void> saveDietHistory(DietHistoryEntity history) {
    return remoteDataSource.saveDietHistory(
      DietHistoryModel.fromEntity(history),
    );
  }
}
