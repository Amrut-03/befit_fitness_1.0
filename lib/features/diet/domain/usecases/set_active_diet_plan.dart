import 'package:fitness_app/features/diet/domain/repositories/diet_repository.dart';

class SetActiveDietPlan {
  final DietRepository repository;

  SetActiveDietPlan(this.repository);

  Future<void> call(String planId) {
    return repository.setActiveDietPlan(planId);
  }
}
