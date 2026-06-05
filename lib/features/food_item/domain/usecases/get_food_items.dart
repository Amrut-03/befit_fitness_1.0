import 'package:fitness_app/features/food_item/domain/entities/food_items_entity.dart';
import 'package:fitness_app/features/food_item/domain/repositories/food_item_repository.dart';

class GetFoodItems {
  final FoodItemsRepository repository;

  GetFoodItems(this.repository);

  Stream<List<FoodItemEntity>> call() {
    return repository.getFoodItems();
  }
}
