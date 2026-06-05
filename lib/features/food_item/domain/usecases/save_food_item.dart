import 'package:fitness_app/features/food_item/domain/entities/food_items_entity.dart';
import 'package:fitness_app/features/food_item/domain/repositories/food_item_repository.dart';

class SaveFoodItem {
  final FoodItemsRepository repository;

  SaveFoodItem(this.repository);

  Future<void> call(FoodItemEntity item) async {
    await repository.saveFoodItem(item);
  }
}
