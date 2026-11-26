import 'package:fitness_app/core/di/storage_module.dart';
import 'package:fitness_app/features/food_item/data/datasources/local/food_item_local_datasource.dart';
import 'package:fitness_app/features/food_item/data/datasources/remote/food_item_remote_datasource_impl.dart';
import 'package:fitness_app/features/food_item/data/repositories/food_items_repository_impl.dart';
import 'package:fitness_app/features/food_item/domain/repositories/food_item_repository.dart';
import 'package:fitness_app/features/food_item/domain/usecases/delete_food_item.dart';
import 'package:fitness_app/features/food_item/domain/usecases/get_food_items.dart';
import 'package:fitness_app/features/food_item/domain/usecases/save_food_item.dart';
import 'package:fitness_app/features/food_item/domain/usecases/update_food_item.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

/// Dependencies for the food item feature.
void registerFoodItemDependencies(GetIt sl) {
  sl.registerFactory(() => FoodItemsBloc(sl(), sl(), sl(), sl()));

  sl.registerLazySingleton(() => GetFoodItems(sl()));

  sl.registerLazySingleton(() => SaveFoodItem(sl()));

  sl.registerLazySingleton(() => DeleteFoodItemUseCase(sl()));

  sl.registerLazySingleton(() => UpdateFoodItemUseCase(sl()));

  sl.registerLazySingleton<FoodItemsRepository>(
    () => FoodItemsRepositoryImpl(sl(), sl()),
  );

  sl.registerLazySingleton(
    () => FoodItemLocalDataSource(sl<Box>(instanceName: StorageModule.food)),
  );

  sl.registerLazySingleton(
    () => FoodItemsRemoteDataSource(firestore: sl(), auth: sl()),
  );
}
