import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';
import 'package:fitness_app/features/diet/domain/repositories/diet_repository.dart';

class GetDietPlans {
  final DietRepository repo;

  GetDietPlans(this.repo);

  Stream<List<DietPlanEntity>> call() {
    return repo.getDietPlans();
  }
}
