import 'package:fitness_app/features/diet/domain/repositories/diet_repository.dart';

class DeleteDietPlan {
  final DietRepository repo;

  DeleteDietPlan(this.repo);

  Future<void> call(String id) {
    return repo.deleteDietPlan(id);
  }
}
