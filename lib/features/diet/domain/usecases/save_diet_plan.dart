import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';
import 'package:fitness_app/features/diet/domain/repositories/diet_repository.dart';

class SaveDietPlan {
  final DietRepository repo;

  SaveDietPlan(this.repo);

  Future<void> call(DietPlanEntity plan) {
    return repo.saveDietPlan(plan);
  }
}
