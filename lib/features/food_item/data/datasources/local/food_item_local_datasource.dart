import 'package:hive/hive.dart';

import '../../models/food_items_model.dart';

class FoodItemLocalDataSource {
  final Box box;

  FoodItemLocalDataSource(this.box);

  static const String cacheKey = 'food_items';

  Future<void> cacheFoodItems(List<FoodItemModel> foods) async {
    final jsonList = foods.map((e) => e.toJson()).toList();

    await box.put(cacheKey, jsonList);
  }

  Future<List<FoodItemModel>> getCachedFoodItems() async {
    final data = box.get(cacheKey);

    if (data == null) return [];

    return List<Map<String, dynamic>>.from(
      data,
    ).map((e) => FoodItemModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}
