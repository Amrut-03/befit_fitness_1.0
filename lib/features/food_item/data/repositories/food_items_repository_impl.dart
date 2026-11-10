import 'package:fitness_app/features/food_item/data/datasources/local/food_item_local_datasource.dart';
import 'package:fitness_app/features/food_item/data/datasources/remote/food_item_remote_datasource_impl.dart';
import 'package:fitness_app/features/food_item/data/models/food_items_model.dart';
import 'package:fitness_app/features/food_item/domain/entities/food_items_entity.dart';
import 'package:fitness_app/features/food_item/domain/repositories/food_item_repository.dart';

class FoodItemsRepositoryImpl implements FoodItemsRepository {
  final FoodItemsRemoteDataSource remoteDataSource;

  final FoodItemLocalDataSource localDataSource;

  FoodItemsRepositoryImpl(this.remoteDataSource, this.localDataSource);

  /// Emits the Hive cache first (instant start, even offline), then live
  /// Firestore updates, refreshing the cache on each. Firestore serves its own
  /// offline cache, so a stream error here is real (e.g. permission denied
  /// after logout). It's passed on to the bloc instead of silently ending the
  /// stream, which the old try/catch around `await for` did.
  @override
  Stream<List<FoodItemEntity>> getFoodItems() async* {
    final cached = await localDataSource.getCachedFoodItems();
    if (cached.isNotEmpty) yield cached.map((e) => e.toEntity()).toList();

    yield* remoteDataSource.getFoodItems().asyncMap((models) async {
      await localDataSource.cacheFoodItems(models);
      return models.map((e) => e.toEntity()).toList();
    });
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
