import 'package:fitness_app/features/food_item/domain/entities/food_items_entity.dart';

abstract class FoodItemsRepository {
  Stream<List<FoodItemEntity>> getFoodItems();
  Future<void> saveFoodItem(FoodItemEntity item);
  Future<void> deleteFoodItem(String id);
  Future<void> updateFoodItem(FoodItemEntity item);
}
