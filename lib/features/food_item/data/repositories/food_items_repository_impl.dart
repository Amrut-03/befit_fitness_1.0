import 'package:fitness_app/features/food_item/data/datasources/local/food_item_local_datasource.dart';
import 'package:fitness_app/features/food_item/data/datasources/remote/food_item_remote_datasource_impl.dart';
import 'package:fitness_app/features/food_item/data/models/food_items_model.dart';
import 'package:fitness_app/features/food_item/domain/entities/food_items_entity.dart';
import 'package:fitness_app/features/food_item/domain/repositories/food_item_repository.dart';

class FoodItemsRepositoryImpl implements FoodItemsRepository {
  final FoodItemsRemoteDataSource remoteDataSource;

  final FoodItemLocalDataSource localDataSource;

  FoodItemsRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Stream<List<FoodItemEntity>> getFoodItems() async* {
    try {
      await for (final models in remoteDataSource.getFoodItems()) {
        await localDataSource.cacheFoodItems(models);

        yield models.map((e) => e.toEntity()).toList();
      }
    } catch (_) {
      final cachedFoods = await localDataSource.getCachedFoodItems();

      yield cachedFoods.map((e) => e.toEntity()).toList();
    }
  }

  @override
  Future<void> saveFoodItem(FoodItemEntity item) async {
    final model = FoodItemModel(
      id: item.id,
      name: item.name,
      brand: item.brand,
      imageUrl: item.imageUrl,
      source: item.source,
      calories: item.calories,
      protein: item.protein,
      carbs: item.carbs,
      fat: item.fat,
    );
    await remoteDataSource.saveFoodItem(model);
  }

  @override
  Future<void> deleteFoodItem(String id) {
    return remoteDataSource.deleteFoodItem(id);
  }

  @override
  Future<void> updateFoodItem(FoodItemEntity item) {
    return remoteDataSource.updateFoodItem(FoodItemModel.fromEntity(item));
  }
}
