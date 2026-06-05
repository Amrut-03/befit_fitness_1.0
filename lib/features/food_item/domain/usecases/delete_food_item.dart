import '../repositories/food_item_repository.dart';

class DeleteFoodItemUseCase {
  final FoodItemsRepository repository;

  DeleteFoodItemUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteFoodItem(id);
  }
}
