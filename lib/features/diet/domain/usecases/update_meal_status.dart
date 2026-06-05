import 'package:fitness_app/features/diet/domain/entities/meal_entity.dart';
import 'package:fitness_app/features/diet/domain/repositories/diet_repository.dart';

class UpdateMealStatus {
  final DietRepository repository;

  UpdateMealStatus(this.repository);

  Future<void> call({required String planId, required List<MealEntity> meals}) {
    return repository.updateMealStatus(planId, meals);
  }
}
