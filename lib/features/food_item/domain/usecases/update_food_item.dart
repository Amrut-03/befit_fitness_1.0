import '../entities/food_items_entity.dart';

import '../repositories/food_item_repository.dart';

class UpdateFoodItemUseCase {
  final FoodItemsRepository repository;

  UpdateFoodItemUseCase(this.repository);

  Future<void> call(FoodItemEntity item) {
    return repository.updateFoodItem(item);
  }
}
