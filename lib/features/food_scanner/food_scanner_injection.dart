import 'package:fitness_app/features/food_scanner/data/datasources/remote/food_scanner_remote_datasource.dart';
import 'package:fitness_app/features/food_scanner/data/repositories/food_scanner_repository_impl.dart';
import 'package:fitness_app/features/food_scanner/domain/repositories/food_scanner_repository.dart';
import 'package:fitness_app/features/food_scanner/domain/usecases/scan_barcode.dart';
import 'package:fitness_app/features/food_scanner/presentation/bloc/food_scanner_bloc.dart';
import 'package:get_it/get_it.dart';

/// Dependencies for the food scanner feature.
void registerFoodScannerDependencies(GetIt sl) {
  sl.registerLazySingleton(() => FoodScannerRemoteDataSource(api: sl()));

  sl.registerLazySingleton<FoodScannerRepository>(
    () => FoodScannerRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => ScanBarcode(sl()));

  sl.registerFactory(() => FoodScannerBloc(sl()));
}
